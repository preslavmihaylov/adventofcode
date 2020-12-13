package com.pmihaylov.navigationsystem;

public class Navigation {
    public final Location origin;
    public final Location waypoint;

    public Navigation(Location origin, Location waypoint) {
        this.origin = origin;
        this.waypoint = waypoint;
    }
}
