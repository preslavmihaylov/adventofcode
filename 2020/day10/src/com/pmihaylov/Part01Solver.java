package com.pmihaylov;

import java.util.List;

public class Part01Solver {
    public static void solve(String[] lines) {
        List<Long> nums = Utils.mapInput(lines);
        nums.sort(Long::compareTo);

        List<Long> singleJolts = JoltCalculator.getSingleJoltDistributions(nums);
        long result = singleJolts.stream().reduce(0L, Long::sum) * singleJolts.size();
        System.out.println("Part 1: " + result);
    }
}
