package com.pmihaylov;

import java.util.Arrays;

public class Instruction {
    public enum Command {
        NOP("nop"),
        JUMP("jmp"),
        ACCUMULATE("acc");

        public final String name;
        Command(String name) {
            this.name = name;
        }

        public static Command from(String name) {
            return Arrays.stream(Command.values())
                    .filter(c -> c.name.equals(name))
                    .findFirst()
                    .orElseThrow(() -> new IllegalArgumentException("no enum with the given name was found"));
        }
    }

    public final Command command;
    public final int argument;

    public Instruction(Command command, int argument) {
        this.command = command;
        this.argument = argument;
    }

    public static Instruction from(String line) {
        String[] tokens = line.split(" ");
        return new Instruction(Command.from(tokens[0]), Integer.parseInt(tokens[1]));
    }
}
