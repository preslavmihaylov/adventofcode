const input = await Bun.file("input.txt").text();
const lines = input.split("\n").filter((line) => line.length > 0);

let sum = 0;
lines.forEach((line) => {
  const [left, right] = line.split("|");
  const winningNums = left
    .split(":")[1]
    .split(" ")
    .filter((n) => n.length > 0)
    .map((n) => parseInt(n));
  const givenNums = right
    .split(" ")
    .filter((n) => n.length > 0)
    .map((n) => parseInt(n));

  const wonPoints = givenNums.filter((n) => winningNums.includes(n)).length;
  sum += wonPoints > 0 ? 2 ** (wonPoints - 1) : 0;
});

console.log(sum);
