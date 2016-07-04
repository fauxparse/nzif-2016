class Dialog
  constructor: (link) ->
    link = $(link)
    @load(link.attr('href'), link.attr('data-dialog'))

  load: (url, className) ->
    @_className = className
    @contents().load url, =>
      @contents().trigger('dialog:loaded').parent().addClass('in')

  contents: ->
    @_el ||= $('<div>', class: "dialog #{@_className}")
      .appendTo('body')
      .data(dialog: this)
      .wrap("<div class=\"dialog-container #{@_className}-container\">")

  close: =>
    @_el.parent()
      .transitionEnd =>
        @_el.parent().remove()
      .removeClass('in')

$(document)
  .on 'click', '[data-dialog]', (e) ->
    e.preventDefault()
    new Dialog($(e.target).closest('[data-dialog]'))
  .on 'click', '.dialog [rel=close]', (e) ->
    e.preventDefault()
    $(e.target).closest('.dialog').data('dialog').close()
  .on 'ajax:success', '.dialog form', (e, data, status, xhr) ->
    dialog = $(e.target).closest('.dialog')
    dialog.data('dialog').close()
    dialog.trigger('dialog:success', data)
  .on 'ajax:error', '.dialog form', (e, xhr, status, error) ->
    dialog = $(e.target).closest('.dialog')
    dialog.empty().append($(xhr.responseText).filter('form'))
    dialog.trigger('dialog:loaded')
