$ = require 'jquery'

AbstractProvider = require "./AbstractProvider"

module.exports =

##*
# Provides linting for class names.
##
class ClassProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    scopes: ['.support.class', '.inherited-class']

    ###*
     * @inheritdoc
    ###
    performLintingAt: (editor, rangeStart, rangeEnd, text, scopeDescriptor) ->
        if rangeStart.column > 0
            # A namespace prefix, if it exists, is not included in the same scope, find it and prepend it.
            bufferPosition = {row: rangeStart.row, column: rangeStart.column - 1}
            scopeDescriptor = editor.scopeDescriptorForBufferPosition(bufferPosition).getScopeChain()

            movedAtLeastOnce = false

            while bufferPosition.column > 0 and scopeDescriptor.indexOf('.other.namespace') != -1
                --bufferPosition.column

                movedAtLeastOnce = true
                scopeDescriptor = editor.scopeDescriptorForBufferPosition(bufferPosition).getScopeChain()

            if movedAtLeastOnce
                ++bufferPosition.column

                namespace = editor.getTextInBufferRange([
                    bufferPosition,
                    [rangeStart.row, rangeStart.column]
                ])

                rangeStart = bufferPosition

                text = namespace + text

        # Callable is identified as class. See also https://github.com/atom/language-php/issues/108 .
        return null if text == 'callable'

        fullClassName = @service.determineFullClassName(editor, text)

        return null if not fullClassName

        return @service.getClassInfo(fullClassName, true).then (calledClassInfo) =>
            if not calledClassInfo?.wasFound
                message = "<strong>#{text}</strong> does not exist"

                return {
                    type     : 'Error'
                    html     : message
                    range    : [rangeStart, rangeEnd]
                    filePath : editor.getPath()
                }
