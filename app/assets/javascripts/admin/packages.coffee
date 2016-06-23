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

  $('.new-package, .edit-package')
    .on 'change', '[type=checkbox]', (e) ->
      $(e.target).nextAll('[type=number]').first()
        .attr(disabled: !e.target.checked).get(0).focus()
    .on 'click', '[rel=duplicate-price]', (e) ->
      e.preventDefault()
      li = $(e.target).closest('.price-with-expiry')
      li.clone().insertAfter(li)
    .on 'click', '[rel=delete-price]', (e) ->
      e.preventDefault()
      $(e.target).closest('.price-with-expiry').remove()
