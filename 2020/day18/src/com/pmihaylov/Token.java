package com.pmihaylov;

public class Token {
    public enum Type {
        NUMBER,
        ADDITION,
        MULTIPLICATION,
        OPENING_PARENTHESES,
        CLOSING_PARENTHESES,
        EOF
    }

    public final Type type;
    public final long value;

    public Token(Type type, long value) {
        this.type = type;
        this.value = value;
    }
}
