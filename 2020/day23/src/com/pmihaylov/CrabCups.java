package com.pmihaylov;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class CrabCups {
    private final Map<Long, Long> linkedCups;

    private CrabCups(Map<Long, Long> linkedCups) {
        this.linkedCups = linkedCups;
    }

    public static CrabCups from(String input, int size) {
        List<Long> inputCups = input.chars().map(c -> c - '0').boxed().map(i -> (long) i).collect(Collectors.toList());

        Map<Long, Long> linkedCups = new HashMap<>();
        for (int i = 0; i < inputCups.size()-1; i++) {
            linkedCups.put(inputCups.get(i), inputCups.get(i+1));
        }

        linkedCups.put(inputCups.get(inputCups.size()-1),
                inputCups.size() < size ? (long)inputCups.size()+1 : inputCups.get(0));

        for (int i = inputCups.size()+1; i <= size; i++) {
            linkedCups.put((long)i, i+1 <= size ? (long)i+1 : inputCups.get(0));
        }

        return new CrabCups(linkedCups);
    }

    public Long getNext(Long after) {
        return linkedCups.get(after);
    }

    public void makeMoves(long start, int movesCnt) {
        Long curr = start;
        for (int i = 0; i < movesCnt; i++) {
            List<Long> nextThree = removeNextThree(curr);

            Long dest = destinationLabel(curr-1);
            addAll(dest, nextThree);
            curr = linkedCups.get(curr);
        }
    }

    private List<Long> removeNextThree(Long current) {
        List<Long> result = new ArrayList<>();
        Long next = current;
        for (int i = 0; i < 3; i++) {
            result.add(linkedCups.get(next));
            next = linkedCups.get(next);
        }

        linkedCups.put(current, linkedCups.get(next));
        for (Long toRemove : result) {
            linkedCups.remove(toRemove);
        }

        return result;
    }

    private void addAll(Long dest, List<Long> elements) {
        Long finalCup = linkedCups.get(dest);
        for (Long elem : elements) {
            linkedCups.put(dest, elem);
            dest = elem;
        }

        linkedCups.put(dest, finalCup);
    }

    private long destinationLabel(long initial) {
        long dest = initial;
        while (dest > 0) {
            if (linkedCups.containsKey(dest)) {
                break;
            }

            dest--;
        }

        return dest > 0 ? dest : linkedCups.keySet().stream().max(Long::compareTo).orElse(0L);
    }

    @Override
    public String toString() {
        StringBuilder result = new StringBuilder();
        Long curr = linkedCups.get(1L);
        for (int i = 0; i < linkedCups.size()-1; i++) {
            result.append(curr);
            curr = linkedCups.get(curr);
        }

        return result.toString();
    }
}
