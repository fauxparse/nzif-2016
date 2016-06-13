class Timetable
  constructor: (el) ->
    @el = el
    $('header [rel=next]', @el).click(@nextDay)
    $('header [rel=prev]', @el).click(@previousDay)
    $('main > section', @el).on('scroll', @scrolled)

  days: ->
    @_days ||= $('main section[role=row]', @el)

  nextDay: =>
    day = $(@days().filter('[aria-selected=true]').next().get()
      .concat(@days().first().get())).first()
    day.attr('aria-selected', 'true')
      .siblings().attr('aria-selected', 'false').end()
    $('header [rel=single]', @el).text(day.data('title'))

  previousDay: =>
    day = $(@days().filter('[aria-selected=true]').prev(':not(header)').get()
      .concat(@days().last().get())).first()
    day.attr('aria-selected', 'true')
      .siblings().attr('aria-selected', 'false').end()
    $('header [rel=single]', @el).text(day.data('title'))

  scrolled: (e) =>
    section = $(e.target).closest('section')
    section.find('[role=rowheader]')
      .css(transform: "translateY(#{section.scrollTop()}px)")

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
