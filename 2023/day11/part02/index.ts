type Coord = {
  row: number;
  col: number;
};

type Pair = [Coord, Coord];

const input = await Bun.file("input.txt").text();
let grid = input
  .split("\n")
  .filter((line) => line.length > 0)
  .map((line) => line.trim().split(""));

const galaxySize = 1000000;
const pairs = getPairs(grid);
let sum = 0;
for (const pair of pairs) {
  sum += calcLength(pair, galaxySize - 1);
}

console.log(sum);

function calcLength(pair: Pair, galaxySize: number): number {
  const [f, s] = pair;
  const emptyRows = calcEmptyRowsBetween(grid, f.row, s.row);
  const emptyCols = calcEmptyColsBetween(grid, f.col, s.col);
  return (
    Math.abs(f.row - s.row) +
    Math.abs(f.col - s.col) +
    emptyRows * galaxySize +
    emptyCols * galaxySize
  );
}

function getPairs(grid: string[][]): Pair[] {
  const planets = findPlanets(grid);
  const pairs: Pair[] = [];
  for (let i = 0; i < planets.length; i++) {
    for (let j = i + 1; j < planets.length; j++) {
      pairs.push([planets[i], planets[j]]);
    }
  }

  return pairs;
}

function findPlanets(grid: string[][]): Coord[] {
  const coords: Coord[] = [];
  for (let row = 0; row < grid.length; row++) {
    for (let col = 0; col < grid[row].length; col++) {
      if (grid[row][col] === "#") {
        coords.push({ row, col });
      }
    }
  }

  return coords;
}

function calcEmptyRowsBetween(
  grid: string[][],
  startRow: number,
  endRow: number
): number {
  let sum = 0;
  let [begin, end] = [Math.min(startRow, endRow), Math.max(startRow, endRow)];
  for (let row = begin; row < end; row++) {
    if (isEmptyRow(grid, row)) {
      sum++;
    }
  }

  return sum;
}

function calcEmptyColsBetween(
  grid: string[][],
  startCol: number,
  endCol: number
): number {
  let sum = 0;
  let [begin, end] = [Math.min(startCol, endCol), Math.max(startCol, endCol)];
  for (let col = begin; col < end; col++) {
    if (isEmptyCol(grid, col)) {
      sum++;
    }
  }

  return sum;
}

function isEmptyRow(grid: string[][], row: number) {
  for (let col = 0; col < grid[row].length; col++) {
    if (grid[row][col] !== ".") {
      return false;
    }
  }

  return true;
}

function isEmptyCol(grid: string[][], col: number) {
  for (let row = 0; row < grid.length; row++) {
    if (grid[row][col] !== ".") {
      return false;
    }
  }

  return true;
}
