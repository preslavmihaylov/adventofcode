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

let currRound = 1;
let firstHighSignalRounds: Record<string, number> = {};

const input = await Bun.file("input.txt").text();
const lines = input.split("\n").filter((line) => line.length > 0);
const modules = lines.map(parseModule);
calcConjunctionInputs(modules);

const result = execCyclesUntilModuleIsLow(modules, "rx");
console.log(result);

function execCyclesUntilModuleIsLow(
  modules: Module[],
  targetModuleId: string
): number {
  const targetModule = _.find(modules, (m) =>
    m.outputs.includes(targetModuleId)
  );
  if (targetModule === undefined) {
    return -1;
  }

  assert(targetModule.type === "conjunction");
  const inputModules = targetModule.inputs;
  while (
    !_.every(inputModules, (m) => firstHighSignalRounds[m] !== undefined)
  ) {
    execCycle(modules);
    currRound++;
  }

  return lowestCommonDenominator(
    inputModules.map((m) => firstHighSignalRounds[m])
  );
}

function lowestCommonDenominator(nums: number[]): number {
  const factors: Record<number, number> = {};
  for (const num of nums) {
    const allFactors = primeFactors(num);
    const currFactors: Record<number, number> = {};
    for (const factor of allFactors) {
      currFactors[factor] = (currFactors[factor] ?? 0) + 1;
    }

    for (const keyStr of Object.keys(currFactors)) {
      const key = parseInt(keyStr);
      factors[key] = Math.max(factors[key] ?? 0, currFactors[key]);
    }
  }

  let result = 1;
  for (const keyStr of Object.keys(factors)) {
    const key = parseInt(keyStr);
    result *= key * factors[key];
  }

  return result;
}

function primeFactors(n: number): number[] {
  const factors = [];
  let divisor = 2;

  while (n >= 2) {
    if (n % divisor == 0) {
      factors.push(divisor);
      n = n / divisor;
    } else {
      divisor++;
    }
  }
  return factors;
}

function execCycle(modules: Module[]): {
  allPulses: InputPulse[];
} {
  let currPulses: InputPulse[] = [
    { type: "low", src: "button", dest: "broadcaster" },
  ];
  let allPulses = [...currPulses];
  while (currPulses.length > 0) {
    let nextPulses: InputPulse[] = [];
    for (const pulse of currPulses) {
      nextPulses = [...nextPulses, ...execPulse(modules, pulse)];
    }

    currPulses = nextPulses;
    allPulses = [...allPulses, ...currPulses];
  }

  return {
    allPulses,
  };
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
    if (!lowCond && firstHighSignalRounds[module.id] === undefined) {
      firstHighSignalRounds[module.id] = currRound;
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
