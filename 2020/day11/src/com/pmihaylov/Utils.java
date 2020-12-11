package com.pmihaylov;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;

public class Utils {
    public static String[][] readInput() {
        try {
            return Arrays.stream(
                    new String(Files.readAllBytes(Paths.get("input.txt")), StandardCharsets.UTF_8).split("\n")
            ).map(line -> line.split("")).toArray(String[][]::new);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
