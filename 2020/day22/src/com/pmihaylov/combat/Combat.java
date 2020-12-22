package com.pmihaylov.combat;

public interface Combat {
    enum Winner {
        NONE,
        PLAYER_ONE,
        PLAYER_TWO
    }

    Winner play();
    int winnerScore();
}
