package com.pmihaylov;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class JigsawPuzzle {
    private static final List<List<Character>> seaMonsterSprite = Utils.readSprite("seamonster.sprite");

    private final List<List<Tile>> tiles;

    public JigsawPuzzle(List<List<Tile>> tiles) {
        this.tiles = Collections.unmodifiableList(tiles);
    }

    public Tile get(int row, int col) {
        return tiles.get(row).get(col);
    }

    public int sideSize() {
        return tiles.size();
    }

    public int filledFieldsCount() {
        Tile bigTile = TileBuilder.buildFrom(trimAllBorders(tiles));

        int cnt = 0;
        for (int row = 0; row < bigTile.rowSize(); row++) {
            for (int col = 0; col < bigTile.colSize(); col++) {
                cnt += bigTile.get(row, col) == '#' ? 1 : 0;
            }
        }

        return cnt;
    }

    public int seaMonsterSize() {
        return seaMonsterSprite.stream()
                .map(line -> (int)line.stream().filter(c -> c == '#').count())
                .reduce(0, Integer::sum);
    }

    public int seaMonstersCount() {
        List<List<Tile>> trimmedTiles = trimAllBorders(tiles);
        Tile bigTile = TileBuilder.buildFrom(trimmedTiles);

        return bigTile.rotations().stream()
                .map(this::seaMonstersCount)
                .filter(cnt -> cnt != 0)
                .findAny().orElse(0);
    }

    private List<List<Tile>> trimAllBorders(List<List<Tile>> tiles) {
        List<List<Tile>> newTiles = new ArrayList<>();
        for (int row = 0; row < tiles.size(); row++) {
            newTiles.add(new ArrayList<>());
            for (int col = 0; col < tiles.get(row).size(); col++) {
                newTiles.get(row).add(tiles.get(row).get(col).trimBorders());
            }
        }

        return newTiles;
    }

    private int seaMonstersCount(Tile tile) {
        int cnt = 0;
        for (int row = 0; row < tile.rowSize(); row++) {
            for (int col = 0; col < tile.colSize(); col++) {
                cnt += isSeaMonster(tile, row, col) ? 1 : 0;
            }
        }

        return cnt;
    }

    private boolean isSeaMonster(Tile tile, int row, int col) {
        Tile subTile = tile.subTile(row, col, seaMonsterSprite.size(), seaMonsterSprite.get(0).size());
        return Utils.spritesMatch(subTile.fields(), seaMonsterSprite);
    }
}
