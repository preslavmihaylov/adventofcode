const input = await Bun.file("input.txt").text();
const matrix = input
  .split("\n")
  .map((line) => line.split(""))
  .filter((line) => line.length > 0);

let gearRatiosSum = 0;
for (let row = 0; row < matrix.length; row++) {
  for (let col = 0; col < matrix[row].length; col++) {
    if (!isGearSymbol(matrix[row][col])) {
      continue;
    }

    const digits = findAdjacentDigits(matrix, row, col);
    const currNums: Record<string, number> = {};
    for (const digit of digits) {
      const { num, idx } = deriveNumberAtPos(matrix, digit.row, digit.col);
      currNums[`${digit.row}:${idx}`] = num;
    }

    // not a gear if not exactly 2 adjacent nums
    if (Object.keys(currNums).length !== 2) {
      continue;
    }

    gearRatiosSum += Object.values(currNums).reduce(
      (acc, curr) => acc * curr,
      1
    );
  }
}

console.log(gearRatiosSum);

function deriveNumberAtPos(
  matrix: string[][],
  row: number,
  col: number
): { num: number; idx: number } {
  let vcol = col;
  let num = "";
  while (isDigit(matrix[row][vcol])) vcol--;

  vcol = vcol + 1;
  const idx = vcol;
  while (isDigit(matrix[row][vcol])) {
    num += matrix[row][vcol];
    vcol++;
  }

  return { num: parseInt(num), idx };
}

function findAdjacentDigits(
  matrix: string[][],
  row: number,
  col: number
): { row: number; col: number }[] {
  const adjacentDigits = [];
  if (inBounds(matrix, row + 1, col) && isDigit(matrix[row + 1][col])) {
    adjacentDigits.push({ row: row + 1, col });
  }
  if (inBounds(matrix, row - 1, col) && isDigit(matrix[row - 1][col])) {
    adjacentDigits.push({ row: row - 1, col });
  }
  if (inBounds(matrix, row, col + 1) && isDigit(matrix[row][col + 1])) {
    adjacentDigits.push({ row, col: col + 1 });
  }
  if (inBounds(matrix, row, col - 1) && isDigit(matrix[row][col - 1])) {
    adjacentDigits.push({ row, col: col - 1 });
  }
  if (inBounds(matrix, row + 1, col + 1) && isDigit(matrix[row + 1][col + 1])) {
    adjacentDigits.push({ row: row + 1, col: col + 1 });
  }
  if (inBounds(matrix, row - 1, col - 1) && isDigit(matrix[row - 1][col - 1])) {
    adjacentDigits.push({ row: row - 1, col: col - 1 });
  }
  if (inBounds(matrix, row + 1, col - 1) && isDigit(matrix[row + 1][col - 1])) {
    adjacentDigits.push({ row: row + 1, col: col - 1 });
  }
  if (inBounds(matrix, row - 1, col + 1) && isDigit(matrix[row - 1][col + 1])) {
    adjacentDigits.push({ row: row - 1, col: col + 1 });
  }

  return adjacentDigits;
}

function isGearSymbol(char: string) {
  return char === "*";
}

function isDigit(char: string) {
  return ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].includes(char);
}

function inBounds(matrix: string[][], row: number, col: number): boolean {
  return (
    row >= 0 && row < matrix.length && col >= 0 && col < matrix[row].length
  );
}
