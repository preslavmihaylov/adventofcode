package com.pmihaylov.ruleengine.rules;

import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

public class AndRule implements Rule {
    private final List<Rule> subRules;

    public AndRule(List<Rule> subRules) {
        this.subRules = Collections.unmodifiableList(subRules);
    }

    @Override
    public Set<String> matches(String input) {
        if (subRules.size() == 0) {
            throw new AssertionError("no sub-rules found in and rule");
        }

        Set<String> matches = subRules.get(0).matches(input);
        for (int i = 1; i < subRules.size(); i++) {
            Set<String> nextMatches = new HashSet<>();
            for (String match : matches) {
                nextMatches.addAll(
                        subRules.get(i).matches(input.substring(match.length()))
                                .stream()
                                .map(nextMatch -> match + nextMatch)
                                .collect(Collectors.toSet()));
            }

            matches = nextMatches;
        }

        return matches;
    }
}
