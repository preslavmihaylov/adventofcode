package com.pmihaylov;

import java.util.*;
import java.util.stream.Collectors;

public class Part02Solver {
    public static void solve(String[] lines) {
        List<Integer> nums = Arrays.stream(lines).map(Integer::parseInt).collect(Collectors.toList());
        System.out.println("Part 2: " + new MemoryGame(nums).spokenNumberOnTurn(30000000));
    }
}
