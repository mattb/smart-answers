# encoding: UTF-8
require_relative '../integration_test_helper'
require_relative 'maternity_answer_logic'
require_relative 'smart_answer_test_helper'

class ContactListTest < ActionDispatch::IntegrationTest
  include SmartAnswerTestHelper

  setup do
    
  end

  context "a flow with a contact list" do

    should "should display the contact list markup" do
      visit '/contact-list-example-flow'
      assert_match /example/i, page.find("#wrapper h1").text

      click_on "Get started"
      expect_question "Question example"
      
      respond_with "Turks and Caicos Islands"

      wait_until { page.has_content? "Reynholm Industries" }
    end

  end

end