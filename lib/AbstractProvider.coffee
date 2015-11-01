{TextEditor} = require 'atom'

module.exports =

##*
# Base class for providers.
##
class AbstractProvider
    ###*
     * The grammar scope selectors for which linting triggers. This must be a root scope, such as .source.php.
    ###
    grammarScopes: null

    ###*
     * The class selectors for which linting triggers in the provider. Multiple scopes must not overlap for best
     # results.
    ###
    scopes: null

    ###*
     * The scope that this linter applies to.
    ###
    scope: 'file'

    ###*
     * Whether this linter supports linting on the fly or not.
    ###
    lintOnFly: false

    ###*
     * The service (that can be used to query the source code and contains utility methods).
    ###
    service: null

    ###*
     * Contains global package settings.
    ###
    config: null

    ###*
     * Constructor.
     *
     * @param {Config} config
    ###
    constructor: (@config) ->
        @grammarScopes = ['source.php']

    ###*
     * Initializes this provider.
     *
     * @param {mixed} service
    ###
    activate: (@service) ->

    ###*
     * Deactives the provider.
    ###
    deactivate: () ->

    ###*
     * Entry point for all requests from linter.
     *
     * @param {TextEditor} editor
     *
     * @return {Promise|array}
    ###
    lint: (editor) ->
        return new Promise (resolve, reject) =>
            suggestions = @performLinting(editor)

            if not suggestions
                suggestions = []

            resolve(suggestions)

    ###*
     * Performs the actual linting in the specified file.
     *
     * @param {TextEditor} editor
     *
     * @return {array}
    ###
    performLinting: (editor) ->
        messages = []

        rangeEnd = null
        rangeStart = null

        for line in [0 .. editor.getLineCount() - 1]
            lineText = editor.lineTextForBufferRow(line)

            for i in [0 .. lineText.length - 1]
                scopeDescriptor = editor.scopeDescriptorForBufferPosition([line, i]).getScopeChain()

                matchesScopes = false

                for scope in @scopes
                    if scopeDescriptor.indexOf(scope) != -1
                        matchesScopes = true
                        break

                if matchesScopes and not rangeStart
                    rangeStart =
                        row    : line
                        column : i

                else if not matchesScopes and rangeStart
                    rangeEnd =
                        row    : line
                        column : i

                    textInRange = editor.getTextInBufferRange([rangeStart, rangeEnd]).trim()

                    message = @performLintingAt(editor, rangeStart, rangeEnd, textInRange, scopeDescriptor)

                    if message
                        if not message.range    then message.range = [rangeStart, rangeEnd]
                        if not message.filePath then message.filePath = editor.getPath()

                        messages.push(message)

                    i = rangeEnd.column

                    if rangeEnd.row != line
                        line = rangeEnd.row
                        lineText = editor.lineTextForBufferRow(line)

                    rangeStart = null
                    rangeEnd = null

        return messages

    ###*
     * Performs linting at the specified location.
     *
     * @param {TextEditor} editor
     * @param {Point}      rangeStart
     * @param {Point}      rangeEnd
     * @param {string}     text
     * @param {string}     scopeDescriptor
     *
     * @return {Object|null} Either an object for linter or null if there is nothing to report. The range and filePath
     *                       will be automatically set if omitted.
    ###
    performLintingAt: (editor, rangeStart, rangeEnd, text, scopeDescriptor) ->
        throw new Error("This method is abstract and must be implemented!")
