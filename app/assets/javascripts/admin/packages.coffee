document.addEventListener 'turbolinks:load', ->
  $('.package [rel=move]').closest('.packages').first().each ->
    dragula [this],
      moves: (el, container, handle) ->
        $(handle).attr('rel') == 'move'
    .on 'drop', (el, target, source, sibling) ->
      position = $(el).prevAll().length
      url = $('[rel=edit]', el).attr('href')
        .replace(/edit$/, 'reorder/' + position)
      $.ajax(url: url, method: 'put')

  $('.new_package, .edit_package')
    .on 'change', '[type=checkbox]', (e) ->
      $(e.target).nextAll('[type=number]').first()
        .attr(disabled: !e.target.checked).get(0).focus()
