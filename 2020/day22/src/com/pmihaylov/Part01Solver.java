package com.pmihaylov;

import com.pmihaylov.combat.Combat;
import com.pmihaylov.combat.StandardCombat;

public class Part01Solver {
    public static void solve(String[] input) {
        Combat game = StandardCombat.from(input);

        game.play();
        System.out.println("Part 1: " + game.winnerScore());
    }
}
