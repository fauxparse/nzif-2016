class @Schedule
  constructor: (attrs) ->
    @id = m.prop(attrs.id)
    @start = m.prop(moment(attrs.start))
    @end = m.prop(moment(attrs.end))
    @activityId = m.prop(attrs.activity_id)

  range: ->
    moment.range(@start(), @end())

  overlaps: (another) ->
    @range().overlaps(another.range())

  length: ->
    @end().diff(@start())

  activity: ->
    Activity.find(@activityId())

  url: (path = '') ->
    location.pathname + '/schedules/' + @id() + path

  @fetch: (force = false) ->
    if force || !@loading
      @loading = m.deferred()
      m.request
        url: location.pathname + '?_=' + new Date().getTime()
        method: 'GET'
      .then (data) =>
        Activity.refresh(data.activities)
        @loading.resolve(@refresh(data.schedules, true))
    @loading.promise

  @all: m.prop([])

  @refresh: (data, clear = false) =>
    all = if clear then [] else @all().slice(0)
    all.push(new Schedule(attrs)) for attrs in data
    @all(all)
    @_byId = {}
    @_byId[schedule.id()] = schedule for schedule in @all()
    @all()

  @create: (attrs) ->
    m.computation => @refresh([attrs])

  @find: (id) ->
    @_byId[id]

  @overlapping: (range) ->
    (schedule for schedule in @all() when schedule.range().overlaps(range))

  @compare: (a, b) ->
    if a.start().isBefore(b.start())
      -1
    else if b.start().isBefore(a.start())
      1
    else
      rangeA = a.range()
      rangeB = b.range()
      if rangeA < rangeB
        1
      else if rangeB < rangeA
        -1
      else
        a.id() - b.id()

  @grouped: (schedules = @all()) ->
    overlapsGroup = (schedule, group) ->
      return true for s in group when schedule.overlaps(s)
      false
    schedules.sort(@compare).reduce (groups, schedule) ->
      group = g for g in groups when overlapsGroup(schedule, g)
      groups.push(group = []) unless group
      group.push(schedule)
      groups
    , []


class Activity
  constructor: (attrs) ->
    @id = m.prop(attrs.id)
    @name = m.prop(attrs.name)
    @type = m.prop(attrs.type)

  @all: m.prop([])

  @refresh: (data) =>
    @all((new Activity(attrs) for attrs in data))
    @_byId = {}
    @_byId[activity.id()] = activity for activity in @all()
    @all()

  @find: (id) ->
    @_byId[id]

