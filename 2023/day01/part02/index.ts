const input = await Bun.file("input.txt").text();
const lines = input.split("\n").filter((line) => line.length > 0);

const wordsToDigits: Record<string, string> = {
  one: "1",
  two: "2",
  three: "3",
  four: "4",
  five: "5",
  six: "6",
  seven: "7",
  eight: "8",
  nine: "9",
  eno: "1",
  owt: "2",
  eerht: "3",
  ruof: "4",
  evif: "5",
  xis: "6",
  neves: "7",
  thgie: "8",
  enin: "9",
};

const result = lines
  .map((line) => {
    var digit1 = extractFirstDigit(
      line,
      /one|two|three|four|five|six|seven|eight|nine/g
    );
    var digit2 = extractFirstDigit(
      line.split("").reverse().join(""),
      /enin|thgie|neves|xis|evif|ruof|eerht|owt|eno/g
    );
    return parseInt(`${digit1}${digit2}`);
  })
  .reduce((a, b) => a + b);

function extractFirstDigit(line: string, regex: RegExp): number {
  let mappedLine = line;
  let matches = line.match(regex);
  if (matches !== null) {
    for (const match of matches) {
      mappedLine = mappedLine.replace(match, wordsToDigits[match]);
    }
  }

  let digits = mappedLine.split("").filter((char) => char.match(/\d/));
  return parseInt(digits[0]);
}

console.log(result);
