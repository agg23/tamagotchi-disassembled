import { numberRegex, whitespaceRegex } from "./regex";
import { log } from "./log";
import { parseNumber } from "./util";

export interface InstructionSet {
  instructions: Array<ImmediateInstruction | LiteralInstruction>;
}

export interface InstructionBase {
  regex: RegExp;
  opcodeString: string;
}

export type ImmediateInstruction = InstructionBase & {
  type: "immediate";
  bitCount: number;
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

  let numberMatch = originalInstruction.match(numberRegex);

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

    config.instructions.push({
      type: "immediate",
      regex: new RegExp(instructionLine),
      bitCount,
      opcodeString: opcode.trim(),
    });
  } else {
    // This is a literal
    const instructionLine = originalInstruction
      .trim()
      .replace(whitespaceRegex, whitespaceRegex.source);

    config.instructions.push({
      type: "literal",
      regex: new RegExp(instructionLine),
      opcodeString: opcode.trim(),
    });
  }
};
