package com.pmihaylov;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class Part01Solver {
    public static void solve(String[] lines) {
        List<Instruction> instructions = Arrays.stream(lines).map(Instruction::from).collect(Collectors.toList());
        Location initialLoc = new Location(0, 0, Direction.EAST);
        Location finalLoc = instructions.stream()
                .reduce(initialLoc, (identity, instruction) -> instruction.execute(identity), (l1, l2) -> l2);

        System.out.println("Part 1: " + finalLoc.manhattanDistanceFrom(initialLoc));
    }
}
