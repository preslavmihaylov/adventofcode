package com.pmihaylov;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class Configuration {
    public final Map<String, TicketValueConstraint> constraints;
    public final Ticket myTicket;
    public final List<Ticket> otherTickets;

    private Configuration(Map<String, TicketValueConstraint> constraints, Ticket myTicket, List<Ticket> otherTickets) {
        this.constraints = Collections.unmodifiableMap(constraints);
        this.myTicket = myTicket;
        this.otherTickets = Collections.unmodifiableList(otherTickets);
    }

    public static Configuration from(String[] lines) {
        Map<String, TicketValueConstraint> constraints =
                Arrays.stream(lines[0].split("\n"))
                        .map(line -> line.split(": "))
                        .collect(Collectors.toMap(
                                chunks -> chunks[0], chunks -> TicketValueConstraint.from(chunks[1])));

        Ticket myTicket = new Ticket(
                Arrays.stream(lines[1].split("\n")[1].split(","))
                        .map(Integer::parseInt)
                        .collect(Collectors.toList()));

        List<String> splitted = Arrays.asList(lines[2].split("\n"));
        List<Ticket> otherTickets = splitted.subList(1, splitted.size()).stream()
                .map(l -> Arrays.asList(l.split(",")))
                .map(values -> values.stream().map(Integer::parseInt).collect(Collectors.toList()))
                .map(Ticket::new)
                .collect(Collectors.toList());

        return new Configuration(constraints, myTicket, otherTickets);
    }
}
