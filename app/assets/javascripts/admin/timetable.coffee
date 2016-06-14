class Timetable
  constructor: (el) ->
    @el = $(el)
    @el.find('header [rel=next]').click(@nextDay)
    @el.find('header [rel=prev]').click(@previousDay)
    @el.find('main > section').on('scroll', @scrolled)
    @activityList = new ActivityList(@el.find('main > footer'))
    @drag = dragula @containers(),
      copy: (el, source) -> $(source).attr('role') == 'group'
      accepts: (el, source) -> $(source).attr('role') != 'group'
    @drag.on 'drop', @drop

  containers: ->
    [].concat(
      @el.find('footer [role=group]').get()
      @el.find('[role=gridcell]').get()
    )

  drop: (el, target, source, sibling) =>
    $target = $(target)
    if $target.attr('role') == 'gridcell'
      $target = $('<div></div>').addClass('timeslot').appendTo(target)
      $target.append(el)
      @drag.containers.push $target.get(0)
    $(source).filter('.timeslot:empty').remove()

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
