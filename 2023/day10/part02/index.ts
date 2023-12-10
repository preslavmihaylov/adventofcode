const input = await Bun.file("input.txt").text();
const matrix = input
  .split("\n")
  .filter((line) => line.length > 0)
  .map((line) => line.trim().split(""));

const [startRow, startCol] = findStartingPos(matrix);

const queue: number[][] = [];
const visited: Record<string, number> = {};

// matrix[startRow][startCol] = "F"; // input_example.txt
// queue.push([startRow, startCol, 0, startRow, startCol + 1]);

// matrix[startRow][startCol] = "7"; // input_example_2.txt
// queue.push([startRow, startCol, 0, startRow, startCol - 1]);

matrix[startRow][startCol] = "-"; // input.txt
queue.push([startRow, startCol, 0, startRow, startCol - 1]);

let [minRow, minCol, maxRow, maxCol] = [0, 0, 0, 0];
while (queue.length > 0) {
  const nums = queue.shift();
  if (nums === undefined) break;

  const [row, col, steps, originRow, originCol] = nums;
  if (outOfBounds(matrix, row, col)) continue;
  if (visited[`${row},${col}`] !== undefined) continue;

  minRow = Math.min(minRow, row);
  minCol = Math.min(minCol, col);
  maxRow = Math.max(maxRow, row);
  maxCol = Math.max(maxCol, col);

  visited[`${row},${col}`] = steps;
  if (matrix[row][col] === "F") {
    if (row !== originRow || col + 1 !== originCol)
      queue.push([row, col + 1, steps + 1, row, col]); // right

    if (row + 1 !== originRow || col !== originCol)
      queue.push([row + 1, col, steps + 1, row, col]); // down
  } else if (matrix[row][col] === "J") {
    if (row - 1 !== originRow || col !== originCol)
      queue.push([row - 1, col, steps + 1, row, col]); // up

    if (row !== originRow || col - 1 !== originCol)
      queue.push([row, col - 1, steps + 1, row, col]); // left
  } else if (matrix[row][col] === "L") {
    if (row - 1 !== originRow || col !== originCol)
      queue.push([row - 1, col, steps + 1, row, col]); // up

    if (row !== originRow || col + 1 !== originCol)
      queue.push([row, col + 1, steps + 1, row, col]); // right
  } else if (matrix[row][col] === "7") {
    if (row !== originRow || col - 1 !== originCol)
      queue.push([row, col - 1, steps + 1, row, col]); // left

    if (row + 1 !== originRow || col !== originCol)
      queue.push([row + 1, col, steps + 1, row, col]); // down
  } else if (matrix[row][col] === "|") {
    if (row - 1 !== originRow || col !== originCol)
      queue.push([row - 1, col, steps + 1, row, col]); // up

    if (row + 1 !== originRow || col !== originCol)
      queue.push([row + 1, col, steps + 1, row, col]); // down
  } else if (matrix[row][col] === "-") {
    if (row !== originRow || col - 1 !== originCol)
      queue.push([row, col - 1, steps + 1, row, col]); // left

    if (row !== originRow || col + 1 !== originCol)
      queue.push([row, col + 1, steps + 1, row, col]); // right
  }
}

for (let row = 0; row < matrix.length; row++) {
  for (let col = 0; col < matrix[0].length; col++) {
    if (visited[`${row},${col}`] === undefined) {
      matrix[row][col] = " ";
    }
  }
}

for (let row = 0; row < matrix.length; row++) {
  for (let col = 0; col < matrix[row].length; col++) {
    process.stdout.write(matrix[row][col]);
  }

  console.log();
}

console.log();
console.log();
console.log();

// scale up
const scaledMatrix: string[][] = [];
for (let row = 0; row < matrix.length * 2; row++) {
  scaledMatrix.push([]);
  for (let col = 0; col < matrix[0].length * 2; col++) {
    scaledMatrix[row].push(" ");
  }
}

