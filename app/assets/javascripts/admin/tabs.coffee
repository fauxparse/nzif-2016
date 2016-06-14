document.addEventListener 'turbolinks:load', ->
  $(document).on 'click', '[role=tab]', (e) ->
    tab = $(e.target).closest('[role=tab]')
    tab
      .attr('aria-selected', 'true')
      .siblings('[aria-selected=true]').attr('aria-selected', 'false').end()
    $("[role=tabpanel][data-tab='#{tab.data('tab')}'")
      .attr('aria-expanded', 'true')
      .siblings('[role=tabpanel][aria-expanded=true]')
        .attr('aria-expanded', 'false').end()
