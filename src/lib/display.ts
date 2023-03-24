import { DisassembledInstruction } from "./types";
import { isLetterChar, maskOfSize } from "./util";

export const buildDisassembledInstructionString = ({
  instruction,
  actualWord,
  address,
}: DisassembledInstruction) => {
  let instructionString = instruction.originalInstruction;

  if (instruction.type === "immediate") {
    const { bitCount, stringIndex, stringLength } = instruction.immediate;

    const argument = maskOfSize(bitCount) & actualWord;

    const immediatePrefix = instructionString.substring(0, stringIndex);
    const immediateSuffix = instructionString.substring(
      stringIndex + stringLength
    );

    let immediate = "";

    if (isLetterChar(immediatePrefix.charAt(immediatePrefix.length - 1))) {
      // If letter, treat as decimal
      immediate = argument.toString();
    } else {
      // Otherwise, treat as hex
      immediate = `0x${argument.toString(16).toUpperCase()}`;
    }

    instructionString = `${immediatePrefix}${immediate}${immediateSuffix}`;
  }

  // Separate out instruction so that it formats nicely
  // Four total columns
  // Opcode - Source - Dest - Comments
  const splitInstruction = instructionString.split(/\s+/);
  const expandedSplitInstruction =
    splitInstruction.length < 4
      ? [...splitInstruction, ...Array(4 - splitInstruction.length).fill("")]
      : splitInstruction;

  const formattedInstructionString = [...expandedSplitInstruction, ...Array()]
    .map((s, i) => {
      let pad = 0;

      switch (i) {
        case 0:
          pad = 6;
          break;
        case 1:
          pad = 5;
          break;
        case 2:
          pad = 10;
        default:
          break;
      }

      return s.padEnd(pad);
    })
    .join("");

  const comment = `// 0x${address
    .toString(16)
    .toUpperCase()
    .padEnd(4)} (0x${actualWord.toString(16).toUpperCase()})`;

  return `${formattedInstructionString}${comment}`;
};
