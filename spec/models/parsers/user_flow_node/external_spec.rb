# Copyright (C) 2010-2012, InSTEDD
#
# This file is part of Verboice.
#
# Verboice is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Verboice is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Verboice.  If not, see <http://www.gnu.org/licenses/>.

require 'spec_helper'

module Parsers
  module UserFlowNode
    describe External do

      let(:call_flow) { CallFlow.make }
      let(:external_service) { external_service_step.external_service }

      describe "variables type" do
        let(:external_service_step) { ExternalServiceStep.make :kind => 'callback', :response_type => 'variables'}

        it "should compile to an equivalent flow" do
          external = External.new call_flow, 'id' => 1,
            'type' => 'external',
            'name' => 'External Service',
            'external_step_id' => external_service_step.id

          external.equivalent_flow.first.should eq(
            Compiler.parse do |c|
              c.Label 1
              c.Assign 'current_step', 1
              c.Trace call_flow_id: call_flow.id, step_id: 1, step_name: 'External Service', store: %("Calling External Service #{external_service.name}.")
              c.Callback external_service_step.callback_url, {:response_type => :variables, :external_service_id => external_service.id}
            end.first
          )
        end

        it "should compile with variables definitions" do
          external = External.new call_flow, 'id' => 1,
            'type' => 'external',
            'name' => 'External Service',
            'external_step_id' => external_service_step.id,
            'settings' => [
              {'name' => 'variable_with_step', 'step' => 20},
              {'name' => 'variable_with_variable', 'variable' => 'foobar'},
              {'name' => 'variable_with_value', 'value' => 'fixed value'}
            ]

          external.equivalent_flow.first.should eq(
            Compiler.parse do |c|
              c.Label 1
              c.Assign 'current_step', 1
              c.Trace call_flow_id: call_flow.id, step_id: 1, step_name: 'External Service', store: %("Calling External Service #{external_service.name}.")
              c.RetrieveVariable 'foobar'
              c.Callback external_service_step.callback_url, {:response_type => :variables, :variables => {
                'variable_with_step' => 'value_20',
                'variable_with_variable' => 'var_foobar',
                'variable_with_value' => "'fixed value'"
              }, :external_service_id => external_service.id}
            end.first
          )
        end

        it "should compile with responses definitions" do
          external_service_step.tap do |s|
            s.response_variables = [
              ExternalServiceStep::Variable.new('response_one'),
              ExternalServiceStep::Variable.new('response_two')
            ]
          end.save!

          external = External.new call_flow, 'id' => 1,
            'type' => 'external',
            'name' => 'External Service',
            'external_step_id' => external_service_step.id,
            'responses' => [
              {'name' => 'response_one', 'variable' => 'my_var'}
            ]

          external.equivalent_flow.first.should eq(
            Compiler.parse do |c|
              c.Label 1
              c.Assign 'current_step', 1
              c.Trace call_flow_id: call_flow.id, step_id: 1, step_name: 'External Service', store: %("Calling External Service #{external_service.name}.")
              c.Callback external_service_step.callback_url, {:response_type => :variables, :external_service_id => external_service_step.external_service_id}
              c.Assign "external_1_response_one", 'response_response_one', :try
              c.PersistVariable "my_var", 'response_response_one'
              c.Assign "external_1_response_two", 'response_response_two', :try
            end.first
          )
        end

      end

      describe "flow type" do
        let(:external_service_step) { ExternalServiceStep.make :kind => 'callback', :response_type => 'flow'}

        it "should compile to an equivalent flow" do
          external = External.new call_flow, 'id' => 1,
            'type' => 'external',
            'name' => 'External Service',
            'external_step_id' => external_service_step.id

          external.equivalent_flow.first.should eq(
            Compiler.parse do |c|
              c.Label 1
              c.Assign 'current_step', 1
              c.Trace call_flow_id: call_flow.id, step_id: 1, step_name: 'External Service', store: %("Calling External Service #{external_service.name}.")
              c.Callback external_service_step.callback_url, {:response_type => :flow, :external_service_id => external_service.id}
            end.first
          )
        end
      end

      describe "none type" do
        let(:external_service_step) { ExternalServiceStep.make :kind => 'callback', :response_type => 'none'}

        it "should compile to an equivalent flow" do
          external = External.new call_flow, 'id' => 1,
            'type' => 'external',
            'name' => 'External Service',
            'external_step_id' => external_service_step.id

          external.equivalent_flow.first.should eq(
            Compiler.parse do |c|
              c.Label 1
              c.Assign 'current_step', 1
              c.Trace call_flow_id: call_flow.id, step_id: 1, step_name: 'External Service', store: %("Calling External Service #{external_service.name}.")
              c.Callback external_service_step.callback_url, {:response_type => :none, :external_service_id => external_service.id}
            end.first
          )
        end
      end

    end
  end
end