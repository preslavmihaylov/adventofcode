import { test, expect, describe } from "bun:test";
import {
  comparator,
  compareByCards,
  isFiveOfAKind,
  isFourOfAKind,
  isFullHouse,
  isOnePair,
  isThreeOfAKind,
  isTwoPair,
} from ".";

describe("camel cards", () => {
  test("isFiveOfAKind", () => {
    expect(isFiveOfAKind("KKKKK")).toEqual(true);
    expect(isFiveOfAKind("QQQQQ")).toEqual(true);
    expect(isFiveOfAKind("KQQQQ")).toEqual(false);
    expect(isFiveOfAKind("12345")).toEqual(false);
  });

  test("isFourOfAKind", () => {
    expect(isFourOfAKind("KKKKQ")).toEqual(true);
    expect(isFourOfAKind("QQQQK")).toEqual(true);
    expect(isFourOfAKind("KQQQQ")).toEqual(true);
    expect(isFourOfAKind("11112")).toEqual(true);
    expect(isFourOfAKind("21111")).toEqual(true);
    expect(isFourOfAKind("KKKQQ")).toEqual(false);
    expect(isFourOfAKind("KKQQJ")).toEqual(false);
  });

  test("isFullHouse", () => {
    expect(isFullHouse("KKKQQ")).toEqual(true);
    expect(isFullHouse("KKQQQ")).toEqual(true);
    expect(isFullHouse("11333")).toEqual(true);
    expect(isFullHouse("KKJQQ")).toEqual(false);
    expect(isFullHouse("12345")).toEqual(false);
  });

  test("isThreeOfAKind", () => {
    expect(isThreeOfAKind("KKK12")).toEqual(true);
    expect(isThreeOfAKind("QQQKJ")).toEqual(true);
    expect(isThreeOfAKind("QQQKK")).toEqual(false);
    expect(isThreeOfAKind("J1122")).toEqual(false);
  });

  test("isTwoPair", () => {
    expect(isTwoPair("KKJJ1")).toEqual(true);
    expect(isTwoPair("KK1J1")).toEqual(true);
    expect(isTwoPair("K1KJ1")).toEqual(true);
    expect(isTwoPair("JJ111")).toEqual(false);
    expect(isTwoPair("JJ123")).toEqual(false);
  });

  test("isOnePair", () => {
    expect(isOnePair("KKJQ1")).toEqual(true);
    expect(isOnePair("K1JQK")).toEqual(true);
    expect(isOnePair("KKJJ1")).toEqual(false);
    expect(isOnePair("KKJJK")).toEqual(false);
  });

  describe("comparator", () => {
    test("compareByCards", () => {
      expect(compareByCards("KQJT9", "QJT98")).toEqual(-1);
      expect(compareByCards("KQJT9", "KJT98")).toEqual(-1);
      expect(compareByCards("QQJT9", "KJT98")).toEqual(1);
      expect(compareByCards("T1234", "91234")).toEqual(-1);
      expect(compareByCards("K", "Q")).toEqual(-1);
      expect(compareByCards("Q", "K")).toEqual(1);
      expect(compareByCards("J", "Q")).toEqual(1);
      expect(compareByCards("T", "J")).toEqual(1);
      expect(compareByCards("T", "9")).toEqual(-1);
      expect(compareByCards("9", "8")).toEqual(-1);
      expect(compareByCards("7", "7")).toEqual(0);
      expect(compareByCards("K1", "K2")).toEqual(1);
      expect(compareByCards("K2", "K1")).toEqual(-1);
      expect(compareByCards("KQ", "KJ")).toEqual(-1);
      expect(compareByCards("KJ", "KQ")).toEqual(1);
      expect(compareByCards("KJT", "KJ9")).toEqual(-1);
      expect(compareByCards("KJT", "KJJ")).toEqual(1);
      expect(compareByCards("A", "K")).toEqual(-1);
    });
    test("five of a kind", () => {
      expect(comparator("QQQQQ", "KKKKK")).toEqual(1);
      expect(comparator("11111", "33332")).toEqual(-1);
      expect(comparator("11111", "33312")).toEqual(-1);
      expect(comparator("11111", "33312")).toEqual(-1);
      expect(comparator("11111", "33112")).toEqual(-1);
      expect(comparator("11111", "33412")).toEqual(-1);
      expect(comparator("11111", "T9876")).toEqual(-1);
    });
    test("four of a kind", () => {
      expect(comparator("KKKKQ", "33333")).toEqual(1);
      expect(comparator("11112", "33332")).toEqual(1);
      expect(comparator("11112", "33312")).toEqual(-1);
      expect(comparator("11112", "33312")).toEqual(-1);
      expect(comparator("11112", "33112")).toEqual(-1);
      expect(comparator("11112", "33412")).toEqual(-1);
      expect(comparator("11112", "T9876")).toEqual(-1);
    });

    test("full house", () => {
      expect(comparator("KKKQQ", "33333")).toEqual(1);
      expect(comparator("KKKQQ", "33332")).toEqual(1);
      expect(comparator("11122", "33312")).toEqual(-1);
      expect(comparator("11122", "33312")).toEqual(-1);
      expect(comparator("11122", "33112")).toEqual(-1);
      expect(comparator("11122", "33412")).toEqual(-1);
      expect(comparator("11122", "T9876")).toEqual(-1);
    });

    test("three of a kind", () => {
      expect(comparator("KKKQJ", "33333")).toEqual(1);
      expect(comparator("KKKQJ", "33332")).toEqual(1);
      expect(comparator("KKKQJ", "33322")).toEqual(1);
      expect(comparator("11123", "33312")).toEqual(1);
      expect(comparator("11123", "33112")).toEqual(-1);
      expect(comparator("11123", "33412")).toEqual(-1);
      expect(comparator("11123", "54321")).toEqual(-1);
    });

    test("two pair", () => {
      expect(comparator("KKQQJ", "33333")).toEqual(1);
      expect(comparator("KKQQJ", "33332")).toEqual(1);
      expect(comparator("KKQQJ", "33322")).toEqual(1);
      expect(comparator("KKQQJ", "33321")).toEqual(1);
      expect(comparator("11223", "33412")).toEqual(-1);
      expect(comparator("11223", "54321")).toEqual(-1);
    });

    test("one pair", () => {
      expect(comparator("KKQTJ", "33333")).toEqual(1);
      expect(comparator("KKQTJ", "33332")).toEqual(1);
      expect(comparator("KKQTJ", "33322")).toEqual(1);
      expect(comparator("KKQTJ", "33321")).toEqual(1);
      expect(comparator("KKQTJ", "33221")).toEqual(1);
      expect(comparator("11223", "54321")).toEqual(-1);
    });

    test("high card", () => {
      expect(comparator("K1QTJ", "33333")).toEqual(1);
      expect(comparator("K1QTJ", "33332")).toEqual(1);
      expect(comparator("K1QTJ", "33322")).toEqual(1);
      expect(comparator("K1QTJ", "33321")).toEqual(1);
      expect(comparator("K1QTJ", "33221")).toEqual(1);
      expect(comparator("K1QTJ", "33521")).toEqual(1);
    });
  });
});
