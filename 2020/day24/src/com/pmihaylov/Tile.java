package com.pmihaylov;

import java.util.Arrays;
import java.util.List;
import java.util.Objects;

public class Tile {
    private final int x;
    private final int y;

    private Tile(int x, int y) {
        this.x = x;
        this.y = y;
    }

    public static Tile from(List<Direction> directions) {
        Tile ref = new Tile(0, 0);
        for (Direction dir : directions) {
            ref = ref.adjacentTile(dir);
        }

        return ref;
    }

    public List<Tile> allNeighbors() {
        return Arrays.asList(
                adjacentTile(Direction.WEST), adjacentTile(Direction.EAST), adjacentTile(Direction.NORTH_WEST),
                adjacentTile(Direction.NORTH_EAST), adjacentTile(Direction.SOUTH_WEST), adjacentTile(Direction.SOUTH_EAST));
    }

    public Tile adjacentTile(Direction dir) {
        switch (dir) {
            case WEST:
                return new Tile(x-2, y);
            case EAST:
                return new Tile(x+2, y);
            case NORTH_EAST:
                return new Tile(x+1, y+3);
            case NORTH_WEST:
                return new Tile(x-1, y+3);
            case SOUTH_EAST:
                return new Tile(x+1, y-3);
            case SOUTH_WEST:
                return new Tile(x-1, y-3);
            default:
                throw new AssertionError("unknown direction: " + dir);
        }
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Tile tile = (Tile) o;
        return x == tile.x &&
                y == tile.y;
    }

    @Override
    public int hashCode() {
        return Objects.hash(x, y);
    }
}
