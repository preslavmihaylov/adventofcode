import _ from "lodash";
import assert from "assert";

type FlipFlopModule = {
  type: "flipflop";
  id: string;
  state: "on" | "off";
  outputs: string[];
};

type ConjunctionModule = {
  type: "conjunction";
  id: string;
  inputs: string[];
  outputs: string[];
  memory: ("high" | "low")[];
};

type BroadcasterModule = {
  type: "broadcaster";
  id: string;
  outputs: string[];
};

type Module = FlipFlopModule | ConjunctionModule | BroadcasterModule;

type InputPulse = {
  type: "high" | "low";
  src: string;
  dest: string;
};

const IS_DEBUG = false;

const input = await Bun.file("input.txt").text();
const lines = input.split("\n").filter((line) => line.length > 0);
const modules = lines.map(parseModule);
calcConjunctionInputs(modules);
const result = execCycles(modules, 1000);
console.log(result.high * result.low);

function execCycles(
  modules: Module[],
  cycles: number
): { high: number; low: number } {
  let result = { high: 0, low: 0 };
  for (let i = 0; i < cycles; i++) {
    const curr = execCycle(modules);
    result.high += curr.high;
    result.low += curr.low;
  }

  return result;
}

function execCycle(modules: Module[]): { high: number; low: number } {
  let result = { high: 0, low: 1 };
  let currPulses: InputPulse[] = [
    { type: "low", src: "button", dest: "broadcaster" },
  ];
  while (currPulses.length > 0) {
    let nextPulses: InputPulse[] = [];
    for (const pulse of currPulses) {
      nextPulses = [...nextPulses, ...execPulse(modules, pulse)];
    }

    currPulses = nextPulses;
    result.high += nextPulses.filter((p) => p.type === "high").length;
    result.low += nextPulses.filter((p) => p.type === "low").length;
  }

  return result;
}

function execPulse(modules: Module[], input: InputPulse): InputPulse[] {
  const module = _.find(modules, (m) => m.id === input.dest);
  if (module === undefined) {
    return [];
  }

  return execPulseForModule(module, input);
}

function execPulseForModule(module: Module, input: InputPulse): InputPulse[] {
  if (module.type === "broadcaster") {
    if (IS_DEBUG) {
      for (const output of module.outputs) {
        console.log(`${module.id} -${input.type}-> ${output}`);
      }
    }

    return module.outputs.map((o) => ({
      type: input.type,
      src: module.id,
      dest: o,
    }));
  } else if (module.type === "flipflop") {
    if (input.type === "high") {
      return [];
    }

    const currState = module.state;
    module.state = currState === "on" ? "off" : "on";

    if (IS_DEBUG) {
      for (const output of module.outputs) {
        console.log(
          `${module.id} -${currState === "on" ? "low" : "high"}-> ${output}`
        );
      }
    }

    return currState === "on"
      ? module.outputs.map((o) => ({ type: "low", src: module.id, dest: o }))
      : module.outputs.map((o) => ({ type: "high", src: module.id, dest: o }));
  } else if (module.type === "conjunction") {
    let foundInput = false;
    for (let i = 0; i < module.inputs.length; i++) {
      if (module.inputs[i] === input.src) {
        module.memory[i] = input.type;
        foundInput = true;
        break;
      }
    }

    assert(
      foundInput,
      "invariant violated - couldn't find input for conjunction module"
    );

    const lowCond = _.every(
      module.inputs,
      (_val, idx) => module.memory[idx] === "high"
    );
    if (IS_DEBUG) {
      for (const output of module.outputs) {
        console.log(`${module.id} -${lowCond ? "low" : "high"}-> ${output}`);
      }
    }

    if (lowCond) {
      return module.outputs.map((o) => ({
        type: "low",
        src: module.id,
        dest: o,
      }));
    } else {
      return module.outputs.map((o) => ({
        type: "high",
        src: module.id,
        dest: o,
      }));
    }
  }

  assert(false, "invalid module type");
}

function calcConjunctionInputs(modules: Module[]) {
  for (const module of modules) {
    if (module.type === "conjunction") {
      const targetId = module.id;
      for (const other of modules) {
        if (other.outputs.includes(targetId)) {
          module.inputs.push(other.id);
          module.memory.push("low");
        }
      }
    }
  }
}

function parseModule(line: string): Module {
  if (line.includes("broadcaster")) {
    return parseBroadcaster(line);
  } else if (line.charAt(0) === "%") {
    return parseFlipFlop(line);
  } else if (line.charAt(0) === "&") {
    return parseConjunction(line);
  }

  assert(false, "unknown module");
}

function parseBroadcaster(line: string): BroadcasterModule {
  const serializedOutputs = line.split(" -> ")[1];
  const outputs = serializedOutputs
    .trim()
    .split(", ")
    .filter((o) => o.length > 0);
  return { type: "broadcaster", id: "broadcaster", outputs };
}

function parseFlipFlop(line: string): FlipFlopModule {
  line = line.slice(1);
  const [id, serializedOutputs] = line
    .trim()
    .split(" -> ")
    .filter((l) => l.length > 0);
  const outputs = serializedOutputs
    .trim()
    .split(", ")
    .filter((l) => l.length > 0);
  return {
    type: "flipflop",
    id,
    state: "off",
    outputs,
  };
}

function parseConjunction(line: string): ConjunctionModule {
  line = line.slice(1);
  const [id, serializedOutputs] = line
    .trim()
    .split(" -> ")
    .filter((l) => l.length > 0);
  const outputs = serializedOutputs
    .trim()
    .split(", ")
    .filter((l) => l.length > 0);
  return {
    type: "conjunction",
    id,
    inputs: [],
    memory: [],
    outputs,
  };
}
