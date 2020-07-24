# frozen_string_literal: true

class Hash
  def compact(opts = {})
    each_with_object({}) do |(k, v), new_hash|
      unless v.nil?
        new_hash[k.to_sym] = opts[:recurse] && v.class == Hash ? v.compact(opts) : v
      end
    end
  end

  def strip(opts = {})
    each_with_object({}) do |(k, v), new_hash|
      v = v.strip if v.class == String && v != ""
      new_hash[k.to_sym] = opts[:recurse] && v.class == Hash ? v.strip(opts) : v
    end
  end
end
