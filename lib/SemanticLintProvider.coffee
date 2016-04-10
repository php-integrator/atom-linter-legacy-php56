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
     * Attaches listeners for the specified base service.
     *
     * @param {mixed} service
    ###
    attachListeners: (service) ->
        service.onDidFinishIndexing (response) =>
            editor = @findTextEditorByPath(response.path)

            return if not editor?

            successHandler = (response) =>
                messages = []

                if response.errors.unknownClasses?
                    for item in response.errors.unknownClasses
                        messages.push @createLinterMessageForOutputItem(
                            editor,
                            item,
                            'Error',
                            '<strong>' + item.name + '</strong> was not found.'
                        )

                if response.warnings.unusedUseStatements?
                    for item in response.warnings.unusedUseStatements
                        messages.push @createLinterMessageForOutputItem(
                            editor,
                            item,
                            'Warning',
                            '<strong>' + item.name + '</strong> is not used anywhere.'
                        )

                if response.warnings.docblockIssues?
                    for item in response.warnings.docblockIssues.varTagMissing
                        messages.push @createLinterMessageForOutputItem(
                            editor,
                            item,
                            'Warning',
                            'The docblock for <strong>' + item.name + '</strong> is missing a @var tag.'
                        )

                    for item in response.warnings.docblockIssues.missingDocumentation
                        messages.push @createLinterMessageForOutputItem(
                            editor,
                            item,
                            'Warning',
                            'Documentation for <strong>' + item.name + '</strong> is missing.'
                        )

                    for item in response.warnings.docblockIssues.parameterMissing
                        messages.push @createLinterMessageForOutputItem(
                            editor,
                            item,
                            'Warning',
                            'The docblock for <strong>' + item.name + '</strong> is missing a @param tag for ' + item.parameter + '.'
                        )

                    for item in response.warnings.docblockIssues.parameterTypeMismatch
                        messages.push @createLinterMessageForOutputItem(
                            editor,
                            item,
                            'Warning',
                            'The docblock for <strong>' + item.name + '</strong> has an incorrect @param type for ' + item.parameter + '.'
                        )

                    for item in response.warnings.docblockIssues.superfluousParameter
                        messages.push @createLinterMessageForOutputItem(
                            editor,
                            item,
                            'Warning',
                            'The docblock for <strong>' + item.name + '</strong> contains superfluous @param tags for: ' + item.parameters.join(', ')
                        )

                if @indieLinter
                    @indieLinter.setMessages(messages)

            failureHandler = (response) =>
                if @indieLinter
                    @indieLinter.setMessages([])

            options = {
                noUnknownClasses      : not @config.get('showUnknownClasses')
                noDocblockCorrectness : not @config.get('validateDocblockCorrectness')
                noUnusedUseStatements : not @config.get('showUnusedUseStatements')
            }

            return @service.semanticLint(editor.getPath(), editor.getBuffer().getText(), options, true).then(successHandler, failureHandler)

        #service.onDidFailIndexing (response) =>
        #    return

    ###*
     * @param {TextEditor} editor
     * @param {Object}     item
     * @param {string}     type
     * @param {string}     html
     *
     * @return {Object}
    ###
    createLinterMessageForOutputItem: (editor, item, type, html) ->
        startPoint = editor.getBuffer().positionForCharacterIndex(item.start)
        endPoint   = editor.getBuffer().positionForCharacterIndex(item.end)

        return {
            type     : type
            html     : html
            range    : [startPoint, endPoint]
            filePath : editor.getPath()
        }

    ###*
     * Retrieves the text editor that is managing the file with the specified path.
     *
     * @param {string} path
     *
     * @return {TextEditor|null}
    ###
    findTextEditorByPath: (path) ->
        for textEditor in atom.workspace.getTextEditors()
            if textEditor.getPath() == path
                return textEditor

        return null
