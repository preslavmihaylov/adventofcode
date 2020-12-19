package com.pmihaylov.ruleengine.rules;

import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class OrRule implements Rule {
    private final List<Rule> subRules;

    public OrRule(List<Rule> subRules) {
        this.subRules = Collections.unmodifiableList(subRules);
    }

    @Override
    public Set<String> matches(String input) {
        if (subRules.size() == 0) {
            throw new AssertionError("no sub-rules found in or rule");
        }

        Set<String> matches = new HashSet<>();
        for (Rule r : subRules) {
            matches.addAll(r.matches(input));
        }

        return matches;
    }
}