class Editor
  @START_TIME: 18 # 9:00 AM
  @END_TIME:   54 # 3:00 AM
  @LENGTH:     @END_TIME - @START_TIME
  @SLOT_SIZE:  30

  constructor: (props) ->
    @dates = m.prop(moment.range(props.start(), props.end()).toArray('days'))
    @selected = props.selected
    Schedule.fetch()

  view: ->
    m('section', { class: 'edit-timetable', onscroll: @scrolled },
      m('.inner',
        m('section', { role: 'grid' },
          m('header', { role: 'row' }, @timeHeaders()),
          @days()
        )
      )
    )

  timeHeaders: ->
    (m('p', { role: 'columnheader' }, time.format('h:mm')) for time in @times())

  times: (date = @dates()[0]) ->
    (date.clone().startOf('day').add(i * 30, 'minutes') for i in [Editor.START_TIME...Editor.END_TIME])

  days: ->
    (@renderDay(date) for date in @dates())

  renderDay: (date) ->
    times = @times(date)
    range = moment.range(times[0], date.clone().add(27, 'hours'))
    m('section',
      {
        role: 'row'
        'aria-selected': @selected().isSame(date, 'day')
        'data-date': date.format('YYYY-MM-DD')
        'data-title': date.format('dddd, D MMMM')
        onmousedown: @startDraw
      },
      m('h3', { role: 'rowheader' }, date.format('dddd')),
      (m('section', {
        role: 'gridcell',
        'data-time': time.toISOString()
      }) for time in times),
      @renderSchedules(Schedule.overlapping(range))
    )

  datesFromConfig: ->
    start = moment(TimetableEditor.properties.start_date)
    end = moment(TimetableEditor.properties.end_date)
    moment.range(start, end).toArray('days')

  renderSchedules: (schedules) ->
    strategy = new LayoutSchedules(schedules)
    (@renderSchedule(layout.schedule, layout) for layout in strategy.layout())

  renderSchedule: (schedule, layout) ->
    maxWidth = 90
    morning = schedule.start().clone().subtract(5, 'hours').startOf('day')
      .add(Editor.START_TIME * Editor.SLOT_SIZE, 'minutes')
    start = schedule.start().diff(morning, 'minutes') / Editor.SLOT_SIZE
    length = schedule.end().diff(schedule.start(), 'minutes') / Editor.SLOT_SIZE

    style =
      width: maxWidth * layout.width / layout.columns
      left: maxWidth * layout.column / layout.columns
      top: start * 100.0 / Editor.LENGTH
      height: length * 100 / Editor.LENGTH

    activity = schedule.activity()

    m('article',
      {
        key: schedule.id()
        class: 'schedule'
        style: ("#{k}: #{v}%" for own k, v of style).join('; ')
        'data-schedule-id': schedule.id()
      }
      m('div',
        {
          class: activity.type()
          onmousedown: @startDrag
        }
        m('h4',
          m('a', { href: schedule.url('/edit'), rel: 'edit', 'data-dialog': 'edit-schedule' },
            schedule.activity().name()
          )
        )
      )
      m('hr', { onmousedown: @startResize })
    )

  startDrag: (e) =>
    e.preventDefault()
    e.stopPropagation()
    $el = $(e.target).closest('.schedule')
    offset = $el.offset()

    schedule = Schedule.find($el.attr('data-schedule-id'))

    @_drag =
      element: $el
      schedule: schedule
      time: schedule.start()
      offset:
        top: e.pageY - offset.top
        left: e.pageX - offset.left

    $(window)
      .on('mousemove.timetable', @drag)
      .on('mouseup.timetable', @endDrag)

  drag: (e) =>
    x = e.pageX - @_drag.offset.left
    parent = @_drag.element.closest('[role=grid]').find('section[role=row]').filter ->
      offset = $(this).offset()
      x >= offset.left && x < offset.left + $(this).width()
    .first()
    parent = @_drag.element.closest('section') unless parent.length
    parentOffset = parent.offset()
    y = (e.pageY - parentOffset.top - @_drag.offset.top)
    slot = Math.round(y * Editor.LENGTH / parent.height())
    time = moment(parent.attr('data-date'))
      .add((slot + Editor.START_TIME) * Editor.SLOT_SIZE, 'minutes')
    unless time.isSame(@_drag.time)
      @_drag.time = time
      @_drag.element.addClass('dragging').appendTo(parent).css
        top: "#{slot * 100.0 / Editor.LENGTH}%"

  endDrag: (e) =>
    $(window).off('.timetable')
    @_drag.element.removeClass('dragging')
    unless @_drag.time.isSame(@_drag.schedule.start())
      m.computation =>
        @_drag.schedule.end(@_drag.time.clone().add(@_drag.schedule.length()))
        @_drag.schedule.start(@_drag.time)

  startResize: (e) =>
    e.preventDefault()
    e.stopPropagation()
    $el = $(e.target).closest('.schedule')
    offset = $el.offset()

    schedule = Schedule.find($el.attr('data-schedule-id'))

    @_drag =
      element: $el
      schedule: schedule
      time: schedule.end()
      length: schedule.length() / Editor.SLOT_SIZE
      offset: offset.top + $el.height() - e.pageY

    $(window)
      .on('mousemove.timetable', @resize)
      .on('mouseup.timetable', @endResize)

  resize: (e) =>
    parent = @_drag.element.closest('section')
    parentOffset = parent.offset()
    y = e.pageY - parentOffset.top + @_drag.offset
    slot = Math.ceil(y * Editor.LENGTH / parent.height())
    time = moment(parent.attr('data-date'))
      .add((slot + Editor.START_TIME) * Editor.SLOT_SIZE, 'minutes')
    length = Math.max(1, time.diff(@_drag.schedule.start(), 'minutes') / Editor.SLOT_SIZE)
    unless length == @_drag.length
      @_drag.length = length
      @_drag.time = time
      @_drag.element.addClass('resizing').css
        height: "#{length * 100.0 / Editor.LENGTH}%"

  endResize: (e) =>
    $(window).off('.timetable')
    @_drag.element.removeClass('resizing')
    @_drag.schedule.end(@_drag.time)
    m.redraw(true)

  startDraw: (e) =>
    e.preventDefault()
    e.stopPropagation()
    parent = $(e.target).closest('[role=row]')
    parentOffset = parent.offset()
    y = e.pageY - parentOffset.top
    slot = Math.floor(y * Editor.LENGTH / parent.height())
    time = moment(parent.attr('data-date'))
      .add((slot + Editor.START_TIME) * Editor.SLOT_SIZE, 'minutes')
    schedule = new Schedule(start: time, end: time.clone().add(1, 'hour'))

    morning = schedule.start().clone().subtract(5, 'hours').startOf('day')
      .add(Editor.START_TIME * Editor.SLOT_SIZE, 'minutes')
    start = schedule.start().diff(morning, 'minutes') / Editor.SLOT_SIZE
    length = schedule.end().diff(schedule.start(), 'minutes') / Editor.SLOT_SIZE

    top = start * 100.0 / Editor.LENGTH
    height = length * 100 / Editor.LENGTH

    $el = $('<article>').addClass('drawing schedule').append($('<div>'))
      .appendTo(parent)
      .css(left: 0, width: '90%', top: "#{top}%", height: "#{height}%")

    @_drag =
      element: $el
      schedule: schedule
      time: schedule.end()
      length: schedule.length() / Editor.SLOT_SIZE
      offset: 0

    $(window)
      .on('mousemove.timetable', @resize)
      .on('mouseup.timetable', @endDraw)

  endDraw: (e) =>
    $(window).off('.timetable')
    url = location.pathname + '/schedules/new'
    url += "?schedule[starts_at]=#{@_drag.schedule.start().toISOString()}"
    url += "&schedule[ends_at]=#{@_drag.time.toISOString()}"
    dialog = new Dialog(url, 'new-schedule')
    dialog.contents()
      .on 'dialog:hide', =>
        @_drag.element.remove()
      .on 'dialog:success', (e, data) =>
        Schedule.create(data)

  scrolled: (e) =>
    requestAnimationFrame ->
      section = $(e.target).closest('section')
      section.find('[role=rowheader]')
        .css(transform: "translateY(#{section.scrollTop()}px)")

