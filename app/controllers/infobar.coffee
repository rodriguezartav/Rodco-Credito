Spine    = require('spine')
Cliente  = require('models/cliente')
Producto = require('models/producto')
Pedido   = require('models/pedido')
Manager  = require('spine/lib/manager')
$        = Spine.$

class Pendientes extends Spine.Controller
  className: 'pendientes active hideable_info_view'

  constructor: ->
    super
    Pedido.bind "refresh create" , @render

  render: =>
    pedidos = Pedido.all()
    @el.html require('views/infobar/pendientes')(items: pedidos)

class Current extends Spine.Controller
  className: 'current active'

  constructor: ->
    super
    Cliente.bind('current_set'   ,  @render_cliente)  if @type == "Cliente"
    Producto.bind('current_set'  ,  @render_producto) if @type == "Producto"
    @html require('views/infobar/all_cliente')()

  render_cliente: (object) =>
    @html require('views/infobar/current_cliente')(object)

  render_producto: (object) =>
    @html require('views/infobar/current_producto')(object)

class Infobar extends Spine.Controller
  className: 'infobar columns three viewport'

  elements:
    ".hideable_info_view" : "hide_panels"

  constructor: ->
    super
    
    @current_cliente = new Current(type: "Cliente")
    @current_producto = new Current(type: "Producto")
    @pendientes_enviar = new Pendientes(type: "Enviar")

    @append @pendientes_enviar ,  @current_cliente , @current_producto

    Spine.bind( "app_state"  ,  @change_app_state)
    @change_app_state("Local")

  change_app_state: (state) =>
    #@hide_panels.removeClass("active")
    #@pendientes_enviar.el.addClass("active") if state == "Remote"

 
module.exports = Infobar