package com.pmihaylov;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

public class Main {

    public static void main(String[] args) throws InterruptedException {
        Labyrinth labyrinth = new Labyrinth(readInput());
        List<Velocity> velocities = Arrays.asList(
                new Velocity(1, 1),
                new Velocity(1, 3),
                new Velocity(1, 5),
                new Velocity(1, 7),
                new Velocity(2, 1)
        );

        ExecutorService exec = Executors.newCachedThreadPool();
        CountDownLatch latch = new CountDownLatch(velocities.size());
        
        AtomicLong result = new AtomicLong(1);
        for (Velocity vel : velocities) {
            exec.execute(() -> {
                int row = vel.row;
                int col = vel.col;

                int treesCnt = 0;
                while (labyrinth.inBounds(row, col)) {
                    treesCnt += labyrinth.posAt(row, col) == '#' ? 1 : 0;
                    row += vel.row;
                    col += vel.col;
                }

                final int tc = treesCnt;
                result.updateAndGet(r -> r * tc);
                latch.countDown();
            });
        }

        latch.await();
        exec.shutdown();
        System.out.println(result);
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

    static class Velocity {
        public final int row, col;
        public Velocity(int row, int col) {
            this.row = row;
            this.col = col;
        }
    }

    static class Labyrinth {
        private final List<String> coords;

        public Labyrinth(String[] coords) {
            this.coords = Arrays.stream(coords)
                    .map(String::trim)
                    .collect(Collectors.toCollection(CopyOnWriteArrayList::new));
        }

        public char posAt(int row, int col) {
            return coords.get(row).charAt(col % coords.get(row).length());
        }

        public boolean inBounds(int row, int col) {
            return row < coords.size();
        }
    }
}
