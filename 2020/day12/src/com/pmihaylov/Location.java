package com.pmihaylov;

public class Location {
    public final int x;
    public final int y;
    public final Direction direction;

    public Location(int x, int y, Direction direction) {
        this.x = x;
        this.y = y;
        this.direction = direction;
    }

    public int manhattanDistanceFrom(Location other) {
        return Math.abs(this.x-other.x) + Math.abs(this.y-other.y);
    }
}
