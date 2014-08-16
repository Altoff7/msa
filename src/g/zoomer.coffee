EventHandler = require "biojs-events"

class Zoomer

  constructor: (@msa) ->

    @maxLabelLength = 20
    @setZoomLevel 2
    @len = 0

    @_setWidth()

  setZoomLevel: (value) ->
    @level = value

    @columnWidth = 1 * value
    @labelFontsize = Math.floor(3 + 0.8 * value)
    @residueFontsize = Math.floor(3 + 0.8 * value)
    @columnHeight = 5 + 1 * value
    @columnSpacing = 0

    if @maxLabelLength > 0
      @seqOffset = @maxLabelLength * @labelFontsize / 2 + 2 * value

    if value is 1
      @seqOffset = 20

    @msa.trigger "zoom", value

  autofit: (tSeqs) ->
    level = @guessZoomLevel tSeqs
    @setZoomLevel level

  isTextVisible: ->
    if @labelFontsize > 5
      true
    else
      false

  getStepSize: ->
    stepSize = 1
    stepSize = 2  if @columnWidth <= 15
    stepSize = 5  if @columnWidth <= 5
    stepSize = 10  if @columnWidth is 2
    stepSize = 20  if @columnWidth is 1
    stepSize

  _setWidth: ->
    # totally slow - draws the entire container
    _rect = @msa.el.getBoundingClientRect()
    @_width = _rect.right - _rect.left

    # fix for inline-block - try parent
    if @_width is 0
      _rect = @msa.el.parentNode.getBoundingClientRect()
      @_width = _rect.right - _rect.left


  # simple getter for the current level
  getLevel: ->
    console.log "level:" + @level
    return @level

  guessZoomLevel:(tSeqs) ->
    @len = @getMaxLength tSeqs
    @maxLabelLength =  @getMaxLabelLength tSeqs

    level = 2

    if @len > @_width
      # go to minzoom
      return 1
    else
      # increase as long as possible
      @setZoomLevel level
      width = 0

      while width < @_width and level <= 100
        width = @msa.stage.width(@len)

        level++
        @setZoomLevel level

      if level is 2
        console.log "len: #{@len} - width: #{@_width}"
        console.log "stage: #{@msa.stage.width(@len)}"
        console.log "stage: #{@msa.container.id}"
      return level - 1

# merge this class with the event class
EventHandler.mixin Zoomer::
module.exports = Zoomer