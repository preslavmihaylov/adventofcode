const input = await Bun.file("input.txt").text();
const lines = input.split("\n").filter((line) => line.length > 0);

let total = 0;
for (const line of lines) {
  const [field, checksumStr] = line.split(" ");
  const checksum = checksumStr.split(",").map((n) => parseInt(n));
  const cnt = generatePossibleArrangements(field, checksum);
  console.log(field, checksum, cnt);
  total += cnt;
}

console.log(total);

function generatePossibleArrangements(field: string, checksum: number[]) {
  const knowns = field.split("").filter((ch) => ch === "#").length;
  const unknowns = checksum.reduce((a, b) => a + b, 0) - knowns;
  return generateAllArrangements(field, unknowns, "", 0).filter((arr) =>
    isValidArrangement(arr, checksum)
  ).length;
}

function generateAllArrangements(
  field: string,
  unknowns: number,
  curr: string,
  idx: number
): string[] {
  if (idx >= field.length) {
    return [curr];
  }

  const ch = field.charAt(idx);
  if (ch === "." || ch === "#") {
    return generateAllArrangements(field, unknowns, `${curr}${ch}`, idx + 1);
  } else {
    return [
      ...generateAllArrangements(field, unknowns, `${curr}.`, idx + 1),
      ...generateAllArrangements(field, unknowns, `${curr}#`, idx + 1),
    ];
  }
}

function isValidArrangement(field: string, checksum: number[]): boolean {
  const segments = field.split(".").filter((line) => line.length > 0);
  if (segments.length !== checksum.length) {
    return false;
  }

  for (let i = 0; i < segments.length; i++) {
    if (segments[i].length !== checksum[i]) {
      return false;
    }
  }

  // console.log("VALID:", field, checksum);
  return true;
}
