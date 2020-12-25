package com.pmihaylov;

import java.util.HashMap;
import java.util.Map;

public class ColoredTiles {
    private enum Color { WHITE, BLACK }

    private Map<Tile, Color> tilesToColor;

    private ColoredTiles(Map<Tile, Color> tilesToColor) {
        this.tilesToColor = tilesToColor;
    }

    public static ColoredTiles from(String[] lines) {
        Map<Tile, Color> tilesToColor = new HashMap<>();
        for (String line : lines) {
            Tile tile = Tile.from(new DirectionTokenizer(line).allDirections());

            tilesToColor.putIfAbsent(tile, Color.WHITE);
            tilesToColor.put(tile, tilesToColor.get(tile) == Color.WHITE ? Color.BLACK : Color.WHITE);
        }

        return new ColoredTiles(tilesToColor);
    }

    public long blackTilesCount() {
        return tilesToColor.values().stream().filter(c -> c == Color.BLACK).count();
    }

    public void flipAllTilesByRules() {
        tilesToColor = addAllNeighbors(tilesToColor);
        tilesToColor = flipTiles(tilesToColor);
    }

    private static Map<Tile, Color> addAllNeighbors(Map<Tile, Color> tilesToColor) {
        Map<Tile, Color> neighbors = new HashMap<>(tilesToColor);
        for (Tile t : tilesToColor.keySet())
            for (Tile neighbor : t.allNeighbors())
                neighbors.putIfAbsent(neighbor, Color.WHITE);

        return neighbors;
    }

    private static Map<Tile, Color> flipTiles(Map<Tile, Color> tilesToColor) {
        Map<Tile, Color> flipped = new HashMap<>();
        for (Tile tile : tilesToColor.keySet())
            flipped.put(tile, nextColorFor(tilesToColor, tile));

        return flipped;
    }

    private static Color nextColorFor(Map<Tile, Color> tilesToColor, Tile tile) {
        long blackNeighborsCnt = tile.allNeighbors().stream()
                .filter(t -> tilesToColor.getOrDefault(t, Color.WHITE) == Color.BLACK)
                .count();

        Color color = tilesToColor.get(tile);
        if (color == Color.BLACK && (blackNeighborsCnt == 0 || blackNeighborsCnt > 2))
            return Color.WHITE;
        else if (color == Color.WHITE && blackNeighborsCnt == 2)
            return Color.BLACK;

        return color;
    }
}
