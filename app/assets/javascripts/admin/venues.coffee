class VenueManager
  constructor: (el) ->
    @el = $(el)
    @container = @el.find('.map')
    @list = @el.find('.list ul')
    @footer = @el.children('footer').first()
    mapboxgl.accessToken = 'pk.eyJ1IjoiZmF1eHBhcnNlIiwiYSI6ImNpcGx3MGRtbTAyZGN0eG00andtcHg2NHIifQ.ZSbjNkEtkpwtxrFlEQzEDA'
    @map = new mapboxgl.Map
      container: @container.get(0)
      style: 'mapbox://styles/fauxparse/cipm2sk380012beng3lbs8h3q'
      attributionControl: false
      center: [
        parseFloat(@container.data('longitude')),
        parseFloat(@container.data('latitude'))
      ]
      zoom: 16
    @map.addControl(new mapboxgl.Navigation(position: 'top-left'))

    @map.on 'load', =>
      @source = new mapboxgl.GeoJSONSource
        data:
          type: 'FeatureCollection'
          features: []
      @map.addSource('markers', @source)
      @map.addLayer
        id: 'markers'
        type: 'symbol'
        source: 'markers'
        layout:
          'icon-image': '{marker-symbol}-15'
          'text-field': '{title}'
          'text-size': 12
          'text-offset': [0, 0.6],
          'text-anchor': 'top'
        paint:
          'text-halo-color': 'rgb(255, 255, 255)'
          'text-halo-width': 1
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
    @list.find("[data-id=#{id}]").replaceWith(data)
    @updateMarkers()
    @footer.removeClass('editing')

  venueCreated: (e, data, status, xhr) =>
    @list.append(data)
    @updateMarkers()
    @footer.removeClass('editing')

  venueDeleted: (e, data, status, xhr) =>
    id = $(e.target).closest('form').data('id')
    @list.find("[data-id=#{id}]").remove()
    @updateMarkers()
    @footer.removeClass('editing')

  updateMarkers: ->
    features = @list.find('.venue').map (i, el) ->
      li = $(el)
      longitude = parseFloat(li.attr('data-longitude'))
      latitude = parseFloat(li.attr('data-latitude'))
      {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: [longitude, latitude]
        }
        properties: {
          title: li.find('[rel=name]').text()
          'marker-symbol': 'theatre'
        }
      }
    .get()
    @source.setData(type: 'FeatureCollection', features: features)

document.addEventListener 'turbolinks:load', ->
  $('[data-controller=venues] main').each -> new VenueManager(this)
