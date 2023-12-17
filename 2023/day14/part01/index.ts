const input = await Bun.file("input.txt").text();
const matrix = input
  .split("\n")
  .filter((line) => line.length > 0)
  .map((line) => line.split(""));

let tiltedMatrix = tiltRocksNorth(matrix);
console.log(calcLoad(tiltedMatrix));

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
