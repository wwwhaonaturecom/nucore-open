#= require support/jasmine-jquery-2.1.0
#= require acgt/plate_mode

describe "AcgtPlateMode", ->

  fixture.set "
    <form>
      <input type='hidden' class='js--acgt__fillOrder' id='test-fill-order' value=''>
      <a href='#' data-toggle-text='Change to individual' data-plate-mode='' class='js--acgt__togglePlateMode' id='test-toggle'>Change to plate</a>

      <div class='js--acgt__plateModeOn' id='test-plateMode'></div>

      <a href='#' class='js--acgt__togglePlateFillOrder js--acgt__plateModeOn' data-toggle-text='Fill Rows' id='test-fill-toggle'>Fill Columns</a>

      <div class='js--acgt__platePosition'>
        <span class='js--acgt__positionText' id='test-position1'></span>
        <input type='hidden' class='js--acgt__plateNumber', id='test-input-plate-number1' />
        <input type='hidden' class='js--acgt__positionInput' id='test-input-position1' />
      </div>
      <div class='js--acgt__platePosition'>
        <span class='js--acgt__positionText' id='test-position2'></span>
        <input type='hidden' class='js--acgt__plateNumber', id='test-input-plate-number1' />
        <input type='hidden' class='js--acgt__positionInput' id='test-input-position2' />
      </div>
    </form>
  "

  describe "starting in plate mode", ->
    beforeEach ->
      $("#test-toggle").data("plate-mode", true)
      @plateMode = new AcgtPlateMode

    it "shows the plate information", ->
      expect("#test-plateMode").not.toBeHidden()
      expect("#test-position1").not.toBeHidden()

    it "has the correct text in the toggle", ->
      expect($("#test-toggle").text()).toEqual("Change to individual")

    it "has the fill values", ->
      expect("#test-position1").toHaveText("A01")
      expect("#test-input-position1").toHaveValue("A01")

      expect("#test-position2").toHaveText("B01")
      expect("#test-input-position2").toHaveValue("B01")

    it "has the correct fill order", ->
      expect($("#test-fill-order").val()).toEqual("columns_first")

    describe "clicking the row/column toggle", ->
      beforeEach ->
        $("#test-fill-toggle").trigger("click")

      it "changes to the correct text", ->
        expect($("#test-fill-toggle").text()).toEqual("Fill Rows")

      it "has the correct order by row first", ->
        expect($("#test-position1").text()).toEqual("A01")
        expect("#test-input-position1").toHaveValue("A01")

        expect("#test-position2").toHaveText("A02")
        expect("#test-input-position2").toHaveValue("A02")

      it "has the correct fill order", ->
        expect($("#test-fill-order").val()).toEqual("rows_first")

    describe "with more than 96 items", ->
      beforeEach ->
        for [1..95]
          last = $(".js--acgt__platePosition").last()
          newPosition = last.clone()
          last.after(newPosition)
        @plateMode.render()

      it "has the correct plate order for the last item", ->
        expect($(".js--acgt__positionInput").last().val()).toEqual("A01")
        expect($(".js--acgt__plateNumber").last().val()).toEqual("2")

      it "has the correct display for the first item", ->
        expect("#test-position1").toContainText("Plate 1")

    describe "clicking the plate mode toggle", ->
      beforeEach ->
        $("#test-toggle").trigger("click")

      it "hides the fields", ->
        expect("#test-plateMode").toBeHidden()
        expect("#test-position1").toBeHidden()

      it "changes to the correct text", ->
        expect($("#test-toggle").text()).toEqual("Change to plate")

      it "clears out the plate position inputs", ->
        expect($("#test-input-position1").val()).toEqual("")

  it "starting in individual mode", ->
    beforeEach ->
      @plateMode = new AcgtPlateMode

    it "hides the plate information", ->
      expect("#test-plateMode").toBeHidden()
      expect("#test-position1").toBeHidden()

    it "has the inputs blank", ->
      expect("#test-input-position1").toHaveValue("")
      expect("#test-input-position2").toHaveValue("")

    it "has the correct toggle text", ->
      expect($("#test-toggle").text()).toEqual("Change to plate")

    it "has a blank fill order", ->
      expect($("#test-fill-order").val()).toEqual("")

    describe "clicking the plate mode toggle", ->
      beforeEach ->
        $("#test-toggle").trigger("click")

      it "has the correct text in the toggle", ->
        expect($("#test-toggle").text()).toEqual("Change to individual")

      it "has the fill values", ->
        expect("#test-position1").toHaveText("A01")
        expect("#test-input-position1").toHaveValue("A01")

        expect("#test-position2").toHaveText("B01")
        expect("#test-input-position2").toHaveValue("B01")

