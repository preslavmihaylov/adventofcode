#!/usr/env/bin ruby

class RobotCost
  def initialize(ore, clay, obsidian)
    @costs = {}
    @costs[:ore] = ore
    @costs[:clay] = clay
    @costs[:obsidian] = obsidian
  end

  def [](symbol)
    @costs[symbol]
  end

  def is_enough?(inventory)
    inventory.minerals[:ore] >= @costs[:ore] and
      inventory.minerals[:clay] >= @costs[:clay] and
      inventory.minerals[:obsidian] >= @costs[:obsidian]
  end
end

class Blueprint
  attr_reader :id, :robot_costs

  def initialize(id, robot_costs)
    @id = id
    @robot_costs = robot_costs
  end
end

class Inventory
  attr_reader :robots, :minerals

  def initialize(robots, minerals)
    @robots = robots
    @minerals = minerals
  end

  def to_s
    "(#{robots[:ore]},#{robots[:clay]},#{robots[:obsidian]},#{robots[:geodes]}," +
      "#{minerals[:ore]},#{minerals[:clay]},#{minerals[:obsidian]},#{minerals[:geodes]})"
  end
end

def read_input(filename = '../input.txt')
  File.readlines(filename).map do |line|
    blueprintID = line.strip.split(/: /)[0][/Blueprint (\d+)/, 1].to_i
    oreRobotOreCost = line.strip.split(/: /)[1].split(/\. /)[0]
                          .strip[/Each ore robot costs (\d+) ore/, 1].to_i
    clayRobotOreCost = line.strip.split(/: /)[1].split(/\. /)[1]
                           .strip[/Each clay robot costs (\d+) ore/, 1].to_i
    obsidianRobotOreCost = line.strip.split(/: /)[1].split(/\. /)[2]
                               .strip[/Each obsidian robot costs (\d+) ore and (\d+) clay/, 1].to_i
    obsidianRobotClayCost = line.strip.split(/: /)[1].split(/\. /)[2]
                                .strip[/Each obsidian robot costs (\d+) ore and (\d+) clay/, 2].to_i
    geodeRobotOreCost = line.strip.split(/: /)[1].split(/\. /)[3]
                            .strip[/Each geode robot costs (\d+) ore and (\d+) obsidian/, 1].to_i
    geodeRobotObsidianCost = line.strip.split(/: /)[1].split(/\. /)[3]
                                 .strip[/Each geode robot costs (\d+) ore and (\d+) obsidian/, 2].to_i

    robot_costs = Hash[
      ore: RobotCost.new(oreRobotOreCost, 0, 0),
      clay: RobotCost.new(clayRobotOreCost, 0, 0),
      obsidian: RobotCost.new(obsidianRobotOreCost, obsidianRobotClayCost, 0),
      geodes: RobotCost.new(geodeRobotOreCost, 0, geodeRobotObsidianCost)
    ]

    Blueprint.new(blueprintID, robot_costs)
  end
end

def farm(inventory)
  minerals = inventory.minerals.dup
  minerals[:ore] += inventory.robots[:ore]
  minerals[:clay] += inventory.robots[:clay]
  minerals[:obsidian] += inventory.robots[:obsidian]
  minerals[:geodes] += inventory.robots[:geodes]

  Inventory.new(inventory.robots.dup, minerals)
end

def buy_robot(blueprint, inventory, robot)
  robots = inventory.robots.dup
  robots[robot] += 1

  minerals = inventory.minerals.dup
  minerals[:ore] -= blueprint.robot_costs[robot][:ore]
  minerals[:clay] -= blueprint.robot_costs[robot][:clay]
  minerals[:obsidian] -= blueprint.robot_costs[robot][:obsidian]

  Inventory.new(robots, minerals)
end

def max_cost(bp, mineral)
  [bp.robot_costs[:ore][mineral],
   bp.robot_costs[:clay][mineral],
   bp.robot_costs[:obsidian][mineral],
   bp.robot_costs[:geodes][mineral]].max
end

def max_geodes(bp, inventory, turns, cache)
  key = "#{inventory}|#{turns}"
  return inventory.minerals[:geodes] if turns <= 0
  return cache[key] if cache.include?(key)

  geodes = []
  if bp.robot_costs[:geodes].is_enough?(inventory)
    geodes.push(max_geodes(bp, buy_robot(bp, farm(inventory), :geodes), turns - 1, cache))
  elsif bp.robot_costs[:obsidian].is_enough?(inventory) and inventory.robots[:obsidian] < max_cost(bp, :obsidian)
    geodes.push(max_geodes(bp, farm(inventory), turns - 1, cache)) # do nothing this turn
    geodes.push(max_geodes(bp, buy_robot(bp, farm(inventory), :obsidian), turns - 1, cache))
  else
    geodes.push(max_geodes(bp, farm(inventory), turns - 1, cache)) # do nothing this turn
    if bp.robot_costs[:ore].is_enough?(inventory) and inventory.robots[:ore] < max_cost(bp, :ore)
      geodes.push(max_geodes(bp, buy_robot(bp, farm(inventory), :ore), turns - 1, cache))
    end

    if bp.robot_costs[:clay].is_enough?(inventory) and inventory.robots[:clay] < max_cost(bp, :clay)
      geodes.push(max_geodes(bp, buy_robot(bp, farm(inventory), :clay), turns - 1, cache))
    end
  end

  cache[key] = geodes.max
  cache[key]
end

if __FILE__ == $0
  blueprints = read_input

  total_quality_levels = 0
  blueprints.each do |blueprint|
    robots = Hash[ore: 1, clay: 0, obsidian: 0, geodes: 0]
    minerals = Hash[ore: 0, clay: 0, obsidian: 0, geodes: 0]
    total_quality_levels += blueprint.id * max_geodes(blueprint, Inventory.new(robots, minerals), 24, {})
  end

  puts total_quality_levels
end
