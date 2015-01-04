ready = ->
  $("select").dropdown()
  $(".dropdown").dropdown()
  $(".ui.radio.checkbox").checkbox()
  $("#start").click ->
    $(".ui.modal").modal "show"
    return

  $("#start-delivering").click ->
    email = $("input#entered_email").val()
    $("input#kindle_email").val email
    if email_check(email)
      $("form").submit()
      $('.ui.modal').modal "hide"
      $('#loader').addClass("active")
    else
      alert "Please enter a valid Kindle email."
      $("input#entered_email").focus()
    return

  email_check = (email) ->
    domain = email.split("@")[1]
    re = /\S+@\S+/
    if re.test(email)
      return true if domain is "kindle.com" or domain is "free.kindle.com" or domain is "kindle.cn"
    false

  return


# Load the script once the page is ready
$(document).ready(ready)
$(document).on('page:load', ready)