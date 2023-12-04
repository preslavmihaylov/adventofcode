const input = await Bun.file("input.txt").text();
const lines = input.split("\n").filter((line) => line.length > 0);

let scratchcards: Record<number, number> = {};
lines.map((line) => {
  // example line: "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53"
  const [left, right] = line.split("|");
  const givenNums = right
    .split(" ")
    .filter((n) => n.length > 0)
    .map((n) => parseInt(n));
  const winningNums = left
    .split(":")[1]
    .split(" ")
    .filter((n) => n.length > 0)
    .map((n) => parseInt(n));
  const cardIdx = parseInt(
    left
      .split(":")[0]
      .split(" ")
      .filter((l) => l.length > 0)[1]
  );

  const wonPoints = givenNums.filter((n) => winningNums.includes(n)).length;
  scratchcards[cardIdx] = (scratchcards[cardIdx] ?? 0) + 1;
  for (let i = 0; i < wonPoints; i++) {
    scratchcards[cardIdx + i + 1] =
      (scratchcards[cardIdx + i + 1] ?? 0) + scratchcards[cardIdx];
  }
});

console.log(Object.values(scratchcards).reduce((acc, card) => acc + card, 0));

// const matrix = input
//   .split("\n")
//   .map((line) => line.split(""))
//   .filter((line) => line.length > 0);
