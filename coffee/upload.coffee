# upload.coffee:
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
    nextDraw: null
#    year: 2018
#    draw: 81
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
    nextDrawAvail: (d) ->
      today = new Date()
      console.log new Date(@nextDraw.date.getTime() + 21*60*60*1000)
      console.log new Date(today.getTime())
      @nextDraw? and
        new Date(@nextDraw.date.getTime() + 21*60*60*1000) <= today.getTime()

    getNextDraw: (d) -> utils.nextDraw d
    getLastDraw: () ->
      @nextDraw = null
      q = '''
        SELECT A, B
        ORDER BY B DESC
        LIMIT 1
        LABEL A 'draw', B 'date'
      '''
      https.get utils.qstring(q), (res) =>
        body = ''
        res.setEncoding 'utf-8'
        res.on 'data', (d) -> body += d
        res.on 'error', (e) -> console.log "query error: #{ e }"
        res.on 'end', () =>
          json = utils.parseResponse body.toString()
          @lastDraw = (utils.qresult json)[0]
          @nextDraw = @getNextDraw @lastDraw

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

    fetchDrawAndUpload: () ->
      throw "Next draw not available" unless @nextDraw
      params =
        godStr: @nextDraw.date.getFullYear().toString()
        koloStr: @nextDraw.draw.toString()
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
        console.log "serializeDrawInfo:", @serializeDrawInfo @info
        @upload()

    serializeDrawInfo: (i) ->
      # serialize draw info
      s  = "draw=#{ i.draw }&date=#{ utils.toDMY i.date }&"

      # LOTTO
      # lotto sales
      s += "lsales=#{ i.lsales }&"
      # lotto winners & winnings
      s += "lx7=#{ i.lx7 }&lx6p=#{ i.lx6p }&lx6=#{ i.lx6 }&lx5=#{ i.lx5 }&lx4=#{ i.lx4 }&"
      s += "lmx7=#{ i.lmx7 }&lmx6p=#{ i.lmx6p }&lmx6=#{ i.lmx6 }&lmx5=#{ i.lmx5 }&lmx4=#{ i.lmx4 }&"
      # lotto funds & jackpots
      s += "lfx7=#{ i.lfx7 }&lfx6p=#{ i.lfx6p }&lfx6=#{ i.lfx6 }&lfx5=#{ i.lfx5 }&lfx4=#{ i.lfx4 }&"
      s += "ljx7=#{ i.ljx7 }&ljx6p=#{ i.ljx6p }&ljx6=#{ i.ljx6 }&ljx5=#{ i.ljx5 }&ljx4=#{ i.ljx4 }&"
      # lotto winning column
      s += "lwc1=#{ i.lwc1 }&lwc2=#{ i.lwc2 }&lwc3=#{ i.lwc3 }&lwc4=#{ i.lwc4 }" +
           "&lwc5=#{ i.lwc5 }&lwc6=#{ i.lwc6 }&lwc7=#{ i.lwc7 }&lwcp=#{ i.lwcp }&"

      # JOKER
      # joker sales
      s += "jsales=#{ i.jsales }&"
      # joker winner & winnings
      s += "jx6=#{ i.jx6 }&jx5=#{ i.jx5 }&jx4=#{ i.jx4 }&" +
           "jx3=#{ i.jx3 }&jx2=#{ i.jx2 }&jx1=#{ i.jx1 }&"
      s += "jmx6=#{ i.jmx6 }&jmx5=#{ i.jmx5 }&jmx4=#{ i.jmx4 }&" +
           "jmx3=#{ i.jmx3 }&jmx2=#{ i.jmx2 }&jmx1=#{ i.jmx1 }&"
      # joker funds & jackpots
      s += "jfx6=#{ i.jfx6 }&jfx5=#{ i.jfx5 }&jfx4=#{ i.jfx4 }&" +
           "jfx3=#{ i.jfx3 }&jfx2=#{ i.jfx2 }&jfx1=#{ i.jfx1 }&"
      s += "jjx6=#{ i.jjx6 }&jjx5=#{ i.jjx5 }&jjx4=#{ i.jjx4 }&" +
           "jjx3=#{ i.jjx3 }&jjx2=#{ i.jjx2 }&jjx1=#{ i.jjx1 }&"
      # joker winning column
      s += "jwc=#{ i.jwc }"

    upload: () ->
      throw "Invalid draw info" unless @info
      headers =
        'Content-Type':     'application/x-www-form-urlencoded'
        'Accept-Charset':   'utf-8'
        'Accept':           'application/json'
      request.post {
        url: utils.APPEND_ULR
        body: @serializeDrawInfo @info
        params: @serializeDrawInfo @info
        headers: headers
      }, (err, res, body) =>
        console.log "Upload status code: #{ res.statusCode }"
        if res.statusCode in [200, 302]
          @getTotalDraws()
          @getLastDraw()
        else
          alert "Upload error: #{ res.statusCode } \n #{ body }"

  created: () ->
    @getTotalDraws()
    @getLastDraw()
