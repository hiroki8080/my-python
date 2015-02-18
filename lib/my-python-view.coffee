{View} = require 'atom'

module.exports =
class MyPythonView extends View

  debug_process: null
  line_number: 0
  path : null
  watch_value: null

  @content: ->
      @div =>
        @div class: 'header', =>
          @h3 "MyPythonView"
          @button click: 'run', class: 'btn', =>
              @span 'run'
          @button click: 'clear', class: 'btn', =>
              @span 'clear'
          @button click: 'debug', class: 'btn', =>
              @span 'debug'
          @button click: 'next', class: 'btn', =>
              @span 'next'
          @button click: 'watch', class: 'btn', =>
              @span 'watch'
          @button click: 'debug_end', class: 'btn', =>
              @span 'debug_end'
          @button click: 'close', class: 'btn', =>
            @span class: "icon icon-x"
            @span 'close'
        @div class: 'body', =>
          @pre class: 'message', =>
          @pre class: 'code', =>
          @pre class: 'variable', =>
        @div class: 'end-line', =>

  initialize: (serializeState) ->
    atom.commands.add 'atom-workspace',
      'my-python:run': => @run()
      'my-python:toggle': => @toggle()
      'my-python:debug': => @debug()
      'my-python:next': => @next()
      'my-python:watch': => @watch()
      'my-python:debug_end': => @debug_end()


  toggle: ->
    atom.workspace.addBottomPanel(item: this)

  run: ->
    @run_python(this)

  clear: ->
    this.find('.message').text("")
    this.find('.code').text("")
    this.find('.variable').text("")

  debug: ->
    @debug_python(this)

  next: ->
    @debug_python_next(this)

  watch: ->
    @debug_python_watch(this)

  debug_end: ->
    @debug_python_end(this)

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
          view.find('.message').append(stderr) if stderr

  debug_python: (view) ->
    activeEditor = atom.workspace.getActiveTextEditor()
    if activeEditor?.getPath()?
      path = activeEditor.getPath()
      if path.slice(-'.py'.length) == '.py'
        @path = path
        select = activeEditor.getSelectedScreenRange()
        @line_number = select.start.row + 1
        view.find('.code').append('debug start.\n')
        @debbug_cmd_continue(view)

  debug_python_next: (view) ->
    @line_number++
    @debbug_cmd_continue(view)
    if @watch != null
      @debbug_cmd_p(view)

  debug_python_watch: (view) ->
    activeEditor = atom.workspace.getActiveTextEditor()
    console.log('call watch')
    @watch = activeEditor.getSelectedText()
    console.log(@watch)
    if @watch != null
      view.find('.variable').append('watch ' + @watch + '\n')
      @debbug_cmd_p(view)

  debug_python_end: (view) ->
    view.find('.code').append('debug end.\n')
    @debug_process.kill()

  debbug_cmd_continue: (view) ->
    activeEditor = atom.workspace.getActiveTextEditor()
    view.find('.code').append('>' + activeEditor.lineTextForScreenRow(@line_number-1) + '\n')
    spawn = require('child_process').spawn
    child = spawn('python', ['-m', 'pdb', @path])
    @debug_process = child
    @debug_process.stdin.write('tbreak ' + @line_number + '\n')
    @debug_process.stdin.write('continue\n')
    @debug_process.stdin.end()

  debbug_cmd_p: (view) ->
    spawn = require('child_process').spawn
    child = spawn('python', ['-m', 'pdb', @path])
    child.stdout.on 'data', (data) ->
      value = data.toString()
      if /NameError/.exec(value)
      else
        result = value.match(/\s(.+?)\n/g)
        if result?
          view.find('.variable').append(result[result.length-1]);
    @debug_process = child
    @debug_process.stdin.write('tbreak ' + @line_number + '\n')
    @debug_process.stdin.write('continue\n')
    if @watch != null
      @debug_process.stdin.write('p ' + @watch + '\n')
    @debug_process.stdin.end()
