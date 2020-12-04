package com.pmihaylov;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.Map;
import java.util.stream.Collectors;

public class Utils {
    public static String[] readInput() {
        try {
            return new String(Files.readAllBytes(Paths.get("input.txt")), StandardCharsets.UTF_8)
                    .split("\n\n");
        } catch (IOException e) {
            e.printStackTrace();
            return new String[0];
        }
    }

    public static Map<String, String> extractKeyValuePairs(String input) {
        return Arrays.stream(input.split("[ \n]"))
                .collect(Collectors.toMap(t -> t.split(":")[0], t -> t.split(":")[1]));
    }
}
