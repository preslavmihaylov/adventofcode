import _ from "lodash";

type Lens = {
  label: string;
  focus: number;
};

const input = await Bun.file("input.txt").text();
const strs = input
  .split(",")
  .filter((l) => l.length > 0)
  .map((l) => l.trim());

let boxes: Record<string, Lens[]> = {};
for (const str of strs) {
  const label = str.split("=")[0].split("-")[0];
  const boxId = hash(label);
  boxes[boxId] = boxes[boxId] ?? [];
  if (str.includes("-")) {
    boxes[boxId] = _.filter(boxes[boxId], (el) => {
      return el.label !== label;
    });
  } else {
    const focus = parseInt(str.split("=")[1]);
    let foundExisting = false;
    for (let i = 0; i < boxes[boxId].length; i++) {
      const lens = boxes[boxId][i];
      if (lens.label === label) {
        boxes[boxId][i].focus = focus;
        foundExisting = true;
        break;
      }
    }

    if (!foundExisting) {
      boxes[boxId].push({ label, focus });
    }
  }
}

let result = 0;
for (const boxId of Object.keys(boxes)) {
  for (let i = 0; i < boxes[boxId].length; i++) {
    const lens = boxes[boxId][i];
    const boxNum = parseInt(boxId);
    result += (boxNum + 1) * (i + 1) * lens.focus;
  }
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
