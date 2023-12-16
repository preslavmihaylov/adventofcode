const input = await Bun.file("input.txt").text();
const lines = input.split("\n").filter((line) => line.length > 0);

let total = 0;
for (const line of lines) {
  const [foldedField, foldedChecksumStr] = line.split(" ");
  const [field, checksumStr] = unfold(foldedField, foldedChecksumStr);

  const checksum = checksumStr.split(",").map((n) => parseInt(n));
  total += generatePossibleArrangements(field, checksum);
}

console.log(total);

function unfold(field: string, checksum: string): [string, string] {
  return [
    [field, field, field, field, field].join("?"),
    [checksum, checksum, checksum, checksum, checksum].join(","),
  ];
}

function generatePossibleArrangements(
  field: string,
  checksum: number[]
): number {
  return generateAllArrangements(field, "", 0, checksum, {});
}

function generateAllArrangements(
  field: string,
  curr: string,
  idx: number,
  checksum: number[],
  cache: Record<string, number>
): number {
  const currChecksumArr = curr
    .split(".")
    .filter((line) => line.length > 0)
    .map((s) => s.length);

  let unfoundGroups = [];
  for (let i = 0; i < checksum.length; i++) {
    if (i < currChecksumArr.length && currChecksumArr[i] === checksum[i]) {
      continue;
    }

    unfoundGroups.push(checksum[i]);
  }

  const unfoundGroupsKey = unfoundGroups.reduce((acc, curr) => acc + curr, 0);
  const cacheKey = `${unfoundGroupsKey}:${idx}`;
  const isCurrSequenceCacheable = curr.charAt(curr.length - 1) === ".";
  if (cache[cacheKey] !== undefined && isCurrSequenceCacheable) {
    return cache[cacheKey];
  }

  const result = (() => {
    if (idx >= field.length) {
      if (isValidArrangement(curr, checksum)) {
        return 1;
      }

      return 0;
    }

    const ch = field.charAt(idx);
    let totalCnt = 0;
    if (ch === "." || ch === "#") {
      if (isPotentiallyValidArrangement(`${curr}${ch}`, checksum)) {
        totalCnt += generateAllArrangements(
          field,
          `${curr}${ch}`,
          idx + 1,
          checksum,
          cache
        );
      }
    } else {
      if (isPotentiallyValidArrangement(`${curr}.`, checksum)) {
        totalCnt += generateAllArrangements(
          field,
          `${curr}.`,
          idx + 1,
          checksum,
          cache
        );
      }
      if (isPotentiallyValidArrangement(`${curr}#`, checksum)) {
        totalCnt += generateAllArrangements(
          field,
          `${curr}#`,
          idx + 1,
          checksum,
          cache
        );
      }
    }

    return totalCnt;
  })();

  if (isCurrSequenceCacheable) {
    cache[cacheKey] = result;
  }

  return result;
}

function isPotentiallyValidArrangement(
  field: string,
  checksum: number[]
): boolean {
  const segments = field.split(".").filter((line) => line.length > 0);
  if (segments.length > checksum.length) {
    return false;
  }

  const nextChar = field.charAt(field.length - 1);
  for (let i = 0; i < segments.length; i++) {
    if (nextChar === "." && segments[i].length !== checksum[i]) {
      return false;
    }

    if (segments[i].length > checksum[i]) {
      return false;
    }
  }

  return true;
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

  return true;
}
