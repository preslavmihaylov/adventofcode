package com.pmihaylov;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class JigsawPuzzleBuilder {
    public static JigsawPuzzle buildFrom(String[] input) {
        List<Tile> allTiles = Arrays.stream(input).map(TileBuilder::buildFrom).collect(Collectors.toList());
        int mazeSize = (int)Math.sqrt(allTiles.size());

        List<List<Tile>> orderedJigsaw = new ArrayList<>();
        List<Integer> excludedTiles = new ArrayList<>();
        Tile corner = findTileNotFittingAnySides(allTiles, "UP", "LEFT");
        for (int row = 0; row < mazeSize; row++) {
            Tile prev = corner;

            orderedJigsaw.add(new ArrayList<>());
            orderedJigsaw.get(row).add(prev);
            excludedTiles.add(prev.id);
            for (int col = 1; col < mazeSize; col++) {
                Tile next = findFittingTile(allTiles, excludedTiles, prev, "RIGHT");
                orderedJigsaw.get(row).add(next);

                excludedTiles.add(next.id);
                prev = next;
            }

            corner = findFittingTile(allTiles, excludedTiles, corner, "DOWN");
        }

        return new JigsawPuzzle(orderedJigsaw);
    }

    private static Tile findFittingTile(List<Tile> tiles, List<Integer> excludedTiles, Tile given, String side) {
        List<Tile> result = tiles.stream()
                .filter(t -> !excludedTiles.contains(t.id))
                .filter(t -> t.anyRotationMatches(given, side))
                .collect(Collectors.toList());

        return result.size() == 0 ? null : result.get(0).getFittingRotation(given, side)
                .orElseThrow(() -> new AssertionError("no fitting rotation found"));
    }

    private static Tile findTileNotFittingAnySides(List<Tile> tiles, String side1, String side2) {
        for (Tile tile : tiles) {
            List<Tile> rotations = tile.rotations();
            for (Tile rotation : rotations) {
                List<Tile> first = tiles.stream()
                        .filter(o -> o != tile && o.anyRotationMatches(rotation, side1))
                        .collect(Collectors.toList());

                List<Tile> second = tiles.stream()
                        .filter(o -> o != tile && o.anyRotationMatches(rotation, side2))
                        .collect(Collectors.toList());

                if (first.size() == 0 && second.size() == 0) {
                    return rotation;
                }
            }
        }

        return null;
    }
}
