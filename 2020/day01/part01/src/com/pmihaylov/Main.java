package com.pmihaylov;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

public class Main {
    public static void main(String[] args) throws InterruptedException {
        String[] lines = readInput();
        Set<Integer> seenNums = ConcurrentHashMap.newKeySet();
        ParallelTraverser<Integer> traverser = new ParallelTraverser<>();
        try {
            Optional<Integer> result = traverser.traverse(lines.length, (r) -> r != -1, (start, end) -> () -> {
                for (int i = start; i < end; i++) {
                    int firstNum = Integer.parseInt(lines[i]);
                    int target = 2020 - firstNum;
                    if (seenNums.contains(target)) {
                        System.out.printf("Finished calculating [%s;%s)\n", start, end);
                        return target * firstNum;
                    }

                    seenNums.add(firstNum);
                }

                System.out.printf("Finished calculating [%s;%s)\n", start, end);
                return -1;
            });

            System.out.println(result.orElse(-1));
        } finally {
            traverser.shutdown();
        }
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
