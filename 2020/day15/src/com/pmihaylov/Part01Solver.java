package com.pmihaylov;

import java.util.*;
import java.util.stream.Collectors;

public class Part01Solver {
    public static void solve(String[] lines) {
        List<Integer> nums = Arrays.stream(lines).map(Integer::parseInt).collect(Collectors.toList());
        System.out.println("Part 1: " + new MemoryGame(nums).spokenNumberOnTurn(2020));
    }
}
