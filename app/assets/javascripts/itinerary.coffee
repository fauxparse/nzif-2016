class Price
  constructor: (attrs) ->
    attrs = attrs.attrs() if attrs instanceof Price
    for own key, value of attrs
      (@[key] ||= m.prop())(if typeof value == 'function' then value() else value)

  attrs: ->
    {
      amount: @amount()
      currency: @currency()
      symbol: @symbol()
    }

  amount: (value) =>
    @_amount = parseFloat(value) if value?
    @_amount

  format: (options = {}) ->
    m('span', { class: 'money' },
      m('span', "#{options.prefix || ''}#{@symbol()}#{Math.abs(options.amount ? @amount())}"),
      m('abbr', @currency())
    )

  diff: (another) ->
    new PriceDifference(this, another)

class PriceDifference
  constructor: (base, another) ->
    @base = m.prop(base)
    @amount = m.prop(base.amount() - another.amount())

  format: ->
    @base().format(amount: @amount(), prefix: @prefix())

  prefix: ->
    if @amount() < 0
      '-'
    else if @amount() > 0
      '+'
    else
      ''

  zero: ->
    Math.abs(@amount()) < 0.005

class @Activity
  constructor: (attrs) ->
    @was = $.extend({}, attrs)
    for own key, value of attrs
      (@[key] ||= m.prop())(value)

  starts_at: (value) =>
    @_starts_at ||= m.prop()
    @_starts_at(value && moment(value)) if arguments.length
    @_starts_at().clone()

  ends_at: (value) =>
    @_ends_at ||= m.prop()
    @_ends_at(value && moment(value)) if arguments.length
    @_ends_at().clone()

  selected: (value) =>
    @_selected ||= m.prop(false)
    if arguments.length && (!value || !@full())
      value = !!value
      if value == @was.selected || @canChange()
        @deselectOverlapping() if value
        @_selected(value)
    @_selected()

  facilitating: ->
    unless @_facilitating?
      @_facilitating = true for f in @facilitators() when f.id == Activity.current_participant_id()
      @_facilitating ?= false
    @_facilitating

  canChange: ->
    !@facilitating() &&
    @starts_at().isAfter(moment()) &&
    (!@full() || @was.selected) &&
    (@selected() || @overlappingAndFacilitating().length == 0)

  hasChanged: ->
    @selected() != @was.selected

  full: (value) =>
    @_full ||= m.prop()
    @_full(value) if arguments.length
    @_full() && !@was.selected && !@selected()

  deselectOverlapping: ->
    activity.selected(false) for activity in @clashes()

  overlaps: (another) ->
    another.ends_at().isAfter(@starts_at()) &&
    another.starts_at().isBefore(@ends_at())

  overlapping: =>
    (a for a in Activity.all() when a.id() != @id() && a.overlaps(this))

  overlappingAndFacilitating: ->
    @_overlappingAndFacilitating ||= (a for a in @overlapping() when a.facilitating())

  clashes: ->
    (a for a in @overlapping() when a.selected() || a.facilitating())

  @current_participant_id: m.prop()

  @fetch: (url = null) ->
    deferred = m.deferred()
    m.request
      url: (url || location.pathname) + '?_=' + new Date().getTime()
      method: 'GET'
    .then (data) =>
      Activity.current_participant_id(data.participant.id)
      Package.refresh(data.packages) if data.packages?
      Package.current(data.package_id)
      deferred.resolve(@refresh(data.activities))
    deferred.promise

  @all: m.prop([])

  @selected: ->
    (activity for activity in @all() when activity.selected())

  @refresh: (data) =>
    @all((new Activity(attrs) for attrs in data))
    @_byId = {}
    @_byId[activity.id()] = activity for activity in @all()
    @_byType = {}
    (@_byType[activity.type()] ||= []).push(activity) for activity in @all()
    @all()

  @byType: (type) ->
    @_byType ||= {}
    @_byType[type] || []

  @grouped: ->
    grouped = {}
    for activity in @all()
      day = activity.starts_at().clone().startOf('day')
      key = day.format('YYYY-MM-DD')
      grouped[key] ||= { date: day }
      (grouped[key][activity.type()] ||= []).push(activity)
    (grouped[key] for key in Object.keys(grouped).sort())

  @unsavedChanges: ->
    return true for a in @all() when a.hasChanged()
    false

