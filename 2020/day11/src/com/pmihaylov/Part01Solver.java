package com.pmihaylov;

import java.util.function.BiFunction;

public class Part01Solver {
    public static void solve(String[][] lines) {
        SeatingSystem system = SeatingSystem.from(lines);
        BiFunction<Integer, Integer, String> nextStateFunc = (row, col) -> {
            if (system.getCell(row, col).equals("L") && system.adjacentSeatsCount(row, col) == 0) {
                return "#";
            } else if (system.getCell(row, col).equals("#") && system.adjacentSeatsCount(row, col) >= 4) {
                return "L";
            }

            return system.getCell(row, col);
        };

        boolean isStable = false;
        while (!isStable) {
            isStable = system.transitionToNextState(nextStateFunc);
        }

        System.out.println("Part 1: " + system.occupiedSeatsCount());
    }
}
