$ ->
  class AcgtOrderForm
    constructor: (@$element) ->
      @initListeners()

    initListeners: ->
      $(".js--sangerFillColumnFromFirst").on "click", @fillColumnFromFirst
      $(".js--sangerClearColumn").on "click", @clearColumn
      $(".js--sangerCheckAll").on "click", @checkAll
      $(".js--sangerUncheckAll").on "click", @uncheckAll
      $(document).on "fields_added.nested_form_fields", @copyValuesFromLastRow

    fillColumnFromFirst: (evt) =>
      $selected = @$_getSelected(evt)
      value = $selected.first().val()
      $selected.val(value)

    clearColumn: (evt) =>
      @$_getSelected(evt).val("")

    checkAll: (evt) =>
      @$_getSelected(evt).prop("checked", true)

    uncheckAll: (evt) =>
      @$_getSelected(evt).prop("checked", false)

    copyValuesFromLastRow: (evt) =>
      $previousRow = $(evt.target).prev()
      $(evt.target).find("input:not(.js--customerSampleId):not(:hidden), select").each (i, elem) =>
        fieldName = elem.name.match(/\[(\w+)\]$/)[1]
        # This uses a wildcard match, so be careful if any field is a substring
        # of another field name
        # We need the not(:hidden) to handle checkboxes (Rails puts two checkboxes, one
        # hidden so it always sends 0 or 1)
        $previousRowElem = $previousRow.find("[name*=#{fieldName}]:not(:hidden)")
        if $(elem).is(":checkbox")
          $(elem).prop("checked", $previousRowElem.prop("checked"))
        else
          $(elem).val($previousRowElem.val())

    $_getSelected: (evt) ->
      evt.preventDefault()
      $($(evt.target).data("selector"))

  new AcgtOrderForm
