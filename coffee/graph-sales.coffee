# graph-sales.coffee: sales line graph
#

utils = require '../js/utils.js'
https = require 'https'

# some globals
WIDTH = 500
HEIGHT = 300

margins =
  top:    20
  right:  60
  bottom: 20
  left:   60
recs = []

# draw, date, lotto sales, lx7, lfx7+ljx7, joker sales, jx6, jfx6+jjx6
lq = '''
  SELECT
    A, B,
    C, D, N, S,
    AF, AG, AS, AY
'''

https.get utils.qstring(lq), (res) =>
  body = ''
  res.setEncoding 'utf-8'
  res.on 'data', (d) -> body += d
  res.on 'error', (e) -> console.log "query error: #{ e }"
  res.on 'end', () =>
    json = utils.parseResponse body
    recs = utils.qresult json
    for r in recs
      days = if r.date.getDay() is 0 then 6 else r.date.getDay() - 1
      r.monday = new Date(r.date)
      r.monday.setDate r.date.getDate() - days

    # console.log recs
    plot()

plot = () ->
  color = d3.scaleOrdinal(d3.schemeCategory10)

  # for now we don't plot older draws on other week days
  wednesdays  = (r for r in recs when r.date.getDay() is 3)
  saturdays   = (r for r in recs when r.date.getDay() is 6)

  # we select recent 50 draws
  wedData = wednesdays[-50..-1]
  satData = saturdays[-50..-1]

  # [-1..][0] is the last element in array
  [xmin, xmax] = [ wedData[0].monday, wedData[-1..][0].monday ]
  xRange = d3.scaleTime()
             .range [margins.left, WIDTH - margins.right]
             .domain [xmin, xmax]

  yminl = d3.min [(d3.min wedData, (d) -> d.lsales), (d3.min satData, (d) -> d.lsales)]
  ymaxl = d3.max [(d3.max wedData, (d) -> d.lsales), (d3.max satData, (d) -> d.lsales)]

  yminj = d3.min [(d3.min wedData, (d) -> d.jsales), (d3.min satData, (d) -> d.jsales)]
  ymaxj = d3.max [(d3.max wedData, (d) -> d.jsales), (d3.max satData, (d) -> d.jsales)]

  yRangel = d3.scaleLinear()
              .range [HEIGHT - margins.top, margins.bottom]
              .domain [yminl, ymaxl]
  yRangej = d3.scaleLinear()
              .range [HEIGHT - margins.top, margins.bottom]
              .domain [yminj, ymaxj]

  xAxis = d3.axisBottom xRange
            .tickFormat d3.timeFormat "%W/%Y"
            .ticks 6

  yAxisl = d3.axisLeft yRangel
  yAxisj = d3.axisRight yRangej

  # line values
  lnvalsl = d3.line() # see curve
              .x (d) -> xRange d.monday
              .y (d) -> yRangel d.lsales
              .curve d3.curveCardinal

  lnvalsj = d3.line() # see curve
              .x (d) -> xRange d.monday
              .y (d) -> yRangej d.jsales
              .curve d3.curveCardinal
  # render LOTTO
  svgl = d3.select '.container'
           .append 'svg'
           .attr 'class', 'axis'
           .attr 'width', WIDTH
           .attr 'height', HEIGHT

  svgl.append 'g'
     .attr 'class', 'x axis'
     .attr 'transform', "translate(0, #{ HEIGHT - margins.bottom })"
     .call xAxis

  svgl.append 'g'
     .attr 'class', 'y axis'
     .attr 'transform', "translate(#{ margins.left }, 0)"
     .call yAxisl

  svgl.append 'path'
     .data [wedData]
     .attr 'class', 'line'
     .attr 'd', lnvalsl
     .style 'stroke', color 0

  svgl.append 'path'
     .data [satData]
     .attr 'class', 'line'
     .attr 'd', lnvalsl
     .style 'stroke', color 1
  # render Joker
  svgj = d3.select '.container'
           .append 'svg'
           .attr 'class', 'axis'
           .attr 'width', WIDTH
           .attr 'height', HEIGHT

  svgj.append 'g'
     .attr 'class', 'x axis'
     .attr 'transform', "translate(0, #{ HEIGHT - margins.bottom })"
     .call xAxis

  svgj.append 'g'
     .attr 'class', 'y axis'
     .attr 'transform', "translate(#{ WIDTH - margins.right }, 0)"
     .call yAxisj

  svgj.append 'path'
     .data [wedData]
     .attr 'class', 'line'
     .attr 'd', lnvalsj
     .style 'stroke', color 2

  svgj.append 'path'
     .data [satData]
     .attr 'class', 'line'
     .attr 'd', lnvalsj
     .style 'stroke', color 3
# TODO:
# add 1st category prize and full jackpot
# add legend and title
# polish appearance
# and dots for each draw including tooltip for sales, etc.

# CURVE:
# var curveArray = [
#     {"d3Curve":d3.curveLinear,"curveTitle":"curveLinear"},
#     {"d3Curve":d3.curveStep,"curveTitle":"curveStep"},
#     {"d3Curve":d3.curveStepBefore,"curveTitle":"curveStepBefore"},
#     {"d3Curve":d3.curveStepAfter,"curveTitle":"curveStepAfter"},
#     {"d3Curve":d3.curveBasis,"curveTitle":"curveBasis"},
#     {"d3Curve":d3.curveCardinal,"curveTitle":"curveCardinal"},
#     {"d3Curve":d3.curveMonotoneX,"curveTitle":"curveMonotoneX"},
#     {"d3Curve":d3.curveCatmullRom,"curveTitle":"curveCatmullRom"}
#   ];


#
#   draw no., date
#   A         B
#   lsales, lx7, lx6p, lx6, lx5, lx4, lmx7, lmx6p, lmx6, lmx5, lmx4,
#   C       D    E     F    G    H    I     J     K      L     M
#           lfx7, lfx6p, lfx6, lfx5, lfx4, ljx7, ljx6p, ljx6, ljx5, ljx4,
#           N      O     P     Q     R     S      T     U     V     W
#           lwc1, lwc2, lwc3, lwc4, lwc5, lwc6, lwc7, lwcp
#           X     Y     Z     AA    AB    AC    AD     AE
#   jsales, jx6, jx5, jx4, jx3, jx2, jx1, jmx6, jmx5, jmx4, jmx3, jmx2, jmx1,
#   AF      AG   AH   AI   AJ   AK   AL   AM    AN    AO    AP    AQ    AR
#           jfx6, jfx5, jfx4, jfx3, jfx2, jfx1, jjx6, jjx5, jjx4, jjx3, jjx2, jjx1,
#           AS    AT    AU    AV    AW    AX    AY    AZ    BA    BB    BC    BD
#           jwc
#           BE
