$(document)
  .on 'turbolinks:load', ->
    $('.vouchers').each -> new SearchableList(this)

    $('#voucher_participant_id')
      .chosen(search_contains: true, enable_split_word_search: true)
