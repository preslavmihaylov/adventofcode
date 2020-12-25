package com.pmihaylov;

import java.util.List;
import java.util.ArrayList;

public class DirectionTokenizer {
    private final String line;
    private int cursor;

    public DirectionTokenizer(String line) {
        this.line = line;
        this.cursor = 0;
    }

    public List<Direction> allDirections() {
        List<Direction> dirs = new ArrayList<>();
        while (hasNext()) {
            dirs.add(next());
        }

        return dirs;
    }

    private boolean hasNext() {
        return cursor < line.length();
    }

    private Direction next() {
        try {
            if (line.charAt(cursor) == 'e') {
                return Direction.EAST;
            } else if (line.charAt(cursor) == 'w') {
                return Direction.WEST;
            } else if (cursor + 1 < line.length()) {
                cursor++;
                String str = line.substring(cursor-1, cursor+1);
                switch (str) {
                    case "nw":
                        return Direction.NORTH_WEST;
                    case "ne":
                        return Direction.NORTH_EAST;
                    case "sw":
                        return Direction.SOUTH_WEST;
                    case "se":
                        return Direction.SOUTH_EAST;
                }
            }
        } finally {
            cursor++;
        }

        throw new AssertionError("couldn't read next token properly. Remaining: " + line.substring(cursor));
    }
}
