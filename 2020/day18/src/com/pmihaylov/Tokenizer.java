package com.pmihaylov;

public class Tokenizer {
    private final String line;
    private int currIndex;

    public Tokenizer(String line) {
        this.line = line.trim();
        this.currIndex = 0;
    }

    public boolean hasNext() {
        return currIndex < line.length();
    }

    public Token next() {
        if (!hasNext()) {
            return new Token(Token.Type.EOF, 0);
        }

        while (line.charAt(currIndex) == ' ') {
            currIndex++;
        }

        Token token;
        switch (line.charAt(currIndex)) {
            case '+':
                token = new Token(Token.Type.ADDITION, 0);
                break;
            case '*':
                token = new Token(Token.Type.MULTIPLICATION, 0);
                break;
            case '(':
                token = new Token(Token.Type.OPENING_PARENTHESES, 0);
                break;
            case ')':
                token = new Token(Token.Type.CLOSING_PARENTHESES, 0);
                break;
            default:
                token = new Token(Token.Type.NUMBER, line.charAt(currIndex)-'0');
                break;
        }

        currIndex++;
        return token;
    }
}