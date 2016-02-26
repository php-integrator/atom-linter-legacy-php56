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

                for unknownClass in response.errors.unknownClasses
                    startPoint = editor.getBuffer().positionForCharacterIndex(unknownClass.start)
                    endPoint   = editor.getBuffer().positionForCharacterIndex(unknownClass.end)

                    messages.push({
                        type     : 'Error'
                        html     : '<strong>' + unknownClass.name + '</strong> was not found.'
                        range    : [startPoint, endPoint]
                        filePath : editor.getPath()
                    })

                for unusedUseStatement in response.warnings.unusedUseStatements
                    startPoint = editor.getBuffer().positionForCharacterIndex(unusedUseStatement.start)
                    endPoint   = editor.getBuffer().positionForCharacterIndex(unusedUseStatement.end)

                    messages.push({
                        type     : 'Warning'
                        html     : '<strong>' + unusedUseStatement.name + '</strong> is not used anywhere.'
                        range    : [startPoint, endPoint]
                        filePath : editor.getPath()
                    })

                @indieLinter.setMessages(messages)

            failureHandler = (response) =>
                @indieLinter.setMessages([])

            return @service.semanticLint(editor.getPath(), editor.getBuffer().getText(), true).then(successHandler, failureHandler)

        #service.onDidFailIndexing (response) =>
        #    return

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
