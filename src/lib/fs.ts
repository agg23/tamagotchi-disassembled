import fs from "fs";
import readline from "readline";
import events from "events";
import { InstructionSet, parseArchLine } from "./bass";

/**
 * Opens a file and streams it out, line by line
 * @param path The path of the file to read
 * @param onLine A callback used to respond to each line content and its line number
 */
export const readByLines = async (
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

/**
 * Reads and parses the BASS arch file
 * @param path The path of the arch file
 * @returns The InstructionSet resulting from parsing the arch file
 */
export const readArch = async (path: string): Promise<InstructionSet> => {
  const instructionSet: InstructionSet = {
    instructions: [],
  };

  await readByLines(path, (line, lineNumber) =>
    parseArchLine(line, lineNumber, instructionSet)
  );

  return instructionSet;
};
