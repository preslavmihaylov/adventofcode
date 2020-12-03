package com.pmihaylov;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

public class Main {

    public static void main(String[] args) {
        Labyrinth labyrinth = new Labyrinth(readInput());

        Velocity vel = new Velocity(1, 3);
        int row = vel.row;
        int col = vel.col;

        int treesCnt = 0;
        while (labyrinth.inBounds(row, col)) {
            treesCnt += labyrinth.posAt(row, col) == '#' ? 1 : 0;
            row += vel.row;
            col += vel.col;
        }

        System.out.println(treesCnt);
    }

    private static String[] readInput() {
        try {
            return new String(Files.readAllBytes(Paths.get("input.txt")), StandardCharsets.UTF_8)
                    .split("\n");
        } catch (IOException e) {
            e.printStackTrace();
            return new String[0];
        }
    }

    static class Velocity {
        public final int row, col;
        public Velocity(int row, int col) {
            this.row = row;
            this.col = col;
        }
    }

    static class Labyrinth {
        List<String> coords = new ArrayList<>();

        public Labyrinth(String[] coords) {
            for (String coord : coords) {
                this.coords.add(coord.trim());
            }
        }

        public char posAt(int row, int col) {
            return coords.get(row).charAt(col % coords.get(row).length());
        }

        public boolean inBounds(int row, int col) {
            return row < coords.size();
        }
    }
}
