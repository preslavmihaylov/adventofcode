package com.pmihaylov;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class Part02Solver {
    public static void solve(String[] lines) {
        List<BusSchedule> schedules = Arrays.stream(lines[1].split(","))
                .map(l -> l.equals("x") ? "1" : l)
                .map(BusSchedule::from)
                .collect(Collectors.toList());

        Result r = intersectingTimestamp(schedules);
        System.out.println("Part 2: " + r.timestamp);
    }

    public static Result intersectingTimestamp(List<BusSchedule> schedules) {
        if (schedules.size() == 1) {
            return new Result(schedules.get(0).schedule, 0, schedules.get(0).schedule);
        }

        Result r = intersectingTimestamp(schedules.subList(0, schedules.size()-1));
        return combineSchedules(schedules.get(schedules.size()-1), r.timestamp, r.offset+1, r.step);
    }

    public static Result combineSchedules(BusSchedule current, long timestamp, long offset, long step) {
        long intersectingTs;
        long nextStep;
        while (true) {
            if ((timestamp + offset) % current.schedule == 0) {
                intersectingTs = timestamp;
                break;
            }

            timestamp += step;
        }

        timestamp += step;
        while (true) {
            if ((timestamp + offset) % current.schedule == 0) {
                nextStep = timestamp-intersectingTs;
                break;
            }

            timestamp += step;
        }

        return new Result(intersectingTs, offset, nextStep);
    }

    private static class Result {
        public final long timestamp;
        public final long offset;
        public final long step;

        public Result(long timestamp, long offset, long step) {
            this.timestamp = timestamp;
            this.offset = offset;
            this.step = step;
        }
    }
}
