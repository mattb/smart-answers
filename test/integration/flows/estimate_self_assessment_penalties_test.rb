require_relative "../../test_helper"
require_relative "flow_test_helper"

class EstimateSelfAssessmentPenaltiesTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow "estimate-self-assessment-penalties"
  end

  should "ask whether self assessment tax return was submitted online or on paper" do
    assert_current_node :how_submitted?
  end

  context "online" do
    setup do
      add_response :online
    end

    should "ask when self assessment tax return was submitted" do
      assert_current_node :when_submitted?
    end

    context "a date" do
      setup do
        add_response "2012-01-01"
      end

      should "ask when bill was paid" do
        assert_current_node :when_paid?
      end

      context "paid on time" do
        setup do
          add_response "2012-01-02"
          calc = mock()
          SmartAnswer::Calculators::SelfAssessmentPenalties.expects(:new).
              with(
                submission_method: "online",
                filing_date: "2012-01-01",
                payment_date: "2012-01-02"
              ).returns(calc)
          calc.expects(:paid_on_time?).returns(true)
        end

        should "show result part two" do
          assert_current_node :result2
        end
      end

      context "paid late" do
        setup do
          add_response "2012-03-01"
          calc = mock()
          SmartAnswer::Calculators::SelfAssessmentPenalties.expects(:new).
              with(
              submission_method: "online",
              filing_date: "2012-01-01",
              payment_date: "2012-03-01"
          ).returns(calc)
          calc.expects(:paid_on_time?).returns(false)
        end

        should "ask how much you tax bill is" do
          assert_current_node :how_much_tax?
        end

        context "bill entered" do
          setup do
            add_response "12.50"
          end

          should "show results" do
            assert_current_node :result1
          end
        end

      end
    end
  end
end