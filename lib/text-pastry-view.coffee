{View} = require 'atom-space-pen-views'

module.exports =
# View for entering custom ranges
class TextPastryView extends View

    # Displays two divs with text and two input boxes for "start" and "step"
    # TODO submit button?
    @content: ->
        @div class: 'test overlay from-top', =>
            @div "Start at ", class: "input-stuff"
            @input value:"", class:"input-text inp1"
            @div " and step up by ", class: "input-stuff"
            @input value:"", class:"input-text inp2"

    # Initializes events for view
    initialize: (@submit) ->
        # Set up command for entering a custom range
        atom.commands.add 'atom-workspace', 'text-pastry:custom-range', => @custom_range()
        view = this

        # If backspace is pressed, clear the input field
        this.on "keydown", "input", (event) ->
            if (event.keyCode == 8)
                @value = ""

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

        # When enter is pressed on the first input, move to the second
        this.on "keydown", ".inp1", (event) ->
            if (event.keyCode == 13)
                view.find(".inp2").focus()

        # When enter is pressed on the second input, perform the operation
        this.on "keydown", ".inp2", (event) ->
            if (event.keyCode == 13)
                if (view.submit)
                    view.submit( parseInt(view.find(".inp1").val(),10), parseInt(view.find(".inp2").val(),10))
                view.detach()

      # Tear down any state and detach
    destroy: ->
        @detach()

    custom_range: ->
        if @hasParent()
          @detach()
        else
          atom.workspace.append(this)
          @find("input").val("")
          @find("input")[0].focus()
