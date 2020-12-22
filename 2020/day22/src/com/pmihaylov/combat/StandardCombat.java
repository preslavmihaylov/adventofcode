package com.pmihaylov.combat;

public class StandardCombat implements Combat {
    private final Deck player1Deck;
    private final Deck player2Deck;

    private StandardCombat(Deck player1Deck, Deck player2Deck) {
        this.player1Deck = new Deck(player1Deck);
        this.player2Deck = new Deck(player2Deck);
    }

    public static StandardCombat from(String[] input) {
        return new StandardCombat(Deck.from(input[0]), Deck.from(input[1]));
    }

    @Override
    public Winner play() {
        while (player1Deck.hasCards() && player2Deck.hasCards()) {
            Integer c1 = player1Deck.draw();
            Integer c2 = player2Deck.draw();

            if (c1 > c2) {
                player1Deck.putAtBottom(c1, c2);
            } else if (c2 > c1) {
                player2Deck.putAtBottom(c2, c1);
            } else {
                throw new AssertionError("received two cards with the same value");
            }
        }

        return winner();
    }

    private Winner winner() {
        if (player1Deck.hasCards() && player2Deck.hasCards()) {
            return Winner.NONE;
        } else if (player1Deck.hasCards()) {
            return Winner.PLAYER_ONE;
        } else {
            return Winner.PLAYER_TWO;
        }
    }

    @Override
    public int winnerScore() {
        return Math.max(player1Deck.score(), player2Deck.score());
    }
}
