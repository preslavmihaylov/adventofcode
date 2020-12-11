package com.pmihaylov;

public class Main {

    public static void main(String[] args) {
        String[][] input = Utils.readInput();
        Part01Solver.solve(input);
        Part02Solver.solve(input);
    }
}
