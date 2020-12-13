package com.pmihaylov.navigationsystem.instructions.part01;

import com.pmihaylov.navigationsystem.Instruction;
import com.pmihaylov.navigationsystem.Location;
import com.pmihaylov.navigationsystem.Navigation;

public class North implements Instruction {
    private final int value;

    public North(int value) {
        this.value = value;
    }

    @Override
    public Navigation execute(Navigation input) {
        return new Navigation(new Location(input.origin.x, input.origin.y + value), input.waypoint);
    }
}
