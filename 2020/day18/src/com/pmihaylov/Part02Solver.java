package com.pmihaylov;

import java.util.Arrays;

public class Part02Solver {
    public static void solve(String[] lines) {
        ExpressionEvaluator evaluator = new ExpressionEvaluator((op) -> op == Token.Type.ADDITION);
        long sum = Arrays.stream(lines).map(evaluator::evaluate).reduce(0L, Long::sum);
        System.out.println("Part 2: " + sum);
    }
}
