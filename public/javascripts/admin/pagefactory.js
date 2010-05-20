Dropdown.PageFactoryTriggerBehavior = Behavior.create(Dropdown.TriggerBehavior, {
  initialize: function($super) {
    $super()
    this.menu = Dropdown.Menu.findOrCreate($('add_child_dropdown'))
  },
  onclick: function($super, event) {
    if(this.menu.wrapper.visible()) {
      $super(event)
    } else {
      new Ajax.Request(this.element.href, {
        method: 'get',
        onSuccess: function(data) {
          this.menu.element.innerHTML = data.responseText
          var factories = this.menu.element.childElements($$('li'))
          if(factories.length == 1) {
            window.location = factories[0].down().href
            event.stop()
          } else {
            $super(event)
          }
        }.bind(this).bind($super).bind(event)
      })
    }
    event.stop()
  }
})

Event.addBehavior({
  'a.dropdown': Dropdown.PageFactoryTriggerBehavior()
})