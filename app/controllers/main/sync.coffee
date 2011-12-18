Spine   = require('spine')
Cliente = require('models/cliente')
Pedido = require('models/pedido')
Error = require('models/error')
Item = require('models/item')
Producto = require('models/producto')
ErrorBox = require('controllers/main/errorbox')

Manager = require('spine/lib/manager')
$       = Spine.$

class Sync extends Spine.Controller
  className: 'sync'
  
  elements:
    "#ajax_loader"        :  "ajax_loader"
    ".error_box"              :   "error_box"
  
  events:
    "click #update_now"       :  "update"
    "click #reset"       :  "reset"
    "click .cancel"       :  "cancel"

  constructor: ->
    super
    
    Cliente.bind 'current_set' , =>
      @render(Cliente.current.id) if @isActive()

    Cliente.bind 'current_reset' , =>
      @render() if @isActive()
      
    Pedido.bind "refresh" , =>
      @render() if @isActive()
    
    Cliente.bind "ajax_error" , (data) =>
      @ajax_loader.hide()
      error = Error.create_from_server data,"descargando clientes" , "el error se presento en el servidor"
      @error_box.html error.to_string()
      
    Producto.bind "ajax_error" , (data) =>
      @ajax_loader.hide()
      error = Error.create_from_server data,"descargando productos" , "el error se presento en el servidor"
      @error_box.html error.to_string()
      
    @active =>
      @render()
      
  render: (id=null)  =>
    @error_box.empty()
    @last_update = new Date( localStorage?.getItem("last_update") ) || new Date(1970, 1, 1, 1, 1, 1, 1)
    @html require('views/sync')({last_update: @last_update})
    @ajax_loader.hide()
  
  reset: =>
    @last_update = new Date(1970, 1, 1, 1, 1, 1, 1)
    Cliente.bulk_delete()
    Producto.bulk_delete()
    @reset = true
    @update() 

  update: =>
    @ajax_loader.show()
    Cliente.bind "ajax_complete" , @update_producto
    Producto.bind "ajax_complete" , @sync_complete
    @update_cliente()
       
  update_cliente:=>
    @log "Updating Cliente"
    username = localStorage?.getItem("username")
    password = localStorage?.getItem("password") + localStorage?.getItem("token")
    Cliente.fetch_from_sf(username,password,@last_update)
    
  update_producto: =>
    @log "Cliente Updated"
    username = localStorage?.getItem("username")
    password = localStorage?.getItem("password") + localStorage?.getItem("token")
    @log "Updating Producto"
    Producto.fetch_from_sf(username,password,@last_update)

  sync_complete: =>
    @log "Producto Update Complete"
    Cliente.unbind "ajax_complete" , @update_producto
    Producto.unbind "ajax_complete" , @sync_complete
    Producto.trigger "refresh"
    Cliente.trigger "refresh"
    window.location.reload(true) if @reset

  cancel: ->
    @navigate ''

    
module.exports = Sync