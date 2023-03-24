import { readFileSync, writeFileSync } from "fs";
import { argv } from "process";
import encode from "image-encode";

interface PossibleImage {
  address: number;
  width: number;
}

const findImages = (buffer: Buffer): PossibleImage[] => {
  const images: PossibleImage[] = [];

  let lbpxCount = 0;

  for (let i = 0; i < buffer.length; i += 2) {
    // Skip the low byte of every word
    const highNibble = buffer[i]! & 0xf;

    if (highNibble === 0x9) {
      // LBPX
      // This is probably a set of pixels for an image
      lbpxCount += 1;
    } else if (highNibble === 0x1 && lbpxCount > 0) {
      // RETD
      // We have some number of possible pixels, so consider this a complete image write
      images.push({
        address: i - lbpxCount * 2,
        width: lbpxCount + 1,
      });

      lbpxCount = 0;
    } else {
      // If there's a gap in instructions, reset lbpxCount
      lbpxCount = 0;
    }
  }

  return images;
};

const IMAGE_HEIGHT = 8;
const IMAGE_WIDTH = 16;

const generateImages = (romBuffer: Buffer) => {
  const images = findImages(romBuffer);

  for (const image of images) {
    const imageBuffer = Buffer.alloc(16 * 8 * 4);

    for (let y = 0; y < IMAGE_HEIGHT; y++) {
      for (let x = 0; x < image.width; x++) {
        // Load the second byte of the word, which is where the immediate is
        const byte = romBuffer[image.address + x * 2 + 1]!;

        const imageCoord = (y * IMAGE_WIDTH + x) * 4;

        if (((byte >> y) & 0x1) !== 0) {
          // Pixel at x, y is on
          // Array is initialized to 0, so we can just toggle the alpha value to display black
          imageBuffer[imageCoord + 3] = 0xff;
        } else {
          imageBuffer[imageCoord + 3] = 0;
        }
      }
    }

    const wordAddress = image.address / 2;

    writeFileSync(
      `images/0x${wordAddress.toString(16)}.png`,
      Buffer.from(encode(imageBuffer, [16, 8], "png"))
    );
  }
};

if (argv.length != 3) {
  console.log(`Received ${argv.length - 2} arguments. Expected 1\n`);
  console.log("Usage: node extractIcons.js [input.bin]");

  process.exit(1);
}

const inputFile = argv[2] as string;

const build = async () => {
  const buffer = readFileSync(inputFile);
  generateImages(buffer);
};

build();
