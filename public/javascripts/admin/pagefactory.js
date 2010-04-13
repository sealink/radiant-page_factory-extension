Popup.PageFactoryTriggerBehavior = Behavior.create(Popup.TriggerBehavior, {
  initialize: function() {
    this.window = new Popup.PageFactoryWindow(this.element.href);
  },
});

Popup.PageFactoryWindow = Class.create(Popup.AjaxWindow, {
  show: function($super) {
      new Ajax.Updater(this.content, this.url, {asynchronous: false, method: "get", evalScripts: true,
                         onComplete: function(response) { response.getHeader('Location') ? window.location.href = response.getHeader('Location') : $super() }
                       })
  },
});

Event.addBehavior({
  'a.popup-factory': Popup.PageFactoryTriggerBehavior(),
})