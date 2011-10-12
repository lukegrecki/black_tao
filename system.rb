require 'set'

class System
  attr_reader :state, :states, :history

  def initialize(rule, initial_state = nil)
    if is_valid_rule?(rule)
      @rule = rule
      @states = rule.keys.to_set
      if is_valid_state?(initial_state)
        @state = initial_state
        @history = [initial_state]
      else
        raise StateError
      end
    else
      raise RuleError
    end
  end

  def state=(new_state)
    if is_valid_state?(new_state)
      @state = new_state
      @history = [@state]
    else
      raise StateError
    end
  end

  def evolve(steps = 1)
    steps.times { @state = @rule[@state]; @history << @state }
    return @state
  end

  def ghost_evolve(ghost_state = @state, steps = 1)
    if is_valid_state?(ghost_state)
      steps.times { ghost_state = @rule[ghost_state] }
      return ghost_state
    else
      raise StateError
    end
  end

  def is_fixed_point?(ghost_state = @state)
    if is_valid_state?(ghost_state)
      return ghost_state == ghost_evolve(ghost_state) ? true : false
    else
      raise StateError
    end
  end

  def fixed_points
    @fixed_points ||= @states.select { |s| is_fixed_point?(s) }.to_set
  end

  def is_invariant_set?(subset_of_states)
    new_subset_of_states =
      Array(subset_of_states).collect { |s| ghost_evolve(s) }.to_set
    return new_subset_of_states == subset_of_states ? true : false
  end

  def is_valid_rule?(rule)
    return (rule.is_a?(Hash) &&
            rule.keys.to_set == rule.values.to_set) ? true : false
  end

  def is_valid_state?(state)
    return @states.include?(state) ? true : false
  end

end

class StateError < StandardError
end

class RuleError < StandardError
end

