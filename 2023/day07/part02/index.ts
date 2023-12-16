import _ from "lodash";
import assert from "assert";

const input = await Bun.file("input.txt").text();
const hands = input
  .split("\n")
  .filter((line) => line.length > 0)
  .map((line) =>
    line.split(" ").map((c, idx) => (idx === 0 ? c : parseInt(c)))
  );

const maxHandCache: Record<string, string> = {};
const result = hands
  .sort((hand1, hand2) => {
    const [cards1] = hand1;
    const [cards2] = hand2;

    const maxHand1 = getMaxHand(cards1 as string);
    const maxHand2 = getMaxHand(cards2 as string);
    return comparator(maxHand1, maxHand2, cards1 as string, cards2 as string);
  })
  .map((hand) => {
    return hand[1] as number;
  })
  .map((bid, idx) => {
    return bid * (hands.length - idx);
  })
  .reduce((acc, curr) => acc + curr, 0);
console.log(result);

export function comparator(
  cards1: string,
  cards2: string,
  orig1: string,
  orig2: string
) {
  const rank1 = getCardsRank(cards1);
  const rank2 = getCardsRank(cards2);
  if (rank1 < rank2) {
    return -1;
  } else if (rank1 > rank2) {
    return 1;
  } else {
    return compareByCards(orig1, orig2);
  }
}

function getMaxHand(cards: string): string {
  if (maxHandCache[cards] !== undefined) {
    return maxHandCache[cards];
  }

  const variations = generateHandVariations(cards);
  const result = _.maxBy(variations, (hand) => -getCardsRank(hand));
  assert(result !== undefined);

  maxHandCache[cards] = result;
  return result;
}

export function generateHandVariations(cards: string): string[] {
  return generateHandVariationsPrivate(cards, 0);
}

function generateHandVariationsPrivate(cards: string, idx: number): string[] {
  if (idx >= cards.length) {
    return [cards];
  }

  const card = cards.charAt(idx);
  if (card !== "J") {
    return generateHandVariationsPrivate(cards, idx + 1);
  } else {
    const left = cards.slice(0, idx);
    const right = cards.slice(idx + 1, cards.length);
    const variations: string[] = [];
    for (const variedCard of [
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "T",
      "Q",
      "K",
      "A",
    ]) {
      variations.push(
        ...generateHandVariationsPrivate(
          `${left}${variedCard}${right}`,
          idx + 1
        )
      );
    }

    return variations;
  }
}

export function compareByCards(cards1: string, cards2: string) {
  const powers: Record<string, number> = {
    A: 14,
    K: 13,
    Q: 12,
    J: 1,
    T: 10,
  };
  for (let i = 0; i < cards1.length; i++) {
    const power1 = powers[cards1[i]] ?? parseInt(cards1[i]);
    const power2 = powers[cards2[i]] ?? parseInt(cards2[i]);
    if (power1 > power2) {
      return -1;
    } else if (power1 < power2) {
      return 1;
    }
  }

  return 0;
}

export function isFiveOfAKind(cards: string) {
  const grouped: Record<string, number> = {};
  for (const card of cards.split("")) {
    grouped[card] = (grouped[card] ?? 0) + 1;
  }

  return (
    Object.keys(grouped).length === 1 && Object.values(grouped).includes(5)
  );
}

export function isFourOfAKind(cards: string) {
  const grouped: Record<string, number> = {};
  for (const card of cards.split("")) {
    grouped[card] = (grouped[card] ?? 0) + 1;
  }

  return (
    Object.keys(grouped).length === 2 &&
    Object.values(grouped).includes(4) &&
    Object.values(grouped).includes(1)
  );
}

export function isFullHouse(cards: string) {
  const grouped: Record<string, number> = {};
  for (const card of cards.split("")) {
    grouped[card] = (grouped[card] ?? 0) + 1;
  }

  return (
    Object.keys(grouped).length === 2 &&
    Object.values(grouped).includes(3) &&
    Object.values(grouped).includes(2)
  );
}

export function isThreeOfAKind(cards: string) {
  const grouped: Record<string, number> = {};
  for (const card of cards.split("")) {
    grouped[card] = (grouped[card] ?? 0) + 1;
  }

  return (
    Object.keys(grouped).length === 3 &&
    Object.values(grouped).includes(3) &&
    Object.values(grouped).includes(1)
  );
}

export function isTwoPair(cards: string) {
  const grouped: Record<string, number> = {};
  for (const card of cards.split("")) {
    grouped[card] = (grouped[card] ?? 0) + 1;
  }

  return (
    Object.keys(grouped).length === 3 &&
    Object.values(grouped).includes(2) &&
    Object.values(grouped).includes(1)
  );
}

export function isOnePair(cards: string) {
  const grouped: Record<string, number> = {};
  for (const card of cards.split("")) {
    grouped[card] = (grouped[card] ?? 0) + 1;
  }

  return (
    Object.keys(grouped).length === 4 &&
    Object.values(grouped).includes(2) &&
    Object.values(grouped).includes(1)
  );
}

function getCardsRank(cards: string) {
  if (isFiveOfAKind(cards)) {
    return 1;
  } else if (isFourOfAKind(cards)) {
    return 2;
  } else if (isFullHouse(cards)) {
    return 3;
  } else if (isThreeOfAKind(cards)) {
    return 4;
  } else if (isTwoPair(cards)) {
    return 5;
  } else if (isOnePair(cards)) {
    return 6;
  } else {
    return 7;
  }
}
