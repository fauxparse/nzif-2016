$(document)
  .on 'turbolinks:load', ->
    $('.payments').each -> new SearchableList(this)
  .on 'ajax:start', '.payment a', (e) ->
    $(e.target).closest('a').attr(disabled: true)
  .on 'ajax:success', '.payment a', (e) ->
    $(e.target).closest('.payment').fadeOut -> $(this).remove()
  .on 'ajax:error', '.payment a', (e) ->
    $(e.target).closest('a').attr(disabled: false)
