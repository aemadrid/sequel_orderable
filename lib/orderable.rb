module Sequel
  module Plugins
    # The orderable plugin allows for model instances to be part of an ordered list,
    # based on a 'position' field in the database.
    #
    #   Page.plugin :orderable, :field => :position, :scope => :parent_id
    #
    #   Sequel::Model.with_identity_map do
    #     Album.filter{id<100}.all do |a|
    #       a.review
    #     end
    #   end
    module Orderable

      def self.apply(model, opts = {})
        opts[:field] ||= :position

        position_field = opts[:field]
        scope_field = opts[:scope]
        if scope_field
          model.dataset.order!(scope_field, position_field)
        else
          model.dataset.order!(position_field)
        end

        model.instance_eval <<-CODE
          def orderable_options
            #{opts.inspect}
          end
        CODE
      end

      module InstanceMethods
        def orderable_position_field
          self.class.orderable_options[:field]
        end

        def orderable_position_value
          orderable_scope_field && @values[orderable_position_field]
        end

        def orderable_scope_field
          self.class.orderable_options[:scope]
        end

        def orderable_scope_value
          orderable_scope_field && @values[orderable_scope_field]
        end

        def at_position(p)
          if orderable_scope_field
            dataset.first orderable_scope_field => orderable_scope_value, orderable_position_field => p
          else
            dataset.first orderable_position_field => p
          end
        end

        def prev(n = 1)
          target = orderable_position_value - n
          # XXX: error checking, negative target?
          return self if orderable_position_value == target
          at_position target
        end

        def next(n = 1)
          target = orderable_position_value + n
          at_position target
        end

        def move_to(pos)
          # XXX: error checking, negative pos?
          cur_pos = orderable_position_value
          return self if pos == cur_pos

          db.transaction do
            if pos < cur_pos
              ds = dataset.filter orderable_position_field >= pos, orderable_position_field < cur_pos
              ds.filter! orderable_scope_field => orderable_scope_value if orderable_scope_field
              ds.update orderable_position_field => "#{orderable_position_field} + 1".lit
            elsif pos > cur_pos
              ds = dataset.filter orderable_position_field > cur_pos, position_field <= pos
              ds.filter! orderable_scope_field => orderable_scope_value if orderable_scope_field
              ds.update orderable_position_field => "#{orderable_position_field} - 1".lit
            end
            set orderable_position_field => pos
          end
        end

        def move_up(n = 1)
          # XXX: orderable_position_value == 1 already?
          self.move_to orderable_position_value - n
        end

        def move_down(n = 1)
          # XXX: what if we're already at the bottom
          self.move_to orderable_position_value + n
        end

        def move_to_top
          self.move_to 1
        end

        def move_to_bottom
          ds = dataset
          ds = ds.filter orderable_scope_field => orderable_scope_value if orderable_scope_field
          last = ds.select(:max[orderable_position_field] => :max).first.values[:max].to_i
          self.move_to last
        end
      end

    end
  end
end