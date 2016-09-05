class @Dialog
  constructor: (url, className) ->
    @load(url, className)

  load: (url, className) ->
    @_className = className
    @contents().load url, @loaded

  loaded: =>
    @contents().trigger('dialog:loaded').parent()
      .addClass('in')
      .transitionEnd =>
        @contents()
          .trigger('dialog:shown')
          .find(':input:visible').first().focus().select()
    @contents().trigger('dialog:show')

  contents: ->
    @_el ||= $('<div>', class: "dialog #{@_className}")
      .appendTo('body')
      .data(dialog: this)
      .wrap("<div class=\"dialog-container #{@_className}-container\">")

  close: =>
    @contents().trigger('dialog:hide')
    @_el.parent()
      .transitionEnd =>
        @contents().trigger('dialog:hidden')
        @_el.parent().remove()
      .removeClass('in')

$(document)
  .on 'click', '[data-dialog]', (e) ->
    e.preventDefault()
    link = $(e.target).closest('[data-dialog]')
    new Dialog(link.attr('href'), link.attr('data-dialog'))
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
