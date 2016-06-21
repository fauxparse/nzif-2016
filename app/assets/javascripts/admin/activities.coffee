document.addEventListener 'turbolinks:load', ->
  $('select[multiple]').chosen(search_contains: true, enable_split_word_search: true)

  $('.activities header [type=search]').on 'input', (e) ->
    nResults = if searchText = $(e.target).val()
      escapedSearchText = searchText
        .replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&")
      regex = new RegExp(escapedSearchText, 'i')
      $('.activity').removeClass('first').hide()
        .filter ->
          regex.test($(this).find('a').text())
        .show()
        .first().addClass('first').end()
        .length
    else
      $('.activity').show().removeClass('first').length
    $('.activities .empty').toggle(!nResults)
