"use strict";

// solving the puzzle takes (my computer) 0.027s

const maps = [];

async function main() {
  await processInput();

  let result = 0;

  let cnt = 0;
  for (const map of maps) {
    result += mapValue(map, cnt);
    cnt++;
  }

  console.log("the answer is", result);
}

///////////////////////////////////////////////////////////

async function processInput() {
  const input = await Bun.file("input.txt").text();

  const parts = input.split("\n\n");

  for (const part of parts) {
    const map = [];

    const lines = part.split("\n");

    for (const line of lines) {
      map.push(line.trim());
    }

    maps.push(map);
  }
}

///////////////////////////////////////////////////////////

function mapValue(map, cnt) {
  const horIndex = indexOfReflectiveHoriz(map);

  if (horIndex != -1) {
    console.log(`${cnt} - HORIZONTAL=${horIndex}`);
    return (horIndex + 1) * 100;
  }

  console.log(`${cnt} - VERTICAL=${indexOfReflectiveVert(map)}`);
  return 1 + indexOfReflectiveVert(map);
}

function indexOfReflectiveVert(map) {
  const rotated = rotate(map);

  return indexOfReflectiveHoriz(rotated);
}

function indexOfReflectiveHoriz(map) {
  for (let index = 0; index < map.length - 1; index++) {
    if (isReflectiveLineDirty(map, index, index + 1)) {
      return index;
    }
  }
  return -1;
}

function rotate(source) {
  const sourceWidth = source[0].length;

  const sourceHeight = source.length;

  const map = [];

  for (let col = 0; col < sourceWidth; col++) {
    let line = "";

    for (let row = 0; row < sourceHeight; row++) {
      line = source[row][col] + line;
    }
    map.push(line);
  }
  return map;
}

///////////////////////////////////////////////////////////

function isReflectiveLineDirty(map, indexA, indexB) {
  // horizontal search

  if (indexA < 0) {
    return false;
  }

  if (indexB > map.length - 1) {
    return false;
  }

  const differences = countDifferences(map[indexA], map[indexB]);

  if (differences > 1) {
    return false;
  }

  if (differences == 1) {
    return isReflectiveLineClean(map, indexA - 1, indexB + 1);
  }

  return isReflectiveLineDirty(map, indexA - 1, indexB + 1);
}

function isReflectiveLineClean(map, indexA, indexB) {
  // horizontal search

  if (indexA < 0) {
    return true;
  }

  if (indexB > map.length - 1) {
    return true;
  }

  if (map[indexA] != map[indexB]) {
    return false;
  }

  return isReflectiveLineClean(map, indexA - 1, indexB + 1);
}

function countDifferences(a, b) {
  let count = 0;

  for (let n = 0; n < a.length; n++) {
    if (a[n] != b[n]) {
      count += 1;
    }
  }

  return count;
}

await main();
