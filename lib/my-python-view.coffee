{View} = require 'atom'
module.exports =
class MyPythonView extends View
  @content: ->
      @div =>
        @div class: 'header', =>
          @h3 "MyPythonView"
          @button click: 'run', class: 'btn', =>
              @span 'run'
          @button click: 'clear', class: 'btn', =>
              @span 'clear'
          @button click: 'close', class: 'btn', =>
            @span class: "icon icon-x"
            @span 'close'
        @div class: 'body', =>
          @div class: 'message', =>

  initialize: (serializeState) ->
    atom.commands.add 'atom-workspace',
      'my-python:run': => @run()
      'my-python:toggle': => @toggle()


  toggle: ->
    atom.workspace.addBottomPanel(item: this)

  run: ->
    @run_python(this)

  clear: ->
    this.find('.message').text("")

  close: ->
    @detach()

  run_python: (view) ->
    activeEditor = atom.workspace.getActiveTextEditor()
    if activeEditor?.getPath()?
      path = activeEditor.getPath()
      if path.slice(-'.py'.length) == '.py'
        {exec} = require 'child_process'
        child = exec "python #{path}", (err, stdout, stderr) ->
          view.find('.message').append(stdout) if stdout
          view.find('.message').append('<br>')
          view.find('.message').append(stderr) if stderr
          view.find('.message').append('<br>')
