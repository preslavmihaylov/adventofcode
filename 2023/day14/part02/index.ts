const input = await Bun.file("input.txt").text();
const matrix = input
  .split("\n")
  .filter((line) => line.length > 0)
  .map((line) => line.split(""));

let tiltedMatrix = execCycles(matrix, 1000000000);
console.log(calcLoad(tiltedMatrix));

function execCycles(matrix: string[][], times: number): string[][] {
  const seen: Record<string, number> = {};
  for (let i = 0; i < times; i++) {
    matrix = execCycle(matrix);
    const skippedCycles = i - seen[matrixHash(matrix)];
    if (seen[matrixHash(matrix)] !== undefined && i + skippedCycles < times) {
      i += skippedCycles;
      seen[matrixHash(matrix)] = i;
      continue;
    }

    seen[matrixHash(matrix)] = i;
  }

  return matrix;
}

function matrixHash(matrix: string[][]) {
  return matrix.map((row) => row.join("")).join("\n");
}

function execCycle(matrix: string[][]): string[][] {
  let tilted = matrix;
  tilted = tiltRocksNorth(tilted);
  tilted = tiltRocksWest(tilted);
  tilted = tiltRocksSouth(tilted);
  tilted = tiltRocksEast(tilted);

  return tilted;
}

function tiltRocksNorth(matrix: string[][]): string[][] {
  for (let col = 0; col < matrix[0].length; col++) {
    for (let row = 0; row < matrix.length; row++) {
      if (matrix[row][col] === "O") {
        const [landRow, landCol] = calcLandingLocation(matrix, row, col, -1, 0);
        matrix[row][col] = ".";
        matrix[landRow][landCol] = "O";
      }
    }
  }

  return matrix;
}

function tiltRocksSouth(matrix: string[][]): string[][] {
  for (let col = 0; col < matrix[0].length; col++) {
    for (let row = matrix.length - 1; row >= 0; row--) {
      if (matrix[row][col] === "O") {
        const [landRow, landCol] = calcLandingLocation(matrix, row, col, 1, 0);
        matrix[row][col] = ".";
        matrix[landRow][landCol] = "O";
      }
    }
  }

  return matrix;
}

function tiltRocksWest(matrix: string[][]): string[][] {
  for (let row = 0; row < matrix.length; row++) {
    for (let col = 0; col < matrix[row].length; col++) {
      if (matrix[row][col] === "O") {
        const [landRow, landCol] = calcLandingLocation(matrix, row, col, 0, -1);
        matrix[row][col] = ".";
        matrix[landRow][landCol] = "O";
      }
    }
  }

  return matrix;
}

function tiltRocksEast(matrix: string[][]): string[][] {
  for (let row = 0; row < matrix.length; row++) {
    for (let col = matrix[row].length - 1; col >= 0; col--) {
      if (matrix[row][col] === "O") {
        const [landRow, landCol] = calcLandingLocation(matrix, row, col, 0, 1);
        matrix[row][col] = ".";
        matrix[landRow][landCol] = "O";
      }
    }
  }

  return matrix;
}

function calcLandingLocation(
  matrix: string[][],
  row: number,
  col: number,
  velRow: number,
  velCol: number
): [number, number] {
  while (
    row + velRow >= 0 &&
    row + velRow < matrix.length &&
    col + velCol >= 0 &&
    col + velCol < matrix[row].length &&
    matrix[row + velRow][col + velCol] !== "O" &&
    matrix[row + velRow][col + velCol] !== "#"
  ) {
    row += velRow;
    col += velCol;
  }

  return [row, col];
}

function calcLoad(matrix: string[][]): number {
  let total = 0;
  for (let row = 0; row < matrix.length; row++) {
    for (let col = 0; col < matrix[row].length; col++) {
      if (matrix[row][col] === "O") {
        total += matrix.length - row;
      }
    }
  }

  return total;
}
