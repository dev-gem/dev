# frozen_string_literal: true

puts __FILE__ if defined?(DEBUG)

class Hash
  def execute(value = nil)
    each do |k, v|
      v.update if v.respond_to?(:update)
      if v.is_a?(Array) && v.length.zero?
        delete k
      elsif v.respond_to?(:execute)
        v.execute(value)
      end
    end
  end

  def to_html
    [
      "<div>",
      map do |k, v|
        ["<br/><div><strong>#{k}</strong>", v.respond_to?(:to_html) ? v.to_html : "<span>#{v}</span></div><br/>"]
      end,
      "</div>",
    ].join
  end
end
