package com.pmihaylov;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class Operation {
    public final String code;
    public final String[] args;

    private Operation(String code, String[] args) {
        this.code = code;
        this.args = args;
    }

    public static Operation from(String line) {
        List<String> tokens = Arrays.stream(line.split("( = |\\[|\\])"))
                .filter(s -> !s.isEmpty())
                .collect(Collectors.toList());
        return new Operation(tokens.get(0), tokens.subList(1, tokens.size()).toArray(new String[0]));
    }
}
