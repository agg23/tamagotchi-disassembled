import fs, { readFileSync, writeFileSync } from "fs";
import { argv } from "process";
import readline from "readline";
import events from "events";

import { InstructionSet, parseArchLine } from "./lib/bass";
import { parseNumber } from "./lib/util";
import * as path from "path";
import { AssembledProgram } from "./lib/types";
import { commentRegex, labelRegex } from "./lib/regex";
import { outputInstructions } from "./lib/opcodeOutput";
import { log } from "./lib/log";

interface ComamndEntry {
  regex: RegExp;
  action: (
    line: { line: string; lineNumber: number },
    matches: RegExpExecArray,
    program: AssembledProgram
  ) => void;
}

// The commands supported by the assembler (separate from opcodes)
const commands: ComamndEntry[] = [
  {
    regex: /origin\s+((?:0x)?[a-f0-9]+)/,
    action: ({ lineNumber }, [_2, address], program) => {
      if (address === undefined) {
        log("Could not parse origin", lineNumber);
        return;
      }

      program.currentAddress = parseNumber(address);
    },
  },
  {
    regex: /constant\s+(?:(0x[a-f0-9]+|[0-9]+)|([a-z0-9_]+))/,
    action: ({ line, lineNumber }, [_, constant, label], program) => {
      const address = program.currentAddress;

      if (constant !== undefined) {
        const value = parseNumber(constant);

        if (value > 4095) {
          log(
            `Constant ${constant} is too large to fit into 12 bits`,
            lineNumber
          );
          return;
        }

        program.matchedInstructions.push({
          type: "constant",
          subtype: "literal",
          value,
          line,
          lineNumber,
          address,
        });
      } else if (label !== undefined) {
        program.matchedInstructions.push({
          type: "constant",
          subtype: "label",
          label,
          line,
          lineNumber,
          address,
        });
      } else {
        log("Unknown constant error", lineNumber);
        return;
      }

      program.currentAddress += 1;
    },
  },
];

const parseAsmLine = (
  line: string,
  lineNumber: number,
  instructionSet: InstructionSet,
  program: AssembledProgram
) => {
  if (line.length == 0 || line.startsWith("//") || line.startsWith(";")) {
    // Comment. Skip
    return;
  }

  for (const command of commands) {
    const matches = command.regex.exec(line);

    if (!!matches && matches.length > 0) {
      command.action({ lineNumber, line }, matches, program);
      return;
    }
  }

  let hasInstruction = false;

  // Match line against all known instructions from the BASS arch
  for (const instruction of instructionSet.instructions) {
    const matches = instruction.regex.exec(line);

    const address = program.currentAddress;

    if (!!matches && matches.length > 0) {
      if (matches[1] !== undefined) {
        // immediate
        if (instruction.type !== "immediate") {
          log(
            "Attempted to match content with non-immediate instruction",
            lineNumber
          );
          return;
        }

        program.matchedInstructions.push({
          type: "immediate",
          line,
          immediate: parseNumber(matches[1]),
          opcodeString: instruction.opcodeString,
          bitCount: instruction.bitCount,
          lineNumber,
          address,
        });
      } else if (matches[2] !== undefined) {
        // potential label
        if (instruction.type !== "immediate") {
          log(
            "Attempted to match content with non-immediate instruction",
            lineNumber
          );
          return;
        }

        program.matchedInstructions.push({
          type: "label",
          line,
          label: matches[2],
          opcodeString: instruction.opcodeString,
          bitCount: instruction.bitCount,
          lineNumber,
          address,
        });
      } else {
        // literal only
        program.matchedInstructions.push({
          type: "literal",
          line,
          opcodeString: instruction.opcodeString,
          lineNumber,
          address,
        });
      }

      hasInstruction = true;
      program.currentAddress += 1;
      break;
    }
  }

  if (hasInstruction && program.unmatchedLabels.length > 0) {
    // Add queued labels
    for (const label of program.unmatchedLabels) {
      const existingLabel = program.matchedLabels[label.label];

      if (existingLabel) {
        log(
          `Label "${label.label}" already exists. Was created on line ${existingLabel.lineNumber}`,
          lineNumber
        );

        return;
      }

      program.matchedLabels[label.label] = {
        lineNumber,
        instructionIndex: program.matchedInstructions.length - 1,
        address: program.currentAddress - 1,
      };
    }

    // We've processed all labels
    program.unmatchedLabels = [];
  }

  let lineWithoutLabel = line;

  const matches = labelRegex.exec(line);

  if (!!matches && matches.length > 0 && matches[1]) {
    lineWithoutLabel =
      lineWithoutLabel.substring(0, matches.index) +
      lineWithoutLabel.substring(matches.index + matches[0].length);

    const label = matches[1];
    const existingLabel = program.matchedLabels[label];
    if (existingLabel) {
      log(
        `Label "${label}" already exists. Was created on line ${existingLabel.lineNumber}`,
        lineNumber
      );

      return;
    }

    if (hasInstruction) {
      // Instruction on this line, pair them up
      program.matchedLabels[label] = {
        lineNumber,
        instructionIndex: program.matchedInstructions.length - 1,
        address: program.currentAddress - 1,
      };
    } else {
      // Will pair with some future instruction. Queue it
      program.unmatchedLabels.push({
        label,
        lineNumber,
      });
    }
  }

  lineWithoutLabel = lineWithoutLabel.replace(commentRegex, "").trim();

  if (!hasInstruction && lineWithoutLabel.length > 0) {
    log(`Unknown instruction "${lineWithoutLabel}"`, lineNumber);
  }
};

const readByLines = async (
  path: string,
  onLine: (line: string, lineNumber: number) => void
) => {
  const rl = readline.createInterface({
    input: fs.createReadStream(path),
    crlfDelay: Infinity,
  });

  let lineNumber = 0;

  rl.on("line", (line) => onLine(line.toLowerCase().trim(), ++lineNumber));

  await events.once(rl, "close");
};

if (argv.length != 4 && argv.length != 5) {
  console.log(`Received ${argv.length - 2} arguments. Expected 2-3\n`);
  console.log(
    "Usage: node assembler.js [input.asm] [output.bin] {true|false: 12 bit output}"
  );

  process.exit(1);
}

const archPath = path.join(__dirname, "../bass/6200.arch");

const inputFile = argv[2] as string;
const outputFile = argv[3] as string;
const word16Align = argv[4] !== "true";

const build = async () => {
  const instructionSet: InstructionSet = {
    instructions: [],
  };

  const program: AssembledProgram = {
    currentAddress: 0,
    matchedInstructions: [],
    matchedLabels: {},
    unmatchedLabels: [],
  };

  await readByLines(archPath, (line, lineNumber) =>
    parseArchLine(line, lineNumber, instructionSet)
  );

  await readByLines(inputFile, (line, lineNumber) =>
    parseAsmLine(line, lineNumber, instructionSet, program)
  );

  const outputBuffer = outputInstructions(program, word16Align);

  if (outputBuffer.type === "some") {
    writeFileSync(outputFile, outputBuffer.value);
  } else {
    console.log("Could not generate output binary");
  }
};

build();
