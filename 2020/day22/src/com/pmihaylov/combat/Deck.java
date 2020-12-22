package com.pmihaylov.combat;

import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class Deck {
    private final List<Integer> cards;

    private Deck(List<Integer> cards) {
        this.cards = new LinkedList<>(cards);
    }

    public Deck(Deck other) {
        this(other.cards);
    }

    public static Deck from(String input) {
        List<Integer> cards = Arrays.stream(input.split("\n"))
                .skip(1)
                .map(Integer::parseInt)
                .collect(Collectors.toList());
        return new Deck(cards);
    }

    public boolean hasCards() {
        return cards.size() > 0;
    }

    public int size() {
        return cards.size();
    }

    public Deck subDeck(int begin, int end) {
        return new Deck(cards.subList(begin, end));
    }

    public Integer draw() {
        Integer c = cards.get(0);
        cards.remove(0);

        return c;
    }

    public void putAtBottom(Integer ...cs) {
        cards.addAll(Arrays.asList(cs));
    }

    public int score() {
        return IntStream.range(0, cards.size())
                .map(i -> (cards.size()-i) * cards.get(i))
                .reduce(0, Integer::sum);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Deck deck = (Deck) o;
        return Objects.equals(cards, deck.cards);
    }

    @Override
    public int hashCode() {
        return Objects.hash(cards);
    }
}
