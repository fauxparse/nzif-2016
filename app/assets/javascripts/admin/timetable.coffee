class Timetable
  constructor: (el) ->
    @el = $(el)
    @el.find('header [rel=next]').click(@nextDay)
    @el.find('header [rel=prev]').click(@previousDay)
    @el.find('main > section').on('scroll', @scrolled)
    @activityList = new ActivityList(@el.find('main > footer'))
    @drag = dragula @containers(),
      copy: (el, source) -> $(source).attr('role') == 'group'
      accepts: (el, target) ->
        $target = $(target)
        return true if $target.is('[rel=trash]') &&
          $(el).is('[data-schedule-id')
        $target.attr('role') != 'group' &&
          !$target.has("[data-id=#{$(el).data('id')}]").length
    @drag.on 'drop', @drop
    @drag.on 'over', (el, target, source) -> $(target).addClass('over')
    @drag.on 'out', (el, target, source) -> $(target).removeClass('over')

  containers: ->
    [].concat(
      @el.find('footer [role=group]').get()
      @el.find('[role=gridcell]').get()
      @el.find('.timeslot').get()
      @el.find('[rel=trash]').get()
    )

  url: (path...) ->
    [location.pathname].concat(path).join('/')

  drop: (el, target, source, sibling) =>
    $target = $(target)
    role = $target.attr('role')
    if role == 'gridcell'
      $target = $('<div></div>').addClass('timeslot').appendTo(target)
      $target.append(el)
      @drag.containers.push $target.get(0)
    @moved(el, source, target)
    $(source).filter('.timeslot:empty').remove()

  moved: (el, source, target) ->
    $el = $(el)
    $target = $(target)
    $source = $(source)
    if $target.is('[rel=trash]')
      $.ajax
        url: @url('schedules', $el.data('schedule-id'))
        method: 'delete'
      $el.remove()
    else
      start = moment($target.data('time'))
      duration = parseInt($el.data('duration'), 10) * 30
      end = start.clone().add(duration, 'minutes')
      options =
        data:
          schedule:
            activity_id: $el.data('id')
            starts_at: start.toISOString()
            ends_at: end.toISOString()
            position: $el.prevAll().length
      if $source.is('.timeslot')
        options.url = @url('schedules', $el.data('schedule-id'))
        options.method = 'put'
      else
        options.url = @url('schedules')
        options.method = 'post'
      $.ajax(options)
        .done (data) -> $el.attr("data-schedule-id", data.id)

  days: ->
    @_days ||= @el.find('main section[role=row]')

  nextDay: =>
    day = $(@days().filter('[aria-selected=true]').next().get()
      .concat(@days().first().get())).first()
    day.attr('aria-selected', 'true')
      .siblings().attr('aria-selected', 'false').end()
    @el.find('header [rel=single]').text(day.data('title'))

  previousDay: =>
    day = $(@days().filter('[aria-selected=true]').prev(':not(header)').get()
      .concat(@days().last().get())).first()
    day.attr('aria-selected', 'true')
      .siblings().attr('aria-selected', 'false').end()
    @el.find('header [rel=single]').text(day.data('title'))

  scrolled: (e) =>
    section = $(e.target).closest('section')
    section.find('[role=rowheader]')
      .css(transform: "translateY(#{section.scrollTop()}px)")

class ActivityList
  constructor: (el) ->
    @el = el

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

  $('[data-controller=timetables]').each ->
    new Timetable(this)
