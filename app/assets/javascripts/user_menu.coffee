UserMenuDropContext = Drop.createContext
  classPrefix: 'user-menu'

document.addEventListener 'turbolinks:load', ->
  $('.user-menu').each ->
    drop = new UserMenuDropContext
      target: $('.user-menu-target', this).get(0)
      content: $('> ul', this).get(0)
      openOn: 'click'
      position: 'bottom right'
