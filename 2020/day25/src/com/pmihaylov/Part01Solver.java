package com.pmihaylov;

public class Part01Solver {
    public static void solve(String[] input) {
        long publicKey1 = Long.parseLong(input[0]);
        long publicKey2 = Long.parseLong(input[1]);
        long loopSize1 = crackLoopSize(publicKey1);

        System.out.println(transform(publicKey2, loopSize1));
    }

    private static long crackLoopSize(long publicKey) {
        long result = 1;
        long cnt = 0;
        while (result != publicKey) {
            result *= 7;
            result = result % 20201227;
            cnt++;
        }

        return cnt;
    }

    private static long transform(long subjectNumber, long loopSize) {
        long result = 1;
        for (int i = 0; i < loopSize; i++) {
            result *= subjectNumber;
            result = result % 20201227;
        }

        return result;
    }
}
