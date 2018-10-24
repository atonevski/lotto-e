# graph-freq.coffee: stacked bars graph
#

utils = require '../js/utils.js'
https = require 'https'

# some globals
lfreq = [ ]
totf = [ ]
drum  = 'BOTH'
WIDTH = 800
HEIGHT = 500

margins =
  top:    20
  right:  120
  bottom: 20
  left:   40

for i in [0..34]
  lfreq.push [0, 0, 0, 0, 0, 0, 0, 0, 0]

lq = '''
  SELECT X, Y, Z, AA, AB, AC, AD, AE
  :filter
'''
lq = switch drum
      when utils.VENUS
        lq.replace /\:filter/,
            "WHERE B <= date '#{utils.toYMD utils.VENUS_DATE}'"
      when utils.STRESA
        lq.replace /\:filter/,
            "WHERE B >= date '#{utils.toYMD utils.STRESA_DATE}'"
      else
        lq.replace /\:filter/, ''

https.get utils.qstring(lq), (res) =>
  body = ''
  res.setEncoding 'utf-8'
  res.on 'data', (d) -> body += d
  res.on 'error', (e) -> console.log "query error: #{ e }"
  res.on 'end', () =>
    json = utils.parseResponse body
    recs = utils.qresult json
    for r in recs
      lfreq[r.lwc1][0] += 1
      lfreq[r.lwc2][1] += 1
      lfreq[r.lwc3][2] += 1
      lfreq[r.lwc4][3] += 1
      lfreq[r.lwc5][4] += 1
      lfreq[r.lwc6][5] += 1
      lfreq[r.lwc7][6] += 1
      lfreq[r.lwcp][7] += 1
    for i in [1..34]
      totf[i] = lfreq[i].reduce (a, s) ->
          a + s
      , 0
    plot()
  null

plot = () ->
  svg = d3.select '.container'
          .append 'svg'
          .attr 'class', 'axis'
          .attr 'width', WIDTH
          .attr 'height', HEIGHT
  [xmin, xmax] = [1, 34]
  ymin = 0
  ymax = d3.max lfreq[1..34], (n) ->
              n.reduce (x, s) ->
                x + s
              , 0
  console.log [xmin, xmax]
  console.log [ymin, ymax]

  xRange = d3.scaleBand()
             .range [margins.left, WIDTH - margins.right]
             .domain [xmin..xmax]
             .padding 0.2

  yRange = d3.scaleLinear()
             .range [HEIGHT - margins.top, margins.bottom]
             .domain [ymin, ymax]

  xAxis = d3.axisBottom xRange
  yAxis = d3.axisLeft yRange


  svg.append 'g'
     .attr 'class', 'x axis'
     .attr 'transform', "translate(0, #{ HEIGHT - margins.bottom })"
     .call xAxis

  svg.append 'g'
     .attr 'class', 'y axis'
     .attr 'transform', "translate(#{ margins.left }, 0)"
     .call yAxis

  svg.append 'g' # title
     .append 'text'
     .attr 'fill', '#93a1a1'
     .attr 'x', xRange Math.round((xmin + xmax)/2)
     .attr 'y', yRange ymax
     .attr 'dy', '-0.35em'
     .attr 'text-anchor', 'middle'
     .text 'Number frequencies'

  dataIntermediate = lfreq[1..34].map (r, i) ->
    v =
      number: i+1
      first: r[0]
      second: r[1]
      third: r[2]
      forth: r[3]
      fifth: r[4]
      sixth: r[5]
      seventh: r[6]
      extra: r[7]
  keys = ['first', 'second', 'third', 'forth', 'fifth', 'sixth', 'seventh', 'extra']
  data = d3.stack().keys(keys)(dataIntermediate)
  console.log data

  color = d3.scaleOrdinal()
      .unknown("#ccc")
      .domain([1..34])
      .range d3.quantize(((t) -> d3.interpolateSpectral(t * 0.8 + 0.1)), data.length).reverse()
  svg.append 'g'
     .selectAll 'g'
     .data data
     .enter().append 'g'
     .attr 'fill', (d, i) -> color i+1
     .selectAll 'rect'
     .data (d) -> d
     .enter().append 'rect'
     .attr 'x', (d, i) -> xRange i+1
     .attr 'y', (d) -> yRange d[1]
     .attr 'height', (d) -> yRange(d[0]) - yRange(d[1])
     .attr 'width', xRange.bandwidth()
     .append 'title'
     .text (d, i) -> "#{ i + 1 }: #{ totf[i + 1]}"

  l = svg.append 'g'
     .attr 'transform', "translate(#{ WIDTH - 25 }, #{ margins.top })"
     .selectAll 'g'
     .data keys.reverse()
     .enter().append 'g'
     .attr 'transform', (d, i) -> "translate(0, #{ i*20 })"

     l.append 'rect'
     .attr 'x', -19
     .attr 'width', 19
     .attr 'height', 19
     .attr 'fill', (d, i) -> color keys.length - i

     l.append 'text'
     .attr 'font-size', '70%'
     .attr 'x', -60
     .attr 'y', 9.5
     .attr 'dy', '0.35em'
     .attr 'fill', '#93a1a1'
     .text (d) -> d
