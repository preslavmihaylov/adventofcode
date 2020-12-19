package com.pmihaylov.ruleengine;

import com.pmihaylov.ruleengine.rules.Rule;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class RuleEngine {
    private final Map<String, Rule> rules;

    private RuleEngine(Map<String, Rule> rules) {
        this.rules = Collections.unmodifiableMap(rules);
    }

    public static RuleEngine from(String input) {
        Map<String, Rule> rules = new HashMap<>();
        String[] lines = input.split("\n");
        for (String line : lines) {
            String key = line.split(": ")[0];
            String encodedRule = line.split(": ")[1];

            rules.put(key, RuleFactory.from(rules, encodedRule));
        }

        return new RuleEngine(rules);
    }

    public boolean matches(String ruleID, String input) {
        if (!rules.containsKey(ruleID)) {
            return false;
        }

        return rules.get(ruleID).matches(input).contains(input);
    }
}
