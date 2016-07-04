document.addEventListener 'turbolinks:load', ->
  $('select[multiple]').chosen(search_contains: true, enable_split_word_search: true)

  $('.activities').each -> new SearchableList(this)

  $(document).on 'dialog:success', '.new-facilitator', (e, data) ->
    select = $('#activity_facilitator_ids')
    selected = select.val()
    select.html(data)
    selected.push(select.find('[selected]').attr('value'))
    select.val(selected)
    select.trigger('chosen:updated')
