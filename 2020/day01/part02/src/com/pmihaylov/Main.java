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
        final String[] lines = readInput();
        Set<Integer> seenNums = ConcurrentHashMap.newKeySet();
        ParallelTraverser<Integer> traverser = new ParallelTraverser<>();
        Optional<Integer> result;
        try {
            result = traverser.traverse(lines.length, (r) -> r != -1, (start, end) -> () -> {
                for (int i = start; i < end; i++) {
                    for (int j = 0; j < lines.length; j++) {
                        System.out.printf("Running [%s;%s)...\n", start, end);
                        if (Thread.currentThread().isInterrupted()) {
                            System.out.printf("Interrupted thread calculating [%s;%s). Reached %d-%d...\n", start, end, i, j);
                            return -1;
                        }

                        int firstNum = Integer.parseInt(lines[i]);
                        int secondNum = Integer.parseInt(lines[j]);

                        int target = 2020 - secondNum - firstNum;
                        if (seenNums.contains(target)) {
                            System.out.printf("Finished calculating [%s;%s)\n", start, end);
                            return target * secondNum * firstNum;
                        }

                        seenNums.add(secondNum);
                    }
                }

                System.out.printf("Finished calculating [%s;%s)\n", start, end);
                return -1;
            });
        } finally {
            traverser.shutdown();
        }

        System.out.println(result.orElse(-1));
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

