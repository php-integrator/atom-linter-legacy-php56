$ = require 'jquery'

AbstractProvider = require "./AbstractProvider"

module.exports =

##*
# Provides linting for class members and shows errors if they don't exist.
##
class MethodProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    scopes: ['.function-call.object', '.function-call.static']

    ###*
     * @inheritdoc
    ###
    performLintingAt: (editor, rangeStart, rangeEnd, text, scopeDescriptor) ->
        # Retrieve information about the class the method is being called on.
        calledClassInfo = null
        calledClass = @service.getCalledClass(editor, rangeStart)

        if calledClass
            calledClassInfo = @service.getClassInfo(calledClass)

        if calledClassInfo?.wasFound
            method = @service.getClassMethod(calledClass, text)

            if not method
                message = "<strong>#{calledClass}</strong> has no method <strong>#{text}</strong>"

                return {
                    type : 'Error'
                    html : message
                }

        else
            # TODO: The class is unknown, that is another error, which should be caught by a ClassProvider.
