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
        assert_current_node :how_many_weeks_at_current_employer?
      end
    end

    context "5 to 6 days" do
      setup do
        add_response "5-to-6-days"
      end

      should "show outcome of holidays" do
        add_response "same-employer"
        assert_state_variable :holiday_entitlement_days, 35
      end
    end

    context "4 to 5 days" do
      setup do
        add_response "4-to-5-days"
      end

      should "show outcome of holidays" do
        add_response "same-employer"
        assert_state_variable :holiday_entitlement_days, 31
      end
    end

    context "3 to 4 days" do
      setup do
        add_response "3-to-4-days"
      end

      should "show outcome of holidays" do
        add_response "same-employer"
        assert_state_variable :holiday_entitlement_days, 25
      end
    end

    context "2 to 3 days" do
      setup do
        add_response "2-to-3-days"
      end

      should "show outcome of holidays" do
        add_response "same-employer"
        assert_state_variable :holiday_entitlement_days, 20
      end
    end

    context "1 to 2 days" do
      setup do
        add_response "1-to-2-days"
      end

      should "show outcome of holidays" do
        add_response "same-employer"
        assert_state_variable :holiday_entitlement_days, 13
      end
    end

    context "1 or less days" do
      setup do
        add_response "up-to-1-day"
      end

      should "show outcome of holidays" do
        add_response "same-employer"
        assert_state_variable :holiday_entitlement_days, 7.5
      end
    end
  end

  context "different number of days each week" do
    setup do
      add_response "different-number-of-days"
    end

    should "be able to enter the number of days I've worked" do
      assert_current_node :how_many_total_days?
    end

    context "100 days worked" do
      setup do
        add_response "100"
      end

      should "be asked when my holiday starts" do
        assert_current_node :what_date_does_holiday_start?
      end

      context "My holiday date is new year's day" do
        setup do
          add_response "2012-01-01"
        end

        should "be asked about my employer after holiday dates" do
          assert_current_node :worked_for_same_employer?
        end

        context "Worked for the same employer" do
          setup do
            add_response "same-employer"
          end

          should "be finished" do
            assert_current_node :done
          end

          should "be told my allowance" do
            assert_state_variable :holiday_entitlement_days, 5
          end
        end

        context "Worked for multiple employers" do
          setup do
            add_response "multiple-employers"
          end

          should "be asked how many weeks I've worked for this employer" do
            assert_current_node :how_many_weeks_at_current_employer?
          end
        end
      end
    end
  end
end
