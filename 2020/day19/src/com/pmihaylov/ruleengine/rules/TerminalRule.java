package com.pmihaylov.ruleengine.rules;

import java.util.Collections;
import java.util.Set;

public class TerminalRule implements Rule {
    private final String term;

    public TerminalRule(String term) {
        this.term = term;
    }

    @Override
    public Set<String> matches(String input) {
        return input.startsWith(term) ? Collections.singleton(input.substring(0, term.length())) : Collections.emptySet();
    }
}
