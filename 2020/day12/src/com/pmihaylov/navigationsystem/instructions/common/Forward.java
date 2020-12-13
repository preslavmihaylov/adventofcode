package com.pmihaylov.navigationsystem.instructions.common;

import com.pmihaylov.navigationsystem.Instruction;
import com.pmihaylov.navigationsystem.Location;
import com.pmihaylov.navigationsystem.Navigation;

public class Forward implements Instruction {
    private final int value;

    public Forward(int value) {
        this.value = value;
    }

    @Override
    public Navigation execute(Navigation input) {
        int x = input.origin.x + (input.waypoint.x * value);
        int y = input.origin.y + (input.waypoint.y * value);

        return new Navigation(new Location(x, y), input.waypoint);
    }
}
