package com.pmihaylov;

import java.util.*;

public class Program {
    public enum ExitCode { OK, NOK }
    private final List<Instruction> instructions;

    public Program(List<Instruction> instructions) {
        this.instructions = Collections.unmodifiableList(instructions);
    }

    public Program withOverride(int i, Instruction ins) {
        List<Instruction> overridden = new ArrayList<>(instructions);
        overridden.set(i, ins);
        return new Program(overridden);
    }

    public Instruction getInstruction(int i) {
        return instructions.get(i);
    }

    public int getSize() {
        return instructions.size();
    }

    public boolean canCompleteWithOverride(int i, Instruction ins) {
        return this.withOverride(i, ins).execute().exitcode != ExitCode.NOK;
    }

    public Result execute() {
        Set<Integer> visitedInstructions = new HashSet<>();

        int instructionPtr = 0;
        int accumulator = 0;
        while (instructionPtr < instructions.size() && !visitedInstructions.contains(instructionPtr)) {
            visitedInstructions.add(instructionPtr);
            Instruction ins = instructions.get(instructionPtr);
            switch (ins.command) {
                case NOP:
                    instructionPtr++;
                    break;
                case ACCUMULATE:
                    accumulator += ins.argument;
                    instructionPtr++;
                    break;
                case JUMP:
                    instructionPtr += ins.argument;
            }
        }

        return instructionPtr >= instructions.size() ?
                new Result(ExitCode.OK, accumulator) : new Result(ExitCode.NOK, accumulator);
    }

    public static class Result {
        public final ExitCode exitcode;
        public final int accumulator;

        public Result(ExitCode exitcode, int accumulator) {
            this.exitcode = exitcode;
            this.accumulator = accumulator;
        }
    }
}
