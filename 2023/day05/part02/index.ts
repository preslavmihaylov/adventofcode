const input = await Bun.file("input.txt").text();
const inputSegments = input.split("\n\n").filter((line) => line.length > 0);

const seedsInput = inputSegments[0]
  .split(":")
  .map((t) => t.trim())[1]
  .split(" ")
  .map((n) => parseInt(n));
const mappings = inputSegments
  .filter((_, idx) => idx > 0)
  .map((segment) => parseMapping(segment));

// TODO: do the mapping in reverse:
//   * start from lowest possible location, map it to a seed and see if that seed is in the input nums
//   * if it is, then we found the lowest possible location, if not - try the next one
const result = seedsToMinLocation(seedsInput);
console.log(result);

function seedToLocation(seed: number): number {
  for (const mapping of mappings) {
    for (const range of mapping) {
      const [destStart, srcStart, rangeLen] = range;
      if (seed >= srcStart && seed < srcStart + rangeLen) {
        seed = destStart + (seed - srcStart);
        break;
      }
    }
  }

  return seed;
}

function parseMapping(mapping: string): number[][] {
  const ranges = mapping
    .split("\n")
    .filter((l) => l.length > 0)
    .filter((_, idx) => idx > 0);
  return ranges.map((range) => range.split(" ").map((n) => parseInt(n)));
}

function seedsToMinLocation(input: number[]): number {
  let minLocation = Number.MAX_SAFE_INTEGER;
  for (let i = 0; i < input.length; i += 2) {
    console.log(`start range ${i / 2}`);
    const [start, len] = input.slice(i, i + 2);
    for (let j = start; j < start + len; j++) {
      const oldLoc = minLocation;
      minLocation = Math.min(minLocation, seedToLocation(j));
      if (oldLoc !== minLocation) console.log(minLocation);
    }
  }

  return minLocation;
}
