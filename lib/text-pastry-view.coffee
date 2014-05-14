{View} = require 'atom'

module.exports =
class TextPastryView extends View
    @content: ->
        @div class: 'test overlay from-top', =>
            @div "Start at ", class: "input-stuff"
            @input value:"", class:"input-text inp1"
            @div " and step up by ", class: "input-stuff"
            @input value:"", class:"input-text inp2"

    initialize: (@submit) ->
        atom.workspaceView.command "text-pastry:custom-range", => @toggle()
        view = this
        this.on "keydown", "input", (event) ->
            if (event.keyCode == 8)
                @value = ""

        this.on "focus", "input", (event) ->
            view.nofocus = false

        this.on "blur", "input", (event) ->
            view.nofocus = true
            setTimeout ->
                if view.nofocus
                    view.detach()
            , 100

        this.on "keydown", ".inp1", (event) ->
            if (event.keyCode == 13)
                view.find(".inp2").focus()

        this.on "keydown", ".inp2", (event) ->
            if (event.keyCode == 13)
                if (view.submit)
                    view.submit( parseInt(view.find(".inp1").val(),10), parseInt(view.find(".inp2").val(),10))
                view.detach()

      # Tear down any state and detach
    destroy: ->
        @detach()

    toggle: ->
        if @hasParent()
          @detach()
        else
          atom.workspaceView.append(this)
          @find("input").val("")
          @find("input")[0].focus()
