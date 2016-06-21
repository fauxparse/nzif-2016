class @SearchableList
  constructor: (el) ->
    @el = $(el)
      .on('input', 'header [type=search]', @search)

  search: (e) =>
    nResults = if searchText = $(e.target).val()
      escapedSearchText = searchText.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&")
      regex = new RegExp(escapedSearchText, 'i')
      @listItems().removeClass('first').hide()
        .filter ->
          regex.test($(this).find('[rel=edit]').text())
        .show()
        .first().addClass('first').end()
        .length
    else
      @listItems().show().removeClass('first').length
    @el.find('.empty').toggle(!nResults)

  listItems: ->
    @el.find('[role=listitem]')
