// import PriorityQueue from "js-priority-queue";
import _ from "lodash";
import assert from "assert";

type Node = {
  row: number;
  col: number;
  dir: "up" | "down" | "left" | "right";
  straightCnt: number;
};

const input = await Bun.file("input_example.txt").text();
const matrix = input
  .split("\n")
  .filter((line) => line.length > 0)
  .map((line) => line.split(""));

const shortestPath: Record<string, number> = {};
const unvisitedNodes: Node[] = [];
for (let row = 0; row < matrix.length; row++) {
  for (let col = 0; col < matrix[row].length; col++) {
    const key = `${row}:${col}`;
    shortestPath[key] = Number.MAX_SAFE_INTEGER;
    unvisitedNodes.push({ row, col, dir: "right", straightCnt: 1 });
  }
}

shortestPath[`0:0`] = 0;
const previousNodes: Record<string, string> = {};
while (unvisitedNodes.length > 0) {
  const currNode = getMinUnvisitedNode(shortestPath, unvisitedNodes);
  const destNode = getDestNode(matrix);
  if (currNode.row === destNode.row && currNode.col === destNode.col) {
    break;
  }

  const nodeKey = nodeToString(currNode);
  unvisitedNodes.splice(indexOfNode(unvisitedNodes, currNode), 1);

  const neighbors = getNeighbors(matrix, currNode);
  for (const neighbor of neighbors) {
    const neighborKey = nodeToString(neighbor);
    const currPath =
      shortestPath[nodeKey] + parseInt(matrix[neighbor.row][neighbor.col]);
    if (currPath < shortestPath[neighborKey]) {
      shortestPath[neighborKey] = currPath;
      previousNodes[neighborKey] = nodeKey;

      unvisitedNodes.splice(indexOfNode(unvisitedNodes, neighbor), 1);
      unvisitedNodes.push(neighbor);
    }
  }
}

const destNode = getDestNode(matrix);
console.log(shortestPath[nodeToString(destNode)]);
printPath(matrix, previousNodes);

function printPath(matrix: string[][], previousNodes: Record<string, string>) {
  let currNode = nodeToString(getDestNode(matrix));
  const path = [currNode];
  while (previousNodes[currNode] !== undefined) {
    currNode = previousNodes[currNode];
    path.push(currNode);
  }

  for (let row = 0; row < matrix.length; row++) {
    for (let col = 0; col < matrix[row].length; col++) {
      if (path.includes(`${row}:${col}`)) {
        process.stdout.write("*");
      } else {
        process.stdout.write(".");
      }
    }

    process.stdout.write("\n");
  }
}

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
      unvisitedNodes[i].col === node.col
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

// function nodeFromString(str: string): Node {
//   const [rowStr, colStr] = str.split(":");
//   return {
//     row: parseInt(rowStr),
//     col: parseInt(colStr),
//   };
// }

function nodeToString(node: Node): string {
  return `${node.row}:${node.col}`;
}
