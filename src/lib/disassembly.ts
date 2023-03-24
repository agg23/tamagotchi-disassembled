import { Instruction, InstructionSet } from "./bass";
import { buildDisassembledInstructionString } from "./display";
import { bassNumberRegex } from "./regex";
import { DisassembledInstruction } from "./types";
import { maskOfSize } from "./util";

export const parseBinaryBuffer = (
  buffer: Buffer,
  instructions: Instruction[]
): string => {
  let disassembledInstructions: DisassembledInstruction[] = [];

  for (let i = 0; i < buffer.length; i += 2) {
    const highByte = buffer[i]!;
    const lowByte = buffer[i + 1]!;

    const correctedWord = (highByte << 8) | lowByte;
    const instruction = findWordInstruction(correctedWord, instructions);

    disassembledInstructions.push({
      instruction,
      actualWord: correctedWord,
      address: i / 2,
    });
  }

  let output = "";

  for (const instruction of disassembledInstructions) {
    output += `${buildDisassembledInstructionString(instruction)}\n`;
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
