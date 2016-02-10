module.exports =
    ###*
     * Configuration settings.
    ###
    #config:

    ###*
     * The name of the package.
    ###
    #packageName: 'php-integrator-linter'

    ###*
     * The configuration object.
    ###
    configuration: null

    ###*
     * List of linters.
    ###
    providers: []

    ###*
     * List of indie linters.
    ###
    indieProviders: []

    ###*
     * The indexing indie linter.
    ###
    indexingIndieLinter: null

    ###*
     * Activates the package.
    ###
    activate: ->
        {CompositeDisposable} = require 'atom'

        @indieProviders = new CompositeDisposable()

        #@configuration = new AtomConfig(@packageName)

        Provider = require './Provider'

        #@providers.push(new Provider(@configuration))
        #@providers.push(new Provider())

    ###*
     * Deactivates the package.
    ###
    deactivate: ->
        @deactivateProviders()
        @indieProviders.dispose()

    ###*
     * Activates the providers using the specified service.
    ###
    activateProviders: (service) ->
        for provider in @providers
            provider.activate(service)

        for provider in @indieProviders
            provider.activate(service)

    ###*
     * Deactivates any active providers.
    ###
    deactivateProviders: () ->
        for provider in @providers
            provider.deactivate()

        @providers = []

        for provider in @indieProviders
            provider.deactivate()

        @indieProviders = []

    ###*
     * Sets the php-integrator service.
     *
     * @param {mixed} service
     *
     * @return {Disposable}
    ###
    setService: (service) ->
        @activateProviders(service)

        service.onDidFinishIndexing (response) =>
            # NOTE: A project index always "succeeds" as errors are ignored, but it may return errors anyway.
            return if not @indexingIndieLinter

            # Remove only messages pertaining to this file or items in this folder.
            filteredMessages = @indexingIndieLinter.messages.filter (value) =>
                return not value.filePath.startsWith(response.path)

            linterMessages = @convertIndexingErrorsToLinterMessages(response.output.errors)

            filteredMessages = filteredMessages.concat(linterMessages)

            @indexingIndieLinter.messages = filteredMessages
            @indexingIndieLinter.setMessages(filteredMessages)

        service.onDidFailIndexing (response) =>
            return if not @indexingIndieLinter

            # Filter out messages pertaining to the current file, but leave others intact.
            filteredMessages = @indexingIndieLinter.messages.filter (value) =>
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

            @indexingIndieLinter.messages = filteredMessages
            @indexingIndieLinter.setMessages(filteredMessages)

        {Disposable} = require 'atom'

        return new Disposable => @deactivateProviders()

    ###*
     * Handles indexing errors by passing them to the indie linter.
     *
     * @param {array} errors
     *
     * @return {array}
    ###
    convertIndexingErrorsToLinterMessages: (errors) ->
        # TODO: Support project indexing errors, response.path = null?

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
     * Sets the linter indie service.
     *
     * @param {mixed} service
     *
     * @return {Disposable}
    ###
    setLinterIndieService: (service) ->
        @indexingIndieLinter = service.register({name : 'php-integrator-linter', scope: 'project', grammarScopes: ['source.php']})
        @indexingIndieLinter.messages = []

        @indieProviders.add(@indexingIndieLinter)

    ###*
     * Retrieves a list of supported autocompletion providers.
     *
     * @return {array}
    ###
    getProviders: ->
        return @providers
