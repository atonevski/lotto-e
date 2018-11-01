# graph-sales.coffee: sales line graph
#

utils = require '../js/utils.js'
https = require 'https'

# some globals
WIDTH = 800
HEIGHT = 500

margins =
  top:    20
  right:  120
  bottom: 20
  left:   40
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
  wednesdays = (r for r in recs when r.date.getDay() is 1)
  saturdays = (r for r in recs when r.date.getDay() is 6)

  # console.log wednesdays

  svg = d3.select '.container'
          .append 'svg'
          .attr 'class', 'axis'
          .attr 'width', WIDTH
          .attr 'height', HEIGHT
  console.log wednesdays[-1].date
  console.log wednesdays[-50].date

  [xmin, xmax] = [ wednesdays[-1].date, wednesdays[-50].date ]
  xRange = d3.scaleTime()
             .range [margins.left, WIDTH - margins.right]
             .domain [xmin..xmax]
#              .padding 0.2

  ymin = d3.min wednesdays[-1..-50], (d) ->
              d.lsales

  ymax = d3.max wednesdays[-1..-50], (d) ->
              d.lsales
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
