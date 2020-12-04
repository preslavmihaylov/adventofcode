package com.pmihaylov;

import java.util.*;
import java.util.function.Predicate;

public class Validator {
    private static final List<String> requiredFields = Collections.unmodifiableList(Arrays.asList("byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"));
    private static final Map<String, Predicate<String>> validators = Collections.unmodifiableMap(new HashMap<String, Predicate<String>>() {{
        put("byr", (v) -> {
            int r = Integer.parseInt(v);
            return r >= 1920 && r <= 2002;
        });

        put("iyr", (v) -> {
            int r = Integer.parseInt(v);
            return r >= 2010 && r <= 2020;
        });

        put("eyr", (v) -> {
            int r = Integer.parseInt(v);
            return r >= 2020 && r <= 2030;
        });

        put("hgt", (v) -> {
            int r = Integer.parseInt(v.substring(0, v.length()-2));
            String measure = v.substring(v.length() - 2);
            if (measure.equals("cm")) {
                return r >= 150 && r <= 193;
            } else if (measure.equals("in")) {
                return r >= 59 && r <= 76;
            } else {
                return false;
            }
        });

        put("hcl", (v) -> v.matches("#[0-9a-f]{6}"));
        put("ecl", (v) -> Arrays.asList("amb", "blu", "brn", "gry", "grn", "hzl", "oth").contains(v));
        put("pid", (v) -> v.length() == 9 && v.matches("[0-9]+"));
    }});

    public static boolean hasAllRequiredFields(Map<String, String> pairs) {
        return pairs.keySet().containsAll(requiredFields);
    }

    public static boolean allPairsAreValid(Map<String, String> pairs) {
        return pairs.entrySet().stream().allMatch(e -> {
            try {
                return validators.getOrDefault(e.getKey(), (v) -> true).test(e.getValue());
            } catch (Exception ignored) {
                return false;
            }
        });
    }
}
