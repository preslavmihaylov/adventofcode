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

type RuleNode = {
  rule: Rule;
  choice: "pass" | "nopass";
};

type Workflow = {
  name: string;
  rules: Rule[];
};

// ie [0; 5) => [0, 1, 2, 3, 4]
type Interval = {
  category: "x" | "m" | "a" | "s";
  start: number;
  end: number;
};

type XmasInterval = {
  x: Interval;
  m: Interval;
  a: Interval;
  s: Interval;
};

const minStart = 1;
const maxEnd = 4001;

const maxInterval = (category: "x" | "m" | "a" | "s"): Interval => ({
  category,
  start: minStart,
  end: maxEnd,
});

const input = await Bun.file("input.txt").text();
const [workflowsInput] = input.split("\n\n").filter((line) => line.length > 0);

const workflows = parseWorkflows(workflowsInput);
const paths = traverseAcceptedPaths(workflows, "in", 0, []);
const pathIntervals = paths
  .map((p) => p.map((n) => getIntervalFor(n)))
  .map((p) => {
    return p.reduce(
      (acc, curr) => {
        return {
          ...acc,
          [curr.category]: intersectIntervals(acc[curr.category], curr),
        };
      },
      {
        x: maxInterval("x"),
        m: maxInterval("m"),
        a: maxInterval("a"),
        s: maxInterval("s"),
      }
    );
  });

const result = pathIntervals
  .map((pi) => calcPossibleCombinations(pi))
  .reduce((acc, curr) => acc + curr, 0);
console.log(result);

function traverseAcceptedPaths(
  workflows: Workflow[],
  currWorkflowName: string,
  currRuleIdx: number,
  currPath: RuleNode[]
): RuleNode[][] {
  if (currWorkflowName === "A") {
    return [currPath];
  } else if (currWorkflowName === "R") {
    return [];
  }

  const currWorkflow = _.find(workflows, (w) => w.name === currWorkflowName);
  assert(currWorkflow !== undefined);
  if (currRuleIdx >= currWorkflow.rules.length) {
    return [];
  }

  const currRule = currWorkflow.rules[currRuleIdx];
  return [
    ...traverseAcceptedPaths(workflows, currRule.next, 0, [
      ...currPath,
      { rule: currRule, choice: "pass" },
    ]),
    ...traverseAcceptedPaths(workflows, currWorkflowName, currRuleIdx + 1, [
      ...currPath,
      { rule: currRule, choice: "nopass" },
    ]),
  ];
}

function getIntervalFor(node: RuleNode): Interval {
  const category = "category" in node.rule ? node.rule.category : "x";
  switch (node.rule.type) {
    case "term":
      return { category, start: minStart, end: maxEnd };
    case "lt":
      return node.choice === "pass"
        ? { category, start: minStart, end: node.rule.value }
        : { category, start: node.rule.value, end: maxEnd };
    case "gt":
      return node.choice === "pass"
        ? { category, start: node.rule.value + 1, end: maxEnd }
        : { category, start: minStart, end: node.rule.value + 1 };
  }
}

function intersectIntervals(i1: Interval, i2: Interval): Interval {
  assert(i1.category === i2.category);
  return {
    category: i1.category,
    start: Math.max(i1.start, i2.start),
    end: Math.min(i1.end, i2.end),
  };
}

function calcPossibleCombinations(i: XmasInterval): number {
  if (
    i.x.end <= i.x.start ||
    i.m.end <= i.m.start ||
    i.a.end <= i.a.start ||
    i.s.end <= i.s.start
  ) {
    return 0;
  }

  return (
    (i.x.end - i.x.start) *
    (i.m.end - i.m.start) *
    (i.a.end - i.a.start) *
    (i.s.end - i.s.start)
  );
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
