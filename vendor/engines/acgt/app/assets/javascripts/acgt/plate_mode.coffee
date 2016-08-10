#= require sanger_sequencing/columns_first_ordering_strategy
#= require sanger_sequencing/rows_first_ordering_strategy

exports = exports ? @

class exports.AcgtPlateMode
  constructor: ->
    @_plateMode = false

    @_initToggles()
    @_initNestedFormFieldListener()
    @_toggleStrategy()
    @_initInPlateMode()

    @render()

  render: ->
    @_disablePlateFeaturesIfOff()
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
    fillOrder = @_fillStrategy.fillOrder()

    @_positionElements().each (i, elem) =>
      # set to blank instead of disabling so that blank gets submitted
      positionString = if @_plateMode then fillOrder[i % 96] else ""
      $(elem).find(".js--acgt__positionText").text positionString
      $(elem).find(".js--acgt__positionInput").val(positionString)

  _toggleStrategy: ->
    @_strategyToggle = !@_strategyToggle
    if @_strategyToggle
      @_fillStrategy = new SangerSequencing.ColumnsFirstOrderingStrategy()
    else
      @_fillStrategy = new SangerSequencing.RowsFirstOrderingStrategy()
    @render()

  _disablePlateFeaturesIfOff: ->
    $(".js--acgt__plateModeOn, .js--acgt__platePosition").toggle(@_plateMode)

  _featureToggleLink: ->
    $(".js--acgt__togglePlateMode")

  _fillOrderToggleLink: ->
    $(".js--acgt__togglePlateFillOrder")

  _positionElements: ->
    $(".js--acgt__platePosition")
