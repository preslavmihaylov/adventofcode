package com.pmihaylov;

public class Part01Solver {
    public static void solve(String[] lines) {
        int maxSeatID = Utils.extractSeatIDs(lines).stream()
                .max(Integer::compareTo)
                .orElse(-1);

        System.out.println("Part 1: " + maxSeatID);
    }
}
