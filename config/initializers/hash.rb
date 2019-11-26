# frozen_string_literal: true

class Hash
  def compact(opts = {})
    inject({}) do |new_hash, (k, v)|
      unless v.nil?
        new_hash[k.to_sym] = opts[:recurse] && v.class == Hash ? v.compact(opts) : v
      end
      new_hash
    end
  end

  def strip(opts = {})
    inject({}) do |new_hash, (k, v)|
      v = v.strip if v.class == String && v != ''
      new_hash[k.to_sym] = opts[:recurse] && v.class == Hash ? v.strip(opts) : v
      new_hash
    end
  end
end
