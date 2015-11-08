Utility = require './Utility'

##*
# Task that searches for (class) members.
##
module.exports = (text) ->
    callback = @async()

    memberRegex = /(?:(?:[a-zA-Z0-9_]*)\s*(?:\(.*\))?\s*(?:->|::)\s*)+([a-zA-Z0-9_]*(?:\(.*\))?)/g

    while (match = memberRegex.exec(text))
        rangeStart = Utility.calculatePointByIndex(text, match.index)

        rangeEnd =
            row    : rangeStart.row
            column : rangeStart.column + match[0].length;

        emit('found-member-match', {
            text       : match[1]
            rangeStart : rangeStart
            rangeEnd   : rangeEnd
        })

    callback()
