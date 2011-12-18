require('lib/setup')
require('lib/format')
Spine    = require('spine')
Pedidos = require('controllers/pedidos')
Lightbox = require('controllers/lightbox')
Cliente = require('models/cliente')
Producto = require('models/producto')
Item = require('models/item')
Archive = require('models/archive')
Pedido = require('models/pedido')
Error = require('models/error')

Mock = require('lib/mock')

class App extends Spine.Controller
  
  events:
    "click .btn_change_app_state"  :  "on_app_change"
    "click .btn_do_login"  :  "on_login"

  constructor: ->
    super
    new Mock() if @test
    @html require('views/layout')()
  
    @pedidos = new Pedidos
    @lightbox = new Lightbox
    @append @pedidos , @lightbox
        
    Spine.Route.setup()

    #Spine.trigger("show_lightbox","login")

    #Archive.history_delete()

    #Error.send_unsent()
    
    #$.ajax
      #url        :  'http://rodco-api.heroku.com/allow_access'
      #type       :  "GET"
      #success    :  @on_check_success

  on_login: (e) ->
    Spine.trigger "show_lightbox" , "login"


  on_app_change: (e) ->
    target = $(e.target)
    options = target.attr("data-other").split(",")
    current_option  = target.html()
    new_option = options[0]
    options = options.splice(1)
    target.html new_option
    options.push current_option 
    target.attr("data-other" , options.join(",")) 
    Spine.trigger("app_state" , new_option)

  @on_check_success: (raw_json) ->
    response = JSON.parse raw_json
    if !response.access == "destroy"
      Cliente.bulk_delete()
      Pedido.bulk_delete()
      Item.bulk_delete()
      Producto.bulk_delete()
    if !response.access == "refresh"
      Cliente.bulk_delete()
      Pedido.bulk_delete()
      Item.bulk_delete()
      Producto.bulk_delete()
      
module.exports = App