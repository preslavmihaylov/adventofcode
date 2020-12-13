package com.pmihaylov;

import com.pmihaylov.navigationsystem.Instruction;
import com.pmihaylov.navigationsystem.Location;
import com.pmihaylov.navigationsystem.Navigation;
import com.pmihaylov.navigationsystem.instructions.InstructionsFactory;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class Part01Solver {
    public static void solve(String[] lines) {
        List<Instruction> instructions = Arrays.stream(lines).map(InstructionsFactory::forPart01).collect(Collectors.toList());
        Navigation destination = instructions.stream()
                .reduce(new Navigation(new Location(0, 0), new Location(1, 0)),
                        (navigation, instruction) -> instruction.execute(navigation),
                        (n1, n2) -> n2);

        System.out.println("Part 1: " + destination.origin.manhattanDistanceFrom(new Location(0, 0)));
    }
}
