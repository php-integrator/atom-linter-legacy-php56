$ = require 'jquery'

AbstractProvider = require "./AbstractProvider"

module.exports =

##*
# Provides autocompletion for members of variables such as after ->, ::.
##
class MemberProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    performLinting: (editor) ->
        errors = []

        rangeEnd = null
        rangeStart = null

        for line in [0 .. editor.getLineCount() - 1]
            lineText = editor.lineTextForBufferRow(line)

            for i in [0 .. lineText.length - 1]
                scopeDescriptor = editor.scopeDescriptorForBufferPosition([line, i]).getScopeChain()

                isStaticMethodCall = (scopeDescriptor.indexOf('.function-call.static') != -1)
                isNonStaticMethodCall = (scopeDescriptor.indexOf('.function-call.object') != -1)

                isMethodCall = isNonStaticMethodCall or isStaticMethodCall

                if isMethodCall and not rangeStart
                    rangeStart =
                        row    : line
                        column : i

                else if not isMethodCall and rangeStart
                    rangeEnd =
                        row    : line
                        column : i

                    methodName = editor.getTextInBufferRange([rangeStart, rangeEnd])

                    calledClass = @service.getCalledClass(editor, rangeStart)

                    if calledClass
                        method = @service.getClassMethod(calledClass, methodName)

                        if not method
                            message = "<strong>#{calledClass}</strong> has no method <strong>#{methodName}</strong>"

                            errors.push({
                                type     : 'Error'
                                html     : message
                                range    : [rangeStart, rangeEnd]
                                filePath : editor.getPath()
                            })

                    else
                        # TODO: The class is unknown, that is another error.

                    i = rangeEnd.column

                    if rangeEnd.row != line
                        line = rangeEnd.row
                        lineText = editor.lineTextForBufferRow(line)

                    rangeStart = null
                    rangeEnd = null

        # TODO: Look at doing this async later (and resolving the promise when done).

        return errors
