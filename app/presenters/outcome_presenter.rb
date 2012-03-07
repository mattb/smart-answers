require 'erubis'

class OutcomePresenter < NodePresenter

  include OutcomeHelper
  include GeoHelper

  def translate!(subkey)
    @places = @node.load_places(geo_header(@geostack)) || []

    form = Erubis::Eruby.new( File.read Rails.root.join('app','views','smart_answers','_location_form.html.erb') ).result(binding)

    output = super(subkey)
    output.nil? ? output : output.gsub(/\+\[location_form\]/,form)
  end

end
