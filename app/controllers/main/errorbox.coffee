Spine   = require('spine')
$       = Spine.$

class ErrorBox extends Spine.Controller
  className: 'error'

  constructor: ->
    super

  render: (error) ->
    @html require('views/error')({error_text: error})

module.exports = ErrorBox