class LayoutSchedules
  constructor: (schedules) ->
    @_schedules = schedules

  layout: ->
    @_layout ||= @layoutSchedules(@_schedules)

  layoutSchedules: (schedules) ->
    Schedule.grouped(schedules).reduce(@layoutGroup, [])

  layoutGroup: (layout, group) =>
    fixed = []
    max = 0
    for schedule in group
      column = @findColumn(schedule, fixed)
      max = Math.max(column, max)
      fixed.push({ schedule, column })
    layout.push(@grow(f, fixed, max + 1)) for f in fixed
    layout

  findColumn: (schedule, fixed) ->
    for i in [0..fixed.length]
      return i if !@overlapsAtColumn(schedule, fixed, i)
    fixed.length

  grow: (blob, layout, columns) ->
    w = blob.column + 1
    w += 1 while w < columns && !@overlapsAtColumn(blob.schedule, layout, w)
    w -= blob.column
    { schedule: blob.schedule, column: blob.column, columns: columns, width: w }

  overlapsAtColumn: (schedule, layout, column) ->
    return true for f in layout when f.column == column && schedule.overlaps(f.schedule)
    false

# class Timetable
#   constructor: (el) ->
#     @el = $(el)
#     @el.find('header [rel=next]').click(@nextDay)
#     @el.find('header [rel=prev]').click(@previousDay)
#     @timetable = @el.find('main > section').on('scroll', @scrolled)
#     @activityList = new ActivityList(@el.find('main > footer'))
#     @drag = dragula @containers(),
#       moves: (el, source, handle, sibling) ->
#         !$(handle).is('hr')
#       copy: (el, source) -> $(source).attr('role') == 'group'
#       accepts: (el, target) ->
#         $target = $(target)
#         return true if $target.is('[rel=trash]') &&
#           $(el).is('[data-schedule-id')
#         $target.attr('role') != 'group' &&
#           !$target.has("[data-id=#{$(el).data('id')}]").length
#     @drag.on 'drop', @drop
#     @drag.on 'over', (el, target, source) -> $(target).addClass('over')
#     @drag.on 'out', (el, target, source) -> $(target).removeClass('over')
#     @el.on('mousedown', '.timetable-activity hr', @resize)

#   containers: ->
#     [].concat(
#       @el.find('footer [role=group]').get()
#       @el.find('[role=gridcell]').get()
#       @el.find('.timeslot').get()
#       @el.find('[rel=trash]').get()
#     )

#   url: (path...) ->
#     [location.pathname].concat(path).join('/')

#   drop: (el, target, source, sibling) =>
#     $target = $(target)
#     role = $target.attr('role')
#     if role == 'gridcell'
#       $target = $('<div></div>')
#         .addClass('timeslot')
#         .attr('data-time', $(target).attr('data-time'))
#         .appendTo(target)
#       $target.append(el)
#       @drag.containers.push $target.get(0)
#     @moved(el, source, target)
#     $(source).filter('.timeslot:empty').remove()