const scaledVisited: Record<string, number> = {};
for (let row = 0; row < matrix.length; row++) {
  for (let col = 0; col < matrix[row].length; col++) {
    if (matrix[row][col] === "-") {
      scaledMatrix[row * 2][col * 2] = "█";
      scaledMatrix[row * 2][col * 2 + 1] = "█";
      scaledMatrix[row * 2][col * 2 - 1] = "█";

      scaledVisited[`${row * 2},${col * 2}`] = 1;
      scaledVisited[`${row * 2},${col * 2 + 1}`] = 1;
      scaledVisited[`${row * 2},${col * 2 - 1}`] = 1;
    } else if (matrix[row][col] === "|") {
      scaledMatrix[row * 2][col * 2] = "█";
      scaledMatrix[row * 2 + 1][col * 2] = "█";
      scaledMatrix[row * 2 - 1][col * 2] = "█";

      scaledVisited[`${row * 2},${col * 2}`] = 1;
      scaledVisited[`${row * 2 + 1},${col * 2}`] = 1;
      scaledVisited[`${row * 2 - 1},${col * 2}`] = 1;
    } else if (matrix[row][col] === "J") {
      scaledMatrix[row * 2][col * 2] = "█";
      scaledMatrix[row * 2 - 1][col * 2] = "█";
      scaledMatrix[row * 2][col * 2 - 1] = "█";

      scaledVisited[`${row * 2},${col * 2}`] = 1;
      scaledVisited[`${row * 2 - 1},${col * 2}`] = 1;
      scaledVisited[`${row * 2},${col * 2 - 1}`] = 1;
    } else if (matrix[row][col] === "F") {
      scaledMatrix[row * 2][col * 2] = "█";
      scaledMatrix[row * 2][col * 2 + 1] = "█";
      scaledMatrix[row * 2 + 1][col * 2] = "█";

      scaledVisited[`${row * 2},${col * 2}`] = 1;
      scaledVisited[`${row * 2},${col * 2 + 1}`] = 1;
      scaledVisited[`${row * 2 + 1},${col * 2}`] = 1;
    } else if (matrix[row][col] === "7") {
      scaledMatrix[row * 2][col * 2] = "█";
      scaledMatrix[row * 2][col * 2 - 1] = "█";
      scaledMatrix[row * 2 + 1][col * 2] = "█";

      scaledVisited[`${row * 2},${col * 2}`] = 1;
      scaledVisited[`${row * 2},${col * 2 - 1}`] = 1;
      scaledVisited[`${row * 2 + 1},${col * 2}`] = 1;
    } else if (matrix[row][col] === "L") {
      scaledMatrix[row * 2][col * 2] = "█";
      scaledMatrix[row * 2 - 1][col * 2] = "█";
      scaledMatrix[row * 2][col * 2 + 1] = "█";

      scaledVisited[`${row * 2},${col * 2}`] = 1;
      scaledVisited[`${row * 2 - 1},${col * 2}`] = 1;
      scaledVisited[`${row * 2},${col * 2 + 1}`] = 1;
    }
  }
}

dfs(scaledMatrix, scaledVisited, {}, 0, 0);
for (let row = 0; row < scaledMatrix.length; row++) {
  for (let col = 0; col < scaledMatrix[row].length; col++) {
    process.stdout.write(scaledMatrix[row][col]);
  }

  console.log();
}

console.log();
console.log();
console.log();

let cnt = 0;
for (let row = 0; row < scaledMatrix.length; row++) {
  for (let col = 0; col < scaledMatrix[0].length; col++) {
    if (scaledMatrix[row][col] === " " && row % 2 === 0 && col % 2 === 0) {
      cnt++;
    }
  }
}

console.log(cnt);

function dfs(
  matrix: string[][],
  pipe: Record<string, number>,
  visited: Record<string, number>,
  row: number,
  col: number
) {
  if (outOfBounds(matrix, row, col)) return;
  if (pipe[`${row},${col}`] !== undefined) return;
  if (visited[`${row},${col}`] !== undefined) return;

  matrix[row][col] = "_";
  visited[`${row},${col}`] = 1;
  dfs(matrix, pipe, visited, row - 1, col); // top
  dfs(matrix, pipe, visited, row - 1, col + 1); // top right
  dfs(matrix, pipe, visited, row, col + 1); // right
  dfs(matrix, pipe, visited, row + 1, col + 1); // bot right
  dfs(matrix, pipe, visited, row + 1, col); // bot
  dfs(matrix, pipe, visited, row + 1, col - 1); // bot left
  dfs(matrix, pipe, visited, row, col - 1); // left
  dfs(matrix, pipe, visited, row - 1, col - 1); // top left
}

function outOfBounds(
  matrix: string[][],
  row: number,
  col: number,
  bounds?: [number, number, number, number]
): boolean {
  if (bounds !== undefined) {
    const [minRow, minCol, maxRow, maxCol] = bounds;
    return row < minRow || row > maxRow || col < minCol || col > maxCol;
  }

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
