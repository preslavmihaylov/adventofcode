package com.pmihaylov;


import sun.jvm.hotspot.utilities.AssertionFailure;
import java.util.Arrays;

public class Instruction {
    public final Action action;
    public final int value;

    public Instruction(Action action, int value) {
        this.action = action;
        this.value = value;
    }

    public static Instruction from(String line) {
        Action action = Arrays.stream(Action.values())
                .filter(a -> a.name.equals(line.substring(0, 1)))
                .findFirst()
                .orElseThrow(() -> new AssertionFailure("unknown action"));
        int value = Integer.parseInt(line.substring(1));

        return new Instruction(action, value);
    }

    public Location execute(Location loc) {
        switch (action) {
            case NORTH:
                return new Location(loc.x, loc.y + value, loc.direction);
            case SOUTH:
                return new Location(loc.x, loc.y - value, loc.direction);
            case EAST:
                return new Location(loc.x + value, loc.y, loc.direction);
            case WEST:
                return new Location(loc.x - value, loc.y, loc.direction);
            case LEFT:
            case RIGHT:
                return turnInDirection(loc);
            case FORWARD:
                return forwardLocationBy(loc, value);
        }

        throw new AssertionFailure("invalid action");
    }

    private Location turnInDirection(Location loc) {
        for (int i = 0; i < value / 90; i++) {
            switch (action) {
                case LEFT:
                    loc = new Location(loc.x, loc.y, loc.direction.left());
                    break;
                case RIGHT:
                    loc = new Location(loc.x, loc.y, loc.direction.right());
                    break;
                default:
                    throw new AssertionFailure("invalid direction to turn to");
            }
        }

        return loc;
    }

    private Location forwardLocationBy(Location loc, int value) {
        switch (loc.direction) {
            case NORTH:
                return new Location(loc.x, loc.y + value, loc.direction);
            case SOUTH:
                return new Location(loc.x, loc.y - value, loc.direction);
            case EAST:
                return new Location(loc.x + value, loc.y, loc.direction);
            case WEST:
                return new Location(loc.x - value, loc.y, loc.direction);
        }

        throw new AssertionFailure("invalid direction");
    }
}