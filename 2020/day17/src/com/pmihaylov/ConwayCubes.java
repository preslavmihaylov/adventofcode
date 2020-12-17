package com.pmihaylov;

import sun.jvm.hotspot.utilities.AssertionFailure;

import java.util.*;
import java.util.function.Consumer;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class ConwayCubes {
    private Map<Coordinate, Character> cubes;
    private final int dimensionsCount;

    private ConwayCubes(Map<Coordinate, Character> cubes, int dimensionsCount) {
        this.cubes = cubes;
        this.dimensionsCount = dimensionsCount;
    }

    public static ConwayCubes from(String[] lines, int dimensionsCount) {
        Map<Coordinate, Character> cubes = new HashMap<>();
        for (int y = 0; y < lines.length; y++) {
            for (int x = 0; x < lines[y].length(); x++) {
                List<Integer> dimensions = new ArrayList<>(Collections.nCopies(dimensionsCount, 0));
                dimensions.set(0, x);
                dimensions.set(1, y);

                cubes.put(new Coordinate(dimensions), lines[y].charAt(x));
            }
        }

        return new ConwayCubes(cubes, dimensionsCount);
    }

    public void transitionToNextState(int times) {
        for (int i = 0; i < times; i++) {
            cubes = nextState();
        }
    }

    public int activeCubesCount() {
        return cubes.values().stream()
                .map(ch -> ch == '#' ? 1 : 0)
                .reduce(0, Integer::sum);
    }

    private Map<Coordinate, Character> nextState() {
        Map<Coordinate, Character> result = new HashMap<>();

        Coordinate botLeft = botLeftCoordinate();
        botLeft = new Coordinate(botLeft.dimensions.stream().map(d -> d-1).collect(Collectors.toList()));

        Coordinate topRight = topRightCoordinate();
        topRight = new Coordinate(topRight.dimensions.stream().map(d -> d+1).collect(Collectors.toList()));

        iterateCoordinates(botLeft, topRight, (c) -> {
            Coordinate coord = new Coordinate(c.dimensions);
            result.put(coord, nextCubeState(coord));
        });

        return result;
    }

    private Character nextCubeState(Coordinate coord) {
        List<Coordinate> adjacentCoords = adjacentCoordinates(coord);
        int adjacentActiveCubes = adjacentCoords.stream()
                .map(c -> cubes.getOrDefault(c, '.') == '#' ? 1 : 0)
                .reduce(0, Integer::sum);

        if (cubes.getOrDefault(coord, '.') == '#') {
            return adjacentActiveCubes == 2 || adjacentActiveCubes == 3 ? '#' : '.';
        } else if (cubes.getOrDefault(coord, '.') == '.') {
            return adjacentActiveCubes == 3 ? '#' : '.';
        } else {
            throw new AssertionFailure("unknown cube state: " + cubes.getOrDefault(coord, '.'));
        }
    }

    private List<Coordinate> adjacentCoordinates(Coordinate coord) {
        Coordinate start = new Coordinate(Collections.nCopies(dimensionsCount, -1));
        Coordinate finish = new Coordinate(Collections.nCopies(dimensionsCount, 1));
        List<Coordinate> result = new ArrayList<>();
        iterateCoordinates(start, finish, (c) -> {
            List<Integer> dimensions = IntStream.range(0, c.dimensions.size())
                    .mapToObj(i -> coord.dimensions.get(i) + c.dimensions.get(i))
                    .collect(Collectors.toList());
            Coordinate adjacent = new Coordinate(dimensions);
            if (coord.equals(adjacent)) {
                return;
            }

            result.add(adjacent);
        });

        return result;
    }

    private void iterateCoordinates(Coordinate start, Coordinate finish, Consumer<Coordinate> func) {
        iterateCoordinates(start, finish, new ArrayList<>(), 0, func);
    }

    private void iterateCoordinates(Coordinate start, Coordinate finish, List<Integer> dimensions, int dim, Consumer<Coordinate> func) {
        if (dim == start.dimensions.size()) {
            func.accept(new Coordinate(dimensions));
            return;
        }

        for (int x = start.dimensions.get(dim); x <= finish.dimensions.get(dim); x++) {
            List<Integer> nextDimensions = new ArrayList<>(dimensions);
            nextDimensions.add(x);

            iterateCoordinates(start, finish, nextDimensions, dim+1, func);
        }
    }

    private Coordinate botLeftCoordinate() {
        Coordinate first = cubes.keySet().stream().findFirst().orElseThrow(() -> new AssertionFailure("no coordinates found"));
        List<Integer> dimensions = first.dimensions.stream().map(d -> Integer.MAX_VALUE).collect(Collectors.toList());
        for (Coordinate c : cubes.keySet()) {
            for (int i = 0; i < dimensions.size(); i++) {
                dimensions.set(i, Math.min(dimensions.get(i), c.dimensions.get(i)));
            }
        }

        return new Coordinate(dimensions);
    }

    private Coordinate topRightCoordinate() {
        Coordinate first = cubes.keySet().stream().findFirst().orElseThrow(() -> new AssertionFailure("no coordinates found"));
        List<Integer> dimensions = first.dimensions.stream().map(d -> Integer.MIN_VALUE).collect(Collectors.toList());
        for (Coordinate c : cubes.keySet()) {
            for (int i = 0; i < dimensions.size(); i++) {
                dimensions.set(i, Math.max(dimensions.get(i), c.dimensions.get(i)));
            }
        }

        return new Coordinate(dimensions);
    }

    private static class Coordinate {
        public final List<Integer> dimensions;

        public Coordinate(List<Integer> dimensions) {
            this.dimensions = Collections.unmodifiableList(dimensions);
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            Coordinate that = (Coordinate) o;
            return Arrays.equals(dimensions.toArray(), that.dimensions.toArray());
        }

        @Override
        public int hashCode() {
            return Arrays.hashCode(dimensions.toArray());
        }
    }
}
