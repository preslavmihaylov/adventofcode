import assert from "assert";

type Node = {
  id: string;
  left: string;
  right: string;
};

const input = await Bun.file("input.txt").text();
const [instructions, graph] = parseInput(input);

let currs = getAllStarts(graph);
let steps = 0;
const cycleTimes: Record<number, number> = {};
while (Object.keys(cycleTimes).length < currs.length) {
  for (const inst of instructions) {
    assert(inst === "L" || inst === "R");

    steps++;
    for (let i = 0; i < currs.length; i++) {
      if (inst === "L") {
        currs[i] = graph[currs[i].left];
      } else if (inst === "R") {
        currs[i] = graph[currs[i].right];
      }
    }

    for (let i = 0; i < currs.length; i++) {
      if (
        currs[i].id.charAt(currs[i].id.length - 1) === "Z" &&
        cycleTimes[i] === undefined
      ) {
        cycleTimes[i] = steps;
      }
    }
  }
}

const factors: Record<number, number> = {};
for (const time of Object.values(cycleTimes)) {
  const allFactors = primeFactors(time);
  const currFactors: Record<number, number> = {};
  for (const factor of allFactors) {
    currFactors[factor] = (currFactors[factor] ?? 0) + 1;
  }

  for (const keyStr of Object.keys(currFactors)) {
    const key = parseInt(keyStr);
    factors[key] = Math.max(factors[key] ?? 0, currFactors[key]);
  }
}

let result = 1;
for (const keyStr of Object.keys(factors)) {
  const key = parseInt(keyStr);
  result *= key * factors[key];
}

console.log(result);

function primeFactors(n: number): number[] {
  const factors = [];
  let divisor = 2;

  while (n >= 2) {
    if (n % divisor == 0) {
      factors.push(divisor);
      n = n / divisor;
    } else {
      divisor++;
    }
  }
  return factors;
}

function getAllStarts(graph: Record<string, Node>): Node[] {
  const starts: Node[] = [];
  for (const key of Object.keys(graph)) {
    if (key.charAt(key.length - 1) === "A") {
      starts.push(graph[key]);
    }
  }

  return starts;
}

function parseInput(input: string): [string[], Record<string, Node>] {
  const [serializedInstructions, serializedNodes] = input
    .split("\n\n")
    .filter((line) => line.length > 0);

  const instructions = serializedInstructions.split("");
  const graph: Record<string, Node> = {};
  for (const nodeStr of serializedNodes
    .split("\n")
    .filter((l) => l.length > 0)) {
    const nodeRegex = /(\w+) = \((\w+), (\w+)\)/g;
    const tokens = nodeRegex.exec(nodeStr);
    assert(tokens !== null);

    graph[tokens[1]] = { id: tokens[1], left: tokens[2], right: tokens[3] };
  }

  return [instructions, graph];
}
