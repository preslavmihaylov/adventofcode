package com.pmihaylov;

import sun.jvm.hotspot.utilities.AssertionFailure;

import java.util.Collections;
import java.util.HashMap;

public class Part01Solver {
    public static void solve(String[] lines) {
        String mask = String.join("", Collections.nCopies(36, "X"));
        HashMap<String, Long> memory = new HashMap<>();
        for (String line : lines) {
            Operation op = Operation.from(line);
            switch (op.code) {
                case "mask":
                    mask = op.args[0];
                    break;
                case "mem":
                    memory.put(op.args[0], getWithMask(Long.parseLong(op.args[1]), mask));
                    break;
                default:
                    throw new AssertionFailure("unknown operation found - " + op.code);
            }
        }

        System.out.println("Part 1: " + memory.values().stream().reduce(0L, Long::sum));
    }

    public static Long getWithMask(Long value, String mask) {
        String bits = Utils.padLeftZeros(Long.toBinaryString(value), 36);
        char[] res = new char[mask.length()];
        for (int i = 0; i < mask.length(); i++) {
            res[i] = bits.length() > i ? bits.charAt(i) : '0';
            if (mask.charAt(i) != 'X') {
                res[i] = mask.charAt(i);
            }
        }

        return Long.parseLong(String.valueOf(res), 2);
    }
}
