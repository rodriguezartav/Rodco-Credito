Spine   = require('spine')
$       = Spine.$

class Box extends Spine.Controller
  className: 'reveal-modal'
  
  constructor: ->
    super
    @html require('views/lighthouse/box')

class Login extends Spine.Controller
  className: 'login reveal-modal'

  elements:
    "#txt_email" : "email"
    "#txt_password" : "password"
    "#txt_token" : "token"

  events:
    "click .login" : "login"
    "click .cancel" : "cancel"

  constructor: ->
    super
    localStorage?.setItem "password" , ""
    @render()
    @active @load

  load: (params) =>
    @password.focus()
    @return = params.return

  render: =>
    @html require('views/lighthouse/login')
    oldemail = localStorage?.getItem "username"
    oldpass = localStorage?.getItem "password"
    oldtoken = localStorage?.getItem "token"
    @email.val oldemail if oldemail
    @password.val oldpass if oldpass
    @token.val oldtoken if oldtoken

  login: =>
    localStorage?.setItem "username" , @email.val()
    localStorage?.setItem "password" , @password.val()
    localStorage?.setItem "token" , @token.val()
    if @return == "true"
      @navigate ''
    else
      @navigate '/sync'

  cancel: ->
    @navigate ''

class Lightbox extends Spine.Controller
  className: 'lightbox reveal-modal-bg'
  
  events:
    "click .close-reveal-modal" : "on_hide"
  
  constructor: ->
    super
    @box = new Box
    @login = new Login
    
    Spine.bind "show_lightbox" , ( type , data , callback ) =>
      @log type
      @el.show()
      @html @box if type=="box"
      @html @login if type=="login"


  on_hide: ->
    @el.hide()

module.exports = Lightbox