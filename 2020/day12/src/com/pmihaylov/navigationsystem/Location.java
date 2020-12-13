package com.pmihaylov.navigationsystem;

public class Location {
    public final int x;
    public final int y;

    public Location(int x, int y) {
        this.x = x;
        this.y = y;
    }

    public int manhattanDistanceFrom(Location other) {
        return Math.abs(this.x-other.x) + Math.abs(this.y-other.y);
    }
}
