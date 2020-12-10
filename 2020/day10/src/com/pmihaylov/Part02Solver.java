package com.pmihaylov;

import java.util.*;

public class Part02Solver {
    public static void solve(String[] lines) {
        List<Long> nums = Utils.mapInput(lines);
        nums.sort(Long::compareTo);

        // this algorithm won't work if there were jolt distributions with offset of 2 (e.g. 1 3 4 5),
        // but AOC's input doesn't contain such cases
        List<Long> singleJoltDistributions = JoltCalculator.getSingleJoltDistributions(nums);
        long allPossibleArrangements = singleJoltDistributions.stream()
                .parallel()
                .filter(jolt -> jolt > 0)
                .map(Part02Solver::possibleArrangements)
                .reduce(1L, Math::multiplyExact, Math::multiplyExact);
        System.out.println("Part 2: " + allPossibleArrangements);
    }

    // I came up with this formula after generating combinations in succession of 1, 2, 3, ..., n numbers
    // until I found a pattern I could encapsulate in the function f(n) = 2 * f(n-1) - f(n-3)
    //
    // This can also be optimized by adding a cache but it was fast enough without it so no need to overcomplicate...
    public static long possibleArrangements(long jolts) {
        if (jolts < 1) {
            return 0;
        } else if (jolts == 1) {
            return 1;
        }

        return 2 * possibleArrangements(jolts-1) - possibleArrangements(jolts-3);
    }
}
