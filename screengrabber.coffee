casper = require("casper").create()

urls = casper.cli.raw.get("urls").split(',')
resolutions = casper.cli.raw.get("resolutions")
name = casper.cli.raw.get("name")
path = casper.cli.raw.get("path")

parseResolutions = (resolutions) ->
  results = []
  array = resolutions.split(',')
  for member in array
    temp = member.split('x')
    results.push([parseInt(temp[0], 10), parseInt(temp[1], 10)])

  results


requestedResolutions = parseResolutions(resolutions)
totalResCount = requestedResolutions.length
totalURLCount = urls.length
currentRes = 0
currentURL = 0

nextResolution = ->
  width = requestedResolutions[currentRes][0]
  height = requestedResolutions[currentRes][1]

  image = "#{path}#{name}-#{currentURL}-#{width}-#{height}.png"

  @viewport width, height

  @then ->
    @capture image, {
      top: 0,
      left: 0,
      width: width,
      height: height
    }

  @then ->
    if currentRes + 1 < totalResCount
      @wait 1000, ->
        currentRes++
        @then nextResolution

    else
      if currentURL + 1 < totalURLCount
        currentRes = 0
        @wait 1000, ->
          currentURL++
          @then nextURL
      else
        casper.exit()

nextURL = ->
  @open urls[currentURL]

  @then nextResolution


casper.start()

casper.then nextURL

casper.run()
