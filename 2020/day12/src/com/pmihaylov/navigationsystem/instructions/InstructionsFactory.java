package com.pmihaylov.navigationsystem.instructions;

import com.pmihaylov.navigationsystem.Instruction;
import com.pmihaylov.navigationsystem.instructions.common.*;
import sun.jvm.hotspot.utilities.AssertionFailure;

public class InstructionsFactory {
    public static Instruction forPart01(String line) {
        String id = line.substring(0, 1);
        int value = Integer.parseInt(line.substring(1));
        switch (id) {
            case "N":
                return new com.pmihaylov.navigationsystem.instructions.part01.North(value);
            case "S":
                return new com.pmihaylov.navigationsystem.instructions.part01.South(value);
            case "E":
                return new com.pmihaylov.navigationsystem.instructions.part01.East(value);
            case "W":
                return new com.pmihaylov.navigationsystem.instructions.part01.West(value);
            case "L":
                return new Left(value);
            case "R":
                return new Right(value);
            case "F":
                return new Forward(value);
            default:
                throw new AssertionFailure("unrecognized instruction detected - " + id);
        }
    }

    public static Instruction forPart02(String line) {
        String id = line.substring(0, 1);
        int value = Integer.parseInt(line.substring(1));
        switch (id) {
            case "N":
                return new com.pmihaylov.navigationsystem.instructions.part02.North(value);
            case "S":
                return new com.pmihaylov.navigationsystem.instructions.part02.South(value);
            case "E":
                return new com.pmihaylov.navigationsystem.instructions.part02.East(value);
            case "W":
                return new com.pmihaylov.navigationsystem.instructions.part02.West(value);
            case "L":
                return new Left(value);
            case "R":
                return new Right(value);
            case "F":
                return new Forward(value);
            default:
                throw new AssertionFailure("unrecognized instruction detected - " + id);
        }
    }
}
