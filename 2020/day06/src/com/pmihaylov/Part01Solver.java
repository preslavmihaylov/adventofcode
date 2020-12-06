package com.pmihaylov;

import java.util.Arrays;

public class Part01Solver {
    public static void solve(String[] lines) {
        long cnt = Arrays.stream(lines)
                .parallel()
                .map(Part01Solver::mapToDistinctAnswersCount)
                .reduce(0L, Long::sum, Long::sum);

        System.out.println("Part 1: " + cnt);
    }

    private static long mapToDistinctAnswersCount(String line) {
        return line.chars().filter(c -> c != '\n').distinct().count();
    }
}
