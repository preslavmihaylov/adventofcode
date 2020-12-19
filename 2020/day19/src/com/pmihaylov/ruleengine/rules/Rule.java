package com.pmihaylov.ruleengine.rules;

import java.util.Set;

public interface Rule {
    Set<String> matches(String input);
}
