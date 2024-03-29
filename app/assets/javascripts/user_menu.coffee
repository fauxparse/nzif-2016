UserMenuDropContext = Drop.createContext
  classPrefix: 'user-menu'

document.addEventListener 'turbolinks:load', ->
  $('.user-menu').each ->
    drop = new UserMenuDropContext
      target: $('.user-menu-target', this).get(0)
      content: $('> ul', this).get(0)
      openOn: 'click'
      position: 'bottom right'
    .on 'open', ->
      $('.user-menu-content [rel=registered]')
        .not(':has(abbr)')
        .each ->
          $.get $(this).attr('href') + '.json', (data) =>
            count = 0
            count += 1 for own key, value of data when !value
            $(this).append($('<abbr>', text: count)) if count