class Allocation
  constructor: (attrs) ->
    attrs = attrs.attrs() if attrs instanceof Allocation
    for own key, value of attrs
      (@[key] ||= m.prop())(value)

  attrs: ->
    {
      singular: @singular(),
      plural: @plural(),
      limit: @limit(),
      type: @type()
    }

  selected: ->
    (activity for activity in Activity.byType(@type()) when activity.selected())

  count: ->
    @selected().length

  leftover: ->
    @limit() - @count()

  label: (count) ->
    word = if (count ? @count()) == 1 then @singular() else @plural()
    if count?
      count + ' ' + word
    else
      word

  diff: ->
    new Allocation(
      singular: @singular(),
      plural: @plural(),
      limit: @limit(),
      type: @type()
    )

  different: ->
    @count() != @limit()

class Package
  constructor: (attrs) ->
    for own key, value of attrs
      (@[key] ||= m.prop())(value)

  allocations: (values) =>
    if values?
      @_allocations = (new Allocation(attrs) for attrs in values when attrs.limit)
    @_allocations || []

  allocation: (type) ->
    return allocation for allocation in @allocations() when allocation.type() == type
    undefined

  totalCount: ->
    @allocations().reduce (total, allocation) ->
      total + allocation.count()
    , 0

  fits: (selection) =>
    for allocation in @allocations()
      return false if allocation.count() > allocation.limit()
    true

  price: (price) =>
    @_price = new Price(price) if price?
    @_price || new Price(amount: 0, currency: 'NZD', symbol: '$')

  description: ->
    sentence(allocation.label(allocation.limit()).toLowerCase() for allocation in @allocations())

  diff: (another) ->
    new Package(
      allocations: (a.diff() for a in @allocations() when a.different())
      price: @price().diff(another.price())
    )

  @current: (id) ->
    @_current = id if id?
    @_current && @find(@_current) || @maximum()

  @all: m.prop([])

  @sorted: ->
    @all().sort (a, b) -> a.totalCount() - b.totalCount()

  @maximum: ->
    sorted = @sorted()
    sorted.length && sorted[sorted.length - 1] || undefined

  @find: (id) ->
    return pkg for pkg in @all() when pkg.id().toString() == id.toString()
    undefined

  @refresh: (data) =>
    @all(new Package(attrs) for attrs in data)
    @all()

  @bestFit: (selected = Activity.selected()) ->
    return pkg for pkg in @all() when pkg.fits(selected)
    undefined

class PackageComparison
  constructor: (current) ->
    @current = m.prop(current)
    @priceDifference = m.prop(@bestFit().price().diff(current.price()))

  bestFit: ->
    @_best ||= Package.bestFit() || Package.maximum()

  maximum: ->
    @_maximum ||= Package.maximum()

  leftovers: ->
    @_leftovers ||= (a for a in @current().allocations() when a.leftover() > 0)

  extras: ->
    @_extras ||= (a for a in @current().allocations() when a.count() > a.limit())

  selections: ->
    @_selections ||= (a for a in @current().allocations() when a.count() > 0)

  overMax: ->
    max = @maximum()
    @_overMax ||= (a for a in @current().allocations() when a.count() > max.allocation(a.type()).limit())

  isSame: ->
    false

  isSamePackage: ->
    @current().id() == @bestFit().id()

  messages: ->
    messages = []
    msg = "You’ve paid for #{@current().description()}"
    only = if @selections().length && !@extras().length then ' only' else ''
    msg += ", but you’ve#{only} picked #{@selection(@selections())}" if @selections().length && (@extras().length || @leftovers().length)
    msg += "."
    messages.push(msg)
    messages.push("You’ll need to make some hard choices, or just pay the difference.") if @extras().length
    messages.push("You can pick an additional #{@selection(@leftovers(), count: 'leftover')}, or we’ll refund you the difference after the festival.") if @leftovers().length && @priceDifference().amount() < 0
    messages.push("You can still pick #{@selection(@leftovers(), count: 'leftover')} without paying any extra.") if @leftovers().length && @isSamePackage()
    messages.push("(Please note: the maximum you can pick is #{Package.maximum().description()}.)") if @overMax().length
    messages

  selection: (allocations, options = {}) ->
    options.count ?= 'count'
    sentence(a.label(a[options.count]()) for a in allocations).toLowerCase()

