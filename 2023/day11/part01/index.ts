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

grid = growGalaxy(grid);
const pairs = getPairs(grid);
let sum = 0;
for (const pair of pairs) {
  sum += calcLength(pair);
}

console.log(sum);

function calcLength(pair: Pair): number {
  const [f, s] = pair;
  return Math.abs(f.row - s.row) + Math.abs(f.col - s.col);
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

function growGalaxy(grid: string[][]): string[][] {
  for (let col = 0; col < grid[0].length; col++) {
    if (isEmptyCol(grid, col)) {
      for (let row = 0; row < grid.length; row++) {
        grid[row].splice(col, 0, ".");
      }

      col++;
    }
  }

  for (let row = 0; row < grid.length; row++) {
    if (isEmptyRow(grid, row)) {
      grid.splice(row, 0, grid[row]);
      row++;
    }
  }

  return grid;
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
