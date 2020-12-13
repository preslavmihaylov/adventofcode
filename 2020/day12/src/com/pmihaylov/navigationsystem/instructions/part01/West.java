package com.pmihaylov.navigationsystem.instructions.part01;

import com.pmihaylov.navigationsystem.Instruction;
import com.pmihaylov.navigationsystem.Location;
import com.pmihaylov.navigationsystem.Navigation;

public class West implements Instruction {
    private final int value;

    public West(int value) {
        this.value = value;
    }

    @Override
    public Navigation execute(Navigation input) {
        return new Navigation(new Location(input.origin.x - value, input.origin.y), input.waypoint);
    }
}
