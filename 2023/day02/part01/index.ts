const input = await Bun.file("input.txt").text();
const lines = input.split("\n").filter((line) => line.length > 0);
console.log(lines);

let sum = 0;
for (const line of lines) {
  const gameId = parseInt(line.split(":")[0].split(" ")[1]);
  const impossibleSubsets = line
    .split(":")[1]
    .split(";")
    .map((subset) => subset.trim())
    .map((subset) => extractCubes(subset))
    .filter((cubes) => !isGamePossible(cubes));
  sum += impossibleSubsets.length === 0 ? gameId : 0;
}

console.log(sum);

function isGamePossible(cubes: { [key: string]: number }): boolean {
  cubes = {
    red: cubes["red"] ?? 0,
    green: cubes["green"] ?? 0,
    blue: cubes["blue"] ?? 0,
  };

  return cubes["red"] <= 12 && cubes["green"] <= 13 && cubes["blue"] <= 14;
}

function extractCubes(subset: string): { [key: string]: number } {
  const cubes = subset.split(", ").map((cube) => cube.trim());
  const result = cubes
    .map((cube) => {
      const [cnt, color] = cube.split(" ").map((part) => part.trim());
      return { [color]: parseInt(cnt) };
    })
    .reduce((acc, curr) => ({ ...acc, ...curr }), {});
  return result;
}
