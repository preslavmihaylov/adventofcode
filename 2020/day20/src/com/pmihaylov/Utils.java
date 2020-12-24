package com.pmihaylov;

import java.util.List;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.stream.Collectors;

public class Utils {
    public static String[] readInput() {
        try {
            return new String(Files.readAllBytes(Paths.get("input.txt")), StandardCharsets.UTF_8)
                    .split("\n\n");
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    public static List<List<Character>> readSprite(String filename) {
        try {
            return Arrays.stream(new String(Files.readAllBytes(Paths.get(filename)), StandardCharsets.UTF_8)
                    .split("\n"))
                    .map(s -> s.chars().mapToObj(c -> (char)c).collect(Collectors.toList()))
                    .collect(Collectors.toList());
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    public static boolean spritesMatch(List<List<Character>> given, List<List<Character>> target) {
        for (int row = 0; row < target.size(); row++) {
            for (int col = 0; col < target.get(row).size(); col++) {
                Character c = target.get(row).get(col);
                if (c != ' ' && c != given.get(row).get(col)) {
                    return false;
                }
            }
        }

        return true;
    }
}


