const input = await Bun.file("input.txt").text();
const hands = input
  .split("\n")
  .filter((line) => line.length > 0)
  .map((line) =>
    line.split(" ").map((c, idx) => (idx === 0 ? c : parseInt(c)))
  );

const result = hands
  .sort((hand1, hand2) => {
    const [cards1] = hand1;
    const [cards2] = hand2;
    return comparator(cards1 as string, cards2 as string);
  })
  .map((hand) => hand[1] as number)
  .map((bid, idx) => bid * (hands.length - idx))
  .reduce((acc, curr) => acc + curr, 0);
console.log(result);

export function comparator(cards1: string, cards2: string) {
  const rank1 = getCardsRank(cards1);
  const rank2 = getCardsRank(cards2);
  if (rank1 < rank2) {
    return -1;
  } else if (rank1 > rank2) {
    return 1;
  } else {
    return compareByCards(cards1, cards2);
  }
}

export function compareByCards(cards1: string, cards2: string) {
  const powers: Record<string, number> = {
    A: 14,
    K: 13,
    Q: 12,
    J: 11,
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
