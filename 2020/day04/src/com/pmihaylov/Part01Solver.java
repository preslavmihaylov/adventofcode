package com.pmihaylov;

import java.util.Arrays;

public class Part01Solver {
    public static void solve(String[] lines) {
        long validPassports = Arrays.stream(lines)
                .parallel()
                .map(Utils::extractKeyValuePairs)
                .filter(Validator::hasAllRequiredFields)
                .count();

        System.out.println("Part 1: " + validPassports);
    }
}
