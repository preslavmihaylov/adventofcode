package com.pmihaylov;

public class Part01Solver {
    public static void solve(String[] lines) {
        System.out.println("Part 1: " + XMASCracker.findInvalidNumber(Utils.mapInput(lines))
                .orElseThrow(() -> new AssertionError("couldn't find invalid number in cipher text")));
    }
}
