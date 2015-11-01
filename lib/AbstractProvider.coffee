{TextEditor} = require 'atom'

module.exports =

##*
# Base class for providers.
##
class AbstractProvider
    ###*
     * The class selectors for which linting triggers.
    ###
    grammarScopes: ['source.php']

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
     * Preforms the actual linting in the specified file.
     *
     * @param {TextEditor} editor
     *
     * @return {array}
    ###
    performLinting: (editor) ->
        throw new Error("This method is abstract and must be implemented!")
