package com.pmihaylov;

import java.util.Arrays;

public class Part01Solver {
    public static void solve(String[] lines) {
        ExpressionEvaluator evaluator = new ExpressionEvaluator((op) -> true);
        long sum = Arrays.stream(lines).map(evaluator::evaluate).reduce(0L, Long::sum);
        System.out.println("Part 1: " + sum);
    }
}
