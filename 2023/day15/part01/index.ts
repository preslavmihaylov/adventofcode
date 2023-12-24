const input = await Bun.file("input.txt").text();
const strs = input
  .split(",")
  .filter((l) => l.length > 0)
  .map((l) => l.trim());

let result = 0;
for (const str of strs) {
  result += hash(str);
}

console.log(result);

function hash(str: string): number {
  let curr = 0;
  for (let i = 0; i < str.length; i++) {
    const code = str.charAt(i).charCodeAt(0);
    curr += code;
    curr *= 17;
    curr %= 256;
  }

  return curr;
}
