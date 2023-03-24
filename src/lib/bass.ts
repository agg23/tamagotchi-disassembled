import { bassNumberRegex, whitespaceRegex } from "./regex";
import { log } from "./log";
import { parseNumber } from "./util";
import { buildOpcode } from "./opcodeOutput";

export interface InstructionSet {
  instructions: Array<Instruction>;
}

export type Instruction = ImmediateInstruction | LiteralInstruction;

export interface InstructionBase {
  regex: RegExp;
  opcodeString: string;
  sortableOpcode: number;
  originalInstruction: string;
}

export type ImmediateInstruction = InstructionBase & {
  type: "immediate";
  immediate: {
    bitCount: number;
    /**
     * The index in the originalInstruction the immediate occurs
     */
    stringIndex: number;
    /**
     * The length of the immediate in the originalInstruction string
     */
    stringLength: number;
  };
};

export type LiteralInstruction = InstructionBase & {
  type: "literal";
};

/**
 * Parses a single line of a BASS architecture file
 * @param line The line being parsed
 * @param lineNumber The one-based index of the line being processed
 * @param config The global instruction set config
 * @returns
 */
export const parseArchLine = (
  line: string,
  lineNumber: number,
  config: InstructionSet
) => {
  if (line.length == 0 || line.startsWith("//") || line.startsWith("#")) {
    // Comment. Skip
    return;
  }

  const sections = line.split(";");

  if (sections.length != 2) {
    log(
      "Unexpected semicolon. Does this instruction have an output?",
      lineNumber
    );

    return;
  }

  const [originalInstruction, opcode] = sections;

  if (!originalInstruction || !opcode) {
    log("Unknown input", lineNumber);
    return;
  }

  const opcodeString = opcode.trim();

  let numberMatch = originalInstruction.match(bassNumberRegex);

  if (!!numberMatch && numberMatch.index) {
    // This instruction contains a star followed by a number
    // This is an immediate
    const matchString = numberMatch[0];
    // This is guaranteed to exist due to the regex
    const bitCount = parseNumber(numberMatch[1]!);
    const index = numberMatch.index;

    let instructionLine =
      originalInstruction.substring(0, index) +
      "(?:(0x[a-f0-9]+|[0-9]+)|([a-z0-9_]+))" +
      originalInstruction.substring(index + matchString.length);

    instructionLine = instructionLine
      .trim()
      .replace(whitespaceRegex, whitespaceRegex.source);

    const sortableOpcode = buildSortableOpcode(opcodeString, bitCount);

    config.instructions.push({
      type: "immediate",
      regex: new RegExp(instructionLine),
      immediate: {
        bitCount,
        stringIndex: index,
        stringLength: matchString.length,
      },
      opcodeString,
      sortableOpcode,
      originalInstruction: originalInstruction.trim(),
    });
  } else {
    // This is a literal
    const instructionLine = originalInstruction
      .trim()
      .replace(whitespaceRegex, whitespaceRegex.source);

    const sortableOpcode = buildSortableOpcode(opcodeString, 0);

    config.instructions.push({
      type: "literal",
      regex: new RegExp(instructionLine),
      opcodeString,
      sortableOpcode,
      originalInstruction: originalInstruction.trim(),
    });
  }
};

const buildSortableOpcode = (template: string, bitCount: number) =>
  buildOpcode(template, bitCount, 0);
