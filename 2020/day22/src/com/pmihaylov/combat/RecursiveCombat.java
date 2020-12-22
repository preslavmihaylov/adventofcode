package com.pmihaylov.combat;

import java.util.*;

public class RecursiveCombat implements Combat {
    private final Deck player1Deck;
    private final Deck player2Deck;
    private final Set<RecursiveCombat> previousRounds;

    private RecursiveCombat(Deck player1Deck, Deck player2Deck) {
        this.player1Deck = new Deck(player1Deck);
        this.player2Deck = new Deck(player2Deck);
        this.previousRounds = new HashSet<>();
    }

    public static RecursiveCombat from(String[] input) {
        return new RecursiveCombat(Deck.from(input[0]), Deck.from(input[1]));
    }

    @Override
    public Winner play() {
        while (player1Deck.hasCards() && player2Deck.hasCards()) {
            if (previousRounds.contains(this)) {
                break;
            }

            previousRounds.add(this);
            Integer c1 = player1Deck.draw();
            Integer c2 = player2Deck.draw();

            Winner winner = Winner.NONE;
            if (player1Deck.size() >= c1 && player2Deck.size() >= c2) {
                winner = new RecursiveCombat(player1Deck.subDeck(0, c1), player2Deck.subDeck(0, c2)).play();
            } else if (c1 > c2) {
                winner = Winner.PLAYER_ONE;
            } else if (c2 > c1) {
                winner = Winner.PLAYER_TWO;
            }

            if (winner == Winner.PLAYER_ONE) {
                player1Deck.putAtBottom(c1, c2);
            } else if (winner == Winner.PLAYER_TWO) {
                player2Deck.putAtBottom(c2, c1);
            } else {
                throw new AssertionError("received two cards with the same value");
            }
        }

        return winner();
    }

    private Winner winner() {
        if (previousRounds.contains(this)) {
            return Winner.PLAYER_ONE;
        }

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
        if (previousRounds.contains(this)) {
            return player1Deck.score();
        }

        return Math.max(player1Deck.score(), player2Deck.score());
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        RecursiveCombat that = (RecursiveCombat) o;
        return Objects.equals(player1Deck, that.player1Deck) &&
                Objects.equals(player2Deck, that.player2Deck);
    }

    @Override
    public int hashCode() {
        return Objects.hash(player1Deck, player2Deck);
    }
}
