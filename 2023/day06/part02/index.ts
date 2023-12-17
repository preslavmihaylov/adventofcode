type Race = {
  time: number;
  distance: number;
};

const input = await Bun.file("input.txt").text();
const races = parseRaces(input);

let result = 1;
for (const race of races) {
  let wins = 0;
  for (let holds = 0; holds < race.time; holds++) {
    const distance = calcDistance(race.time, holds);
    if (distance > race.distance) {
      wins++;
    }
  }

  result *= wins;
}

console.log(result);

function calcDistance(time: number, holds: number) {
  const speed = holds;
  const distance = (time - holds) * speed;
  return distance;
}

function parseRaces(input: string): Race[] {
  const cols = input
    .split("\n")
    .filter((line) => line.length > 0)
    .map((line) => line.split(":"));

  const time = parseInt(
    cols[0][1]
      .split(" ")
      .filter((l) => l.length > 0)
      .join("")
  );
  const distance = parseInt(
    cols[1][1]
      .split(" ")
      .filter((l) => l.length > 0)
      .join("")
  );

  return [{ time, distance }];
}
