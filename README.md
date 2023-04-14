# Tamagotchi P1 Disassembly

This is an partial, incomplete disassembly of the Tamagotchi P1 ROM. It is intended for educational purposes and to allow insight into the operating logic of the Tamagotchi. The provided disassembler and assembler allow you to symmetrically convert the ROM into human readable assembly, then convert it back into a working ROM identical to the original.

This project was undertaken to discover a bug in my FPGA Tamagotchi project.

The disassembly can be found in [tama.asm](./tama.asm).

## Findings

Besides what is in the source code itself, I maintained a list of interesting findings in [Useful Addresses](./Useful%20Addresses.md)

## Tools

Several tools are provided:

* Assembler
* Disassembler
* Image extraction - Inspired by https://github.com/jcrona/tamatool

## Licensing

The Tamagotchi ROM and source code is property of Bandai, and is not subject to the licensing of this repo. The disassembly is presented here for educational purpsoses only.