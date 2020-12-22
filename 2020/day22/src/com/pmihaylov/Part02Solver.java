package com.pmihaylov;

import com.pmihaylov.combat.Combat;
import com.pmihaylov.combat.RecursiveCombat;

public class Part02Solver {
    public static void solve(String[] input) {
        Combat game = RecursiveCombat.from(input);

        game.play();
        System.out.println("Part 2: " + game.winnerScore());
    }
}
