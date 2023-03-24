import { ImmediateInstruction, Instruction } from "./bass";
import { buildDisassembledInstructionString } from "./display";
import { DisassembledInstruction } from "./types";
import { maskOfSize } from "./util";

export const parseBinaryBuffer = (
  buffer: Buffer,
  instructions: Instruction[]
): string => {
  const disassembledInstructions: DisassembledInstruction[] = [];
  const unsetLabels: Array<DisassembledInstruction[] | undefined> = new Array(
    8192
  );

  for (let i = 0; i < buffer.length; i += 2) {
    const highByte = buffer[i]!;
    const lowByte = buffer[i + 1]!;
    const address = i / 2;

    const correctedWord = (highByte << 8) | lowByte;
    const instruction = findWordInstruction(correctedWord, instructions);

    const disassembledInstruction: DisassembledInstruction = {
      instruction,
      actualWord: correctedWord,
      address,
    };

    if (isFlowControlWithImmediate(instruction)) {
      // Convert local address into global one
      const pcLowerByte =
        correctedWord & maskOfSize(instruction.immediate.bitCount);

      let pcUpperFive = (address >> 8) & 0x1f;

      const lastInstruction =
        disassembledInstructions[disassembledInstructions.length - 1]!;

      if (isPset(lastInstruction.instruction)) {
        // PSET immediate determines our upper 5 bits
        pcUpperFive = lastInstruction.actualWord & 0x1f;
      }

      const pc = (pcUpperFive << 8) | pcLowerByte;

      const existingLabel = unsetLabels[pc];

      if (existingLabel) {
        existingLabel.push(disassembledInstruction);
      } else {
        unsetLabels[pc] = [disassembledInstruction];
      }
    }

    disassembledInstructions.push(disassembledInstruction);
  }

  // Build label names
  let labelCount = 0;
  const namedLabels: Array<
    | {
        name: string;
        instructions: DisassembledInstruction[];
      }
    | undefined
  > = unsetLabels.map((instructions) => {
    if (!!instructions) {
      return {
        name: `label_${labelCount++}`,
        instructions,
      };
    }

    return undefined;
  });

  // Build list of instructions that will replace the immedates with these labels, and build labels
  const labelUsageMap: Array<string | undefined> = new Array(8192);

  for (const namedLabel of namedLabels) {
    if (namedLabel) {
      for (const instruction of namedLabel.instructions) {
        labelUsageMap[instruction.address] = namedLabel.name;
      }
    }
  }

  let output = "";
  let address = 0;

  for (const instruction of disassembledInstructions) {
    const immediateLabel = labelUsageMap[instruction.address];

    const lineLabel = namedLabels[instruction.address];

    if (lineLabel) {
      output += `\n${lineLabel.name}:\n`;
    }

    output += `  ${buildDisassembledInstructionString(
      instruction,
      immediateLabel
    )}\n`;

    address += 1;
  }

  return output;
};

const findWordInstruction = (word: number, instructions: Instruction[]) => {
  // Naive because it doesn't really matter
  let bestMatch = instructions[0]!;

  for (let i = 0; i < instructions.length; i++) {
    const instruction = instructions[i]!;

    if (instruction.sortableOpcode <= word) {
      bestMatch = instruction;
    } else {
      // We've passed the best solution, end
      break;
    }
  }

  return bestMatch;
};

const flowControlImmediateMnemonics = ((): Set<string> =>
  new Set<string>(["call", "calz", "jp"]))();

const extractMnemonic = (instruction: Instruction): string =>
  instruction.originalInstruction.split(/\s/)[0]!.trim();

const isFlowControlWithImmediate = (
  instruction: Instruction
): instruction is ImmediateInstruction => {
  const mnemonic = extractMnemonic(instruction);

  return flowControlImmediateMnemonics.has(mnemonic);
};

const isPset = (instruction: Instruction): boolean => {
  const mnemonic = extractMnemonic(instruction);

  return mnemonic === "pset";
};
