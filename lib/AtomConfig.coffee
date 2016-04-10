Config = require './Config'

module.exports =

##*
# Config that retrieves its settings from Atom's config.
##
class AtomConfig extends Config
    ###*
     * The name of the package to use when searching for settings.
    ###
    packageName: null

    ###*
     * @inheritdoc
    ###
    constructor: (@packageName) ->
        super()

        @attachListeners()

    ###*
     * @inheritdoc
    ###
    load: () ->
        @set('showUnknownClasses', atom.config.get("#{@packageName}.showUnknownClasses"))
        @set('showUnusedUseStatements', atom.config.get("#{@packageName}.showUnusedUseStatements"))
        @set('validateDocblockCorrectness', atom.config.get("#{@packageName}.validateDocblockCorrectness"))

    ###*
     * Attaches listeners to listen to Atom configuration changes.
    ###
    attachListeners: () ->
        atom.config.onDidChange "#{@packageName}.showUnknownClasses", () =>
            @set('showUnknownClasses', atom.config.get("#{@packageName}.showUnknownClasses"))

        atom.config.onDidChange "#{@packageName}.showUnusedUseStatements", () =>
            @set('showUnusedUseStatements', atom.config.get("#{@packageName}.showUnusedUseStatements"))

        atom.config.onDidChange "#{@packageName}.validateDocblockCorrectness", () =>
            @set('validateDocblockCorrectness', atom.config.get("#{@packageName}.validateDocblockCorrectness"))
