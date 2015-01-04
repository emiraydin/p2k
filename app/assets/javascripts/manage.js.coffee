ready = ->

  $('#stop-all').click ->
  	$('.ui.modal').modal('show')

  $('#approve-stop').click ->
  	$('form.button_to').submit()
  	$('.ui.modal').modal('hide')
  	$('#loader').addClass('active')


# Load the script once the page is ready
$(document).ready(ready)
$(document).on('page:load', ready)