package com.pmihaylov;

import java.util.ArrayList;
import java.util.List;

public class JoltCalculator {
    public static List<Long> getSingleJoltDistributions(List<Long> nums) {
        List<Long> result = new ArrayList<>();
        List<Long> currComponent = new ArrayList<Long>() {{ add(0L); }};
        for (Long num : nums) {
            int lastIndex = currComponent.size()-1;
            if (num - currComponent.get(lastIndex) == 1) {
                currComponent.add(num);
            } else {
                result.add((long)lastIndex);
                currComponent = new ArrayList<Long>() {{ add(num); }};
            }
        }

        result.add((long)currComponent.size()-1);
        return result;
    }
}
