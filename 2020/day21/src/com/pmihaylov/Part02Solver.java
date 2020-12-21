package com.pmihaylov;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

public class Part02Solver {
    public static void solve(String[] lines) {
        Map<String, Set<String>> allergensByIngredients = Utils.allAlergensByFood(lines);
        List<String> dangerousIngredients = allergensByIngredients.entrySet().stream()
                .sorted(Map.Entry.comparingByKey())
                .map(e -> e.getValue().stream().findAny().orElse(""))
                .collect(Collectors.toList());

        System.out.println("Part 2: " + String.join(",", dangerousIngredients));
    }
}
