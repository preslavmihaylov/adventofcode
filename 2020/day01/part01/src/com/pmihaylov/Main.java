package com.pmihaylov;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Collections;
import java.util.HashSet;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import java.util.concurrent.atomic.AtomicInteger;

public class Main {
    public static void main(String[] args) throws InterruptedException {
        String[] lines = readInput();
        ConcurrentHashMap<Integer, Boolean> seenNums = new ConcurrentHashMap<>();
        ParallelTraverser<Integer> traverser = new ParallelTraverser<>();
        try {
            Optional<Integer> result = traverser.traverse(lines.length, (r) -> r != -1, (start, end) -> () -> {
                for (int i = start; i < end; i++) {
                    int firstNum = Integer.parseInt(lines[i]);
                    int target = 2020 - firstNum;

                    AtomicInteger r = new AtomicInteger(-1);
                    seenNums.compute(firstNum, (k, v) -> {
                        if (seenNums.containsKey(target)) {
                            System.out.printf("Finished calculating [%s;%s)\n", start, end);
                            r.set(target * firstNum);
                        }

                        return true;
                    });

                    if (r.get() != -1) {
                        return r.get();
                    }
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
