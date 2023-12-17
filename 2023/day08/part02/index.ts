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
while (currs.some((curr) => curr.id.charAt(curr.id.length - 1) !== "Z")) {
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

console.log(steps);

function gcd(a: number, b: number): number {
  if (!b) {
    return a;
  }

  return gcd(b, a % b);
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
