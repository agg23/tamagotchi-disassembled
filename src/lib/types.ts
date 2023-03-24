import { Instruction } from "./bass";

export interface MatchedInstructionBase {
  line: string;
  lineNumber: number;
  address: number;
}

export type ConstantLiteralMatchedInstruction = MatchedInstructionBase & {
  type: "constant";
  subtype: "literal";
  value: number;
};

export type ConstantLabelMatchedInstruction = MatchedInstructionBase & {
  type: "constant";
  subtype: "label";
  label: string;
};

export type ImmediateMatchedInstruction = MatchedInstructionBase & {
  type: "immediate";
  immediate: number;
  bitCount: number;
  opcodeString: string;
};

export type LabelMatchedInstruction = MatchedInstructionBase & {
  type: "label";
  label: string;
  bitCount: number;
  opcodeString: string;
};

export type LiteralMatchedInstruction = MatchedInstructionBase & {
  type: "literal";
  opcodeString: string;
};

export interface AssembledProgram {
  currentAddress: number;
  matchedInstructions: Array<
    | ConstantLiteralMatchedInstruction
    | ConstantLabelMatchedInstruction
    | ImmediateMatchedInstruction
    | LabelMatchedInstruction
    | LiteralMatchedInstruction
  >;

  matchedLabels: {
    [name: string]: {
      lineNumber: number;
      instructionIndex: number;
      address: number;
    };
  };
  unmatchedLabels: Array<{
    label: string;
    lineNumber: number;
  }>;
}

/// Disassembly ///

export interface DisassembledInstruction {
  instruction: Instruction;
  actualWord: number;
  address: number;
}

export interface Some<T> {
  type: "some";
  value: T;
}

export interface None {
  type: "none";
}

export type Option<T> = Some<T> | None;
