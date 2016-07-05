class Activity
  constructor: (attrs) ->
    for own key, value of attrs
      (@[key] ||= m.prop())(value)
    @was = $.extend({}, attrs)

  starts_at: (value) =>
    @_starts_at ||= m.prop()
    @_starts_at(value && moment(value)) if arguments.length
    @_starts_at().clone()

  ends_at: (value) =>
    @_ends_at ||= m.prop()
    @_ends_at(value && moment(value)) if arguments.length
    @_ends_at().clone()

  selected: (value) =>
    @_selected ||= m.prop()
    if arguments.length && (!value || !@full())
      @deselectOverlapping() if value
      @_selected(value)
    @_selected()

  full: (value) =>
    @_full ||= m.prop()
    @_full(value) if arguments.length
    @_full() && !@was.selected && !@selected()

  deselectOverlapping: ->
    for activity in Activity.all() when activity.id() != @id()
      activity.selected(false) if activity.overlaps(this)

  overlaps: (another) ->
    another.ends_at().isAfter(@starts_at()) &&
    another.starts_at().isBefore(@ends_at())

  @fetch: ->
    deferred = m.deferred()
    m.request
      url: location.pathname + '?_=' + new Date().getTime()
      method: 'GET'
    .then (data) =>
      Allocation.refresh(data.allocations)
      deferred.resolve(@refresh(data.activities))
    deferred.promise

  @all: m.prop([])

  @refresh: (data) =>
    @all((new Activity(attrs) for attrs in data))
    @_byType = {}
    (@_byType[activity.type()] ||= []).push(activity) for activity in @all()
    @all()

  @byType: (type) ->
    @_byType ||= {}
    @_byType[type] || []

  @grouped: ->
    grouped = {}
    for activity in @all()
      day = activity.starts_at().startOf('day')
      key = day.format('YYYY-MM-DD')
      grouped[key] ||= { date: day }
      (grouped[key][activity.type()] ||= []).push(activity)
    grouped

class Allocation
  constructor: (attrs) ->
    for own key, value of attrs
      (@[key] ||= m.prop())(value)

  selected: ->
    (activity for activity in Activity.byType(@type()) when activity.selected())

  count: ->
    @selected().length

  label: ->
    if @limit() == 1 then @singular() else @plural()

  @all: m.prop([])

  @refresh: (data) =>
    @all((new Allocation(attrs) for attrs in data))
    @all()

class Editor
  constructor: ->
    Activity.fetch()

  view: ->
    [
      m('header', { config: @initHeader },
        m('div', { class: 'inner' },
          m('ul', { class: 'counts' },
            (@renderAllocation(allocation) for allocation in Allocation.all())
          )
        )
      )
      m('section',
        m('div', { class: 'inner' },
          (@renderDay(day) for own _, day of Activity.grouped())
        )
      )
    ]

  initHeader: (header, isInitialized) ->
    unless isInitialized
      $header = $(header)
      $(window).on 'scroll', (e) ->
        top = $header.parent().offset().top
        $header.toggleClass('fixed', $('body').scrollTop() >= top)

  renderDay: (day) ->
    m('section', { class: 'day' },
      m('h2', day.date.format('dddd, D MMMM')),
      (@renderActivities(a, day[a.type()]) for a in Allocation.all())
    )

  renderActivities: (allocation, activities) ->
    return [] unless activities
    [
      m('h3', allocation.plural()),
      m('section', { role: 'list' }
        (@renderActivity(activity) for activity in activities)
        (m('div') for i in [0...4])
      )
    ]

  renderActivity: (activity) ->
    m('article', { role: 'listitem', 'aria-selected': activity.selected() },
      m('label',
        m('input', { type: 'checkbox', checked: activity.selected(), onclick: m.withAttr('checked', activity.selected) })
        m('img', { src: activity.image() })
        m('svg', { width: 40, height: 40, viewbox: '0 0 40 40' },
          m('circle', { cx: 20, cy: 20, r: 18 })
          m('path', { d: 'M 11.7 20.3 L 17 25.6 L 28.3 14.4' })
        )
      )
      m('div', { class: 'description' },
        m('p', { class: 'dates' }, activity.starts_at().format('h:mm A – ') + activity.ends_at().format('h:mm A'))
        m('h4', activity.name())
      )
    )

  renderAllocation: (allocation) ->
    pathLength = Math.PI * 36
    fraction = Math.min(1.0, allocation.count() * 1.0 / allocation.limit())
    m('li',
      m('svg', { width: 40, height: 40, viewbox: '0 0 40 40' },
        m('circle', { cx: 20, cy: 20, r: 18 })
        m('path', { d: 'M 20 2 A 18 18 0 1 1 20 38 A 18 18 0 1 1 20 2', style: "stroke-dasharray: #{pathLength}; stroke-dashoffset: #{pathLength * (1.0 - fraction)}" })
      )
      m('b', allocation.count())
      m('span', { rel: 'limit' }, "of #{allocation.limit()}")
      m('span', { rel: 'type' }, allocation.label())
    )

@ItineraryEditor =
  controller: (args...) ->
    new Editor(args...)

  view: (controller) ->
    controller.view()
