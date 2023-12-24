import assert from "assert";

const input = await Bun.file("input.txt").text();
const patterns = input
  .split("\n\n")
  .filter((line) => line.length > 0)
  .map((l) => l.trim())
  .map((l) => l.split("\n").map((l) => l.trim().split("")));

let sum = 0;
for (const pattern of patterns) {
  const [verticalReflection, horizontalReflection] = [
    findVerticalReflection(pattern),
    findHorizontalReflection(pattern),
  ];

  if (verticalReflection !== -1) {
    sum += verticalReflection + 1;
  } else if (horizontalReflection !== -1) {
    sum += (horizontalReflection + 1) * 100;
  } else {
    assert(false, "no horizontal or vertical reflection found");
  }
}

console.log(sum);

function findVerticalReflection(pattern: string[][]): number {
  for (let col = 0; col < pattern[0].length; col++) {
    let [left, right] = [col, (col + 1) % pattern[0].length];
    while (
      left >= 0 &&
      right < pattern[0].length &&
      areEqualColumns(pattern, left, right)
    ) {
      left--;
      right++;
    }

    if (left < 0 || right >= pattern[0].length) {
      return col;
    }
  }

  return -1;
}

function findHorizontalReflection(pattern: string[][]): number {
  for (let row = 0; row < pattern.length; row++) {
    let [left, right] = [row, (row + 1) % pattern.length];
    while (
      left >= 0 &&
      right < pattern.length &&
      areEqualRows(pattern, left, right)
    ) {
      left--;
      right++;
    }

    if (left < 0 || right >= pattern.length) {
      return row;
    }
  }

  return -1;
}

function areEqualColumns(
  pattern: string[][],
  col1: number,
  col2: number
): boolean {
  for (let row = 0; row < pattern.length; row++) {
    if (pattern[row][col1] !== pattern[row][col2]) {
      return false;
    }
  }

  return true;
}

function areEqualRows(
  pattern: string[][],
  row1: number,
  row2: number
): boolean {
  return pattern[row1].join("") === pattern[row2].join("");
}
