#= require sanger_sequencing/columns_first_ordering_strategy
#= require sanger_sequencing/rows_first_ordering_strategy

exports = exports ? @

class exports.AcgtPlateMode
  constructor: ->
    @_plateMode = false

    @_initToggles()
    @_initNestedFormFieldListener()
    @_initFillStrategy()
    @_initInPlateMode()

    @render()

  render: ->
    @_disablePlateFeaturesIfOff()
    @_setFillOrder()
    @_fillWellPlatePositions()

  _initToggles: ->
    @_fillOrderToggleLink()
      .click(@_toggleText)
      .click =>
        @_toggleStrategy()

    @_featureToggleLink()
      .click(@_toggleText)
      .click =>
        @_plateMode = !@_plateMode
        @render()

  _initNestedFormFieldListener: ->
    $(document).on "fields_added.nested_form_fields fields_removed.nested_form_fields", =>
      @render()

  _toggleText: (evt) ->
    evt.preventDefault()
    elem = $(evt.target)
    oldText = elem.text()
    elem.text(elem.data("toggle-text"))
    elem.data("toggle-text", oldText)

  _initInPlateMode: ->
    @_featureToggleLink().trigger("click") if @_featureToggleLink().data("plate-mode")

  _fillWellPlatePositions: =>
    fillOrder = @_fillStrategies[@_fillStrategy].fillOrder()

    @_positionElements().each (i, elem) =>
      # set to blank instead of disabling so that blank gets submitted
      positionString = if @_plateMode then fillOrder[i % 96] else ""
      $(elem).find(".js--acgt__positionText").text positionString
      $(elem).find(".js--acgt__positionInput").val(positionString)

  _initFillStrategy: ->
    @_fillStrategy = @_setFillOrderInput().val() || Object.keys(@_fillStrategies)[0]

  _fillStrategies:
    "columns_first": new SangerSequencing.ColumnsFirstOrderingStrategy()
    "rows_first": new SangerSequencing.RowsFirstOrderingStrategy()

  _toggleStrategy: ->
    @_fillStrategy = if @_fillStrategy == "columns_first" then "rows_first" else "columns_first"
    @render()

  _setFillOrder: ->
    mode = if @_plateMode then @_fillStrategy else ""
    @_setFillOrderInput().val(mode)

  _disablePlateFeaturesIfOff: ->
    $(".js--acgt__plateModeOn, .js--acgt__platePosition").toggle(@_plateMode)

  _setFillOrderInput: ->
    $(".js--acgt__fillOrder")

  _featureToggleLink: ->
    $(".js--acgt__togglePlateMode")

  _fillOrderToggleLink: ->
    $(".js--acgt__togglePlateFillOrder")

  _positionElements: ->
    $(".js--acgt__platePosition")
