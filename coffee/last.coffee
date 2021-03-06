# last.coffee: last few draws
#

utils = require '../js/utils.js'
https = require 'https'

vue = new Vue
  el: '#app'

  data:
    draws: []

  filters:
    number: (v) ->
      if v? and typeof v.toLocaleString is 'function'
        v.toLocaleString()
      else
        ''
    toYMD: utils.toYMD
    toDMY: utils.toDMY

  methods:
    getDraws: () ->
      # D-H: lotto winners
      # AG-AL: joker winners
      q = '''
        SELECT
          A, B,
          C, 
          D, E, F, G, H,
          X, Y, Z, AA, AB, AC, AD, AE,
          AF,
          AG, AH, AI, AJ, AK, AL,
          BE
        ORDER BY B DESC
        LIMIT 25
      '''
      https.get utils.qstring(q), (res) =>
        body = ''
        res.setEncoding 'utf-8'
        res.on 'data', (d) -> body += d
        res.on 'error', (e) -> console.log "query error: #{ e }"
        res.on 'end', () =>
          json = utils.parseResponse body.toString()
          @draws = utils.qresult json

  created: () ->
    @getDraws()
    console.log location.pathname
