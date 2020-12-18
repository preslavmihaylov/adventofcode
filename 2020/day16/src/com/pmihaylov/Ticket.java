package com.pmihaylov;

import java.util.Collections;
import java.util.List;

public class Ticket {
    public final List<Integer> values;
    public Ticket(List<Integer> values) {
        this.values = Collections.unmodifiableList(values);
    }
}
