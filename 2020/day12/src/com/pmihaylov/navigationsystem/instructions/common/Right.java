package com.pmihaylov.navigationsystem.instructions.common;

import com.pmihaylov.navigationsystem.Instruction;
import com.pmihaylov.navigationsystem.Location;
import com.pmihaylov.navigationsystem.Navigation;

public class Right implements Instruction {
    private final int value;

    public Right(int value) {
        this.value = value;
    }

    @Override
    public Navigation execute(Navigation input) {
        Navigation result = input;
        for (int i = 0; i < value / 90; i++) {
            result = new Navigation(result.origin, new Location(result.waypoint.y, -result.waypoint.x));
        }

        return result;
    }
}
