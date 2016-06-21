document.addEventListener 'turbolinks:load', ->
  $('.participants').each -> new SearchableList(this)
