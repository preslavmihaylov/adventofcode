package com.pmihaylov;

public class Part02Solver {
    public static void solve(String[] lines) {
        RulesGraph graph = RulesGraph.from(lines);
        System.out.println("Part 2: " + graph.totalCapacityOf("shiny gold"));
    }
}
