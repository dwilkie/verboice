module Parsers
  module UserFlowNode
    class Branch < UserCommand
      attr_reader :id, :options, :name, :application

      def initialize application, params
        @id = params['id']
        @name = params['name'] || ''
        @options = params['options'].deep_clone || []
        @root_index = params['root']
        @application = application
        @next = params['next']
      end

      def solve_links_with nodes
        @options.each do |an_option|
          if an_option['next'] && !an_option['next'].is_a?(UserCommand)
            possible_nodes = nodes.select do |a_node|
              a_node.id == an_option['next']
            end
            if possible_nodes.size == 1
              an_option['next'] = possible_nodes.first
            else
              if possible_nodes.size == 0
                raise "There is no command with id #{an_option['next']}"
              else
                raise "There are multiple commands with id #{an_option['next']}: #{possible_nodes.inspect}."
              end
            end
          end
        end
        if @next && !@next.is_a?(UserCommand)
          possible_nodes = nodes.select do |a_node|
            a_node.id == @next
          end
          if possible_nodes.size == 1
            @next = possible_nodes.first
          else
            if possible_nodes.size == 0
              raise "There is no command with id #{@next}"
            else
              raise "There are multiple commands with id #{@next}: #{possible_nodes.inspect}."
            end
          end
        end
      end

      def is_root?
        @root_index.present?
      end

      def root_index
        @root_index
      end

      def equivalent_flow
        Compiler.parse do |c|
          c.Label @id
          c.Assign "current_step", @id
          @options.each_with_index do |an_option, index|
            c.If(merge_conditions_from(an_option['conditions'])) do |c|
              c.Trace(application_id: @application.id, step_id: @id, step_name: @name, store: "\"Branch number #{index + 1} selected: '#{an_option['description']}'\"")
              c.append(an_option['next'].equivalent_flow) if an_option['next']
              c.Goto("end#{@id}")
            end
          end
          c.Trace(application_id: @application.id, step_id: @id, step_name: @name, store: '"No branch was selected."')
          c.Label("end#{@id}")
          c.append(@next.equivalent_flow) if @next
        end
      end

      def merge_conditions_from conditions
        if conditions.nil? or conditions.empty?
          'true'
        else
          conditions.collect do |condition|
            "(value_#{condition['step']} #{condition['operator']} #{condition['value']})"
          end.join(' && ')
        end
      end

    end
  end
end