package com.pmihaylov;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.*;
import java.util.function.BiFunction;
import java.util.function.Predicate;

public class ParallelTraverser<T> {
    private final ExecutorService executor = Executors.newCachedThreadPool();

    public Optional<T> traverse(int inputSize, Predicate<T> isCompletedPredicate, BiFunction<Integer, Integer, Callable<T>> taskFactory) {
        int cores = Runtime.getRuntime().availableProcessors();
        int offset = inputSize / cores;

        CompletionService<T> complService = new ExecutorCompletionService<>(executor);
        List<Future<T>> futures = new ArrayList<>();
        for (int chunk = 0; chunk < inputSize; chunk += offset) {
            Callable<T> task = taskFactory.apply(chunk, Math.min(inputSize, chunk+offset));
            futures.add(complService.submit(task));
        }

        for (int i = 0; i < futures.size(); i++) {
            try {
                T result = complService.take().get();
                System.out.println("received " + result + "...");
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

    public void shutdown() throws InterruptedException {
        executor.shutdownNow();
        executor.awaitTermination(5, TimeUnit.SECONDS);
    }
}
