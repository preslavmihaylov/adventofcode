package com.pmihaylov;

public class Part01Solver {
    public static void solve(String[] input) {
        JigsawPuzzle puzzle = JigsawPuzzleBuilder.buildFrom(input);

        Tile topLeft = puzzle.get(0, 0);
        Tile topRight = puzzle.get(0, puzzle.sideSize() - 1);
        Tile botLeft = puzzle.get(puzzle.sideSize() - 1, 0);
        Tile botRight = puzzle.get(puzzle.sideSize() - 1, puzzle.sideSize() - 1);

        long result = (long) topLeft.id * topRight.id * botLeft.id * botRight.id;
        System.out.println("Part 1: " + result);
    }
}
