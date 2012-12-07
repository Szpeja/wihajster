module Boolean
end
TrueClass.send(:include, Boolean)
FalseClass.send(:include, Boolean)

module Typed
  require 'set'

  module ClassMethods
    def attributes
      @attributes ||= Set.new
    end

    def has(*args)
      if args.last.is_a?(Hash)
        o = args.pop
        kind = o[:kind]
        check = o[:check]
        default = o[:default]
        from = o[:from]
      end
      if args.last.is_a?(Class)
        kind = args.pop
      end

      args.each do |m|
        define_method("#{m}=") do |ov|
          v = from && from[ov.class] ? from[ov.class].call(ov) : ov
          if kind && !v.is_a?(kind)
            raise(TypeError, "When setting #{m} expected: #{kind}#{from ? " or "+from.keys.join(', ') : ""}, but got: #{ov.inspect}::#{ov.class}")
          end
          if check && (reason = check.call(v))
            raise(ArgumentError, "Expected #{v.inspect} to pass check. It's #{reason}")
          end

          instance_variable_set("@#{m}", v)
        end

        define_method(m) do
          v = instance_variable_get("@#{m}")
          v.nil? ? default : v
        end

        self.attributes.add m.to_sym
      end
    end

    def inherit_attributes
      if ancestor = ancestors.select{|a| a.respond_to?(:attributes) }[1]
        ancestor.attributes.each{|a| attributes.add a }
      end
    end

    def [](*args)
      new(*args)
    end
  end

  def initialize(*args)
    # We only want to assign values that are provided to us, not all defined.
    args.zip(self.class.attributes) do |value, name|
      self.send("#{name}=", value)
    end
  end

  def errors
    @errors ||= Set.new
  end

  def valid?
    errors.clear
    validate

    errors.empty?
  end

  def validate
  end

  def inspect
    attribute_values = self.class.attributes.map{|a| instance_variable_get("@#{a}").inspect }.join(", ")
    "#{self.class.name}[ #{attribute_values} ]"
  end

  def to_s
    inspect
  end

  class Base
    extend ClassMethods
    include ::Typed
  end
end
