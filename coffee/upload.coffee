# upload.coffe:
# - reads and parses data from draw report
# - updates gs db
#

utils = require '../js/utils.js'
https = require 'https'
http  = require 'http'
request = require 'request'

vue = new Vue
  el: '#app'

  data:
    count: null
    lastDraw: { }
    year: 2018
    draw: 81
    html: null
    info: null

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

    fetchDraw: () ->
      params =
        godStr: @year.toString()
        koloStr: @draw.toString()
      # http.post utils.L_URL, params, (res) =>
      #   body = ''
      #   res.setEncoding 'utf-8'
      #   res.on 'data', (d) -> body += d
      #   res.on 'error', (e) -> console.log "draw report error: #{ e }"
      #   res.on 'end', () =>
      #     @html = body
      #     console.log @html
      #     # parse here
      request.post {
        url: utils.L_URL
        body: params
        json: yes
      }, (err, res, body) =>
        @html = body.d
        @info = utils.parseL @html
        console.log @info

  created: () ->
    @getTotalDraws()
    @getLastDraw()
    @fetchDraw()
