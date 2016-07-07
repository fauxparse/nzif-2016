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

  @selected: ->
    (activity for activity in @all() when activity.selected())

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
      m('header',
        m('div', { class: 'inner' },
          m('ul', { class: 'counts' },
            (@renderAllocation(allocation) for allocation in Allocation.all())
          )
          m('button', { rel: 'save', onclick: @save },
            m('svg', { width: 40, height: 40, viewbox: '0 0 40 40' },
              m('circle', { class: 'outline', cx: 20, cy: 20, r: 18 })
              m('path', { class: 'check', d: 'M 11.7 20.3 L 17 25.6 L 35.3 7.4' })
            )
            m('span', 'Save changes')
          )
        )
      )
      m('section', { config: @initScrolling },
        (@renderDay(day) for own _, day of Activity.grouped())
      )
    ]

  renderDay: (day) ->
    m('section', { class: 'day' },
      m('header',
        m('h2', day.date.format('dddd, D MMMM')),
      )
      (@renderActivities(a, day[a.type()]) for a in Allocation.all())
    )

  renderActivities: (allocation, activities) ->
    return [] unless activities
    [
      m('header',
        m('h3', allocation.plural()),
      )
      m('section',
        m('div', { role: 'list' },
          (@renderActivity(activity) for activity in activities)
          (m('div') for i in [0...4])
        )
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

  initScrolling: (body, isInitialized) =>
    unless isInitialized
      scrolled = @scrolled.bind(this, body)
      $(window).on 'scroll resize', -> requestAnimationFrame(scrolled)
      $(body).on 'click', '.day header', @dayHeaderClicked.bind(this, body)

  scrolled: (body) ->
    $body = $(body)
    $header = $body.prevAll('header').first()
    scrollTop = $(document).scrollTop()
    top = $header.parent().offset().top
    fixed = scrollTop >= top
    $header.toggleClass('fixed', fixed)
    if fixed
      headerBottom = $header.height()
      $body.find('.day').each (i, el) ->
        $day = $(el)
        y = headerBottom
        heights = $day.find('header').map(-> this.offsetHeight).get()
        allHeaderHeights = heights.reduce(((a, b) -> a + b), 0)
        bottom = offsetTop(this) + this.offsetHeight
        $day.find('header').each (j, el) ->
          top = offsetTop(this)
          max = bottom - allHeaderHeights - top
          offset = Math.max(0, Math.min(max, Math.min(max, scrollTop + y - top)))
          $(el).css(transform: "translateY(#{offset}px)")
          y += heights[j]
          allHeaderHeights -= heights[j]
    else
      $body.find('.day header').css(transform: 'translateY(0)')

  dayHeaderClicked: (body, e) ->
    $clicked = $(e.target).closest('header')
    $header = $(body).prev('header')
    $headers = $clicked.prevAll('header')
    top = offsetTop($clicked[0]) - $header.height() - $headers.map(-> this.offsetHeight).get().reduce(((a, b) -> a + b), 0)
    $('body').animate(scrollTop: top)

  save: (e) =>
    button = $(e.target).closest('button').attr('aria-busy', true)
    minimumTimeout = m.deferred()
    setTimeout ->
      minimumTimeout.resolve()
    , 1500

    m.request
      url: location.pathname.replace(/\/edit\/?$/, '')
      method: 'put'
      data:
        itinerary:
          selections: (activity.id() for activity in Activity.selected())
    .then ->
      minimumTimeout.promise.then ->
        button.addClass('done').find('.check').transitionEnd ->
          button.removeClass('done').attr('aria-busy', false)

offsetTop = (el) ->
  y = 0
  while el && !isNaN(el.offsetTop)
    y += el.offsetTop
    el = el.offsetParent
  y

@ItineraryEditor =
  controller: (args...) ->
    new Editor(args...)

  view: (controller) ->
    controller.view()
