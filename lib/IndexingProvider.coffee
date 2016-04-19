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
     * A list of messages that are relevant and currently set in the indie linter.
    ###
    messages: null

    ###*
     * Timeout handle used to invoke the processing of the queue.
    ###
    queueProcessingTimeout: null

    ###*
     * A list of responses that have been queued for processing.
    ###
    responseQueue: null

    ###*
     * Constructor.
    ###
    constructor: () ->
        @messages = []
        @responseQueue = []

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
        @messages = []

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
            @responseQueue.push({
                method   : 'onDidFinishIndexing'
                response : response
            })

            @scheduleQueueProcessing()

        service.onDidFailIndexing (response) =>
            @responseQueue.push({
                method   : 'onDidFailIndexing'
                response : response
            })

            @scheduleQueueProcessing()

    ###*
     * Schedules processing of the queue to happen after a specific delay.
     *
     * @param {number} delay
    ###
    scheduleQueueProcessing: (delay = 25) ->
        if not @queueProcessingTimeout
            @queueProcessingTimeout = setTimeout ( =>
                @processQueueItems()
                @queueProcessingTimeout = null
            ), delay

    ###*
     * Processes all items currently in the queue.
    ###
    processQueueItems: () ->
        while @responseQueue.length > 0
            item = @responseQueue.pop()

            @processQueueItem(item)

    ###*
     * Processes the specified queue item.
     *
     * @param {mixed} service
    ###
    processQueueItem: (item) ->
        newMessages = @[item.method](item.response)

        if !newMessages
            return

        # *Apparently*, the linter package runs a "JSON.stringify" on each message and then sets it as the key of the
        # *same* message object. As objects are by reference and we're maintaining old messages with our internal
        # bookkeeping, the linter keeps re-stringifying the same object containing the previously stringified data,
        # making each message larger and larger, until it finally runs out of memory.
        for message in newMessages
            delete message.key

        @messages = newMessages

        if @indieLinter
            @indieLinter.setMessages(newMessages)

    ###*
     * Handles indexing finishing (successfully).
     *
     * @param {Object} response
     *
     * @return {array}
    ###
    onDidFinishIndexing: (response) ->
        return [] if not @indieLinter

        # Remove only messages pertaining to this file or items in this folder.
        filteredMessages = @messages.filter (value) =>
            return not value.filePath.startsWith(response.path)

        linterMessages = @convertIndexingErrorsToLinterMessages(response.output.errors)

        return filteredMessages.concat(linterMessages)

    ###*
     * Handles indexing failing.
     *
     * @param {Object} response
     *
     * @return {array}
    ###
    onDidFailIndexing: (response) ->
        return [] if not @indieLinter

        # Filter out messages pertaining to the current file, but leave others intact.
        filteredMessages = @messages.filter (value) =>
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
            filteredMessages.push({
                type     : 'Error'
                html     : 'Indexing failed and an invalid response was returned, something might be wrong with your setup!'
                filePath : response.path
                range    : [[0, 0], [0, 0]]
            })

        return filteredMessages
