package com.pmihaylov;

import sun.jvm.hotspot.utilities.AssertionFailure;

import java.util.List;
import java.util.Optional;

public class Part02Solver {
    public static void solve(String[] lines) {
        List<Instruction> instructions = Utils.instructionsFrom(lines);
        Program fixed = fixProgramParallel(new Program(instructions))
                .orElseThrow(() -> new AssertionFailure("couldn't fix initial program"));

        System.out.println("Part 2: " + fixed.execute().accumulator);
    }

    private static Optional<Program> fixProgramParallel(Program program) {
        try (ParallelTraverser<Optional<Program>> traverser = new ParallelTraverser<>()) {
            return traverser.traverse(program.getSize(), Optional::isPresent,
                        (start, end) -> fixProgram(program, start, end)).flatMap(o -> o);
        }
    }

    private static Optional<Program> fixProgram(Program program, int start, int end) {
        for (int i = start; i < end; i++) {
            Optional<Instruction> override = overrideFor(program.getInstruction(i));
            if (override.isPresent() && program.canCompleteWithOverride(i, override.get())) {
                return Optional.of(program.withOverride(i, override.get()));
            }
        }

        return Optional.empty();
    }

    private static Optional<Instruction> overrideFor(Instruction ins) {
        if (ins.command == Instruction.Command.JUMP) {
            return Optional.of(new Instruction(Instruction.Command.NOP, ins.argument));
        } else if (ins.command == Instruction.Command.NOP) {
            return Optional.of(new Instruction(Instruction.Command.JUMP, ins.argument));
        }

        return Optional.empty();
    }
}
