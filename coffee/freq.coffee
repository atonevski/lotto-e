# cat
# cat2.coffee: 2nd category winners
#

utils = require '../js/utils.js'
https = require 'https'

vue = new Vue
  el: '#app'

  data:
    count: null
    lastDraw: { }
    lfreq: [ ]
    jfreq: [ ]
    drum: 'BOTH'

    showGraphs: yes
    LWIDTH:  800
    LHEIGHT: 500

    lmargins:
      top:    20
      right:  120
      bottom: 20
      left:   40

  filters:
    number: (v) ->
      if v? and typeof v.toLocaleString is 'function'
        v.toLocaleString()
      else
        ''

    toYMD: utils.toYMD
    toDMY: utils.toDMY

  methods:
    toggleShow: () -> @showGraphs = not @showGraphs
    getLastDraw: () ->
      q = '''
        SELECT A, B
        ORDER BY B DESC
        LIMIT 1
        LABEL A 'number', B 'date'
      '''
      https.get utils.qstring(q), (res) =>
        body = ''
        res.setEncoding 'utf-8'
        res.on 'data', (d) -> body += d
        res.on 'error', (e) -> console.log "query error: #{ e }"
        res.on 'end', () =>
          json = utils.parseResponse body.toString()
          @lastDraw = (utils.qresult json)[0]

    getTotalDraws: () ->
      q = '''
        SELECT COUNT(A)
        LABEL COUNT(A) 'count'
      '''
      https.get utils.qstring(q), (res) =>
        body = ''
        res.setEncoding 'utf-8'
        res.on 'data', (d) -> body += d
        res.on 'error', (e) -> console.log "query error: #{ e }"
        res.on 'end', () =>
          json = utils.parseResponse body
          @count = (utils.qresult json)[0].count

    drawLgraph: () ->
      svg = d3.select '#id-lgraph'
              .attr 'class', 'axis'
              .attr 'width', @LWIDTH + 'px'
              .attr 'height', @LHEIGHT + 'px'
      [xmin, xmax] = [1, 34]
      ymin = 0
      ymax = d3.max @lfreq[1..34], (n) ->
                  n.reduce (x, s) ->
                    x + s
                  , 0
      xRange = d3.scaleBand()
                .range [@lmargins.left, @LWIDTH - @lmargins.right]
                .domain [xmin..xmax]
                .padding 0.2

      yRange = d3.scaleLinear()
                .range [@LHEIGHT - @lmargins.top, @lmargins.bottom]
                .domain [ymin, ymax]

      xAxis = d3.axisBottom xRange
      yAxis = d3.axisLeft yRange

      console.log svg

      svg.append 'g' # take care for redrawing
        .attr 'class', 'x axis'
        .attr 'transform', "translate(0, #{ @LHEIGHT - @lmargins.bottom })"
        .call xAxis

      svg.append 'g'
        .attr 'class', 'y axis'
        .attr 'transform', "translate(#{ @lmargins.left }, 0)"
        .call yAxis

    getFreq: () -> # drum: options argument
      lfreq = [ ]
      for i in [0..34]
        lfreq.push [0, 0, 0, 0, 0, 0, 0, 0]

      lq = '''
        SELECT X, Y, Z, AA, AB, AC, AD, AE
        :filter
      '''
      lq = switch @drum
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
          @lfreq = lfreq
          @drawLgraph()
        null


      jq = '''
        SELECT BE
        :filter
      '''
      jq = switch @drum
            when utils.VENUS
              jq.replace /\:filter/,
                  "WHERE B <= date '#{utils.toYMD utils.VENUS_DATE}'"
            when utils.STRESA
              jq.replace /\:filter/,
                  "WHERE B >= date '#{utils.toYMD utils.STRESA_DATE}'"
            else
              jq.replace /\:filter/, ''
      https.get utils.qstring(jq), (res) =>
        jfreq = []
        for i in [0..9]
          jfreq.push [0, 0, 0, 0, 0, 0]
        body = ''
        res.setEncoding 'utf-8'
        res.on 'data', (d) -> body += d
        res.on 'error', (e) -> console.log "query error: #{ e }"
        res.on 'end', () =>
          json = utils.parseResponse body
          recs = utils.qresult json
          arr = recs.map (r) ->
                r.jwc.split ''
                 .map (e) -> parseInt e
          for a in arr
            for i, n of a
              jfreq[n][i]++
          @jfreq = jfreq
        null
      null

    drumChanged: () ->
      console.log "Drum is:", @drum
      @getFreq()


  created: () ->
    @getTotalDraws()
    @getLastDraw()
    @getFreq()

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


