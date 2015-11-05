{View} = require 'atom-space-pen-views'

module.exports =
# View for entering custom ranges
class TextPastryMultipleStringView extends View

    # Displays two divs with text and two input boxes for "start" and "step"
    # TODO submit button?
    @content: ->
        @div class: 'test overlay from-top', =>
            @div "Enter space-delimited words", class: "input-stuff"
            @input value:"", class:"input-multiple-strings inp1"

    # Initializes events for view
    initialize: (@submit) ->
        # Set up command for entering a custom range
        atom.commands.add 'atom-workspace', 'text-pastry:paste-multiple-strings', =>
            @open()
        view = this

        # If either input goes out of focus, close the dialog
        this.on "focus", "input", (event) ->
            view.nofocus = false

        this.on "blur", "input", (event) ->
            view.nofocus = true
            # A slight delay to allow the other text field to come into focus
            # if it doesn't, then close the dialog
            setTimeout ->
                if view.nofocus
                    view.detach()
            , 100

        this.on "keydown", ".inp1", (event) ->
            if (event.keyCode == 13)
                view.detach()
                if view.submit
                    view.submit(@value.split(" "))
            else if event.keyCode == 8
                # For some reason, inputs don't always allow backspacing, this
                # is a temporary fix
                if @value.length > 0
                    @value = @value.substr(0,@value.length-1)
                return false


      # Tear down any state and detach
    destroy: ->
        @detach()

    open: ->
        if @hasParent()
          @detach()
        else
          atom.workspace.append(this)
          @find("input").val("")
          @find("input")[0].focus()
