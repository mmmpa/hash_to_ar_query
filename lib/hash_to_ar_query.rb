module HashToArQuery
  def self.prepare(allow: {}, default: {})
    Builder.new(allow, default)
  end

  class Builder
    def initialize(allow, default)
      @allow = wrap_rule(allow)
      @default = default
    end

    def wrap_rule(hash)
      hash.inject({}) do |a, (k, v)|
        a.merge!(k => Set.new(value_to_sym_array(v)))
      end
    end

    def value_to_sym_array(value)
      Array(value).map { |n| n.to_s.to_sym }
    end

    def add(query_hash)
      params = build(query_hash)
      Enchanter.new(self, query_hash, params)
    end

    def build(hash)
      @allow.inject({}) do |a, (key, rule)|
        a.merge!(key => parse(key, rule, hash))
      end
    end

    def parse(key, rule, hash)
      value = hash[key] || default[key]
      return value if rule.include? :all

      if Array === value && rule.include?(:array)
        value.map { |v| convert(rule, v) }
      else
        convert(rule, value)
      end
    end

    def convert(rule, value)
      this_rule = rule.dup.delete(:all).delete(:array)
      begin
        case
          when this_rule.include?(:string)
            value.to_s
          when this_rule.include?(:integer)
            value.to_i
          when this_rule.include?(:float)
            value.to_i
          when this_rule.include?(:hash)
            value.to_h
          else
            nil
        end
      rescue
        nil
      end
    end
  end

  class Enchanter
    def initialize(builder, raw_query, params = {})
      @builder = builder
      @raw_query = raw_query
      @params = params
    end

    def addition
      @params
    end

    def add(query_hash)
      @builder.add(@raw_query.merge(query_hash))
    end

    def to(query)
      @params.inject(query) do |a, (k, v)|
        !!v ? a.send(k, v) : a
      end
    end
  end
end
