import { readFileSync, writeFileSync } from "fs";
import path from "path";
import { argv } from "process";
import { parseBinaryBuffer } from "./lib/disassembly";
import { readArch } from "./lib/fs";

if (argv.length != 4) {
  console.log(`Received ${argv.length - 2} arguments. Expected 2\n`);
  console.log("Usage: node disassembler.js [input.bin] [output.asm]");

  process.exit(1);
}

const archPath = path.join(__dirname, "../bass/6200.arch");

const inputFile = argv[2] as string;
const outputFile = argv[3] as string;

const build = async () => {
  const instructionSet = await readArch(archPath);

  const sortedInstructions = instructionSet.instructions.sort(
    (a, b) => a.sortableOpcode - b.sortableOpcode
  );

  const buffer = readFileSync(inputFile);
  const outputString = parseBinaryBuffer(buffer, sortedInstructions);

  writeFileSync(outputFile, outputString);
};

build();
