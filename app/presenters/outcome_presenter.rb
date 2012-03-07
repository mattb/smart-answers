require 'erubis'

class OutcomePresenter < NodePresenter

  include OutcomeHelper
  include GeoHelper

  def translate!(subkey)
    output = super(subkey)
    output.gsub!(/\+\[location_form\]/,location_form) unless output.nil?
    output.gsub!(/\+\[contact_list\]/,contact_list) unless output.nil?

    output
  end

  def location_form
    @places = @node.load_places(geo_header(@geostack)) || []
    form = Erubis::Eruby.new( File.read Rails.root.join('app','views','smart_answers','_location_form.html.erb') ).result(binding)
  end

  def contact_list
    @contact_list = @state.send(@node.contact_list_sym)
    Erubis::Eruby.new( File.read Rails.root.join('app','views','smart_answers','_contact_list.html.erb') ).result(binding)
  end

end
