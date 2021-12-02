# frozen_string_literal: true

puts __FILE__ if defined?(DEBUG)

class String
  def fix(size, padstr = ' ')
    self[0...size].rjust(size, padstr)
  end
end
