package com.pmihaylov;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.*;
import java.util.function.BiFunction;
import java.util.function.Predicate;

public class ParallelTraverser<T> implements AutoCloseable {
    private final ExecutorService executor = Executors.newCachedThreadPool();

    public Optional<T> traverse(int inputSize, Predicate<T> isCompletedPredicate, BiFunction<Integer, Integer, T> taskFactory) {
        int cores = Runtime.getRuntime().availableProcessors();
        int offset = inputSize / cores;

        CompletionService<T> svc = new ExecutorCompletionService<>(executor);
        List<Future<T>> futures = new ArrayList<>();
        for (int chunk = 0; chunk < inputSize; chunk += offset) {
            final int currChunk = chunk;
            futures.add(svc.submit(() -> taskFactory.apply(currChunk, Math.min(inputSize, currChunk+offset))));
        }

        for (int i = 0; i < futures.size(); i++) {
            try {
                T result = svc.take().get();
                if (isCompletedPredicate.test(result)) {
                    futures.forEach((f) -> f.cancel(true));
                    return Optional.of(result);
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            } catch (ExecutionException e) {
                throw new RuntimeException(e);
            }
        }

        return Optional.empty();
    }

    @Override
    public void close() {
        executor.shutdownNow();
        try {
            executor.awaitTermination(5, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}

