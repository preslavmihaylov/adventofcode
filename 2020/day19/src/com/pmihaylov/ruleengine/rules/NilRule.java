package com.pmihaylov.ruleengine.rules;

import java.util.Collections;
import java.util.Set;

public class NilRule implements Rule {
    private static final NilRule rule = new NilRule();
    private NilRule() {}

    public static NilRule instance() {
        return rule;
    }

    @Override
    public Set<String> matches(String input) {
        return Collections.emptySet();
    }
}
