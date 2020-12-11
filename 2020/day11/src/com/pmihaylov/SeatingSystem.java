package com.pmihaylov;

import java.util.Arrays;
import java.util.function.BiFunction;
import java.util.stream.Stream;

public class SeatingSystem {
    private volatile String[][] layout;

    private SeatingSystem(String[][] layout) {
        this.layout = layout;
    }

    public static SeatingSystem from(String[][] lines) {
        return new SeatingSystem(lines);
    }

    public boolean transitionToNextState(BiFunction<Integer, Integer, String> nextStateFunc) {
        String[][] newLayout = new String[layout.length][];
        boolean isStable = true;
        for (int row = 0; row < layout.length; row++) {
            newLayout[row] = new String[layout[row].length];
            for (int col = 0; col < layout[row].length; col++) {
                newLayout[row][col] = nextStateFunc.apply(row, col);
                if (!newLayout[row][col].equals(layout[row][col])) {
                    isStable = false;
                }
            }
        }

        layout = newLayout;
        return isStable;
    }

    public long visibleAdjacentSeatsCount(int row, int col) {
        return Stream.of(
                isFirstVisibleSeatOccupied(row, col, -1, -1),
                isFirstVisibleSeatOccupied(row, col, -1, 0),
                isFirstVisibleSeatOccupied(row, col, -1, 1),
                isFirstVisibleSeatOccupied(row, col, 1, 1),
                isFirstVisibleSeatOccupied(row, col, 1, 0),
                isFirstVisibleSeatOccupied(row, col, 1, -1),
                isFirstVisibleSeatOccupied(row, col, 0, 1),
                isFirstVisibleSeatOccupied(row, col, 0, -1)
        ).filter(r -> r).count();
    }

    public long adjacentSeatsCount(int row, int col) {
        return Stream.of(
                isOccupied(row-1, col-1), isOccupied(row-1, col), isOccupied(row-1, col+1),
                isOccupied(row+1, col+1), isOccupied(row+1, col), isOccupied(row+1, col-1),
                isOccupied(row, col+1), isOccupied(row, col-1)
        ).filter(r -> r).count();
    }

    public long occupiedSeatsCount() {
        return Arrays.stream(layout)
                .map(row -> Arrays.stream(row).filter(cell -> cell.equals("#")).count())
                .reduce(0L, Long::sum);
    }

    private boolean isFirstVisibleSeatOccupied(int row, int col, int velRow, int velCol) {
        int cRow = row;
        int cCol = col;
        do {
            cRow += velRow;
            cCol += velCol;
        } while (getCell(cRow, cCol).equals("."));

        return isOccupied(cRow, cCol);
    }

    private boolean isOccupied(int row, int col) {
        return getCell(row, col).equals("#");
    }

    public String getCell(int row, int col) {
        if (row < 0 || row >= layout.length || col < 0 || col >= layout[row].length) {
            return "X";
        }

        return layout[row][col];
    }
}
