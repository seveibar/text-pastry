TextPastryView = require './text-pastry-view'

module.exports =
    view:null
    activate: (state) ->
        # Undo last selection
        atom.workspaceView.command "text-pastry:undo-last-selection", => @undo_last_selection()
        # Command for "0 to X" command
        atom.workspaceView.command "text-pastry:paste-0-to-x", => @paste_values(@step_generator(0, 1))
        # Command for "1 to X" command
        atom.workspaceView.command "text-pastry:paste-1-to-x", => @paste_values(@step_generator(1, 1))
        # Set up view for "Custom Range" command
        @view = new TextPastryView( (start, step) =>
            @paste_values(@step_generator(start,step)))

    deactivate: ->
        @view.destroy()

    # This will generate a function that returns the start value plus
    # the step value times the number of times it has been previously called
    # ex) if start = 0 and step = 1, the first call to the resulting function
    # will result in 0, second in 1, third in 2 etc.
    step_generator: (start,step) ->
        i = start
        ->
            ret = i
            i += step
            ret

    list_generator: (list) ->
        i = 0
        ->
            list[i++]

    get_buffer_range_at: (row,col) ->
        #TODO this should return an actual Range object
        return {start:[row,col],end:[row,col]}

    # This will insert values from the provided generator function to each
    # of the multiple carets.
    paste_values: (generator) ->

        editor = atom.workspace.getActiveEditor()

        # Get all the selected ranges (each multiple selection)
        selections = editor.getSelectedBufferRanges()

        # The new editor selections after all the insertions
        new_selections = []

        # Last row that was inserted to
        last_row = -1
        # Number of characters that have been inserted on last_row
        length_on_row = 0

        # Loop through each selection
        for i in [0...selections.length]

            # If we have already had a selection on this row, the position of
            # this selection has changed by the length of all previous
            # insertions
            if (selections[i].start.row != last_row)
                # If we are on a unique row, then there are no previous
                # selections on this row
                last_row = selections[i].start.row
                length_on_row = 0

            # Current placement of caret
            selection_row = selections[i].start.row
            selection_col = selections[i].start.column + length_on_row

            # Set editor selection to current caret
            editor.setSelectedBufferRange @get_buffer_range_at(
                selection_row, selection_col)

            # Get next value from generator
            ins_string = "#{generator()}"

            # Insert the value where the current caret is
            editor.insertText ins_string

            # Increase the number of characters on this row
            length_on_row += ins_string.length

            # Add the shifted selection region to new_selections
            # (when we're done, the caret will be reset to the proper place)
            new_selections.push(@get_buffer_range_at(
                selection_row, selection_col + ins_string.length))

        # Set the editor's selected regions to the proper place
        editor.setSelectedBufferRanges new_selections

        # Reclaim focus on editor if it was lost
        atom.workspaceView.focus()

    # Removes the last multiple selection/buffer range/ caret
    undo_last_selection: () ->

        editor = atom.workspace.getActiveEditor()

        # Get all the selected ranges (each multiple selection)
        selections = editor.getSelectedBufferRanges()

        # Remove the last selection
        selections.pop()

        # Reset the buffer ranges
        if (selections.length > 0)
            editor.setSelectedBufferRanges selections
