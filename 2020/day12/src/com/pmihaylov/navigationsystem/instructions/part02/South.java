package com.pmihaylov.navigationsystem.instructions.part02;

import com.pmihaylov.navigationsystem.Instruction;
import com.pmihaylov.navigationsystem.Location;
import com.pmihaylov.navigationsystem.Navigation;

public class South implements Instruction {
    private final int value;

    public South(int value) {
        this.value = value;
    }

    @Override
    public Navigation execute(Navigation input) {
        return new Navigation(input.origin, new Location(input.waypoint.x, input.waypoint.y - value));
    }
}
