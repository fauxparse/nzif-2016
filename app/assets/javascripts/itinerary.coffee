class Activity
  constructor: (attrs) ->
    for own key, value of attrs
      (@[key] ||= m.prop())(value)
    @was = $.extend({}, attrs)

  starts_at: (value) =>
    @_starts_at ||= m.prop()
    @_starts_at(value && moment(value)) if arguments.length
    @_starts_at()

  ends_at: (value) =>
    @_ends_at ||= m.prop()
    @_ends_at(value && moment(value)) if arguments.length
    @_ends_at()

  selected: (value) =>
    @_selected ||= m.prop()
    if arguments.length && (!value || !@full())
      @deselectOverlapping() if value
      @_selected(value)
    @_selected()

  full: (value) =>
    @_full ||= m.prop()
    @_full(value) if arguments.length
    @_full() && !(@was.selected && !@selected())

  deselectOverlapping: ->
    for activity in Activity.all() when activity.id() != @id()
      activity.selected(false) if activity.overlaps(this)

  overlaps: (another) ->
    another.ends_at().isAfter(@starts_at()) &&
    another.starts_at().isBefore(@ends_at())

  @fetch: ->
    deferred = m.deferred()
    m.request
      url: location.pathname
      method: 'GET'
    .then (data) =>
      deferred.resolve(@refresh(data.activities))
    deferred.promise

  @all: m.prop([])

  @refresh: (data) =>
    @all((new Activity(attrs) for attrs in data))
    @all()

class Editor
  constructor: ->
    Activity.fetch()

  view: ->
    [
      m('header',
        m('div', { class: 'inner' })
      )
      m('ul',
        (@renderActivity(activity) for activity in Activity.all())
      )
    ]

  renderActivity: (activity) ->
    m('li',
      m('input', { type: 'checkbox', checked: activity.selected(), onclick: m.withAttr('checked', activity.selected) }),
      m('b', activity.name()),
      m('i', activity.starts_at().format())
    )

@ItineraryEditor =
  controller: (args...) ->
    new Editor(args...)

  view: (controller) ->
    controller.view()
