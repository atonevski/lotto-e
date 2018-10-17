# cat
# cat2.coffee: 2nd category winners
#

utils = require '../js/utils.js'
https  = require 'https'

vue = new Vue
  el: '#app'

  filters:
    number: (v) ->
      if v? and typeof v.toLocaleString is 'function'
        v.toLocaleString()
      else
        ''

    toYMD: utils.toYMD
    toDMY: utils.toDMY

  methods:
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

  data:
    count: null
    lastDraw: { }
    lfreq: [ ]
    jfreq: [ ]
    drum: 'BOTH'

  created: () ->
    console.log utils.VENUS_DATE, utils.toYMD utils.VENUS_DATE
    console.log utils.STRESA_DATE, utils.toYMD utils.STRESA_DATE
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


