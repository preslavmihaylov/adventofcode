package com.pmihaylov;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;
import java.util.regex.Matcher;
import java.util.stream.Collectors;
import java.util.regex.Pattern;

public class Utils {
    public static String[] readInput() {
        try {
            return new String(Files.readAllBytes(Paths.get("input.txt")), StandardCharsets.UTF_8)
                    .split("\n");
        } catch (IOException e) {
            e.printStackTrace();
            return new String[0];
        }
    }

    public static List<String> allIngredients(String[] lines) {
        return Arrays.stream(lines).flatMap(l -> ingredientsFor(l).stream()).collect(Collectors.toList());
    }

    public static Map<String, Set<String>> allAlergensByFood(String[] lines) {
        Map<String, Set<String>> allergensByIngredients = new HashMap<>();
        for (String line : lines) {
            List<String> ingredients = ingredientsFor(line);
            Set<String> allergens = allergensFor(line);

            for (String allergen : allergens) {
                allergensByIngredients.putIfAbsent(allergen, new HashSet<>(ingredients));
                allergensByIngredients.get(allergen).retainAll(ingredients);
            }
        }

        return deduplicateAllergens(allergensByIngredients);
    }

    public static Map<String, Set<String>> deduplicateAllergens(Map<String, Set<String>> allergensByIngredients) {
        Map<String, Set<String>> result = new HashMap<>(allergensByIngredients);
        while (allergensByIngredients.entrySet().stream().anyMatch(e -> e.getValue().size() > 1)) {
            for (Map.Entry<String, Set<String>> allergen1 : allergensByIngredients.entrySet()) {
                for (Map.Entry<String, Set<String>> allergen2 : allergensByIngredients.entrySet()) {
                    if (allergen1.getKey().equals(allergen2.getKey())) {
                        continue;
                    }

                    if (allergen1.getValue().size() == 1) {
                        result.get(allergen2.getKey()).remove(allergen1.getValue().stream().findAny().orElse(""));
                    }
                }
            }
        }

        return result;
    }

    public static List<String> ingredientsFor(String line) {
        return Arrays.stream(line.substring(0, line.indexOf('(')).split(" ")).collect(Collectors.toList());
    }

    public static Set<String> allergensFor(String line) {
        Pattern p = Pattern.compile("\\(contains ([a-zA-Z, ]+)\\)");
        Matcher matcher = p.matcher(line);
        if (!matcher.find()) {
            throw new AssertionError("didn't find any allergens in line: " + line);
        }

        return Arrays.stream(matcher.group(1).split(", ")).collect(Collectors.toSet());
    }
}

