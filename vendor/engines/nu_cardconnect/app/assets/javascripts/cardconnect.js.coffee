$ ->
  class Cardconnect
    constructor: (@$form) ->

    init: =>
      @$form.submit @submitCallback

    tokenField: =>
      @$form.find("[data-cc-token]")

    numberField: =>
      @$form.find("[data-cc-number]")

    yearField: =>
      @$form.find("[data-cc-exp-year]")

    monthField: =>
      @$form.find("[data-cc-exp-month]")

    submitCallback: (e) =>
      # If we've already tokenized, go ahead and submit
      return if @tokenField().val()

      e.preventDefault()

      return false unless @validateFields()

      params = {
        action: 'CE',
        data: @numberField().val(),
        type: 'json'
      }

      $.get($(e.target).data("endpoint"), params)
       .done(@successfullyTokenized)
       .error(@failedTokenize)

    failedTokenize: (e) ->
      # renable disable_with fields
      $.rails.enableFormElements($($.rails.formSubmitSelector))
      throw new Error("Tokenization error: #{e}")

    successfullyTokenized: (responseText) =>
      response = JSON.parse responseText.substring(14, responseText.length - 2)

      if response.action == 'CE'
        token = response.data
        masked = "****************"
        @numberField().val(masked).prop('disabled', true)
        @tokenField().val(token)
        @$form.submit()
      else # usually "ER"
        console.error "ERROR", response.data

    error: (message) =>
      warning = $("<div>").addClass("alert alert-error js--cardconnect-error").text(message)
      @$form.prepend(warning)
      false

    validateFields: =>
      @$form.find(".js--cardconnect-error").remove()
      @validateExpiration() && @validateCardLength()

    validateExpiration: =>
      currentYear = new Date().getFullYear()
      selectedYear = parseInt(@yearField().val())
      currentMonth = new Date().getMonth() + 1
      selectedMonth = parseInt(@monthField().val())
      # We only show current & future years
      if currentYear != selectedYear || currentMonth <= selectedMonth
        true
      else
        @error("The expiration date is in the past")

    validateCardLength: =>
      trimmed = @numberField().val().replace(/\s/g, "")
      length = trimmed.length
      return @error("The card number is too short") if length < 15
      return @error("The card number is too long") if length > 16
      return @error("The card number must be numeric") unless $.isNumeric(trimmed)
      true

  action = new Cardconnect($(".cardConnectForm"))
  action.init()
