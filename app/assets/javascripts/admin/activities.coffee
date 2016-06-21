document.addEventListener 'turbolinks:load', ->
  $('select[multiple]').chosen(search_contains: true, enable_split_word_search: true)

  $('.activities').each -> new SearchableList(this)
