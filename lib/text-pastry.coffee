module.exports =
    activate: ->
        atom.workspaceView.command "text-pastry:paste-0-to-x", => @paste_values(@step_generator(0, 1))
        atom.workspaceView.command "text-pastry:paste-1-to-x", => @paste_values(@step_generator(1, 1))

    step_generator: (start,step) ->
        i = start
        ->
            i += step
            i - step

    paste_values: (generator) ->
        # This assumes the active pane item is an editor
        editor = atom.workspace.getActiveEditor()

        selections = editor.getSelectedBufferRanges();

        new_selections = []

        last_row = -1
        length_on_row = 0

        for i in [0...selections.length]

            if (selections[i].start.row != last_row)
                last_row = selections[i].start.row
                length_on_row = 0

            loc = [
                selections[i].start.row
                selections[i].start.column + length_on_row
            ]
            # TODO actually create range object instead of making this fake one
            new_selection =
                start:loc
                end:loc
            editor.setSelectedBufferRange new_selection

            ins_string = "#{generator()}"
            editor.insertText ins_string

            length_on_row += ins_string.length

            loc = [
                selections[i].start.row
                selections[i].start.column + length_on_row
            ]
            new_selection =
                start:loc
                end:loc
            new_selections.push(new_selection)

        editor.setSelectedBufferRanges new_selections
