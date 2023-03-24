import { DisassembledInstruction } from "./types";
import { isLetterChar, maskOfSize } from "./util";

export const buildDisassembledInstructionString = (
  { instruction, actualWord, address }: DisassembledInstruction,
  immediateLabel: string | undefined
) => {
  let instructionString = instruction.originalInstruction;

  if (instruction.type === "immediate") {
    const { bitCount, stringIndex, stringLength } = instruction.immediate;

    const immediatePrefix = instructionString.substring(0, stringIndex);
    const immediateSuffix = instructionString.substring(
      stringIndex + stringLength
    );

    let immediate = "";

    if (immediateLabel) {
      immediate = immediateLabel;
    } else {
      const argument = maskOfSize(bitCount) & actualWord;

      if (isLetterChar(immediatePrefix.charAt(immediatePrefix.length - 1))) {
        // If letter, treat as decimal
        immediate = argument.toString();
      } else {
        // Otherwise, treat as hex
        immediate = `0x${argument.toString(16).toUpperCase()}`;
      }
    }

    instructionString = `${immediatePrefix}${immediate}${immediateSuffix}`;
  }

  // Separate out instruction so that it formats nicely
  // Four total columns
  // Opcode - Source - Dest - Comments
  const splitInstruction = instructionString.split(/\s+/);

  let lastPadWidth = 0;

  for (let i = 2; i >= splitInstruction.length - 1; i--) {
    lastPadWidth += columnPadWidth(i);
  }

  const formattedInstructionString = splitInstruction
    .map((s, i) => {
      const pad =
        i === splitInstruction.length - 1 ? lastPadWidth : columnPadWidth(i);

      return s.padEnd(pad);
    })
    .join("");

  const comment = `// 0x${address
    .toString(16)
    .toUpperCase()
    .padEnd(4)} (0x${actualWord.toString(16).toUpperCase()})`;

  return `${formattedInstructionString}${comment}`;
};

const columnPadWidth = (column: number) => {
  switch (column) {
    case 0:
      return 6;
    case 1:
      return 5;
    case 2:
      return 10;
  }

  return 0;
};