class ActivitySelector
  @controller: (options = {}) =>
    new this(options)

  @view: (controller) ->
    pkg = Package.current()
    m('section', { class: 'activity-selector', config: controller.initScrolling },
      (controller.renderDay(day, pkg) for day in Activity.grouped())
    )

  constructor: (options = {}) ->
    @options = $.extend({ model: 'itinerary' }, options)

  renderDay: (day, pkg) ->
    m('section', { class: 'day' },
      m('header',
        m('div', { class: 'inner' },
          m('h2', day.date.format('dddd, D MMMM'))
        )
      )
      (@renderActivities(a, day[a.type()]) for a in pkg.allocations())
    )

  renderActivities: (allocation, activities) ->
    return [] unless activities
    [
      m('header',
        m('div', { class: 'inner' },
          m('h3', allocation.plural())
        )
      )
      m('section',
        m('div', { role: 'list' },
          (@renderActivity(activity) for activity in activities)
          (m('div') for i in [0...4])
        )
      )
    ]

  renderActivity: (activity) ->
    inputOptions =
      name: "#{@options.model}[selections][]"
      value: activity.id()

    m('article', { role: 'listitem', 'aria-selected': activity.selected() || activity.facilitating(), 'data-id': activity.id(), 'data-full': activity.full(), 'data-mine': activity.facilitating() },
      m('label',
        (m('input[type="hidden"]', inputOptions) unless activity.canChange())
        m('input[type="checkbox"]', $.extend({}, inputOptions, checked: activity.selected(), disabled: !activity.canChange(), onchange: m.withAttr('checked', activity.selected)))
        m('img', { src: activity.image() })
        (m('svg', { width: 40, height: 40, viewbox: '0 0 40 40' },
          m('circle', { cx: 20, cy: 20, r: 18 })
          m('path', { d: 'M 11.7 20.3 L 17 25.6 L 28.3 14.4' })
        ) if activity.selected() || activity.canChange())
        (m('span.full', 'Full!') if activity.full())
      )
      m('div', { class: 'description' },
        m('a[rel="more"]', { href: activity.url(), onclick: ((e) => @zoomActivity(e, activity)) }, m('i.material-icons', 'info_outline'))
        m('p', { class: 'dates' }, activity.starts_at().format('h:mm A – ') + activity.ends_at().format('h:mm A'))
        m('h4', activity.name())
        (m('p', { class: 'facilitating' }, "Your #{activity.type()}") if activity.facilitating())
      )
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
    top = $header.parent().offset()?.top ? 0
    fixed = scrollTop >= top
    $header.toggleClass('fixed', fixed)
    if fixed
      headerBottom = $header.height()
      $body.css(paddingTop: headerBottom)
      $body.find('.day').each (i, el) ->
        dayTop = offsetTop(this)
        dayBottom = dayTop + this.offsetHeight
        if dayTop < (headerBottom + scrollTop) < dayBottom
          $day = $(el)
          y = headerBottom
          heights = $day.find('header').map(-> this.offsetHeight).get()
          allHeaderHeights = heights.reduce(((a, b) -> a + b), 0)
          $day.find('header').each (j, el) ->
            top = offsetTop(this)
            max = dayBottom - allHeaderHeights - top
            offset = Math.max(0, Math.min(max, Math.min(max, scrollTop + y - top)))
            $(el).find('.inner').addClass('fixed').css(top: top - scrollTop + offset)
            y += heights[j]
            allHeaderHeights -= heights[j]
        else
          $(el).find('.fixed').removeClass('fixed').css(top: 0)
    else
      $body
        .css(paddingTop: 0)
        .find('.fixed').removeClass('fixed').css(top: 0)

  dayHeaderClicked: (body, e) ->
    $clicked = $(e.target).closest('header')
    $header = $(body).prev('header')
    $headers = $clicked.prevAll('header')
    top = offsetTop($clicked[0]) - $header.height() - $headers.map(-> this.offsetHeight).get().reduce(((a, b) -> a + b), 0)
    $('body').animate(scrollTop: top)

  zoomActivity: (e, activity) ->
    e.preventDefault()
    zoomWindow = document.createElement('div')
    document.body.appendChild(zoomWindow)
    m.mount(zoomWindow, new ActivityViewer(activity))

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

class ActivityViewer
  constructor: (activity) ->
    @activity = m.prop(activity)

  controller: =>
    this

  view: (controller) =>
    m('article', { config: @show },
      m('button[rel="close"]', { onclick: @hide }, m('i.material-icons', 'close'))
      m('div.body', { onscroll: @scrolled },
        m('header',
          m('img', src: @activity().image())
          m('div.shim')
          m('h4', @activity().name())
        )
        (@clash(activity) for activity in @activity().clashes())
        m('div.text', { class: 'loading', config: @load })
      )
      m('footer',
        @stateButton()
      )
    )

  clash: (activity) ->
    m('div.clash',
      m('i.material-icons', 'warning')
      m('p', "Clashes with #{activity.name()}")
    )

  stateButton: ->
    if @activity().selected()
      m('button', { 'aria-selected': true, disabled: !@activity().canChange() || undefined, onclick: @toggle },
        m('i.material-icons', 'done')
        m('span', 'Selected')
      )
    else if @activity().full()
      m('button', { disabled: true },
        m('i.material-icons', 'block')
        m('span', "Sorry, this #{@activity().type()} is full!")
      )
    else
      m('button', { onclick: @toggle, disabled: !@activity().canChange() || undefined },
        m('i.material-icons', 'add')
        m('span', "Select this #{@activity().type()}")
      )

  load: (el, isInitialized) =>
    $(el).load @activity().url(), -> $(el).removeClass('loading')

  show: (el, isInitialized) =>
    unless isInitialized
      zoom = $(el).parent()
      zoom
        .addClass('zoomed-activity-window')
        .css(@originalPosition())
      $('body').trigger('scroll')

      requestAnimationFrame ->
        zoom.addClass('zoomed')

  hide: (e) =>
    e.preventDefault()
    activity = $(e.target).closest('article').addClass('fade')
    activity.parent()
      .transitionEnd (e) ->
        m.mount(e.target, null)
        $(e.target).remove()
        $('body').trigger('scroll')
      .css(@originalPosition())
      .removeClass('zoomed')

  originalPosition: =>
    article = $("article[data-id=#{@activity().id()}]")
    offset = article.offset()
    $.extend(offset, top: offset.top - $('body').scrollTop(), width: article.width(), height: article.height())

  toggle: =>
    m.computation =>
      @activity().selected(!@activity().selected())

  scrolled: (e) =>
    requestAnimationFrame ->
      body = $(e.target).closest('.body')
      header = body.find('header')
      heading = header.find('h4')
      space = header.height() - heading.height() - 32
      scrollTop = body.scrollTop()
      opacity = Math.min(1, scrollTop * 1.0 / space)
      header.find('.shim').css({ opacity })

      if scrollTop > space
        body.css(paddingTop: header.height())
        header.css(position: 'absolute', top: -space)
      else
        body.css(paddingTop: 0)
        header.css(position: 'relative', top: 0)

offsetTop = (el) ->
  y = 0
  while el && !isNaN(el.offsetTop)
    y += el.offsetTop
    el = el.offsetParent
  y

class @RegistrationActivitySelector
  @controller: (args...) =>
    new this(args...)

  @view: (controller) ->
    controller.view()

  constructor: (args...) ->
    Activity.fetch(@url())

  url: ->
    "/#{RegistrationActivitySelector.properties.year}/register/activities"

  view: ->
    [
      m('header',
        m('div.inner',
          m('p', RegistrationActivitySelector.properties.instructions)
        )
      )
      m.component(ActivitySelector, model: 'registration')
      m('footer',
        m('div.inner',
          @footerContent(Package.bestFit())
        )
      )
    ]

  footerContent: (pkg) ->
    [
      m.component(ActivityCounts)
      (pkg.price().format() if pkg)
      (@packageFormFields(pkg) if pkg)
      m('button[type="submit"]', { disabled: !pkg }, 'Continue')
    ]

  packageFormFields: (pkg) ->
    [
      @hidden('registration[package_id]', pkg.id())
    ]

  hidden: (name, value) ->
    m('input[type="hidden"]', { name: name, value: value })

class @ItineraryEditor
  @controller: (args...) =>
    new this(args...)

  @view: (controller) =>
    controller.view()

  constructor: ->
    Activity.fetch()
    $(window).on('beforeunload.unsaved-changes, turbolinks:before-visit.unsaved-changes', @promptToSaveChanges)

  view: ->
    comparison = new PackageComparison(Package.current())
    [
      @header(comparison)
      m.component(ActivitySelector, model: 'itinerary')
      @footer(comparison)
    ]

  header: (comparison) ->
    m('header', { config: @setupForm },
      m('div.inner',
        m.component(ActivityCounts)
        m('button[type="submit"]', { disabled: !!comparison.overMax().length }, m('span', 'Save changes'))
      )
    )

  footer: (comparison) ->
    messages = comparison.messages()
    hidden = !messages.length
    m('footer', { 'aria-hidden': hidden },
      m('div.inner',
        m('label[for="show-messages"]', { 'aria-hidden': hidden })
        m('input[type="checkbox"]#show-messages', { disabled: hidden }),
        m('div.messages',
          (m('p', message) for message in comparison.messages())
          m('label[for="show-messages"]',
            m('i.material-icons', 'close')
          )
        )
        comparison.priceDifference().format() unless comparison.priceDifference().zero()
      )
    )

  promptToSaveChanges: (e) =>
    if @unsavedChanges()
      message = 'You have unsaved changes. Do you really want to leave this page?'
      if e.type.match(/^turbolinks:/)
        if window.confirm(message)
          $(window).off('.unsaved-changes')
        else
          e.preventDefault()
      else
        e.returnValue = message
        return message
    else
      $(window).off('.unsaved-changes')
      undefined

  setupForm: (el) =>
    $(el).closest('form').on 'submit', =>
      @_saving = true
      $(window).off('.unsaved-changes')

  unsavedChanges: ->
    !@_saving && Activity.unsavedChanges()

sentence = (array) ->
  return array[0] || '' if array.length < 2
  array = array.slice()
  last = array.pop()
  join = if array.length > 1 then ', and ' else ' and '
  [array.join(', '), last].join(join)

class ActivityCounts
  @controller: (args...) =>
    new this(args...)

  @view: (controller) =>
    controller.view()

  view: =>
    max = Package.maximum()
    m('ul', { class: 'activity-counts' },
      (@renderAllocation(allocation, max.allocation(allocation.type())) for allocation in max.allocations() when allocation.limit())
    )

  renderAllocation: (allocation, max) ->
    pathLength = Math.PI * 36
    fraction = Math.min(1.0, allocation.count() * 1.0 / max.limit())
    m('li',
      m('svg', { width: 40, height: 40, viewbox: '0 0 40 40' },
        m('circle', { cx: 20, cy: 20, r: 18 })
        m('path', { d: 'M 20 2 A 18 18 0 1 1 20 38 A 18 18 0 1 1 20 2', style: "stroke-dasharray: #{pathLength}; stroke-dashoffset: #{pathLength * (1.0 - fraction)}" })
      )
      m('b', allocation.count())
      m('span', { rel: 'type' }, allocation.label())
    )

$(document)
  .on 'ajax:send', '[rel~=email-itinerary]', (e) ->
    $(e.target).closest('a').attr(disabled: true)
  .on 'ajax:success', '[rel~=email-itinerary]', (e) ->
    $(e.target).closest('a').find('i').text('done')
  .on 'ajax:error', '[rel~=email-itinerary]', (e) ->
    $(e.target).closest('a').find('i').text('close')
  .on 'ajax:complete', '[rel~=email-itinerary]', (e) ->
    $(e.target).closest('a').attr(disabled: false)
