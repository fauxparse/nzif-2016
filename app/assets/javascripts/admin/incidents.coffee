document.addEventListener 'turbolinks:load', ->
  $('.incidents').each -> new SearchableList(this)

  $('.incident-comments .comment')
    .on 'click', '[rel=edit], [rel=cancel]', (e) ->
      e.preventDefault()
      $(e.target).closest('.comment').toggleClass('editing')
        .find('textarea:visible').focus()
