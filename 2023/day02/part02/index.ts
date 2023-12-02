const input = await Bun.file("input.txt").text();
const lines = input.split("\n").filter((line) => line.length > 0);

let sum = 0;
for (const line of lines) {
  let minCubes = {
    red: 0,
    blue: 0,
    green: 0,
  };
  line
    .split(":")[1]
    .split(";")
    .map((subset) => subset.trim())
    .map((subset) => extractCubes(subset))
    .forEach((subset) => {
      minCubes = {
        red: Math.max(minCubes["red"], subset["red"] ?? 0),
        blue: Math.max(minCubes["blue"], subset["blue"] ?? 0),
        green: Math.max(minCubes["green"], subset["green"] ?? 0),
      };
    });

  sum += minCubes["red"] * minCubes["blue"] * minCubes["green"];
}

console.log(sum);

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
