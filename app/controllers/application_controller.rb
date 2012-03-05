require "slimmer/headers"
require 'gds_api/helpers'

class ApplicationController < ActionController::Base
  include Slimmer::Headers
  include GdsApi::Helpers

  before_filter :set_analytics_headers

protected
  def set_analytics_headers
    set_slimmer_headers(
      format:      "smart_answers",
      proposition: "citizen"
    )
  end
end
