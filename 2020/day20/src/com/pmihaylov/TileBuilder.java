package com.pmihaylov;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class TileBuilder {
    public static Tile buildFrom(String input) {
        String[] lines = input.split("\n");
        Pattern p = Pattern.compile("\\d+");
        Matcher m = p.matcher(lines[0]);
        if (!m.find()) {
            throw new AssertionError("couldn't find tile ID");
        }

        Integer id = Integer.parseInt(m.group());
        List<List<Character>> fields = new ArrayList<>();
        for (int row = 1; row < lines.length; row++) {
            fields.add(lines[row].chars().mapToObj(c -> (char)c).collect(Collectors.toList()));
        }

        return new Tile(id, fields);
    }

    public static Tile buildFrom(List<List<Tile>> tiles) {
        List<List<Character>> fields = new ArrayList<>();
        for (int row = 0; row < tiles.size() * tiles.get(0).get(0).rowSize(); row++) {
            fields.add(new ArrayList<>());
            for (int col = 0; col < tiles.size() * tiles.get(0).get(0).colSize(); col++) {
                fields.get(row).add(charAt(tiles, row, col));
            }
        }

        return new Tile(0, fields);
    }

    private static Character charAt(List<List<Tile>> tiles, int row, int col) {
        int tileRow = row / tiles.get(0).get(0).rowSize();
        int fieldRow = row % tiles.get(0).get(0).rowSize();
        int tileCol = col / tiles.get(0).get(0).colSize();
        int fieldCol = col % tiles.get(0).get(0).colSize();

        return tiles.get(tileRow).get(tileCol).get(fieldRow, fieldCol);
    }
}
