
module.exports =
    ###*
     * Calculates the point for the specified absolute index into the given text.
     *
     * @param {string} text
     * @param {number} index
     *
     * @return {Point}
    ###
    calculatePointByIndex: (text, index) ->
        point =
            row    : 0
            column : 0

        for i in [0 .. index - 1]
            if text[i] == "\n"
                ++point.row

                point.column = 0

            else
                ++point.column

        return point
