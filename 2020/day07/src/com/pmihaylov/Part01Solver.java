package com.pmihaylov;

public class Part01Solver {
    public static void solve(String[] lines) {
        RulesGraph graph = RulesGraph.from(lines);
        System.out.println("Part 1: " + graph.totalBagsContaining("shiny gold"));
    }
}
