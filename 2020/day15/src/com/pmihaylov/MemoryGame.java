package com.pmihaylov;

import java.util.*;

public class MemoryGame {
    private final List<Integer> startingNums;

    public MemoryGame(List<Integer> startingNums) {
        this.startingNums = Collections.unmodifiableList(startingNums);
    }

    public int spokenNumberOnTurn(int finalTurn) {
        Map<Integer, List<Integer>> spokenNums = new HashMap<>();
        Integer lastSpoken = 0;
        for (int i = 1; i <= startingNums.size(); i++) {
            lastSpoken = startingNums.get(i-1);
            persistSpokenNumberTurn(spokenNums, lastSpoken, i);
        }

        for (int turn = startingNums.size()+1; turn <= finalTurn; turn++) {
            if (spokenNums.getOrDefault(lastSpoken, new ArrayList<>()).size() <= 1) {
                lastSpoken = 0;
            } else {
                List<Integer> prevTurns = spokenNums.get(lastSpoken);
                lastSpoken = prevTurns.get(prevTurns.size()-1) - prevTurns.get(prevTurns.size()-2);
            }

            persistSpokenNumberTurn(spokenNums, lastSpoken, turn);
        }

        return lastSpoken;
    }

    private void persistSpokenNumberTurn(Map<Integer, List<Integer>> spokenNums, int spokenNum, int turn) {
        spokenNums.putIfAbsent(spokenNum, new ArrayList<>());
        List<Integer> prevNums = spokenNums.get(spokenNum);
        if (prevNums.size() == 2) {
            prevNums.set(0, prevNums.get(1));
            prevNums.set(1, turn);
        } else {
            prevNums.add(turn);
        }
    }
}
