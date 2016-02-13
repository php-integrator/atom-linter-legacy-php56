{TextEditor, Task} = require 'atom'

module.exports =

##*
# The (provider) that handles indexing errors using an indie linter.
##
class IndexingProvider
    ###*
     * The service (that can be used to query the source code and contains utility methods).
    ###
    service: null

    ###*
     * The indie linter.
    ###
    indieLinter: null

    ###*
     * Constructor.
    ###
    constructor: () ->

    ###*
     * Initializes this provider.
     *
     * @param {mixed} service
    ###
    activate: (@service) ->
        @attachListeners(@service)

    ###*
     * Deactives the provider.
    ###
    deactivate: () ->

    ###*
     * Sets the indie linter to use.
     *
     * @param {mixed} indieLinter
    ###
    setIndieLinter: (@indieLinter) ->
        if @indieLinter
            @indieLinter.messages = []

    ###*
     * Handles indexing errors by passing them to the indie linter.
     *
     * @param {array} errors
     *
     * @return {array}
    ###
    convertIndexingErrorsToLinterMessages: (errors) ->
        linterMessages = []

        for error in errors
            startLine = if error.startLine then error.startLine else 1
            endLine   = if error.endLine   then error.endLine   else 1

            startColumn = if error.startColumn then error.startColumn else 1
            endColumn =   if error.endColumn   then error.endColumn   else 1

            linterMessages.push({
                type     : 'Error'
                html     : error.message
                filePath : error.file
                range    : [[startLine - 1, startColumn - 1], [endLine - 1, endColumn]]
            })

        return linterMessages

    ###*
     * Attaches listeners for the specified base service.
     *
     * @param {mixed} service
    ###
    attachListeners: (service) ->
        service.onDidFinishIndexing (response) =>
            # NOTE: A project index always "succeeds" as errors are ignored, but it may return errors anyway.
            return if not @indieLinter

            # Remove only messages pertaining to this file or items in this folder.
            filteredMessages = @indieLinter.messages.filter (value) =>
                return not value.filePath.startsWith(response.path)

            linterMessages = @convertIndexingErrorsToLinterMessages(response.output.errors)

            filteredMessages = filteredMessages.concat(linterMessages)

            @indieLinter.messages = filteredMessages
            @indieLinter.setMessages(filteredMessages)

        service.onDidFailIndexing (response) =>
            return if not @indieLinter

            # Filter out messages pertaining to the current file, but leave others intact.
            filteredMessages = @indieLinter.messages.filter (value) =>
                return not value.filePath.startsWith(response.path)

            invalidOutput = false

            try
                decodedOutput = JSON.parse(response.error.rawOutput)

            catch error
                invalidOutput = true

            if not invalidOutput
                linterMessagesForFile = @convertIndexingErrorsToLinterMessages(decodedOutput.result.errors)

                filteredMessages = filteredMessages.concat(linterMessagesForFile)

            else
                @filteredMessages.push({
                    type     : 'Error'
                    html     : 'Indexing failed and an invalid response was returned, something might be wrong with your setup!'
                    filePath : response.path
                    range    : [[0, 0], [0, 0]]
                })

            @indieLinter.messages = filteredMessages
            @indieLinter.setMessages(filteredMessages)
