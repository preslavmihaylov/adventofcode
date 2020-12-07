package com.pmihaylov;

import sun.jvm.hotspot.utilities.AssertionFailure;

import java.util.Arrays;
import java.util.Collections;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class RulesGraph {
    private static final Rule EMPTY_BAG = new Rule("", Collections.emptyMap());
    private final Map<String, Rule> rules;

    private RulesGraph(Map<String, Rule> rules) {
        this.rules = Collections.unmodifiableMap(rules);
    }

    public static RulesGraph from(String[] lines) {
        Map<String, Rule> rules = Arrays.stream(lines)
                .parallel()
                .map(Rule::from)
                .collect(Collectors.toMap(r -> r.parentColor, r -> r));
        return new RulesGraph(rules);
    }

    public long totalBagsContaining(String target) {
        return rules.values().stream()
                .parallel()
                .filter(r -> ruleTransitivelyContains(r, target))
                .count();
    }

    public long totalCapacityOf(String target) {
        return innerBagsCountOf(rules.getOrDefault(target, EMPTY_BAG));
    }

    private boolean ruleTransitivelyContains(Rule rule, String targetColor) {
        return rule.containedBags.keySet().stream()
                .anyMatch(c -> c.equals(targetColor) ||
                        ruleTransitivelyContains(rules.getOrDefault(c, EMPTY_BAG), targetColor));
    }

    private long innerBagsCountOf(Rule rule) {
        return directBagsCountOf(rule) +
                rule.containedBags.entrySet().stream()
                .parallel()
                .map(e -> e.getValue() * innerBagsCountOf(rules.getOrDefault(e.getKey(), EMPTY_BAG)))
                .reduce(0L, Long::sum, Long::sum);
    }

    private long directBagsCountOf(Rule rule) {
        return rule.containedBags.values().stream()
                .parallel()
                .reduce(0L, Long::sum, Long::sum);
    }

    private static class Rule {
        private static final Pattern PATTERN = Pattern.compile("([a-zA-Z]+ [a-zA-Z]+) bags contain (.*)\\.");

        public final String parentColor;
        public final Map<String, Long> containedBags;

        private Rule(String parentColor, Map<String, Long> containedBags) {
            this.parentColor = parentColor;
            this.containedBags = Collections.unmodifiableMap(containedBags);
        }

        public static Rule from(String line) {
            Matcher m = PATTERN.matcher(line);
            if (!m.find()) {
                throw new AssertionFailure("Some line doesn't match the regex pattern");
            }

            String parentColor = m.group(1);
            String childRules = m.group(2);
            return new Rule(parentColor, extractChildRulesFrom(childRules));
        }

        private static Map<String, Long> extractChildRulesFrom(String childRules) {
            return Arrays.stream(childRules.split(" bag[s]?(, )?"))
                    .filter(bag -> !bag.equals("no other"))
                    .map(bag -> new Object() {
                        final String color = bag.substring(2);
                        final Long count = Long.parseLong(bag.substring(0, 1));
                    }).collect(Collectors.toMap(o -> o.color, o -> o.count));
        }
    }
}
