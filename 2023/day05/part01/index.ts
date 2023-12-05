const input = await Bun.file("input.txt").text();
const inputSegments = input.split("\n\n").filter((line) => line.length > 0);

const seeds = inputSegments[0]
  .split(":")
  .map((t) => t.trim())[1]
  .split(" ")
  .map((n) => parseInt(n));
const mappings = inputSegments
  .filter((_, idx) => idx > 0)
  .map((segment) => parseMapping(segment));

const results = seeds.map((seed) => {
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
});

console.log(Math.min(...results));

function parseMapping(mapping: string): number[][] {
  const ranges = mapping
    .split("\n")
    .filter((l) => l.length > 0)
    .filter((_, idx) => idx > 0);
  return ranges.map((range) => range.split(" ").map((n) => parseInt(n)));
}
