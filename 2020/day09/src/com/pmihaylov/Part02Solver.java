package com.pmihaylov;

import sun.jvm.hotspot.utilities.AssertionFailure;

public class Part02Solver {
    public static void solve(String[] lines) {
        System.out.println("Part 2: " + XMASCracker.findEncryptionWeakness(Utils.mapInput(lines))
                .orElseThrow(() -> new AssertionFailure("couldn't find encryption weakness in ciphertext")));
    }
}
