const input = await Bun.file("input.txt").text();
const sequences = input
  .split("\n")
  .filter((line) => line.length > 0)
  .map((line) => line.split(" ").map((el) => parseInt(el)));

let sum = 0;
for (const sequence of sequences) {
  const derivatives: number[][] = [sequence];
  let currList = sequence;
  while (!currList.every((el) => el === 0)) {
    const nextList = [];
    for (let i = 0; i < currList.length - 1; i++) {
      nextList.push(currList[i + 1] - currList[i]);
    }

    currList = nextList;
    derivatives.push(currList);
  }

  const result = extrapolate(derivatives);
  sum += result;
}

console.log(sum);

function extrapolate(derivatives: number[][]): number {
  const lastDerivative = derivatives[derivatives.length - 1];
  let curr = lastDerivative[0];
  for (let i = derivatives.length - 2; i >= 0; i--) {
    curr = derivatives[i][0] - curr;
  }

  return curr;
}
