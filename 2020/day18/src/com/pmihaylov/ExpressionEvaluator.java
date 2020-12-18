package com.pmihaylov;

import sun.jvm.hotspot.utilities.AssertionFailure;

import java.util.List;
import java.util.Stack;
import java.util.function.Predicate;

public class ExpressionEvaluator {
    private final Predicate<Token.Type> isHighOperatorPrecedenceFunc;

    public ExpressionEvaluator(Predicate<Token.Type> isHighOperatorPrecedenceFunc) {
        this.isHighOperatorPrecedenceFunc = isHighOperatorPrecedenceFunc;
    }

    public long evaluate(String expression) {
        return evaluate(new Tokenizer(expression));
    }

    private long evaluate(Tokenizer tokenizer) {
        Stack<Long> nums = new Stack<>();
        Stack<Token.Type> operations = new Stack<>();
        Token.Type operation = Token.Type.ADDITION;
        while (tokenizer.hasNext()) {
            Token next = tokenizer.next();
            switch (next.type) {
                case ADDITION:
                case MULTIPLICATION:
                    operation = next.type;
                    break;
                case NUMBER:
                    evaluateIntermediaryOperation(nums, operations, next.value, operation);
                    break;
                case OPENING_PARENTHESES:
                    evaluateIntermediaryOperation(nums, operations, evaluate(tokenizer), operation);
                    break;
                case CLOSING_PARENTHESES:
                    return reduceStacks(nums, operations);
                default:
                    throw new AssertionFailure("Unrecognized token type: " + next.type.toString());
            }
        }

        return reduceStacks(nums, operations);
    }

    private void evaluateIntermediaryOperation(Stack<Long> nums, Stack<Token.Type> operations, long num, Token.Type operation) {
        if (isHighOperatorPrecedenceFunc.test(operation)) {
            long other = nums.size() > 0 ? nums.pop() : 0;
            nums.push(performOperation(other, num, operation));
        } else {
            nums.push(num);
            operations.push(operation);
        }
    }

    private long reduceStacks(Stack<Long> numsStack, Stack<Token.Type> operationsStack) {
        List<Long> nums = numsStack.subList(0, numsStack.size());
        List<Token.Type> operators = operationsStack.subList(0, operationsStack.size());

        long result = nums.get(0);
        for (int i = 1; i < nums.size(); i++) {
            result = performOperation(result, nums.get(i), operators.get(i-1));
        }

        return result;
    }

    private long performOperation(long first, long second, Token.Type operation) {
        switch (operation) {
            case ADDITION:
                return first + second;
            case MULTIPLICATION:
                return first * second;
            default:
                throw new AssertionError("unrecognized operation: " + operation);
        }
    }
}
