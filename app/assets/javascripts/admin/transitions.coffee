EVENTS = 'transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd'

$.fn.transitionEnd = (callback) ->
  this.on EVENTS, (e) =>
    if this.index(e.target) > -1
      callback(e)
      this.off(EVENTS)
