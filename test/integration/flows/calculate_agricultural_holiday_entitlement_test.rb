# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateAgriculturalHolidayEntitlementTest < ActionDispatch::IntegrationTest
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'calculate-agricultural-holiday-entitlement'
  end

  should "ask what your days worked per week is" do
    assert_current_node :work_the_same_number_of_days_each_week?
  end

  context "Same number of days each week" do
    setup do
      add_response 'same-number-of-days'
    end

    should "ask how many days per week you work" do
      assert_current_node :how_many_days_per_week?
    end

    context "6 or more days" do
      setup do
        add_response '6-or-more-days'
      end

      should "ask if you worked for the same employer all year" do
        assert_current_node :worked_for_same_employer?
      end

      should "show outcome for only one employer" do
        add_response 'same-employer'
        assert_current_node :done
        assert_state_variable :holiday_entitlement_days, 38
      end

      should "ask for number of days worked" do
        add_response "multiple-employers"
        assert_current_node :how_many_total_days?
      end
    end
  end
end
