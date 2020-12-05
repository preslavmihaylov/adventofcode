package com.pmihaylov;

import sun.jvm.hotspot.utilities.AssertionFailure;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;

public class Utils {
    public static String[] readInput() {
        try {
            return new String(Files.readAllBytes(Paths.get("input.txt")), StandardCharsets.UTF_8)
                    .split("\n");
        } catch (IOException e) {
            e.printStackTrace();
            return new String[0];
        }
    }

    public static Set<Integer> extractSeatIDs(String[] lines) {
        return Arrays.stream(lines)
            .parallel()
            .map(l -> new Object() {
                final String rowsCode = l.substring(0, 7);
                final String colsCode = l.substring(7);
            }).map(o -> new Object() {
                final int row = Utils.decodeRow(o.rowsCode);
                final int col = Utils.decodeCol(o.colsCode);
            }).map(o -> o.row * 8 + o.col)
            .collect(Collectors.toSet());
    }

    public static int decodeRow(String code) {
        return decode(code, 'F', 'B', 0, 128);
    }

    public static int decodeCol(String code) {
        return decode(code, 'L', 'R', 0, 8);
    }

    private static int decode(String code, Character lowerCode, Character upperCode, int start, int end) {
        if (code.length() == 0) {
            return start;
        }

        int mid = (start + end) / 2;
        if (code.charAt(0) == lowerCode) {
            return decode(code.substring(1), lowerCode, upperCode, start, mid);
        } else if (code.charAt(0) == upperCode) {
            return decode(code.substring(1), lowerCode, upperCode, mid, end);
        }

        throw new AssertionFailure("Invalid state");
    }
}
