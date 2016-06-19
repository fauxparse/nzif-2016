class VenueManager
  constructor: (el) ->
    @el = $(el)
    @container = @el.find('.map')
    @list = @el.find('.list ul')
    @footer = @el.children('footer').first()
    L.mapbox.accessToken = 'pk.eyJ1IjoiZmF1eHBhcnNlIiwiYSI6ImNpcGx3MGRtbTAyZGN0eG00andtcHg2NHIifQ.ZSbjNkEtkpwtxrFlEQzEDA'
    @map = L.mapbox.map(@container.get(0), 'mapbox.streets')
      .setView([
        parseFloat(@container.data('latitude'))
        parseFloat(@container.data('longitude'))
      ], 16)
    @updateMarkers()

    @el
      .on('click', '[rel=new]', @newVenue)
      .on('click', '[rel=edit]', @editVenue)
      .on('click', '[rel=cancel]', @hideForm)
      .on('ajax:error', '#form', @showFormErrors)
      .on('ajax:success', '.new-venue', @venueCreated)
      .on('ajax:success', '.edit-venue', @venueUpdated)
      .on('ajax:success', '[rel=delete]', @venueDeleted)

    dragula [@list.get(0)],
      moves: (el, container, handle) ->
        $(handle).attr('rel') == 'move'
    .on 'drop', (el, target, source, sibling) ->
      position = $(el).prevAll().length
      url = $('[rel=edit]', el).attr('href')
        .replace(/edit$/, 'reorder/' + position)
      $.ajax(url: url, method: 'put')

  newVenue: =>
    @footer.addClass('editing')
    $('.form', @footer).empty().load(location.pathname + '/new #form')

  editVenue: (e) =>
    e.preventDefault()
    @panToVenue(e.target)
    @footer.addClass('editing')
    url = $(e.target).closest('[href]').attr('href')
    $('.form', @footer).empty().load(url + ' #form')

  hideForm: (e) =>
    e.preventDefault()
    @el.find('form').attr(disabled: true)
    @footer.removeClass('editing')

  showFormErrors: (e, xhr, status, error) ->
    $(this).replaceWith($(xhr.responseText).find('#form'))

  venueUpdated: (e, data, status, xhr) =>
    id = $(e.target).data('id')
    li = @list.find("[data-id=#{id}]")
    marker = li.data('marker')
    li.replaceWith(data)
    li = @list.find("[data-id=#{id}]")
    li.data(marker: marker)
    @panToVenue(li)
    @updateMarkers()
    @footer.removeClass('editing')

  venueCreated: (e, data, status, xhr) =>
    @list.append(data)
    @panToVenue(@list.children().last())
    @updateMarkers()
    @footer.removeClass('editing')

  venueDeleted: (e, data, status, xhr) =>
    id = $(e.target).closest('form').data('id')
    li = @list.find("[data-id=#{id}]")
    @map.removeLayer(li.data('marker'))
    li.remove()
    @footer.removeClass('editing')

  updateMarkers: ->
    @list.find('.venue').each (i, el) =>
      li = $(el)
      latitude = parseFloat(li.attr('data-latitude'))
      longitude = parseFloat(li.attr('data-longitude'))
      geoJSON =
        type: 'Feature'
        geometry:
          type: 'Point'
          coordinates: [longitude, latitude]
        properties:
          title: li.find('[rel=name]').text()
          description: li.find('[rel=address]').text()
          id: li.attr('data-id')
          'marker-size': 'large',
          'marker-color': '#ff6447',
          'marker-symbol': 'theatre'

      if marker = li.data('marker')
        marker.setGeoJSON(geoJSON)
      else
        marker = L.mapbox.featureLayer(geoJSON)
        li.data(marker: marker)
        marker.addTo(@map)
        marker.on 'mouseover', (e) -> e.layer.openPopup()
        marker.on 'mouseout', (e) -> e.layer.closePopup()
        marker.on 'click', -> li.find('[rel=edit]').click()

  panToVenue: (venue) ->
    li = $(venue).closest('.venue')
    latitude = parseFloat(li.attr('data-latitude'))
    longitude = parseFloat(li.attr('data-longitude'))
    @map.panTo(L.latLng(latitude, longitude))

document.addEventListener 'turbolinks:load', ->
  $('[data-controller=venues] main').each -> new VenueManager(this)
