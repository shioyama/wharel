require "wharel/version"
require "active_record"

module Wharel
  module QueryMethods
    %w[select where order having pluck group].each do |method_name|
      module_eval <<-EOM, __FILE__, __LINE__ + 1
      def #{method_name}(*, &block)
        block_given? ? super(VirtualRow.build_query(self, &block), &nil) : super
      end
      EOM
    end

    def or(*, &block)
      block_given? ? super(model.where(VirtualRow.build_query(self, &block))) : super
    end

    module WhereChain
      def not(*args, &block)
        block_given? ? super(VirtualRow.build_query(@scope, &block)) : super
      end
    end
  end

  class VirtualRow < BasicObject
    def initialize(klass)
      @klass = klass
    end

    def method_missing(m, *)
      @klass.column_names.include?(m.to_s) ? @klass.arel_table[m] : super
    end

    class << self
      def build_query(klass, &block)
        row = new(klass)
        query = block.arity.zero? ? row.instance_eval(&block) : block.call(row)
        ::ActiveRecord::Relation === query ? query.arel.constraints.inject(&:and) : query
      end
    end
  end
end

# Monkey-patch ActiveRecord. Should make this optional.
::ActiveRecord::Base.singleton_class.prepend ::Wharel::QueryMethods
::ActiveRecord::Relation.prepend ::Wharel::QueryMethods
::ActiveRecord::QueryMethods::WhereChain.prepend ::Wharel::QueryMethods::WhereChain
