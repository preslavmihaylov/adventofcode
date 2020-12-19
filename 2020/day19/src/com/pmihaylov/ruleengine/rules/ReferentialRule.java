package com.pmihaylov.ruleengine.rules;

import java.util.Collections;
import java.util.Map;
import java.util.Set;

public class ReferentialRule implements Rule {
    private final String referencedID;
    private final Map<String, Rule> allRules;

    public ReferentialRule(String referencedID, Map<String, Rule> allRules) {
        this.referencedID = referencedID;
        this.allRules = Collections.unmodifiableMap(allRules);
    }

    @Override
    public Set<String> matches(String input) {
        return allRules.getOrDefault(referencedID, NilRule.instance()).matches(input);
    }
}
