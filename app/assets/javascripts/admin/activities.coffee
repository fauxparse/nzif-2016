document.addEventListener 'turbolinks:load', ->
  $('#activity_facilitator_ids')
    .chosen(search_contains: true, enable_split_word_search: true)
    .on 'chosen:no_results', (e, data) ->
      li = data.chosen.search_results.find('.no-results')
      url = $(e.target).nextAll('a').attr('href')
      terms = li.find('span').text()
      li.empty()
        .append(
          $('<a>',
            href: "#{url}?participant[name]=#{escape(terms)}",
            "data-dialog": "new-facilitator",
            text: "Create ‘#{terms}’"
          )
        )

  $('#activity_related_activity_ids')
    .chosen(search_contains: true, enable_split_word_search: true)

  $('.activities').each -> new SearchableList(this)

  $(document)
    .on 'dialog:success', '.new-facilitator', (e, data) ->
      select = $('#activity_facilitator_ids')
      selected = select.val()
      select.html(data)
      selected.push(select.find('[selected]').attr('value'))
      select.val(selected)
      select.trigger('chosen:updated')
