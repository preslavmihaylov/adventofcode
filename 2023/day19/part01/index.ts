import _ from "lodash";
import assert from "assert";

type GtRule = {
  type: "gt";
  category: "x" | "m" | "a" | "s";
  value: number;
  next: string;
};

type LtRule = {
  type: "lt";
  category: "x" | "m" | "a" | "s";
  value: number;
  next: string;
};

type TermRule = {
  type: "term";
  next: string;
};

type Rule = GtRule | LtRule | TermRule;

type Workflow = {
  name: string;
  rules: Rule[];
};

type Part = {
  x: number;
  m: number;
  a: number;
  s: number;
};

const input = await Bun.file("input.txt").text();
const [workflowsInput, partsInput] = input
  .split("\n\n")
  .filter((line) => line.length > 0);

const workflows = parseWorkflows(workflowsInput);
const parts = parseParts(partsInput);

let sum = 0;
for (const part of parts) {
  let outcome = "in";
  while (outcome !== "A" && outcome !== "R") {
    outcome = execWorkflowByName(workflows, part, outcome);
  }

  if (outcome === "A") {
    sum += part.x + part.m + part.a + part.s;
  }
}

console.log(sum);

function execWorkflowByName(
  workflows: Workflow[],
  part: Part,
  name: string
): string {
  const workflow = _.find(workflows, (w) => w.name === name);
  assert(workflow !== undefined);

  return execWorkflow(workflow, part);
}

function execWorkflow(workflow: Workflow, part: Part): string {
  for (const rule of workflow.rules) {
    if (matches(rule, part)) {
      return rule.next;
    }
  }

  assert(false, "no rule matched part");
}

function matches(rule: Rule, part: Part): boolean {
  if (rule.type === "gt") {
    return part[rule.category] > rule.value;
  } else if (rule.type === "lt") {
    return part[rule.category] < rule.value;
  } else {
    return true;
  }
}

function parseWorkflows(input: string): Workflow[] {
  return input
    .split("\n")
    .filter((l) => l.length > 0)
    .map((l) => parseWorkflow(l));
}

function parseWorkflow(line: string): Workflow {
  const [name, serializedRules] = line.split(/{|}/).filter((l) => l.length > 0);
  const rules = serializedRules.split(",").map((r) => parseRule(r));
  return {
    name,
    rules,
  };
}

function parseRule(input: string): Rule {
  if (input.includes(">")) {
    const tokens = /([xmas])>([0-9]+):(\w+)/.exec(input);
    assert(tokens !== null);
    assert(
      tokens[1] === "x" ||
        tokens[1] === "m" ||
        tokens[1] === "a" ||
        tokens[1] === "s"
    );

    return {
      type: "gt",
      category: tokens[1],
      value: parseInt(tokens[2]),
      next: tokens[3],
    };
  } else if (input.includes("<")) {
    const tokens = /([xmas])<([0-9]+):(\w+)/.exec(input);
    assert(tokens !== null);
    assert(
      tokens[1] === "x" ||
        tokens[1] === "m" ||
        tokens[1] === "a" ||
        tokens[1] === "s"
    );

    return {
      type: "lt",
      category: tokens[1],
      value: parseInt(tokens[2]),
      next: tokens[3],
    };
  } else {
    return {
      type: "term",
      next: input,
    };
  }
}

function parseParts(input: string): Part[] {
  return input
    .split("\n")
    .filter((l) => l.length > 0)
    .map((l) => {
      const tokens = /{x=([0-9]+),m=([0-9]+),a=([0-9]+),s=([0-9]+)}/.exec(l);
      assert(tokens !== null);

      return {
        x: parseInt(tokens[1]),
        m: parseInt(tokens[2]),
        a: parseInt(tokens[3]),
        s: parseInt(tokens[4]),
      };
    });
}
