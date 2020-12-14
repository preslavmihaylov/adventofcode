package com.pmihaylov;

import sun.jvm.hotspot.utilities.AssertionFailure;

import java.util.*;

public class Part02Solver {
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
                    List<String> addresses = getAddressesFrom(mask, op.args[0]);
                    for (String address : addresses) {
                        memory.put(address, Long.parseLong(op.args[1]));
                    }
                    break;
                default:
                    throw new AssertionFailure("unknown operation found - " + op.code);
            }
        }

        System.out.println("Part 1: " + memory.values().stream().reduce(0L, Long::sum));
    }

    public static List<String> getAddressesFrom(String mask, String address) {
        return getAddressesFromBinaryAddress(mask, Utils.padLeftZeros(Long.toBinaryString(Long.parseLong(address)), 36));
    }


    public static List<String> getAddressesFromBinaryAddress(String mask, String address) {
        if (mask.length() == 0) {
            return Collections.singletonList("");
        }

        List<String> addresses = getAddressesFromBinaryAddress(mask.substring(1), address.substring(1));
        if (mask.charAt(0) == '1') {
            return prependCharsTo(Collections.singletonList('1'), addresses);
        } else if (mask.charAt(0) == '0') {
            return prependCharsTo(Collections.singletonList(address.charAt(0)), addresses);
        } else {
            return prependCharsTo(Arrays.asList('1', '0'), addresses);
        }
    }

    private static List<String> prependCharsTo(List<Character> chars, List<String> addresses) {
        List<String> res = new ArrayList<>();
        for (Character ch : chars) {
            for (String addr : addresses) {
                res.add(String.format("%c%s", ch, addr));
            }
        }

        return res;
    }
}
