import _ from "lodash";
import assert from "assert";

type Node = {
  row: number;
  col: number;
  dir: "up" | "down" | "left" | "right";
  straightCnt: number;
};

const input = await Bun.file("input.txt").text();
const matrix = input
  .split("\n")
  .filter((line) => line.length > 0)
  .map((line) => line.split(""));

const shortestPath: Record<string, number> = {};
const unvisitedNodes: Node[] = [];

shortestPath[`0:0:right:0`] = 0;
unvisitedNodes.push({ row: 0, col: 0, dir: "right", straightCnt: 0 });
const previousNodes: Record<string, Node> = {};
let finalDestNode = getDestNode(matrix);
while (unvisitedNodes.length > 0) {
  const currNode = getMinUnvisitedNode(shortestPath, unvisitedNodes);
  const destNode = getDestNode(matrix);
  if (currNode.row === destNode.row && currNode.col === destNode.col) {
    finalDestNode = currNode;
    break;
  }

  const nodeKey = nodeToString(currNode);
  unvisitedNodes.splice(indexOfNode(unvisitedNodes, currNode), 1);

  const neighbors = getNeighbors(matrix, currNode);
  for (const neighbor of neighbors) {
    const neighborKey = nodeToString(neighbor);
    const currPath =
      shortestPath[nodeKey] + parseInt(matrix[neighbor.row][neighbor.col]);
    if (currPath < (shortestPath[neighborKey] ?? Number.MAX_SAFE_INTEGER)) {
      shortestPath[neighborKey] = currPath;
      previousNodes[neighborKey] = currNode;

      unvisitedNodes.push(neighbor);
    }
  }
}

console.log(shortestPath[nodeToString(finalDestNode)]);

function getMinUnvisitedNode(
  shortestPath: Record<string, number>,
  unvisitedNodes: Node[]
): Node {
  return _.minBy(unvisitedNodes, (n) => shortestPath[nodeToString(n)]) as Node;
}

function indexOfNode(unvisitedNodes: Node[], node: Node): number {
  for (let i = 0; i < unvisitedNodes.length; i++) {
    if (
      unvisitedNodes[i].row === node.row &&
      unvisitedNodes[i].col === node.col &&
      unvisitedNodes[i].dir === node.dir &&
      unvisitedNodes[i].straightCnt === node.straightCnt
    ) {
      return i;
    }
  }

  assert(false);
}

function getNeighbors(matrix: string[][], node: Node): Node[] {
  let result: Node[] = [];
  if (node.dir === "up") {
    result.push(
      ...([
        {
          row: node.row - 1,
          col: node.col,
          dir: "up",
          straightCnt: node.straightCnt + 1,
        },
        {
          row: node.row,
          col: node.col - 1,
          dir: "left",
          straightCnt: 1,
        },
        {
          row: node.row,
          col: node.col + 1,
          dir: "right",
          straightCnt: 1,
        },
      ] as const)
    );
  } else if (node.dir === "down") {
    result.push(
      ...([
        {
          row: node.row + 1,
          col: node.col,
          dir: "down",
          straightCnt: node.straightCnt + 1,
        },
        {
          row: node.row,
          col: node.col - 1,
          dir: "left",
          straightCnt: 1,
        },
        {
          row: node.row,
          col: node.col + 1,
          dir: "right",
          straightCnt: 1,
        },
      ] as const)
    );
  } else if (node.dir === "left") {
    result.push(
      ...([
        {
          row: node.row,
          col: node.col - 1,
          dir: "left",
          straightCnt: node.straightCnt + 1,
        },
        {
          row: node.row - 1,
          col: node.col,
          dir: "up",
          straightCnt: 1,
        },
        {
          row: node.row + 1,
          col: node.col,
          dir: "down",
          straightCnt: 1,
        },
      ] as const)
    );
  } else if (node.dir === "right") {
    result.push(
      ...([
        {
          row: node.row,
          col: node.col + 1,
          dir: "right",
          straightCnt: node.straightCnt + 1,
        },
        {
          row: node.row - 1,
          col: node.col,
          dir: "up",
          straightCnt: 1,
        },
        {
          row: node.row + 1,
          col: node.col,
          dir: "down",
          straightCnt: 1,
        },
      ] as const)
    );
  }

  return result
    .filter(
      (n) =>
        n.row >= 0 &&
        n.row < matrix.length &&
        n.col >= 0 &&
        n.col < matrix[n.row].length
    )
    .filter((n) => n.straightCnt <= 3);
}

function getDestNode(matrix: string[][]): Node {
  return {
    row: matrix.length - 1,
    col: matrix[matrix.length - 1].length - 1,
    dir: "right",
    straightCnt: 0,
  };
}

function nodeToString(node: Node): string {
  return `${node.row}:${node.col}:${node.dir}:${node.straightCnt}`;
}
