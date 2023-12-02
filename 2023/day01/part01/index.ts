const input = await Bun.file("input.txt").text();
const lines = input.split("\n").filter((line) => line.length > 0);
const result = lines
  .map((line) => {
    const digits = line
      .split("")
      .filter((char) => char.match(/\d/))
      .map((char) => parseInt(char));
    return parseInt(`${digits[0]}${digits[digits.length - 1]}`);
  })
  .reduce((a, b) => a + b);
console.log(result);

