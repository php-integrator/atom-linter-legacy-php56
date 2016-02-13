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
     * The indexing provider.
    ###
    indexingProvider: null

    ###*
     * Activates the package.
    ###
    activate: ->
        #@configuration = new AtomConfig(@packageName)

        IndexingProvider = require './IndexingProvider'

        @indexingProvider = new IndexingProvider()

        @indieProviders.push(@indexingProvider)

    ###*
     * Deactivates the package.
    ###
    deactivate: ->
        @deactivateProviders()

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
        indieLinter = null

        if service
            indieLinter = service.register({name : 'php-integrator-linter', scope: 'project', grammarScopes: ['source.php']})

        @indexingProvider.setIndieLinter(indieLinter)
        
    ###*
     * Retrieves a list of supported autocompletion providers.
     *
     * @return {array}
    ###
    getProviders: ->
        return @providers
