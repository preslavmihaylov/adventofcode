package com.pmihaylov;

public class Part01Solver {
    public static void solve(String[] lines) {
        CrabCups cups = CrabCups.from(lines[0], lines[0].length());

        long start = Long.parseLong(lines[0].split("")[0]);
        cups.makeMoves(start, 100);

        System.out.println("Part 1: " + cups);
    }
}
