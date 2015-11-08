Utility = require './Utility'

##*
# Task that searches for static access with class names.
##
module.exports = (text) ->
    callback = @async()

    staticClassAccessRegex = /((?:\\?[A-Z][a-zA-Z0-9_]+\\)*[A-Z][a-zA-Z0-9_]+)(?=::)/g

    while (match = staticClassAccessRegex.exec(text))
        rangeStart = Utility.calculatePointByIndex(text, match.index)

        rangeEnd =
            row    : rangeStart.row
            column : rangeStart.column + match[0].length;

        emit('found-direct-class-match', {
            name       : match[1]
            rangeStart : rangeStart
            rangeEnd   : rangeEnd
        })

    callback()
