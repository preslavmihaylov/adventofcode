#!/usr/env/bin ruby

class ValveNode
  attr_reader :id, :flow_rate, :conns

  def initialize(id, flow_rate, conns)
    @id = id
    @flow_rate = flow_rate
    @conns = conns
  end

  def to_s
    "id=#{@id}, flow_rate=#{@flow_rate}, conns=#{@conns}"
  end
end

def read_input(filename = '../input.txt')
  result = {}
  f = File.open(filename)
  f.each_line do |line|
    id = line.scan(/Valve\s(\w+)\shas\sflow/).flatten.first
    flowRate = line.scan(/rate=(\d+)/).flatten.first.to_i
    conns = line.gsub(/, /, '_').split(/\s/).last.split(/_/)
    result[id] = ValveNode.new(id, flowRate, conns)
  end

  result
end

def calc_final_pressure(openPipes)
  r = openPipes.map { |l| l[0] * (30 - l[1]) }.reduce(:+)
  !r.nil? ? r : 0
end

def build_adj_matrix(nodes, _max_rounds)
  # Create a matrix of infinite distances for initialization
  n = nodes.length
  matrix = {}
  nodes.each do |id, _|
    matrix[id] = {}
  end

  nodes.each do |id1, _|
    nodes.each do |id2, _|
      matrix[id1][id2] = Float::INFINITY
      matrix[id2][id1] = Float::INFINITY
    end
  end

  # Fill in the matrix with distances where edges exist
  nodes.each do |id1, node|
    matrix[id1][id1] = 0 # Distance to self is 0
    node.conns.each do |id2|
      matrix[id1][id2] = 1
      matrix[id2][id1] = 1
    end
  end

  # Floyd-Warshall algorithm
  nodes.each do |k, _|
    nodes.each do |i, _|
      nodes.each do |j, _|
        matrix[i][j] = matrix[i][k] + matrix[k][j] if matrix[i][j] > matrix[i][k] + matrix[k][j]
      end
    end
  end

  matrix
end

def all_paths(nodes, adj_matrix, nodes_list, start_node, round, max_rounds)
  return [nodes_list] if nodes_list.length == 1

  result = []
  nodes_list.each_with_index do |node, idx|
    dist = adj_matrix[start_node][node.id]
    next if dist >= max_rounds - round

    sub_list = nodes_list.slice(0, idx) + nodes_list.slice(idx + 1, nodes_list.length)
    sub_paths = all_paths(nodes, adj_matrix, sub_list, node.id, round + dist + 1, max_rounds)

    sub_paths.each do |sub_path|
      result << [node] + sub_path
    end

    result << [node] if sub_paths.length == 0
  end

  result
end

def calc_pressure(nodes, adj_matrix, path, max_rounds)
  path = [nodes['AA']] + path

  openPipes = []
  round = 0
  for i in 0..path.length - 2
    node1 = path[i]
    node2 = path[i + 1]
    round += adj_matrix[node1.id][node2.id] + 1
    break if round >= max_rounds

    openPipes.push([node2.flow_rate, round])
  end

  calc_final_pressure(openPipes)
end

def max_pressure(nodes, max_rounds)
  adj_matrix = build_adj_matrix(nodes, max_rounds)

  nodes_with_flow = nodes.select { |_, n| n.flow_rate > 0 }.values
  paths = all_paths(nodes, adj_matrix, nodes_with_flow, 'AA', 0, max_rounds)
  paths.map { |path| calc_pressure(nodes, adj_matrix, path, max_rounds) }.max
end

if __FILE__ == $0
  # nodes = read_input('../input-example.txt')
  nodes = read_input
  puts max_pressure(nodes, 30)
end
