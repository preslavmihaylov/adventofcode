package com.pmihaylov.ruleengine;

import com.pmihaylov.ruleengine.rules.*;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class RuleFactory {
    public static Rule from(Map<String, Rule> rules, String encodedRule) {
        if (encodedRule.contains(" | ")) {
            List<Rule> subRules = toSubRules(rules, encodedRule.split(" \\| "));
            return new OrRule(subRules);
        } else if (encodedRule.contains(" ")) {
            List<Rule> subRules = toSubRules(rules, encodedRule.split(" "));
            return new AndRule(subRules);
        } else if (encodedRule.contains("\"")) {
            return new TerminalRule(encodedRule.replaceAll("[\" ]", ""));
        } else {
            return new ReferentialRule(encodedRule.trim(), rules);
        }
    }

    private static List<Rule> toSubRules(Map<String, Rule> rules, String[] ruleTokens) {
        return Arrays.stream(ruleTokens)
                .map(r -> RuleFactory.from(rules, r))
                .collect(Collectors.toList());
    }
}
