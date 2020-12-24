package com.pmihaylov;

public class Part02Solver {
    public static void solve(String[] input) {
        JigsawPuzzle puzzle = JigsawPuzzleBuilder.buildFrom(input);
        int seaMonsterTiles = puzzle.seaMonsterSize() * puzzle.seaMonstersCount();
        System.out.println("Part 2: " + (puzzle.filledFieldsCount() - seaMonsterTiles));
    }
}
