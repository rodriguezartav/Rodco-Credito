Spine = require('spine')
Item = require('models/item')
Archive = require('models/archive')

class Pedido extends Spine.Model
  @configure 'Pedido', "Name" , "Cliente" , "Total" , "Referencia" , "Transporte" , "Observacion","Plazo","Ruta", "Items" , "Email" , "Telefono" , "Nombre" , "Identificacion"
  
  @extend Spine.Model.Local

  format_for_server: ->  
    results = []
    items = Item.findAllByAttribute "Parent_id" , @id
    for item in items
      temp = 
        id: @id
        item_id: item.id
        Cliente__c: @Cliente
        Plazo__c: @Plazo
        Producto__c: item.Producto
        Cantidad__c: item.Cantidad
        Precio__c: item.Precio
        Descuento__c: item.Descuento
        Impuesto__c: item.Impuesto
        Subtotal__c: item.Subtotal
        Referencia__c: @Referencia
        Observacion__c: @Observacion
        Costo__c : item.Costo
        Nombre__c : @Nombre
        Telefono__c : @Telefono
        Identificacion__c : @Identificacion
        Email__c : @Email
        IsContado__c: false
        Fuente__c: "AGENTE"
        Estado__c: "Pendiente"
        Tipo__c: "Credito"
      results.push temp
    results

  @create_from_cliente: (cliente = {Name: "",id: null}) ->
    Pedido.create 
      Name        : cliente.Name
      Cliente     : cliente.id if cliente.id
      Ruta        : cliente.Ruta
      Plaza : cliente.DiasCredito
      Total       : 0
      Referencia  : parseInt(Math.random() * 100000)
      Items       : []
      Observacion : ""
      Transporte  : "" 

  @send_to_server: (pedidos) =>
    formated_items = []
    for pedido in pedidos
      formated_items = formated_items.concat pedido.format_for_server()
      data = {type: "Oportunidad__c" ,username: localStorage?.getItem("username"), password: localStorage?.getItem("password") + localStorage?.getItem("token") , items: JSON.stringify(formated_items)  }
    $.ajax
      url        :  'http://rodco-api.heroku.com/save'
      type       :  "POST"
      data       :  data
      success    :  @on_send_success
      error      :  @on_send_error

  @on_send_success: (raw_results) =>
    results = JSON.parse raw_results
    pedido = null
    errors = []
    hasErrors = false
    for result in results
      if result.success
        source= result.source
        pedido = Pedido.exists source.id
        item = Item.exists source.item_id
        if pedido and item
          Archive.create_from_server pedido,item,source
          item.destroy()
        else
          throw "El pedido y el articulo " + source.to_json + " fue guardo pero no se encuentra en este equipo."
      else
        hasErrors = true
        errors.push result

    if hasErrors
      Pedido.trigger "ajax_error" , errors
    else
      items = Item.findAllByAttribute "Parent_id" , source.id
      pedido.destroy() if items.length == 0
      Pedido.trigger "refresh"
      Pedido.trigger "ajax_complete"

  @on_send_error: (error) =>
    responseText  = error.responseText
    if responseText.length > 0
      errors = JSON.parse responseText
    else
      errors = {type:"LOCAL" , error: " Indefinido: Posiblemente Problema de Red", source: "Pedido" }
    Pedido.trigger "ajax_error" , errors
 
  @items_by_cliente: (query,over_cero=false) ->
    return Pedido.all() if !query
    @select (item) ->
      match = true
      if query
        match = item.Cliente == query and (item.Total > 0 or !over_cero)
      else
        match = item.Total > 0 if over_cero
      match

  @bulk_delete: ->
    for item in Pedido.all()
      item.destroy()

module.exports = Pedido