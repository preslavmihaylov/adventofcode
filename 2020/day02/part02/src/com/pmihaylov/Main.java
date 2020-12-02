package com.pmihaylov;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;

public class Main {
    public static void main(String[] args) {
        String[] passwords = readInput();

        long cnt = Arrays.stream(passwords)
            .parallel()
            .map(pwd -> {
                String[] tokens = pwd.split(" ");
                return new Object(){
                    final String validity = tokens[0];
                    final char validChar = tokens[1].charAt(0);
                    final String givenPwd = tokens[2];
                    final int minValid = Integer.parseInt(validity.split("-")[0]) - 1;
                    final int maxValid = Integer.parseInt(validity.split("-")[1]) - 1;
                };
            })
            .filter(o -> o.givenPwd.charAt(o.minValid) == o.validChar ^ o.givenPwd.charAt(o.maxValid) == o.validChar)
            .count();

        System.out.println(cnt);
    }

    private static String[] readInput() {
        try {
            return new String(Files.readAllBytes(Paths.get("input.txt")), StandardCharsets.UTF_8)
                    .split("\n");
        } catch (IOException e) {
            e.printStackTrace();
            return new String[0];
        }
    }
}
