MyPythonView = require './my-python-view'

module.exports = MyPython =
  myPythonView: null
  activate: (state) ->
    @myPythonView = new MyPythonView(state.myPhthonViewState)

  deactivate: ->
    @myPythonView.destroy()
