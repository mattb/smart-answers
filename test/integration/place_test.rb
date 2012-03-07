# encoding: UTF-8
require_relative '../integration_test_helper'
require_relative 'maternity_answer_logic'
require_relative 'smart_answer_test_helper'

class PlaceTest < ActionDispatch::IntegrationTest
  include SmartAnswerTestHelper

  setup do
    # mock the call to MaPit from Rack::Geo
    # Rack::Geo probably should mock its own requests in test helpers in the future

    areas = '{"1": {"codes": {"ons": "1"}, "name": "Airstrip One", "type": "DIS" }, "2": {"codes": {"ons": "2"}, "name": "Eurasia", "type": "CTY"}}'

    stub_request(:get, /http:\/\/mapit.mysociety.org\/point\/4326\/.*/).
     to_return(:status => 200, :body => areas)
  
    stub_request(:get, /http:\/\/mapit.mysociety.org\/postcode\/.*/).
      to_return(:status => 200, :body => '{"wgs84_lat": 24.0312, "coordsyst": "G", "shortcuts": {"ward": 1, "council": 2}, "wgs84_lon": -3.141, "postcode": "WC2B 6NH", "areas": ' + areas + '}')
  end

  context "an outcome with a place" do
    setup do
      @place_one = { '_id' => "abcde12345678",
        "location" => [
          24.0312,
          -3.141
        ],
        "name" => "Ministry of Truth",
        "latitude" => 24.0312,
        "longitude" => -3.141,
        "address" => ''
      }

      @place_two = { '_id' => "fghijk9123456",
        "location" => [
          24.0312,
          -3.141
        ],
        "name" => "Ministry of Love",
        "latitude" => 24.0312,
        "longitude" => -3.141,
        "address" => ''
      }

      options = { 'slug' => "example", 'details' => [@place_one, @place_two] }
      imminence_has_places("24.03", "-3.14", options)
      imminence_has_places("24.0312", "-3.141", options)

      imminence_has_places("52.01", "-1.8", { 'slug' => "example", 'details' => [] })
    end

    should "show a place box" do
      visit '/place-example-flow'
      assert_match /example/i, page.find("#wrapper h1").text

      click_on "Get started"
      expect_question "Question example"
      
      respond_with "one"
      
      wait_until { page.has_selector?("form#local-locator-form") }

      assert page.has_content? 'Enter a UK postcode'
      assert page.has_selector? '.found_location.hidden'

      fill_in "postcode", :with => 'WC2B 6NH'
      click_button "Find"

      wait_until { page.has_content? "Eurasia" }
      assert page.has_content? "Ministry of Truth"
    end

    context "when provided with coordinates" do
      should "return nearest places in JSON" do
        post '/place-example-flow/y/one.json', { :lat => '24.0312', :lon => '-3.141' }
        json = JSON.parse(response.body)

        assert_equal 2, json['places'].size
        assert_equal @place_one, json['places'].first
      end

      should "not return places if there are none nearby" do
        post '/place-example-flow/y/one.json', { :lat => '52.0101', :lon => '-1.800' }
        json = JSON.parse(response.body)

        assert_equal 0, json['places'].size
      end
    end
  end

end