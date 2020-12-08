package com.pmihaylov;

import java.util.*;

public class Part01Solver {
    public static void solve(String[] lines) {
        List<Instruction> instructions = Utils.instructionsFrom(lines);
        Program program = new Program(instructions);

        System.out.println("Part 1: " + program.execute().accumulator);
    }
}
