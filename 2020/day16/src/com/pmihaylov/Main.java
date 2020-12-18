package com.pmihaylov;

public class Main {
    public static void main(String[] args) {
	Configuration cfg = Configuration.from(Utils.readInput());
	Part01Solver.solve(cfg);
	Part02Solver.solve(cfg);
    }
}
