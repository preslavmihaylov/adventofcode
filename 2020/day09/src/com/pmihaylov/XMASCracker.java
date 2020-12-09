package com.pmihaylov;

import java.util.*;

public class XMASCracker {
    private static final int PREAMBLE_SIZE = 25;

    public static Optional<Long> findEncryptionWeakness(List<Long> nums) {
        Optional<Long> invalidNumber = findInvalidNumber(nums);
        if (!invalidNumber.isPresent()) {
            return invalidNumber;
        }

        Long target = invalidNumber.get();
        int start = 0, end = 0;
        Long sum = 0L;
        for (Long num : nums) {
            sum += num;
            end++;

            while (sum > target) {
                sum -= nums.get(start);
                start++;
            }

            if (sum.equals(target)) {
                return Optional.of(sumMinMax(nums.subList(start, end)));
            }
        }

        return Optional.empty();
    }

    public static Optional<Long> findInvalidNumber(List<Long> nums) {
        Set<Long> preamble = Collections.newSetFromMap(new LinkedHashMap<Long, Boolean>(){
            protected boolean removeEldestEntry(Map.Entry<Long, Boolean> eldest) {
                return size() > PREAMBLE_SIZE;
            }
        });

        for (Long num : nums) {
            if (preamble.size() >= PREAMBLE_SIZE && !hasMatchingPair(preamble, num)) {
                return Optional.of(num);
            }

            preamble.add(num);
        }

        return Optional.empty();
    }

    private static Long sumMinMax(List<Long> nums) {
        return nums.stream().min(Long::compareTo).orElse(0L) + nums.stream().max(Long::compareTo).orElse(0L);
    }

    private static boolean hasMatchingPair(Set<Long> preamble, Long target) {
        return preamble.stream()
                .anyMatch(first -> !first.equals(target-first) && preamble.contains(target-first));
    }
}
