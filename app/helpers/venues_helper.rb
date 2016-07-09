module VenuesHelper
  def venue_link(venue)
    if venue.present?
      link_to(venue.name, maps_url(venue), target: :_blank)
    else
      t('venues.none')
    end
  end

  def maps_url(venue)
    "http://maps.apple.com?q=#{ERB::Util.url_encode(venue.address)}"
  end
end
