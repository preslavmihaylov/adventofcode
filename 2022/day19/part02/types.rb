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
