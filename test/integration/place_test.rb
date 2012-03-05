# encoding: UTF-8
require_relative '../integration_test_helper'
require_relative 'maternity_answer_logic'
require_relative 'smart_answer_test_helper'

class PlaceTest < ActionDispatch::IntegrationTest
  include SmartAnswerTestHelper

  context "an outcome with a place" do
    should "show a place box" do
      visit '/place-example-flow'
      assert_match /example/i, page.find("#wrapper h1").text

      click_on "Get started"
      expect_question "Question example"
      
      respond_with "one"
      assert page.has_css?(".places"), "Should have a places box present."
    end

    context "when provided with coordinates" do
      should "return nearest places in JSON" do
        post '/place-example-flow/y/one.json', { lat: 24.0312, lon: -3.141 }
        imminence_api.expects(:places).with('example', 24.0312, -3.141)
      end
    end
  end

end