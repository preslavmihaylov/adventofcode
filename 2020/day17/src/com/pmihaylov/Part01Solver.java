package com.pmihaylov;

public class Part01Solver {
    public static void solve(String[] lines) {
        ConwayCubes conwayCubes = ConwayCubes.from(lines, 3);
        conwayCubes.transitionToNextState(6);
        System.out.println("Part 1: " + conwayCubes.activeCubesCount());
    }
}
