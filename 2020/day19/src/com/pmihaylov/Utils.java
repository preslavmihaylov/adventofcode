package com.pmihaylov;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

public class Utils {
    public static String[] readPart01Input() {
        return readInput("input01.txt");
    }

    public static String[] readPart02Input() {
        return readInput("input02.txt");
    }

    private static String[] readInput(String filename) {
        try {
            return new String(Files.readAllBytes(Paths.get(filename)), StandardCharsets.UTF_8)
                    .split("\n\n");
        } catch (IOException e) {
            e.printStackTrace();
            return new String[0];
        }
    }
}

