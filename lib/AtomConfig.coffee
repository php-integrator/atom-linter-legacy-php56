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
        @set('showUnknownMembers', atom.config.get("#{@packageName}.showUnknownMembers"))
        @set('showUnknownGlobalFunctions', atom.config.get("#{@packageName}.showUnknownGlobalFunctions"))
        @set('showUnknownGlobalConstants', atom.config.get("#{@packageName}.showUnknownGlobalConstants"))
        @set('showUnusedUseStatements', atom.config.get("#{@packageName}.showUnusedUseStatements"))
        @set('showMissingDocs', atom.config.get("#{@packageName}.showMissingDocs"))
        @set('validateDocblockCorrectness', atom.config.get("#{@packageName}.validateDocblockCorrectness"))

    ###*
     * Attaches listeners to listen to Atom configuration changes.
    ###
    attachListeners: () ->
        atom.config.onDidChange "#{@packageName}.showUnknownClasses", () =>
            @set('showUnknownClasses', atom.config.get("#{@packageName}.showUnknownClasses"))

        atom.config.onDidChange "#{@packageName}.showUnknownMembers", () =>
            @set('showUnknownMembers', atom.config.get("#{@packageName}.showUnknownMembers"))

        atom.config.onDidChange "#{@packageName}.showUnknownGlobalFunctions", () =>
            @set('showUnknownGlobalFunctions', atom.config.get("#{@packageName}.showUnknownGlobalFunctions"))

        atom.config.onDidChange "#{@packageName}.showUnknownGlobalConstants", () =>
            @set('showUnknownGlobalConstants', atom.config.get("#{@packageName}.showUnknownGlobalConstants"))

        atom.config.onDidChange "#{@packageName}.showUnusedUseStatements", () =>
            @set('showUnusedUseStatements', atom.config.get("#{@packageName}.showUnusedUseStatements"))

        atom.config.onDidChange "#{@packageName}.showMissingDocs", () =>
            @set('showMissingDocs', atom.config.get("#{@packageName}.showMissingDocs"))

        atom.config.onDidChange "#{@packageName}.validateDocblockCorrectness", () =>
            @set('validateDocblockCorrectness', atom.config.get("#{@packageName}.validateDocblockCorrectness"))
