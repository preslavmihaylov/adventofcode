const input = await Bun.file("input.txt").text();
const matrix = input
  .split("\n")
  .filter((line) => line.length > 0)
  .map((line) => line.trim().split(""));

const [startRow, startCol] = findStartingPos(matrix);
// matrix[startRow][startCol] = "F"; // input_example.txt
matrix[startRow][startCol] = "-"; // input.txt

const queue: number[][] = [];
const visited: Record<string, number> = {};
queue.push([startRow, startCol, 0]);

let maxSteps = 0;
while (queue.length > 0) {
  const nums = queue.shift();
  if (nums === undefined) break;

  const [row, col, steps] = nums;
  if (outOfBounds(matrix, row, col)) continue;
  if (visited[`${row},${col}`] !== undefined) continue;

  maxSteps = Math.max(maxSteps, steps);
  visited[`${row},${col}`] = steps;
  if (matrix[row][col] === "F") {
    queue.push([row, col + 1, steps + 1]); // right
    queue.push([row + 1, col, steps + 1]); // down
  } else if (matrix[row][col] === "J") {
    queue.push([row - 1, col, steps + 1]); // up
    queue.push([row, col - 1, steps + 1]); // left
  } else if (matrix[row][col] === "L") {
    queue.push([row - 1, col, steps + 1]); // up
    queue.push([row, col + 1, steps + 1]); // right
  } else if (matrix[row][col] === "7") {
    queue.push([row, col - 1, steps + 1]); // left
    queue.push([row + 1, col, steps + 1]); // down
  } else if (matrix[row][col] === "|") {
    queue.push([row - 1, col, steps + 1]); // up
    queue.push([row + 1, col, steps + 1]); // down
  } else if (matrix[row][col] === "-") {
    queue.push([row, col - 1, steps + 1]); // left
    queue.push([row, col + 1, steps + 1]); // right
  }
}

console.log(maxSteps);

function outOfBounds(matrix: string[][], row: number, col: number): boolean {
  return (
    row < 0 || row >= matrix.length || col < 0 || col >= matrix[row].length
  );
}

function findStartingPos(matrix: string[][]): [number, number] {
  for (let row = 0; row < matrix.length; row++) {
    for (let col = 0; col < matrix[row].length; col++) {
      if (matrix[row][col] === "S") {
        return [row, col];
      }
    }
  }

  return [-1, -1];
}
