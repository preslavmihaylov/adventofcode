import PriorityQueue from "js-priority-queue";
import _ from "lodash";
// import assert from "assert";

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
const queue: PriorityQueue<Node> = new PriorityQueue({
  comparator: (n1, n2) => {
    return shortestPath[nodeToString(n1)] - shortestPath[nodeToString(n2)];
  },
});

shortestPath[`0:0:right:0`] = 0;
shortestPath[`0:0:down:0`] = 0;
queue.queue({ row: 0, col: 0, dir: "right", straightCnt: 0 });
queue.queue({ row: 0, col: 0, dir: "down", straightCnt: 0 });

const previousNodes: Record<string, Node> = {};
let finalDestNode = getDestNode(matrix);
while (queue.length > 0) {
  const currNode = queue.dequeue();
  const destNode = getDestNode(matrix);
  if (
    currNode.row === destNode.row &&
    currNode.col === destNode.col &&
    currNode.straightCnt >= 4
  ) {
    finalDestNode = currNode;
    break;
  }

  const nodeKey = nodeToString(currNode);

  const neighbors = getNeighbors(matrix, currNode);
  for (const neighbor of neighbors) {
    const neighborKey = nodeToString(neighbor);
    const currPath =
      shortestPath[nodeKey] + parseInt(matrix[neighbor.row][neighbor.col]);
    if (currPath < (shortestPath[neighborKey] ?? Number.MAX_SAFE_INTEGER)) {
      shortestPath[neighborKey] = currPath;
      previousNodes[neighborKey] = currNode;

      queue.queue(neighbor);
    }
  }
}

console.log(shortestPath[nodeToString(finalDestNode)]);

function getNeighbors(matrix: string[][], node: Node): Node[] {
  let result: Node[] = [];
  if (node.dir === "up") {
    result.push(
      ...([
        ...(node.straightCnt < 10
          ? ([
              {
                row: node.row - 1,
                col: node.col,
                dir: "up",
                straightCnt: node.straightCnt + 1,
              },
            ] as const)
          : []),
        ...(node.straightCnt >= 4
          ? ([
              {
                row: node.row,
                col: node.col - 1,
                dir: "left",
                straightCnt: 1,
              },
            ] as const)
          : []),
        ...(node.straightCnt >= 4
          ? ([
              {
                row: node.row,
                col: node.col + 1,
                dir: "right",
                straightCnt: 1,
              },
            ] as const)
          : []),
      ] as const)
    );
  } else if (node.dir === "down") {
    result.push(
      ...([
        ...(node.straightCnt < 10
          ? ([
              {
                row: node.row + 1,
                col: node.col,
                dir: "down",
                straightCnt: node.straightCnt + 1,
              },
            ] as const)
          : []),
        ...(node.straightCnt >= 4
          ? ([
              {
                row: node.row,
                col: node.col - 1,
                dir: "left",
                straightCnt: 1,
              },
            ] as const)
          : []),
        ...(node.straightCnt >= 4
          ? ([
              {
                row: node.row,
                col: node.col + 1,
                dir: "right",
                straightCnt: 1,
              },
            ] as const)
          : []),
      ] as const)
    );
  } else if (node.dir === "left") {
    result.push(
      ...([
        ...(node.straightCnt < 10
          ? ([
              {
                row: node.row,
                col: node.col - 1,
                dir: "left",
                straightCnt: node.straightCnt + 1,
              },
            ] as const)
          : []),
        ...(node.straightCnt >= 4
          ? ([
              {
                row: node.row - 1,
                col: node.col,
                dir: "up",
                straightCnt: 1,
              },
            ] as const)
          : []),
        ...(node.straightCnt >= 4
          ? ([
              {
                row: node.row + 1,
                col: node.col,
                dir: "down",
                straightCnt: 1,
              },
            ] as const)
          : []),
      ] as const)
    );
  } else if (node.dir === "right") {
    result.push(
      ...([
        ...(node.straightCnt < 10
          ? ([
              {
                row: node.row,
                col: node.col + 1,
                dir: "right",
                straightCnt: node.straightCnt + 1,
              },
            ] as const)
          : []),
        ...(node.straightCnt >= 4
          ? ([
              {
                row: node.row - 1,
                col: node.col,
                dir: "up",
                straightCnt: 1,
              },
            ] as const)
          : []),
        ...(node.straightCnt >= 4
          ? ([
              {
                row: node.row + 1,
                col: node.col,
                dir: "down",
                straightCnt: 1,
              },
            ] as const)
          : []),
      ] as const)
    );
  }

  return result.filter(
    (n) =>
      n.row >= 0 &&
      n.row < matrix.length &&
      n.col >= 0 &&
      n.col < matrix[n.row].length
  );
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
