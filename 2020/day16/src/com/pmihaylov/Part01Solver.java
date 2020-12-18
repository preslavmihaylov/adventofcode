package com.pmihaylov;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class Part01Solver {
    public static void solve(Configuration cfg) {
        int errorRate = totalErrorRate(cfg);
        System.out.println("Part 1: " + errorRate);
    }

    private static int totalErrorRate(Configuration cfg) {
        return cfg.otherTickets.parallelStream()
                .map(t -> invalidValuesOf(cfg, t).stream().reduce(0, Integer::sum))
                .reduce(0, Integer::sum, Integer::sum);
    }

    private static List<Integer> invalidValuesOf(Configuration cfg, Ticket t) {
        return t.values.stream().filter(v -> !anyMatchingConstraint(cfg.constraints, v)).collect(Collectors.toList());
    }

    private static boolean anyMatchingConstraint(Map<String, TicketValueConstraint> constraints, int value) {
        return constraints.values().stream().anyMatch(c -> c.matches(value));
    }
}
