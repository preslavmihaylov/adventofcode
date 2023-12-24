import assert from "assert";

const input = await Bun.file("input.txt").text();
const patterns = input
  .split("\n\n")
  .filter((line) => line.length > 0)
  .map((l) => l.trim())
  .map((l) => l.split("\n").map((l) => l.trim().split("")));

let sum = 0;
for (let i = 0; i < patterns.length; i++) {
  let pattern = patterns[i];
  const [defaultVerticalReflection, defaultHorizontalReflection] = [
    findVerticalReflection(pattern),
    findHorizontalReflection(pattern),
  ];

  const [verticalReflection, horizontalReflection] = findReflectionWithSmudge(
    pattern,
    defaultVerticalReflection,
    defaultHorizontalReflection
  );

  if (horizontalReflection !== -1) {
    sum += (horizontalReflection + 1) * 100;
  } else if (verticalReflection !== -1) {
    sum += verticalReflection + 1;
  } else {
    assert(false, "no horizontal or vertical reflection found");
  }
}

console.log(sum);

function findReflectionWithSmudge(
  pattern: string[][],
  defaultVerticalReflection: number,
  defaultHorizontalReflection: number
): [number, number] {
  for (let row = 0; row < pattern.length; row++) {
    for (let col = 0; col < pattern[row].length; col++) {
      const existingSymbol = pattern[row][col];
      pattern[row][col] = existingSymbol === "." ? "#" : ".";
      const [verticalReflection, horizontalReflection] = [
        findVerticalReflection(pattern, defaultVerticalReflection),
        findHorizontalReflection(pattern, defaultHorizontalReflection),
      ];

      if (verticalReflection !== -1 || horizontalReflection !== -1) {
        return [verticalReflection, horizontalReflection];
      }

      pattern[row][col] = existingSymbol;
    }
  }

  assert(false, "reflection with smudge not found");
}

function findVerticalReflection(pattern: string[][], ignored?: number): number {
  for (let col = 0; col < pattern[0].length - 1; col++) {
    let [left, right] = [col, col + 1];
    while (
      left >= 0 &&
      right < pattern[0].length &&
      areEqualColumns(pattern, left, right)
    ) {
      left--;
      right++;
    }

    if ((left < 0 || right >= pattern[0].length) && col !== ignored) {
      return col;
    }
  }

  return -1;
}

function findHorizontalReflection(
  pattern: string[][],
  ignored?: number
): number {
  for (let row = 0; row < pattern.length - 1; row++) {
    let [left, right] = [row, row + 1];
    while (
      left >= 0 &&
      right < pattern.length &&
      areEqualRows(pattern, left, right)
    ) {
      left--;
      right++;
    }

    if ((left < 0 || right >= pattern.length) && row !== ignored) {
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
