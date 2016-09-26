# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('#prize_search').keyup ->
    $.get $('#prizes_table').attr('action'), $('#prizes_table').serialize(), null, 'script'
    false
  return

$(document).ready ->
  setTableRowsClickableEmployees()
  return
$(document).ajaxStop ->
  setTableRowsClickableEmployees()
  return

setTableRowsClickableEmployees = undefined

setTableRowsClickableEmployees = ->
  j = undefined
  k = undefined
  k = document.getElementById('table-prizes-choose')
  if k != null
    rows = k.rows
    j = 0
    while j < rows.length

      rows[j].onclick = (event) ->
        cells = undefined
        s1 = undefined
        s2 = undefined
        if @parentNode.nodeName == 'THEAD'
          return
        cells = @cells
        s1 = document.getElementById('prize_name')
        s2 = document.getElementById('prize_cost')
        s3 = document.getElementById('prize_image')
        s1.value = cells[0].innerHTML
        s2.value = cells[1].innerHTML
        s3.value = cells[2].innerHTML
        return

      j++
  return