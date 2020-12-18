package com.pmihaylov;

import sun.jvm.hotspot.utilities.AssertionFailure;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.regex.*;

public class TicketValueConstraint {
    private static final Pattern pattern = Pattern.compile("(\\d+)-(\\d+) or (\\d+)-(\\d+)");
    private final List<Interval> intervals;

    public TicketValueConstraint(List<Interval> intervals) {
        this.intervals = Collections.unmodifiableList(intervals);
    }

    public static TicketValueConstraint from(String line) {
        Matcher m = pattern.matcher(line);
        if (!m.find()) {
            throw new AssertionFailure("couldn't correctly match a ticket constraint from line \"" + line + "\"");
        }

        Interval start = new Interval(Integer.parseInt(m.group(1)), Integer.parseInt(m.group(2)));
        Interval end = new Interval(Integer.parseInt(m.group(3)), Integer.parseInt(m.group(4)));

        return new TicketValueConstraint(Arrays.asList(start, end));
    }

    public boolean matches(int value) {
        return intervals.stream().anyMatch(interval -> interval.matches(value));
    }

    private static class Interval {
        public final int start;
        public final int end;

        public Interval(int start, int end) {
            this.start = start;
            this.end = end;
        }

        public boolean matches(int value) {
            return value >= start && value <= end;
        }
    }
}
