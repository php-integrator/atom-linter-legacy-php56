{TextEditor, Task} = require 'atom'

module.exports =

##*
# The linter (provider).
##
class Provider
    ###*
     * The grammar scope selectors for which linting triggers. This must be a root scope, such as .source.php.
    ###
    grammarScopes: null

    ###*
     * The class selectors for which linting triggers in the provider. Multiple scopes must not overlap for best
     # results.
    ###
    scopes: null

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
     * A list of task files to execute.
    ###
    tasks: null

    ###*
     * Constructor.
     *
     * @param {Config} config
    ###
    constructor: (@config) ->
        @grammarScopes = ['source.php']

        @tasks = [
            './Tasks/MemberTask'
            './Tasks/StaticClassAccessTask'
        ]

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
        return new Promise (resolveLinting, rejectLinting) =>
            taskOutputPromises = []

            for taskName in @tasks
                taskPromises = []

                taskOutputPromise = new Promise (resolve, reject) =>
                    task = Task.once require.resolve(taskName), editor.getText(), =>
                        resolve Promise.all(taskPromises).then (messages) =>
                            messages = messages.filter (value) ->
                                return !!value

                            return messages

                    task.on('found-direct-class-match', (data) =>
                        # NOTE: The reason we don't just use scope descriptors to check everything is because access
                        # to the text editor needs to happen here, in the main thread (it can't be offloaded to the task
                        # without copying the entire text editor, which is very expensive).
                        scopeDescriptor = editor.scopeDescriptorForBufferPosition(data.rangeStart).getScopeChain()

                        return if scopeDescriptor.indexOf('.comment') != -1

                        fullClassName = @service.determineFullClassName(editor, data.name)

                        return if not fullClassName

                        # NOTE: getClassList is cached in the background, so there is no expensive refetching going on.
                        promise = @service.getClassList(true).then (classList) =>
                            if fullClassName not of classList
                                message = "<strong>#{data.name}</strong> does not exist"

                                return {
                                    type     : 'Error'
                                    html     : message
                                    range    : [data.rangeStart, data.rangeEnd]
                                    filePath : editor.getPath()
                                }

                        taskPromises.push(promise)
                    )

                    task.on('found-member-match', (data) =>
                        scopeDescriptor = editor.scopeDescriptorForBufferPosition(data.rangeStart).getScopeChain()

                        return if scopeDescriptor.indexOf('.comment') != -1

                        try
                            resultingType = @service.getResultingTypeAt(editor, data.rangeEnd, false)

                        catch error
                            message = "Member <strong>#{data.text}</strong> does not exist in class"

                            linterData = {
                                type     : 'Error'
                                html     : message
                                range    : [data.rangeStart, data.rangeEnd]
                                filePath : editor.getPath()
                            }

                            taskPromises.push new Promise (resolve, reject) =>
                                resolve(linterData)
                    )

                taskOutputPromises.push(taskOutputPromise)

            resolveLinting Promise.all(taskOutputPromises).then (messageArrays) =>
                flattenedMessageArray = []

                for messageArray in messageArrays
                    flattenedMessageArray = flattenedMessageArray.concat(messageArray)

                return flattenedMessageArray
