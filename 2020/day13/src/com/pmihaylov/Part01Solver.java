package com.pmihaylov;

import sun.jvm.hotspot.utilities.AssertionFailure;

import java.util.Arrays;
import java.util.Comparator;

public class Part01Solver {
    public static void solve(String[] lines) {
        long minTimestamp = Long.parseLong(lines[0]);
        BusSchedule optimalSchedule = Arrays.stream(lines[1].split(","))
                .filter(l -> !l.equals("x"))
                .map(BusSchedule::from)
                .min(Comparator.comparingLong(f -> f.closestArrivalTo(minTimestamp)))
                .orElseThrow(() -> new AssertionFailure("couldn't find any valid bus schedules"));

        System.out.println("Part 1: " + (optimalSchedule.schedule * optimalSchedule.waitingTimeFrom(minTimestamp)));
    }
}
