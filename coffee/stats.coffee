# stats.coffee
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
    getStats: () ->
      q = '''
        SELECT
          YEAR(B),
          COUNT(B),
          MIN(C),AVG(C), MAX(C),
          SUM(D), SUM(E),
          AVG(F), AVG(G), AVG(H)
        GROUP BY YEAR(B)
        ORDER BY YEAR(B)
        LABEL YEAR(B) 'year', COUNT(B) 'draws',
              MIN(C) 'minLsales', AVG(C) 'avgLsales', MAX(C) 'maxLsales',
              SUM(D) 'x7', SUM(E) 'x6p',
              AVG(F) 'x6', AVG(G) 'x5', AVG(H) 'x4'
      '''
      q6p = '''
        SELECT
          YEAR(B),
          COUNT(E)
        WHERE
          E > 0
        GROUP BY YEAR(B)
        ORDER BY YEAR(B)
        LABEL YEAR(B) 'year', COUNT(E) 'x6pDraws'
      '''
      q6 = '''
        SELECT
          YEAR(B),
          COUNT(F)
        WHERE
          F > 0
        GROUP BY YEAR(B)
        ORDER BY YEAR(B)
        LABEL YEAR(B) 'year', COUNT(F) 'x6Draws'
      '''
      @lstats   = []
      @lstats6p = []
      @lstats6  = []
      https.get utils.qstring(q), (res) =>
        body = ''
        res.setEncoding 'utf-8'
        res.on 'data', (d) -> body += d
        res.on 'error', (e) -> console.log "query error: #{ e }"
        res.on 'end', () =>
          json = utils.parseResponse body
          @lstats = utils.qresult json

      https.get utils.qstring(q6p), (res) =>
        body = ''
        res.setEncoding 'utf-8'
        res.on 'data', (d) -> body += d
        res.on 'error', (e) -> console.log "query error: #{ e }"
        res.on 'end', () =>
          json = utils.parseResponse body
          @lstats6p = utils.qresult json

      https.get utils.qstring(q6), (res) =>
        body = ''
        res.setEncoding 'utf-8'
        res.on 'data', (d) -> body += d
        res.on 'error', (e) -> console.log "query error: #{ e }"
        res.on 'end', () =>
          json = utils.parseResponse body
          @lstats6 = utils.qresult json

      jq = '''
        SELECT
          YEAR(B),
          COUNT(B),
          MIN(AF),AVG(AF), MAX(AF),
          SUM(AG), SUM(AH),
          AVG(AI), AVG(AJ), AVG(AK), AVG(AL)
        GROUP BY YEAR(B)
        ORDER BY YEAR(B)
        LABEL YEAR(B) 'year', COUNT(B) 'draws',
              MIN(AF) 'minJsales', AVG(AF) 'avgJsales', MAX(AF) 'maxJsales',
              SUM(AG) 'x6', SUM(AH) 'x5',
              AVG(AI) 'x4', AVG(AJ) 'x3', AVG(AK) 'x2', AVG(AL) 'x1'
      '''
      jq5 = '''
        SELECT
          YEAR(B),
          COUNT(AH)
        WHERE
          AH > 0
        GROUP BY YEAR(B)
        ORDER BY YEAR(B)
        LABEL YEAR(B) 'year', COUNT(AH) 'x5Draws'
      '''
      jq4 = '''
        SELECT
          YEAR(B),
          COUNT(AI)
        WHERE
          AI > 0
        GROUP BY YEAR(B)
        ORDER BY YEAR(B)
        LABEL YEAR(B) 'year', COUNT(AI) 'x4Draws'
      '''
      @jstats   = []
      @jstats5  = []
      @jstats4  = []
      https.get utils.qstring(jq), (res) =>
        body = ''
        res.setEncoding 'utf-8'
        res.on 'data', (d) -> body += d
        res.on 'error', (e) -> console.log "query error: #{ e }"
        res.on 'end', () =>
          json = utils.parseResponse body
          @jstats = utils.qresult json

      https.get utils.qstring(jq5), (res) =>
        body = ''
        res.setEncoding 'utf-8'
        res.on 'data', (d) -> body += d
        res.on 'error', (e) -> console.log "query error: #{ e }"
        res.on 'end', () =>
          json = utils.parseResponse body
          @jstats5 = utils.qresult json

      https.get utils.qstring(jq4), (res) =>
        body = ''
        res.setEncoding 'utf-8'
        res.on 'data', (d) -> body += d
        res.on 'error', (e) -> console.log "query error: #{ e }"
        res.on 'end', () =>
          json = utils.parseResponse body
          @jstats4 = utils.qresult json

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
        
  data:
    count: null
    lastDraw: { }
    lstats: [ ]
    lstats6p: [ ]
    lstats6: [ ]
    jstats: [ ]
    jstats5: [ ]
    jstats4: [ ]
 
  created: () ->
    @getTotalDraws()
    @getLastDraw()
    @getStats()

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
