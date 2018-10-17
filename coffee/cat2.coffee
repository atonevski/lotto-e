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

    getWinners: () ->
      @ldraws = [ ]
      lq = '''
        SELECT
          A, B, E,
          J, O, T
        WHERE
          E > 0
        ORDER BY B
        LABEL A 'draw', B 'date',
              E 'x6p',  J 'winnings', O 'funds', T 'jackpot'
      '''
      https.get utils.qstring(lq), (res) =>
        body = ''
        res.setEncoding 'utf-8'
        res.on 'data', (d) -> body += d
        res.on 'error', (e) -> console.log "query error: #{ e }"
        res.on 'end', () =>
          json = utils.parseResponse body
          @ldraws = utils.qresult json

      @jdraws = [ ]
      jq = '''
        SELECT
          A, B,
          AH, AN, AT, AZ
        WHERE
          AH > 0
        ORDER BY B
        LABEL A 'draw', B 'date',
              AH 'x5',  AN 'winnings', AT 'funds', AZ 'jackpot'
      '''
      https.get utils.qstring(jq), (res) =>
        body = ''
        res.setEncoding 'utf-8'
        res.on 'data', (d) -> body += d
        res.on 'error', (e) -> console.log "query error: #{ e }"
        res.on 'end', () =>
          json = utils.parseResponse body
          @jdraws = utils.qresult json

  data:
    count: null
    lastDraw: { }
    ldraws: [ ]
    jdraws: [ ]
    colors: [ 'light-gray-c', 'white-c', 'red-c', 'green-c', 'yellow-c',
              'blue-c', 'magenta-c', 'cyan-c', 'light-red-c', 'light-green-c',
              'light-yellow-c', 'light-blue-c', 'light-magenta-c', 'light-cyan-c'
    ]

  created: () ->
    @getTotalDraws()
    @getLastDraw()
    @getWinners()

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
