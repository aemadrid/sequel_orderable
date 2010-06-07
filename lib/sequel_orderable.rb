module Sequel
  module Plugins
    # The orderable plugin allows for model instances to be part of an ordered list,
    # based on a 'position' field in the database.
    #
    #   Page.plugin :orderable, :field => :position, :scope => :parent_id
    #
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
          @values[orderable_position_field]
        end

        def orderable_scope_field
          self.class.orderable_options[:scope]
        end

        def orderable_scope_value
          orderable_scope_field && @values[orderable_scope_field]
        end

        def at_position(p)
          if orderable_scope_field
            self.class.dataset.first orderable_scope_field => orderable_scope_value, orderable_position_field => p
          else
            self.class.dataset.first orderable_position_field => p
          end
        end

        def prev(n = 1)
          target = orderable_position_value - n
          return self if orderable_position_value == target
          at_position target
        end

        def next(n = 1)
          target = orderable_position_value + n
          at_position target
        end

        def move_to(target)
          raise "Moving too far up" if target < 0
          raise "Moving too far down" if target > last_orderable_position
          current = orderable_position_value
          return self if target == current

          db.transaction do
            if target < current
              ds = self.class.dataset.filter "? >= ? AND ? < ?", orderable_position_field, target, orderable_position_field, current
              ds.filter! orderable_scope_field => orderable_scope_value if orderable_scope_field
              ds.update orderable_position_field => %Q{"#{orderable_position_field}" + 1}.lit
            else
              ds = self.class.dataset.filter "? > ? AND ? <= ?", orderable_position_field, current, orderable_position_field, target
              ds.filter! orderable_scope_field => orderable_scope_value if orderable_scope_field
              ds.update orderable_position_field => %Q{"#{orderable_position_field}" - 1}.lit
            end
            update orderable_position_field => target
          end
        end

        def move_up(n = 1)
          target = orderable_position_value - n
          raise "Moving too far up" if target < 0
          self.move_to target 
        end

        def move_down(n = 1)
          target = orderable_position_value + n
          raise "Moving too far down" if target > last_orderable_position
          self.move_to target
        end

        def move_to_top
          self.move_to 1
        end

        def move_to_bottom
          self.move_to last_orderable_position
        end

        def last_orderable_position
          ds = self.class.dataset
          ds = ds.filter orderable_scope_field => orderable_scope_value if orderable_scope_field
          ds.max(orderable_position_field).to_i
        end
      end

    end
  end
end