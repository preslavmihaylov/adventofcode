package com.pmihaylov;

import java.util.function.BiFunction;

public class Part02Solver {
    public static void solve(String[][] lines) {
        final SeatingSystem system = SeatingSystem.from(lines);
        BiFunction<Integer, Integer, String> nextStateFunc = (row, col) -> {
            if (system.getCell(row, col).equals("L") && system.visibleAdjacentSeatsCount(row, col) == 0) {
                return "#";
            } else if (system.getCell(row, col).equals("#") && system.visibleAdjacentSeatsCount(row, col) >= 5) {
                return "L";
            }

            return system.getCell(row, col);
        };

        boolean isStable = false;
        while (!isStable) {
            isStable = system.transitionToNextState(nextStateFunc);
        }

        System.out.println("Part 2: " + system.occupiedSeatsCount());
    }
}
