# all.coffee: list all draws (complete)
#

utils = require '../js/utils.js'
https = require 'https'

cclass =
  draw: 'center'
  date: 'center'
  lsales: 'right'
  lx7:    'center'
  lx6p: 'center'
  lx6: 'center'
  lx5: 'right'
  lx4: 'right'
  lmx7: 'right'
  lmx6p: 'right'
  lmx6: 'right'
  lmx5: 'right'
  lmx4: 'right'
  lfx7: 'right'
  lfx6p: 'right'
  lfx6: 'right'
  lfx5: 'right'
  lfx4: 'right'
  ljx7: 'right'
  ljx6p: 'right'
  ljx6: 'right'
  ljx5: 'right'
  ljx4: 'right'
  lwc1: 'center red-c wc'
  lwc2: 'center green-c wc'
  lwc3: 'center yellow-c wc'
  lwc4: 'center blue-c wc'
  lwc5: 'center magenta-c wc'
  lwc6: 'center light-blue-c wc'
  lwc7: 'center light-magenta-c wc'
  lwcp: 'center white-c wc'
  jsales: 'right'
  jx6: 'center'
  jx5: 'center'
  jx4: 'center'
  jx3: 'right'
  jx2: 'right'
  jx1: 'right'
  jmx6: 'right'
  jmx5: 'right'
  jmx4: 'right'
  jmx3: 'right'
  jmx2: 'right'
  jmx1: 'right'
  jfx6: 'right'
  jfx5: 'right'
  jfx4: 'right'
  jfx3: 'right'
  jfx2: 'right'
  jfx1: 'right'
  jjx6: 'right'
  jjx5: 'right'
  jjx4: 'right'
  jjx3: 'right'
  jjx2: 'right'
  jjx1: 'right'
  jwc: 'center white-c'

vue = new Vue
  el: '#app'

  data:
    draws: []
    offset: 0
    PAGE: 25
    isLoading: no
    cclass: cclass

  filters:
    number: (v) ->
      if v? and typeof v.toLocaleString is 'function'
        if typeof v is 'number'
          Math.round(v).toLocaleString()
        else
          v.toLocaleString()
      else
        ''

    toYMD: utils.toYMD
    toDMY: utils.toDMY

  methods:
    getMoreDraws: () ->
      return if @isLoading

      @isLoading = yes
      q = """
        SELECT
          *
        LIMIT #{ @PAGE }
        OFFSET #{ @offset }
      """
      https.get utils.qstring(q), (res) =>
        body = ''
        res.setEncoding 'utf-8'
        res.on 'data', (d) -> body += d
        res.on 'error', (e) =>
          console.log "query error: #{ e }"
          @isLoading = no # not any more
        res.on 'end', () =>
          json = utils.parseResponse body.toString()
          rows = utils.qresult json
          if rows.length > 0
            @draws.push r for r in rows
            @offset += rows.length
            console.log @draws
            console.log @offset
          @isLoading = no

  created: () ->
    @getMoreDraws()
    window.onscroll = () =>
      reachedBottom = document.documentElement.scrollTop + window.innerHeight >= 
                        document.documentElement.offsetHeight

      if reachedBottom and not @isLoading
        console.log 'reached bottom of window'
        @getMoreDraws()

