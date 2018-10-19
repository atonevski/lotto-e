# all.coffee: list all draws (complete)
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
    getFirstDraws: () ->
      https.get utils.qstring('SELECT * LIMIT 25'), (res) =>
        body = ''
        res.setEncoding 'utf-8'
        res.on 'data', (d) -> body += d
        res.on 'error', (e) -> console.log "query error: #{ e }"
        res.on 'end', () =>
          json = utils.parseResponse body.toString()
          @draws = utils.qresult json

  created: () ->
    @getFirstDraws()
    window.onscroll = () ->
      console.log 'onscroll called'
      if document.documentElement.scrollTop + window.innerHeight is document.documentElement.offsetHeight
        console.log 'reached bottom of window'
