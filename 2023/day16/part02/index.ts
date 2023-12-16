const input = await Bun.file("input.txt").text();
const matrix = input
  .split("\n")
  .filter((line) => line.length > 0)
  .map((line) => line.split(""));

type Direction = "up" | "right" | "down" | "left";
type Beam = {
  row: number;
  col: number;
  dir: Direction;
};

let maxEnergizedTiles = 0;
for (let row = 0; row < matrix.length; row++) {
  maxEnergizedTiles = Math.max(
    maxEnergizedTiles,
    calcEnergizedTiles({ row, col: 0, dir: "right" })
  );

  maxEnergizedTiles = Math.max(
    maxEnergizedTiles,
    calcEnergizedTiles({ row, col: matrix[row].length - 1, dir: "left" })
  );
}

for (let col = 0; col < matrix[0].length; col++) {
  maxEnergizedTiles = Math.max(
    maxEnergizedTiles,
    calcEnergizedTiles({ row: 0, col, dir: "down" })
  );

  maxEnergizedTiles = Math.max(
    maxEnergizedTiles,
    calcEnergizedTiles({ row: matrix.length - 1, col, dir: "up" })
  );
}

console.log(maxEnergizedTiles);

function calcEnergizedTiles(startBeam: Beam) {
  let beams: Beam[] = [startBeam];
  let duplicateStates: Record<string, boolean> = {};
  let energizedTiles: Record<string, boolean> = {};
  while (beams.length > 0) {
    // printDebugInfo(matrix, beams);
    // await Bun.sleep(500);

    for (let bi = 0; bi < beams.length; bi++) {
      const { row, col } = beams[bi];
      const stateKey = `${row}:${col}:${beams[bi].dir}`;
      if (
        isOutOfBounds(matrix, row, col) ||
        duplicateStates[stateKey] === true
      ) {
        beams.splice(bi, 1);
        bi--;
        continue;
      }

      energizedTiles[`${row}:${col}`] = true;
      duplicateStates[stateKey] = true;
      if (isUpwardsFacingMirror(matrix, row, col)) {
        beams[bi] = {
          ...beams[bi],
          dir: getUpward90DegreeAngle(beams[bi].dir),
        };
        beams[bi] = move(beams[bi]);
      } else if (isDownwardsFacingMirror(matrix, row, col)) {
        beams[bi] = {
          ...beams[bi],
          dir: getDownward90DegreeAngle(beams[bi].dir),
        };
        beams[bi] = move(beams[bi]);
      } else if (
        isVerticalSplitter(matrix, row, col) &&
        (beams[bi].dir === "left" || beams[bi].dir === "right")
      ) {
        const [dir1, dir2] = splitDirection(beams[bi].dir);
        beams.push({ ...beams[bi], dir: dir1 });
        beams.push({ ...beams[bi], dir: dir2 });
        beams.splice(bi, 1);
        bi--;
      } else if (
        isHorizontalSplitter(matrix, row, col) &&
        (beams[bi].dir === "up" || beams[bi].dir === "down")
      ) {
        const [dir1, dir2] = splitDirection(beams[bi].dir);
        beams.push({ ...beams[bi], dir: dir1 });
        beams.push({ ...beams[bi], dir: dir2 });
        beams.splice(bi, 1);
        bi--;
      } else {
        beams[bi] = move(beams[bi]);
      }
    }
  }

  return Object.keys(energizedTiles).length;
}

function printDebugInfo(matrix: string[][], beams: Beam[]) {
  for (let row = 0; row < matrix.length; row++) {
    for (let col = 0; col < matrix[row].length; col++) {
      let beamExists = false;
      for (let beam of beams) {
        if (beam.row === row && beam.col === col) {
          beamExists = true;
          break;
        }
      }

      if (beamExists) {
        process.stdout.write("*");
      } else {
        process.stdout.write(matrix[row][col]);
      }
    }

    process.stdout.write("\n");
  }

  process.stdout.write("\n\n");
}

function isVerticalSplitter(matrix: string[][], row: number, col: number) {
  return matrix[row][col] === "|";
}

function isHorizontalSplitter(matrix: string[][], row: number, col: number) {
  return matrix[row][col] === "-";
}

function isOutOfBounds(matrix: string[][], row: number, col: number): boolean {
  return (
    row < 0 || row >= matrix.length || col < 0 || col >= matrix[row].length
  );
}

function isUpwardsFacingMirror(matrix: string[][], row: number, col: number) {
  return matrix[row][col] === "/";
}

function getUpward90DegreeAngle(dir: Direction): Direction {
  switch (dir) {
    case "up":
      return "right";
    case "left":
      return "down";
    case "down":
      return "left";
    case "right":
      return "up";
  }
}

function isDownwardsFacingMirror(matrix: string[][], row: number, col: number) {
  return matrix[row][col] === "\\";
}

function getDownward90DegreeAngle(dir: Direction): Direction {
  switch (dir) {
    case "up":
      return "left";
    case "right":
      return "down";
    case "down":
      return "right";
    case "left":
      return "up";
  }
}

function splitDirection(dir: Direction): [Direction, Direction] {
  switch (dir) {
    case "up":
    case "down":
      return ["left", "right"];
    case "left":
    case "right":
      return ["up", "down"];
  }
}

function move(beam: Beam): Beam {
  switch (beam.dir) {
    case "up":
      return { ...beam, row: beam.row - 1 };
    case "right":
      return { ...beam, col: beam.col + 1 };
    case "down":
      return { ...beam, row: beam.row + 1 };
    case "left":
      return { ...beam, col: beam.col - 1 };
  }
}
