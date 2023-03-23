/**
 * Converts a string into a number. If it is prefixed with 0x, it will be interpreted as base 16, otherwise base 10
 * @param string
 * @returns The parsed number
 */
export const parseNumber = (string: string) => {
  if (string.startsWith("0x")) {
    return parseInt(string.substring(2), 16);
  } else {
    return parseInt(string, 10);
  }
};

/**
 * Creates a bitmask used to truncate a number to fit within `size` bits
 * @param size The number of bits in the mask
 * @returns A bitmask of `size` bits, each bit set as 1
 */
export const maskOfSize = (size: number) => {
  let mask = 0;
  for (let i = 0; i < size; i++) {
    mask <<= 1;
    mask |= 1;
  }

  return mask;
};
