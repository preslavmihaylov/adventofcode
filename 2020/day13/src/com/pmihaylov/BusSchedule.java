package com.pmihaylov;

public class BusSchedule {
    public final int schedule;

    public BusSchedule(int schedule) {
        this.schedule = schedule;
    }

    public static BusSchedule from(String line) {
        return new BusSchedule(Integer.parseInt(line));
    }

    public long waitingTimeFrom(long timestamp) {
        return closestArrivalTo(timestamp) - timestamp;
    }

    public long closestArrivalTo(long timestamp) {
        long roundTrips = (long)Math.ceil((double)timestamp / (double)schedule);
        return schedule * roundTrips;
    }
}
