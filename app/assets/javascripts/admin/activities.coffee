document.addEventListener 'turbolinks:load', ->
  $('select[multiple]').chosen(search_contains: true)
