package com.pmihaylov;

import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class Part02Solver {
    public static void solve(Configuration cfg) {
        List<Ticket> filteredTickets = filterValidTickets(cfg);
        List<List<String>> matchingFieldsByColumns = matchingFieldsByColumns(cfg, filteredTickets);
        Map<String, Long> myTicketDetails = mapFieldsToValuesFor(matchingFieldsByColumns, cfg.myTicket);

        long result = multiplyValuesWhereFieldStartsWith(myTicketDetails, "departure");
        System.out.println("Part 2: " + result);
    }

    private static List<Ticket> filterValidTickets(Configuration cfg) {
        return cfg.otherTickets.stream()
                .filter(t -> t.values.stream().allMatch(v -> matchesAnyConstraint(cfg.constraints.values(), v)))
                .collect(Collectors.toList());
    }

    private static boolean matchesAnyConstraint(Collection<TicketValueConstraint> constraints, int value) {
        return constraints.stream().anyMatch(c -> c.matches(value));
    }

    private static List<List<String>> matchingFieldsByColumns(Configuration cfg, List<Ticket> tickets) {
        List<List<String>> result = new ArrayList<>();
        for (int col = 0; col < tickets.get(0).values.size(); col++) {
            result.add(matchingFieldsForColumn(cfg, tickets, col));
        }

        return result;
    }

    private static List<String> matchingFieldsForColumn(Configuration cfg, List<Ticket> tickets, int col) {
        List<Integer> values = valuesAtIndex(tickets, col);
        return cfg.constraints.keySet().stream()
                .filter(k -> values.stream().allMatch(v -> cfg.constraints.get(k).matches(v)))
                .collect(Collectors.toList());
    }

    private static List<Integer> valuesAtIndex(List<Ticket> tickets, int index) {
        List<Integer> values = new ArrayList<>();
        for (Ticket t : tickets) {
            values.add(t.values.get(index));
        }

        return values;
    }

    private static Map<String, Long> mapFieldsToValuesFor(List<List<String>> matchingFieldsByColumns, Ticket ticket) {
        Map<String, Long> result = new HashMap<>();
        while (anyMatchedFieldsLeft(matchingFieldsByColumns)) {
            String onlyMatch = singleMatchingField(matchingFieldsByColumns);
            int index = indexOfSingleMatchingField(matchingFieldsByColumns);

            matchingFieldsByColumns = removeMatchFrom(matchingFieldsByColumns, onlyMatch);
            result.put(onlyMatch, (long)ticket.values.get(index));
        }

        return result;
    }

    private static boolean anyMatchedFieldsLeft(List<List<String>> matchingFieldsByColumns) {
        return matchingFieldsByColumns.stream().anyMatch(fields -> fields.size() > 0);
    }

    private static String singleMatchingField(List<List<String>> matchingFieldsByColumns) {
        return matchingFieldsByColumns.stream()
                .filter(fields -> fields.size() == 1)
                .findFirst()
                .orElseThrow(() -> new AssertionError("there were no matching field which matched only once"))
                .get(0);
    }

    private static int indexOfSingleMatchingField(List<List<String>> matchingFieldsByColumns) {
        return IntStream.range(0, matchingFieldsByColumns.size())
                .filter(i -> matchingFieldsByColumns.get(i).size() == 1)
                .findFirst().orElseThrow(() -> new AssertionError("couldn't find matching index"));
    }

    private static List<List<String>> removeMatchFrom(List<List<String>> matchingFieldsByColumns, String onlyMatch) {
        return matchingFieldsByColumns.stream()
                .peek(fields -> fields.remove(onlyMatch))
                .collect(Collectors.toList());
    }

    private static long multiplyValuesWhereFieldStartsWith(Map<String, Long> fields, String prefix) {
        return fields.entrySet().stream()
                .filter(e -> e.getKey().startsWith(prefix))
                .map(Map.Entry::getValue)
                .reduce(1L, Math::multiplyExact);
    }
}
