package com.pmihaylov;

public enum Action {
    NORTH("N"),
    SOUTH("S"),
    EAST("E"),
    WEST("W"),
    LEFT("L"),
    RIGHT("R"),
    FORWARD("F");

    String name;
    Action(String name) {
        this.name = name;
    }
}
