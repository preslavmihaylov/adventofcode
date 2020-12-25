package com.pmihaylov;

public class Part01Solver {
    public static void solve(String[] input) {
        ColoredTiles tiles = ColoredTiles.from(input);
        System.out.println("Part 1: " + tiles.blackTilesCount());
    }
}
