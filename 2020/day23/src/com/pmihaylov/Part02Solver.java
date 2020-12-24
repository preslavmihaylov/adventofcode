package com.pmihaylov;

public class Part02Solver {
    public static void solve(String[] lines) {
        CrabCups cups = CrabCups.from(lines[0], 1000000);

        long start = Long.parseLong(lines[0].split("")[0]);
        cups.makeMoves(start, 10000000);

        Long first = cups.getNext(1L);
        Long second = cups.getNext(first);
        System.out.println("Part 2: " + (first * second));
    }
}
