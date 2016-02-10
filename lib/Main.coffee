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
            if @indexingIndieLinter
                @indexingIndieLinter.setMessages([])

        service.onDidFailIndexing (response) =>
            if @indexingIndieLinter
                # TODO: Support project indexing errors, response.path = null?

                try
                    decodedOutput = JSON.parse(response.error.rawOutput)

                catch error
                    @indexingIndieLinter.setMessages([{
                        type     : 'Error'
                        html     : 'The current file could not be indexed, it might contain syntax or semantic errors!'
                        filePath : response.path
                    }])

                    return

                linterMessages = []

                for error in decodedOutput.result.errors
                    linterMessages.push({
                        type     : 'Error'
                        html     : error.message
                        filePath : error.file
                        range    : [[error.startLine - 1, error.startColumn - 1], [error.endLine - 1, error.endColumn - 1]]
                    })

                @indexingIndieLinter.setMessages(linterMessages)

        {Disposable} = require 'atom'

        return new Disposable => @deactivateProviders()

    ###*
     * Sets the linter indie service.
     *
     * @param {mixed} service
     *
     * @return {Disposable}
    ###
    setLinterIndieService: (service) ->
        @indexingIndieLinter = service.register({name : 'php-integrator-linter'})
        @indieProviders.add(@indexingIndieLinter)

    ###*
     * Retrieves a list of supported autocompletion providers.
     *
     * @return {array}
    ###
    getProviders: ->
        return @providers
