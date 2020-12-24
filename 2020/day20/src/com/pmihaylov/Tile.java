package com.pmihaylov;

import java.util.*;

public class Tile {
    public final Integer id;
    private final List<List<Character>> fields;

    public Tile(Integer id, List<List<Character>> fields) {
        this.id = id;
        this.fields = Collections.unmodifiableList(fields);
    }

    private Tile(Tile other) {
        this(other.id, other.fields);
    }

    public List<List<Character>> fields() {
        return transformTile((newFields, row, col) -> newFields.get(row).set(col, fields.get(row).get(col))).fields;
    }

    public Character get(int row, int col) {
        if (row < 0 || row >= fields.size() || col < 0 || col >= fields.get(row).size()) {
            return '.';
        }

        return fields.get(row).get(col);
    }

    public Tile subTile(int row, int col, int rowSize, int colSize) {
        List<List<Character>> result = new ArrayList<>();
        for (int nr = 0; nr < rowSize; nr++) {
            result.add(new ArrayList<>());
            for (int nc = 0; nc < colSize; nc++) {
                result.get(nr).add(get(row+nr, col+nc));
            }
        }

        return new Tile(id, result);
    }

    public int rowSize() {
        return fields.size();
    }

    public int colSize() {
        return fields.get(0).size();
    }

    public boolean anyRotationMatches(Tile other, String side) {
        return getFittingRotation(other, side).isPresent();
    }

    public Tile trimBorders() {
        List<List<Character>> newFields = new ArrayList<>();
        for (int row = 1; row < fields.size()-1; row++) {
            newFields.add(new ArrayList<>());
            for (int col = 1; col < fields.get(row).size()-1; col++) {
                newFields.get(row-1).add(fields.get(row).get(col));
            }
        }

        return new Tile(id, newFields);
    }

    public Optional<Tile> getFittingRotation(Tile other, String side) {
        return rotations().stream().filter(r -> r.fitsTileOnSide(other, side)).findAny();
    }

    private boolean fitsTileOnSide(Tile other, String side) {
        switch (side) {
            case "UP":
                return fields.get(fields.size() - 1).equals(other.fields.get(0));
            case "DOWN":
                return fields.get(0).equals(other.fields.get(other.fields.size() - 1));
            case "RIGHT":
                for (int row = 0; row < fields.size(); row++) {
                    if (fields.get(row).get(0) != other.fields.get(row).get(other.fields.size() - 1)) {
                        return false;
                    }
                }

                return true;
            case "LEFT":
                for (int row = 0; row < fields.size(); row++) {
                    if (fields.get(row).get(fields.size() - 1) != other.fields.get(row).get(0)) {
                        return false;
                    }
                }

                return true;
            default:
                throw new AssertionError("unrecognized direction");
        }
    }

    public List<Tile> rotations() {
        return Arrays.asList(new Tile(this), rotate(), rotate().rotate(), rotate().rotate().rotate(),
                flip(), flip().rotate(), flip().rotate().rotate(), flip().rotate().rotate().rotate());
    }

    private Tile rotate() {
        return transformTile((newFields, row, col) ->
                newFields.get(col).set(fields.size()-1-row, fields.get(row).get(col)));
    }

    private Tile flip() {
        return transformTile((newFields, row, col) ->
                newFields.get(fields.size()-1-row).set(col, fields.get(row).get(col)));
    }

    private Tile transformTile(TriConsumer<List<List<Character>>, Integer, Integer> consumer) {
        List<List<Character>> newFields = new ArrayList<>(Collections.nCopies(fields.size(), new ArrayList<>()));
        for (int row = 0; row < fields.size(); row++) {
            newFields.set(row, new ArrayList<>(Collections.nCopies(fields.get(row).size(), '.')));
        }

        for (int row = 0; row < fields.size(); row++) {
            for (int col = 0; col < fields.get(row).size(); col++) {
                consumer.accept(newFields, row, col);
            }
        }

        return new Tile(id, newFields);
    }

    @FunctionalInterface
    private interface TriConsumer<A,B,C> {
        void accept(A a, B b, C c);
    }
}
