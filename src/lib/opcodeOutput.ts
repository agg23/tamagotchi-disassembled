import { log } from "./log";
import { AssembledProgram, Option } from "./types";
import { maskOfSize } from "./util";

/**
 * Builds the output buffer from the matched instructions
 * @param program The configured program we have built
 * @param word16Align If true, align the 12 bit opcodes to 16 bit words. The lowest nibble will be 0
 * @returns The output buffer that should be written to the assembled binary
 */
export const outputInstructions = (
  program: AssembledProgram,
  word16Align: boolean
): Option<Buffer> => {
  // This buffer stores each nibble of the program separately, and we will combine this later into the output buffer
  const threeNibbleBuffer: number[] = new Array(8192 * 3);

  // Fill array with 0xF
  for (let i = 0; i < threeNibbleBuffer.length; i++) {
    threeNibbleBuffer[i] = 0xf;
  }

  for (const instruction of program.matchedInstructions) {
    let opcode = 0;
    switch (instruction.type) {
      case "literal": {
        opcode = buildOpcode(instruction.opcodeString, 0, 0);
        break;
      }
      case "immediate": {
        opcode = buildOpcode(
          instruction.opcodeString,
          instruction.bitCount,
          instruction.immediate
        );
        break;
      }
      case "label": {
        const label = program.matchedLabels[instruction.label];

        if (!label) {
          log(`Unknown label ${instruction.label}`, instruction.lineNumber);

          return { type: "none" };
        }

        opcode = buildOpcode(
          instruction.opcodeString,
          instruction.bitCount,
          label.address
        );
        break;
      }
      case "constant": {
        if (instruction.subtype === "literal") {
          opcode = instruction.value;
        } else {
          // Label
          const label = program.matchedLabels[instruction.label];

          if (!label) {
            log(`Unknown label ${instruction.label}`, instruction.lineNumber);

            return { type: "none" };
          }

          console.log(`${label.address.toString(16)}`);

          opcode = label.address;
        }
        break;
      }
    }

    const low = opcode & 0xf;
    const mid = (opcode & 0xf0) >> 4;
    const high = (opcode & 0xf00) >> 8;

    const baseAddress = instruction.address * 3;

    // We use reverse order because that's how the nibbles are in the ROM
    threeNibbleBuffer[baseAddress] = high;
    threeNibbleBuffer[baseAddress + 1] = mid;
    threeNibbleBuffer[baseAddress + 2] = low;
  }

  return {
    type: "some",
    value: copyToOutputBuffer(threeNibbleBuffer, word16Align),
  };
};

const copyToOutputBuffer = (
  threeNibbleBuffer: number[],
  word16Align: boolean
): Buffer => {
  const bufferSize = word16Align ? 8192 * 2 : (8192 * 3) / 2;
  const buffer = Buffer.alloc(bufferSize);

  let byteBuffer = 0;
  let bufferAddress = 0;
  let lowNibble = false;
  let evenByte = true;
  for (let i = 0; i < threeNibbleBuffer.length; i++) {
    const nibble = threeNibbleBuffer[i]!;

    const writeSpacerValue = word16Align && !lowNibble && evenByte;

    if (lowNibble || writeSpacerValue) {
      // "Second", lower value of byte, or we're writing the spacer now
      byteBuffer |= nibble;

      buffer[bufferAddress] = byteBuffer;

      bufferAddress += 1;
      byteBuffer = 0;

      evenByte = !evenByte;
    } else {
      // "First", upper value of byte
      byteBuffer |= nibble << 4;
    }

    if (!writeSpacerValue) {
      // We've moved to the next byte if we wrote a spacer, so stay at !lowNibble
      lowNibble = !lowNibble;
    }
  }

  return buffer;
};

/**
 * Comsumes the opcode template from the BASS arch file and produces the actual output word
 * @param template The opcode template from the BASS arch file
 * @param argSize The number of bits in an argument to the opcode, if any
 * @param argument The actual data to pass as an argument to the opcode, if any
 * @returns The output opcode as a 12 bit word
 */
export const buildOpcode = (
  template: string,
  argSize: number,
  argument: number
) => {
  let index = 0;
  let outputWord = 0;

  while (index < template.length) {
    const char = template[index];

    if (char === "%") {
      // Consume chars until whitespace
      let data = 0;
      let count = 0;
      for (let i = 1; i < Math.min(13, template.length - index); i++) {
        const nextChar = template[index + i]!;

        if (nextChar !== "1" && nextChar !== "0") {
          // Stop consuming
          break;
        }

        data <<= 1;
        data |= nextChar === "1" ? 1 : 0;
        count += 1;
      }

      // Consume the next four chars as bits

      outputWord <<= count;
      outputWord |= data;

      index += count + 1;
    } else if (char === "=") {
      if (template[index + 1] !== "a") {
        console.log(
          `ERROR: Unexpected char after = in instruction definition "${template}"`
        );
        return 0;
      }

      outputWord <<= argSize;
      outputWord |= maskOfSize(argSize) & argument;

      index += 2;
    } else {
      index += 1;
    }
  }

  return outputWord;
};
