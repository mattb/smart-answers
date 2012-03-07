# encoding: UTF-8

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'minitest/unit'
require 'minitest/autorun'

require 'webmock/test_unit'

WebMock.disable_net_connect!(:allow_localhost => true)

require 'mocha'