#   moved: (el, source, target) ->
#     $el = $(el)
#     $target = $(target)
#     $source = $(source)
#     if $target.is('[rel=trash]')
#       $.ajax
#         url: @url('schedules', $el.data('schedule-id'))
#         method: 'delete'
#       $el.remove()
#     else
#       start = moment($target.data('time'))
#       duration = parseInt($el.data('duration'), 10) * 30
#       end = start.clone().add(duration, 'minutes')
#       options =
#         dataType: 'json'
#         contentType: 'application/json'
#         data:
#           schedule:
#             activity_id: $el.data('id')
#             starts_at: start.toISOString()
#             ends_at: end.toISOString()
#             position: $el.prevAll().length
#       if $source.is('.timeslot')
#         options.url = @url('schedules', $el.data('schedule-id'))
#         options.method = 'put'
#       else
#         options.url = @url('schedules')
#         options.method = 'post'
#       options.data = JSON.stringify(options.data)
#       $.ajax(options)
#         .done (data) =>
#           $el
#             .attr("data-schedule-id", data.id)
#             .find("h4")
#             .html("<a href=\"#{data.url}\" rel=\"edit\" data-dialog=\"edit-schedule\">#{data.name}</a>")

#   days: ->
#     @_days ||= @el.find('main section[role=row]')

#   nextDay: =>
#     day = $(@days().filter('[aria-selected=true]').next().get()
#       .concat(@days().first().get())).first()
#     day.attr('aria-selected', 'true')
#       .siblings().attr('aria-selected', 'false').end()
#     @el.find('header [rel=single]').text(day.data('title'))

#   previousDay: =>
#     day = $(@days().filter('[aria-selected=true]').prev(':not(header)').get()
#       .concat(@days().last().get())).first()
#     day.attr('aria-selected', 'true')
#       .siblings().attr('aria-selected', 'false').end()
#     @el.find('header [rel=single]').text(day.data('title'))

#   scrolled: (e) =>
#     section = $(e.target).closest('section')
#     section.find('[role=rowheader]')
#       .css(transform: "translateY(#{section.scrollTop()}px)")

#   resize: (e) =>
#     $el = $(e.target).closest('.timetable-activity')
#     duration = parseInt($el.attr('data-duration'), 10)
#     height = $el.height()
#     blockSize = height / duration
#     top = $el.offset().top
#     offset = top - @timetable.scrollTop() + height - e.pageY
#     @timetable.on 'mousemove.resize-activity', (e) =>
#       h = e.pageY + offset - top + @timetable.scrollTop()
#       $el.attr('data-duration', Math.max(Math.round(h / blockSize), 1))
#     $(document).on 'mouseup.resize-activity', (e) =>
#       @timetable.off('.resize-activity')
#       $(document).off('.resize-activity')
#       end = moment($el.closest('.timeslot').attr('data-time'))
#         .add(parseInt($el.attr('data-duration'), 10) * 30, 'minutes')
#       $.ajax
#         url: @url('schedules', $el.attr('data-schedule-id') + '.json')
#         method: 'put'
#         data:
#           schedule:
#             ends_at: end.toISOString()

# class ActivityList
#   constructor: (el) ->
#     @el = el

EditorComponent =
  controller: (args...) ->
    new Editor(args...)

  view: (controller) ->
    controller.view()

@TimetableEditor =
  controller: (args...) ->
    start = moment(TimetableEditor.properties.start_date)
    end = moment(TimetableEditor.properties.end_date)
    {
      start: m.prop(start)
      end: m.prop(end)
      selected: m.prop(start)
    }

  view: (controller) ->
    [
      m('header',
        m('section',
          m('h1', TimetableEditor.properties.title)
          m('h2', { rel: 'range' }, TimetableEditor.properties.subtitle)
          m('h3', { rel: 'single' }, '')
        )
        m('aside',
          m('button',
            {
              rel: 'prev'
              disabled: controller.start().isSame(controller.selected())
              onclick: -> controller.selected(controller.selected().clone().subtract(1, 'day'))
            },
            m('i', { class: 'material-icons' }, 'keyboard_arrow_left')
          )
          m('button',
            {
              rel: 'next'
              disabled: controller.end().isSame(controller.selected())
              onclick: -> controller.selected(controller.selected().clone().add(1, 'day'))
            },
            m('i', { class: 'material-icons' }, 'keyboard_arrow_right')
          )
        )
      )
      m.component(EditorComponent, {
        start: controller.start
        end: controller.end
        selected: controller.selected
      })
    ]

document.addEventListener 'turbolinks:load', ->
  $(document).on 'mousedown', 'footer [role=separator]', (e) ->
    height = $('main').height()
    separator = $(e.target).closest('[role=separator]')
    footer = separator.closest('footer')
    offset = e.pageY - separator.offset().top

    $(document).on 'mousemove.resize-footer', (e) ->
      h = height - e.pageY + offset
      footer.css(height: "#{h * 100 / height}%")

    $(document).on 'mouseup.resize-footer', ->
      $(document).off('.resize-footer')

  # $('[data-controller=timetables]').each ->
  #   new Timetable(this)

  $(document).on 'dialog:loaded', '.new-schedule, .edit-schedule', (e) ->
    $('select', e.target).chosen(allow_single_deselect: true, search_contains: true)
