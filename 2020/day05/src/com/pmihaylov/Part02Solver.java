package com.pmihaylov;

import java.util.Set;
import java.util.stream.IntStream;

public class Part02Solver {
    public static void solve(String[] lines) {
        Set<Integer> passes = Utils.extractSeatIDs(lines);
        int mySeat = IntStream.range(0, 1024)
                .filter(seatID -> doesntExist(passes, seatID))
                .filter(seatID -> isBetweenExistingSeats(passes, seatID))
                .findFirst()
                .orElse(-1);
        System.out.println("Part 2: " + mySeat);
    }

    private static boolean doesntExist(Set<Integer> passes, int seatID) {
        return !passes.contains(seatID);
    }

    private static boolean isBetweenExistingSeats(Set<Integer> passes, int seatID) {
        return passes.contains(seatID-1) && passes.contains(seatID+1);
    }
}
