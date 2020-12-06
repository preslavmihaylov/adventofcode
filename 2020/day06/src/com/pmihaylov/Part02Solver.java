package com.pmihaylov;

import com.sun.tools.javac.util.StringUtils;

import java.util.Arrays;
import java.util.stream.Collectors;

public class Part02Solver {
    public static void solve(String[] lines) {
        long cnt = Arrays.stream(lines)
                .parallel()
                .map(Part02Solver::mapToIntersectingAnswers)
                .map(String::length)
                .reduce(0, Integer::sum, Integer::sum);

        System.out.println("Part 2: " + cnt);
    }

    private static String mapToIntersectingAnswers(String line) {
        return Arrays.stream(line.split("\n"))
                        .reduce(Part02Solver::intersectingCharacters)
                        .orElse("");
    }

    private static String intersectingCharacters(String first, String second) {
        return first.chars()
                .filter(c -> second.indexOf(c) != -1)
                .mapToObj(c -> String.valueOf((char)c))
                .collect(Collectors.joining());
    }
}
