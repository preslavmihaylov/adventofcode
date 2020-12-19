package com.pmihaylov;

import com.pmihaylov.ruleengine.RuleEngine;

import java.util.Arrays;

public class Part02Solver {
    public static void solve(String[] input) {
        RuleEngine engine = RuleEngine.from(input[0]);
        int cnt = Arrays.stream(input[1].split("\n"))
                .parallel()
                .map(line -> engine.matches("0", line) ? 1 : 0)
                .reduce(0, Integer::sum, Integer::sum);
        System.out.println("Part 2: " + cnt);
    }
}
