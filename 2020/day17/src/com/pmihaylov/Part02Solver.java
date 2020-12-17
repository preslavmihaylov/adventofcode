package com.pmihaylov;

public class Part02Solver {
    public static void solve(String[] lines) {
        ConwayCubes conwayCubes = ConwayCubes.from(lines, 4);
        conwayCubes.transitionToNextState(6);
        System.out.println("Part 2: " + conwayCubes.activeCubesCount());
    }
}
