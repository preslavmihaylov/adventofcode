package com.pmihaylov;

public class Part02Solver {
    public static void solve(String[] input) {
        ColoredTiles tiles = ColoredTiles.from(input);
        for (int i = 0; i < 100; i++) {
            tiles.flipAllTilesByRules();
        }

        System.out.println("Part 2: " + tiles.blackTilesCount());
    }
}
