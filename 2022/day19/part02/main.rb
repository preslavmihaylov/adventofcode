#!/usr/env/bin ruby

require './types'

$EARLIEST_GEODE_TURN = [0, 0, 0]

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

def calc_max_geodes(bp, inventory, turns, cache)
  key = "#{inventory}|#{turns}"
  return inventory.minerals[:geodes] if turns <= 0
  return cache[key] if cache.include?(key)
  return 0 if turns < $EARLIEST_GEODE_TURN and inventory.robots[:geodes] == 0

  max_geode = 0
  if inventory.robots[:obsidian] > 0
    ninventory = inventory
    nturns = turns
    while !bp.robot_costs[:geodes].is_enough?(ninventory) and nturns > 0
      ninventory = farm(ninventory)
      nturns -= 1
    end

    if nturns > 0
      $EARLIEST_GEODE_TURN = [$EARLIEST_GEODE_TURN, nturns - 1].max if ninventory.robots[:geodes] == 0
      max_geode = [max_geode, calc_max_geodes(bp, buy_robot(bp, farm(ninventory), :geodes), nturns - 1, cache)].max
    else
      max_geode = [max_geode, ninventory.minerals[:geodes]].max
    end
  end

  if inventory.robots[:clay] > 0
    ninventory = inventory
    nturns = turns
    while !bp.robot_costs[:obsidian].is_enough?(ninventory) and nturns > 0
      ninventory = farm(ninventory)
      nturns -= 1
    end

    max_geode = if nturns > 0
                  [max_geode, calc_max_geodes(bp, buy_robot(bp, farm(ninventory), :obsidian), nturns - 1, cache)].max
                else
                  [max_geode, ninventory.minerals[:geodes]].max
                end
  end

  if inventory.robots[:clay] < max_cost(bp, :clay)
    ninventory = inventory
    nturns = turns
    while !bp.robot_costs[:clay].is_enough?(ninventory) and nturns > 0
      ninventory = farm(ninventory)
      nturns -= 1
    end

    max_geode = if nturns > 0
                  [max_geode, calc_max_geodes(bp, buy_robot(bp, farm(ninventory), :clay), nturns - 1, cache)].max
                else
                  [max_geode, ninventory.minerals[:geodes]].max
                end
  end

  if inventory.robots[:ore] < max_cost(bp, :ore)
    ninventory = inventory
    nturns = turns
    while !bp.robot_costs[:ore].is_enough?(ninventory) and nturns > 0
      ninventory = farm(ninventory)
      nturns -= 1
    end

    max_geode = if nturns > 0
                  [max_geode, calc_max_geodes(bp, buy_robot(bp, farm(ninventory), :ore), nturns - 1, cache)].max
                else
                  [max_geode, ninventory.minerals[:geodes]].max
                end
  end

  cache[key] = max_geode
  cache[key]
end

if __FILE__ == $0
  blueprints = read_input

  max_geodes_product = 1
  blueprints.each_index do |idx|
    break if idx >= 3

    blueprint = blueprints[idx]
    robots = Hash[ore: 1, clay: 0, obsidian: 0, geodes: 0]
    minerals = Hash[ore: 0, clay: 0, obsidian: 0, geodes: 0]
    $EARLIEST_GEODE_TURN = 0
    max_geodes_product *= calc_max_geodes(blueprint, Inventory.new(robots, minerals), 32, {})
  end

  puts max_geodes_product
end
