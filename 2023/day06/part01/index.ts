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
    .map((line) => line.split(" ").filter((line) => line.length > 0));

  const races: Race[] = [];
  for (let i = 1; i < cols[0].length; i++) {
    races.push({ time: parseInt(cols[0][i]), distance: parseInt(cols[1][i]) });
  }

  return races;
}
