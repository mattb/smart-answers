require 'addressable/uri'

module GeoHelper
  def geo_known_to_at_least?(accuracy, geostack)
    options = ['point', 'postcode', 'postcode_district', 'ward', 'council', 'nation', 'country', 'planet']
    the_index = options.index(accuracy.to_s)
    geo_known_to?(geostack, *options.slice(0, the_index + 1))
  end

  def geo_known_to?(geostack, *accuracy)
    geo_header(geostack) and geo_header(geostack)['fuzzy_point'] and accuracy.include?(geo_header(geostack)['fuzzy_point']['accuracy'])
  end

  def geo_friendly_name(geostack)
    geo_header(geostack)['friendly_name']
  end

  def geo_header(geostack)
    if geostack and geostack != ''
      @geo_header ||= JSON.parse(Base64.decode64(geostack))
      @geo_header = false unless @geo_header['fuzzy_point'] and @geo_header['fuzzy_point']["lon"] != "0.0"
    else
      @geo_header ||= {}
    end
    @geo_header
  end
end
