package com.pmihaylov;

import java.util.*;

public class Part02Solver {
    public static void solve(String[] lines) {
        long validPassports = Arrays.stream(lines)
                .parallel()
                .map(Utils::extractKeyValuePairs)
                .filter(Validator::hasAllRequiredFields)
                .filter(Validator::allPairsAreValid)
                .count();

        System.out.println("Part 2: " + validPassports);
    }
}
