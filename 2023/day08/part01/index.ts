import assert from "assert";

type Node = {
  id: string;
  left: string;
  right: string;
};

const input = await Bun.file("input.txt").text();
const [instructions, graph] = parseInput(input);

let curr = graph["AAA"];
let steps = 0;
while (curr.id !== "ZZZ") {
  for (const inst of instructions) {
    assert(inst === "L" || inst === "R");

    steps++;
    if (inst === "L") {
      curr = graph[curr.left];
    } else if (inst === "R") {
      curr = graph[curr.right];
    }
  }
}

console.log(steps);

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
