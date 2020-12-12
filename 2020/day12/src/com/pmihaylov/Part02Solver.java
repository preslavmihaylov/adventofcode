package com.pmihaylov;

import sun.jvm.hotspot.utilities.AssertionFailure;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class Part02Solver {
    public static void solve(String[] lines) {
        List<Instruction> instructions = Arrays.stream(lines).map(Instruction::from).collect(Collectors.toList());
        Location initialLoc = new Location(0, 0, Direction.EAST);
        Location waypoint = new Location(10, 1, Direction.EAST);
        for (Instruction instruction : instructions) {
            switch (instruction.action) {
                case NORTH:
                case EAST:
                case SOUTH:
                case WEST:
                    waypoint = instruction.execute(waypoint);
                    break;
                case LEFT:
                case RIGHT:
                    for (int i = 0; i < instruction.value / 90; i++) {
                        waypoint = rotate(waypoint, instruction.action);
                    }
                    break;
                case FORWARD:
                    for (int i = 0; i < instruction.value; i++) {
                        initialLoc = new Location(initialLoc.x + waypoint.x, initialLoc.y + waypoint.y, initialLoc.direction);
                    }
                    break;
            }
        }

        System.out.println("Part 2: " + initialLoc.manhattanDistanceFrom(new Location(0, 0, Direction.EAST)));
    }

    public static Location rotate(Location loc, Action action) {
        if (action == Action.LEFT) {
            return new Location(-loc.y, loc.x, loc.direction);
        } else if (action == Action.RIGHT) {
            return new Location(loc.y, -loc.x, loc.direction);
        }

        throw new AssertionFailure("invalid action passed to rotate on");
    }
}
