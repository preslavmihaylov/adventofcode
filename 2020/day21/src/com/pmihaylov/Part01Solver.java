package com.pmihaylov;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

public class Part01Solver {
    public static void solve(String[] lines) {
        List<String> allIngredients = Utils.allIngredients(lines);
        Map<String, Set<String>> allergensByIngredients = Utils.allAlergensByFood(lines);

        List<String> allergenFreeIngredients = allIngredients.stream()
                .filter(ingredient -> allergensByIngredients.entrySet().stream().noneMatch(e -> e.getValue().contains(ingredient)))
                .collect(Collectors.toList());

        System.out.println("Part 1: " + allergenFreeIngredients.size());
    }
}
