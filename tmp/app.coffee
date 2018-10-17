#
# win.coffe:
#   Demo application using Vue.js framework. It 
#

# utils: constants, routines
u =
  VENUS_DATE:   "2011-09-15" # date ≤ 15.09.2011
  STRESA_DATE:  "2011-09-17" # date ≥ 17.09.2011

  L_URL: "http://test.lotarija.mk/Results/WebService.asmx/GetDetailedReport"
  UPLOAD_URL: "https://script.google.com/macros/s/" +
              "AKfycbz_vGNNQpXV4VFBt8dAktnbSWKASduNUS9OJkq8PBpuoUAabh1W/exec"

  # upload draw info
  serializeDrawInfo: (i) ->
    # serialize draw info
    s  = "draw=#{ i.draw }&date=#{ u.date2MK i.date }&"
    
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


  # strip '.' and leave \d only
  strip: (s) ->
    re = /([\d.]*)/
    match = re.exec s
    match[1].replace /\./g, ''

  # strip float: strip '.' and leave \d only, convert ',' to '.'
  stripf: (s) ->
    re = /([\d.,]*)/
    match = re.exec s
    match = match[1].replace /\./g, ''
    match.replace /,/g, '.'

  # parse draw report page
  parseL: (text) ->
    ret = { }
    
    # extract draw date
    re = /<th>Датум на извлекување:<\/th>\s*<td[^>]*>([^>]*)\s*<\/td>/m
    match = re.exec text
    re = /^(\d\d).(\d\d).(\d\d\d\d)$/
    match = re.exec match[1]
    ret.date = new Date match[1..3].reverse().join '-'

    # extract draw number
    re = /br>\s*(\d+)\.[^<]*<\/h2>/m
    match = re.exec text
    ret.draw = parseInt match[1]

    # extract lotto sales
    re = /<th>Уплата:<\/th>\s*<td[^>]*>([^>]*)\s*<\/td>(.*)/m
    match = re.exec text
    ret.lsales = parseInt u.strip match[1]
    
    t = match[2] # rest of.. (post-match)

    # extract joker sales
    re = /<th>Уплата:<\/th>\s*<td[^>]*>([^>]*)\s*<\/td>/m
    match = re.exec t
    ret.jsales = parseInt u.strip match[1]

    # extract lotto winners
    re = /<table\s+class="nl734"\s*>(.*?)<\/table>/gm
    tab = text.match re
    tab = tab[1] # 2nd table is with winners
    
    re = /<tbody>\s*(.*?)\s*<\/tbody>/m
    tab = re.exec tab
    
    re = ///
      <tr>\s*<th>\s*(.*?)\s*<\/th>\s*
      <td>\s*(.*?)\s*<\/td>\s*<td>\s*
      (.*?)\s*<\/td>\s*<\/tr>(.*)
    ///m
    match = re.exec tab[1]
    while match
      switch match[1]
        when "7 погодоци"
          ret.lx7   = parseInt match[2]
          ret.lmx7  = parseFloat u.stripf(match[3])
        when "6+1 погодоци"
          ret.lx6p  = parseInt match[2]
          ret.lmx6p = parseFloat u.stripf(match[3])
        when "6 погодоци"
          ret.lx6   = parseInt match[2]
          ret.lmx6  = parseFloat u.stripf(match[3])
        when "5 погодоци"
          ret.lx5   = parseInt match[2]
          ret.lmx5  = parseFloat u.stripf(match[3])
        when "4 погодоци"
          ret.lx4   = parseInt match[2]
          ret.lmx4  = parseFloat u.stripf(match[3])
      tab = match[4]
      match = re.exec tab

    # extract lotto funds, and jackpots
    re = /<table\s+class="nl734"\s*>(.*?)<\/table>/gm
    tab = text.match re
    tab = tab[0] # 1st table is with winners
    
    re = /<tbody>\s*(.*?)\s*<\/tbody>/m
    tab = re.exec tab
    
    re = ///
      <tr>\s*<th>\s*(.*?)\s*<\/th>\s*
      <th\s*(.*?)\s*<\/th>\s*
      <td\s*>\s*(.*?)\s*<\/td>\s*<td\s*>\s*
      (.*?)\s*<\/td>\s*
      <td\s*>\s*(.*?)\s*<\/td>\s*<\/tr>(.*)
    ///m
    match = re.exec tab[1]
    while match
      switch match[1]
        when "I"
          ret.lfx7  = parseFloat u.stripf(match[3])
          ret.ljx7  = parseFloat u.stripf(match[4])
        when "II"
          ret.lfx6p = parseFloat u.stripf(match[3])
          ret.ljx6p = parseFloat u.stripf(match[4])
        when "III"
          ret.lfx6  = parseFloat u.stripf(match[3])
          ret.ljx6  = parseFloat u.stripf(match[4])
        when "IV"
          ret.lfx5  = parseFloat u.stripf(match[3])
          ret.ljx5  = parseFloat u.stripf(match[4])
        when "V"
          ret.lfx4  = parseFloat u.stripf(match[3])
          ret.ljx4  = parseFloat u.stripf(match[4])
      tab = match[6]
      match = re.exec tab

    # extract joker winners
    re = /<table\s+class="j734"\s*>(.*?)<\/table>/gm
    tab = text.match re
    raise "can't extract joker winners!" unless tab
    tab = tab[1] # 2nd table is with winners
    
    re = /<tbody>\s*(.*?)\s*<\/tbody>/m
    tab = re.exec tab
    
    re = ///
      <tr>\s*<th>\s*(.*?)\s*<\/th>\s*
      <td>\s*.*?\s*<\/td>\s*<td>\s*(.*?)\s*<\/td>\s*
      <td>\s*(.*?)\s*<\/td>\s*<\/tr>(.*)
    ///m
    match = re.exec tab[1]
    while match
      switch match[1]
        when "6 погодоци"
          ret.jx6  = parseInt match[2]
          ret.jmx6 = parseFloat u.stripf(match[3])
        when "5 погодоци"
          ret.jx5  = parseInt match[2]
          ret.jmx5 = parseFloat u.stripf(match[3])
        when "4 погодоци"
          ret.jx4  = parseInt match[2]
          ret.jmx4 = parseFloat u.stripf(match[3])
        when "3 погодоци"
          ret.jx3  = parseInt match[2]
          ret.jmx3 = parseFloat u.stripf(match[3])
        when "2 погодоци"
          ret.jx2  = parseInt match[2]
          ret.jmx2 = parseFloat u.stripf(match[3])
        when "1 погодок"
          ret.jx1  = parseInt match[2]
          ret.jmx1 = parseFloat u.stripf(match[3])
      tab = match[4]
      match = re.exec tab

    # extract joker winners
    re = /<table\s+class="j734"\s*>(.*?)<\/table>/gm
    tab = text.match re
    raise "can't extract joker winners!" unless tab
    tab = tab[0] # st table is with funds/jackpots
    
    re = /<tbody>\s*(.*?)\s*<\/tbody>/m
    tab = re.exec tab
    
    re = ///
      <tr>\s*
        <th>\s*(.*?)\s*<\/th>\s*<th\s*(.*?)\s*<\/th>\s*
      <td>\s*(.*?)\s*<\/td>\s*<td>\s*(.*?)\s*<\/td>\s*
      <td>\s*(.*?)\s*<\/td>\s*<\/tr>(.*)
    ///m
    match = re.exec tab[1]
    while match
      switch match[1]
        when "I"
          ret.jfx6 = parseFloat u.stripf(match[3])
          ret.jjx6 = parseFloat u.stripf(match[4])
        when "II"
          ret.jfx5 = parseFloat u.stripf(match[3])
          ret.jjx5 = parseFloat u.stripf(match[4])
        when "III"
          ret.jfx4 = parseFloat u.stripf(match[3])
          ret.jjx4 = parseFloat u.stripf(match[4])
        when "IV"
          ret.jfx3 = parseFloat u.stripf(match[3])
          ret.jjx3 = parseFloat u.stripf(match[4])
        when "V"
          ret.jfx2 = parseFloat u.stripf(match[3])
          ret.jjx2 = parseFloat u.stripf(match[4])
        when "VI"
          ret.jfx1 = parseFloat u.stripf(match[3])
          ret.jjx1 = parseFloat u.stripf(match[4])
      tab = match[6]
      match = re.exec tab
 
    # extract lotto winning columns
    re = /<p>Редослед на извлекување:\s*([\d,]+)\.?\s*<\/p>/m
    match = re.exec text
    throw "can't extract lotto winning column!" unless match
    lwcol = match[1].split /\s*,\s*/
                    .map (e) -> parseInt e
    [ ret.lwc1, ret.lwc2, ret.lwc3, ret.lwc4, ret.lwc5, ret.lwc6, ret.lwc7, ret.lwcp ] = lwcol

    # joker winnig column
    re = /<div\s+id="joker">\s*(\d+)\s*<\/div>/m
    match = re.exec text
    ret.jwc = match[1]

    # return result
    ret

  nextDraw: (d) ->
    throw "nextDraw(); argument error" unless d
    throw "Not a valid draw: #{ d }" unless d.draw? or d.date?
    date = new Date d.date
    switch date.getDay()
      when 3 then date.setDate(date.getDate() + 3)
      when 6 then date.setDate(date.getDate() + 4)
      else throw "Invalid draw date: #{ d.date }"
    if date.getFullYear() == d.date.getFullYear()
      { draw: d.draw + 1, date: date }
    else
      { draw: 1, date: date }

  GS_KEY: "1deUDEVwaNPH1fgy3RlmV98TwgVtHfxQc7gA9YeVs_mc"
  GS_URL: "https://spreadsheets.google.com"


  # some queries
  QRY_LOTTO_X7:   'SELECT A, B, D, I, N, S WHERE D > 0 ORDER BY B'
  QRY_LOTTO_X6P:  'SELECT A, B, E, J, O, T WHERE E > 0 ORDER BY B'
  QRY_JOKER_X6:   'SELECT A, B, AG, AM, AS, AY WHERE AG > 0 ORDER BY B'
  QRY_JOKER_X5:   'SELECT A, B, AH, AN, AT, AZ WHERE AH > 0 ORDER BY B'

  qstr: (qry) ->
    "#{ u.GS_URL }/tq?tqx=out:json&key=#{ u.GS_KEY }&tq=#{ encodeURI qry }"

  parseResponse: (r) ->
    JSON.parse r.replace(/(^.+?\()|(^\/.*\/$)|\);$/mg,'')

  queryRes: (json) ->
    rset = []
    for r in json.table.rows
      h = { }
      for c, i in json.table.cols
        h[c.label] = r.c[i].v
        if c.type is 'date'
          h[c.label] = eval 'new ' + h[c.label]
      rset.push h
    rset

  date2YMD: (d) ->
    offset = d.getTimezoneOffset() * 60000
    (new Date(d - offset)).toISOString().slice(0, 10)

  date2MK: (d) -> # dd.mm.yyyy
    offset = d.getTimezoneOffset() * 60000
    (new Date(d - offset)).toISOString().slice(0, 10)
        .split('-').reverse().join('.')

  labels:
    en:
      draw:   'Draw'
      date:   'Date'
      ## LOTTO
      lsales: 'Lotto sales'
      # winners
      lx7:    'x7'
      lx6p:   'x6+'
      lx6:    'x6'
      lx5:    'x5'
      lx4:    'x4'
      # winnings
      lmx7:    'winnings x7'
      lmx6p:   'winnings x6+'
      lmx6:    'winnings x6'
      lmx5:    'winnings x5'
      lmx4:    'winnings x4'
      # funds
      lfx7:    'fund x7'
      lfx6p:   'fund x6+'
      lfx6:    'fund x6'
      lfx5:    'fund x5'
      lfx4:    'fund x4'
      # jackpots
      ljx7:    'jackpot x7'
      ljx6p:   'jackpot x6+'
      ljx6:    'jackpot x6'
      ljx5:    'jackpot x5'
      ljx4:    'jackpot x4'
      # winning column
      lwc1:     '1st'
      lwc2:     '2nd'
      lwc3:     '3rd'
      lwc4:     '4th'
      lwc5:     '5th'
      lwc6:     '6th'
      lwc7:     '7th'
      lwcp:     'extra'
      ## JOKER
      jsales:   'Joker sales'
      # winners
      jx6:    'Jx6'
      jx5:    'Jx5'
      jx4:    'Jx4'
      jx3:    'Jx3'
      jx2:    'Jx2'
      jx1:    'Jx1'
      # winnings
      jmx6:    'winnings Jx6'
      jmx5:    'winnings Jx5'
      jmx4:    'winnings Jx4'
      jmx3:    'winnings Jx3'
      jmx2:    'winnings Jx2'
      jmx1:    'winnings Jx1'
      # funds
      jfx6:    'fund Jx6'
      jfx5:    'fund Jx5'
      jfx4:    'fund Jx4'
      jfx3:    'fund Jx3'
      jfx2:    'fund Jx2'
      jfx1:    'fund Jx1'
      # jackpots
      jjx6:    'jackpot Jx6'
      jjx5:    'jackpot Jx5'
      jjx4:    'jackpot Jx4'
      jjx3:    'jackpot Jx3'
      jjx2:    'jackpot Jx2'
      jjx1:    'jackpot Jx1'
      # winning column
      jwc:      'Winning column'

    mk:
      draw:   'Извлекување'
      date:   'Дата'
      ## LOTTO
      lsales: 'Уплата лото'
      # winners
      lx7:    'x7'
      lx6p:   'x6+'
      lx6:    'x6'
      lx5:    'x5'
      lx4:    'x4'
      # winnings
      lmx7:    'добивка x7'
      lmx6p:   'добивка x6+'
      lmx6:    'добивка x6'
      lmx5:    'добивка x5'
      lmx4:    'добивка x4'
      # funds
      lfx7:    'фонд x7'
      lfx6p:   'фонд x6+'
      lfx6:    'фонд x6'
      lfx5:    'фонд x5'
      lfx4:    'фонд x4'
      # jackpots
      ljx7:    'џекпот x7'
      ljx6p:   'џекпот x6+'
      ljx6:    'џекпот x6'
      ljx5:    'џекпот x5'
      ljx4:    'џекпот x4'
      # winning column
      lwc1:     '1ви'
      lwc2:     '2ри'
      lwc3:     '3ти'
      lwc4:     '4ти'
      lwc5:     '5ти'
      lwc6:     '6ти'
      lwc7:     '7ми'
      lwcp:     'дополнителен'
      ## JOKER
      jsales:   'Уплата џокер'
      # winners
      jx6:    'џx6'
      jx5:    'џx5'
      jx4:    'џx4'
      jx3:    'џx3'
      jx2:    'џx2'
      jx1:    'џx1'
      # winnings
      jmx6:    'добивка џx6'
      jmx5:    'добивка џx5'
      jmx4:    'добивка џx4'
      jmx3:    'добивка џx3'
      jmx2:    'добивка џx2'
      jmx1:    'добивка џx1'
      # funds
      jfx6:    'фонд џx6'
      jfx5:    'фонд џx5'
      jfx4:    'фонд џx4'
      jfx3:    'фонд џx3'
      jfx2:    'фонд џx2'
      jfx1:    'фонд џx1'
      # jackpots
      jjx6:    'џекпот џx6'
      jjx5:    'џекпот џx5'
      jjx4:    'џекпот џx4'
      jjx3:    'џекпот џx3'
      jjx2:    'џекпот џx2'
      jjx1:    'џекпот џx1'
      # winning column
      jwc:      'Добитна комбинација'

# all of lotto x7
Vue.component 'top-winners', {
  template: """
      <table class='table table-bordered table-striped table-hover table-condensed
             table-responsive roboto' v-if='allWinners'>
        <thead>
          <tr>
            <th v-for='(v, c) in allWinners[0]' class='text-right'>{{ c | label }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for='r in allWinners'>
            <td v-for='(v, c) in r' class='text-right'>
              <span v-if="c === 'date'">{{ v | toYMD }}</span>
              <span v-else="c === 'date'">{{ v | number }}</span>
            </td>
          </tr>
        </tbody>
      </table>
      <p v-else=''>Loading...</p>
    """

  props:  ['game', 'winners']

  data: () ->
    ret =
      allWinners: @getAllWinners()

  filters:
    toYMD: (d) -> if d? then u.date2YMD d else ''
    label: (l) -> if l? then u.labels.en[l] else ''
    number: (v) ->
      if v? and typeof v.toLocaleString is 'function'
        v.toLocaleString()
      else
        ''

  methods:
    getAllWinners: () ->
      console.log "getAllWinners(): entered"
      console.log "game: #{ @game }, winners: #{ @winners }"
      qry = switch
              when @game is 'lotto' and @winners is 'x7'  then u.QRY_LOTTO_X7
              when @game is 'lotto' and @winners is 'x6p' then u.QRY_LOTTO_X6P
              when @game is 'joker' and @winners is 'x6'  then u.QRY_JOKER_X6
              when @game is 'joker' and @winners is 'x5'  then u.QRY_JOKER_X5
      console.log "query:", qry
      @$http.get u.qstr(qry)
        .then (res) -> # success
          json = u.parseResponse res.bodyText
          @allWinners = u.queryRes json
          console.log "allWinners:", @allWinners
        , (res) -> # error
          console.log "getAllWinners() error:", res
      null
}

# some routes
routes = [
  {
    path: '/lotto-x7'
    component:
      template: """
        <top-winners :game="'lotto'" :winners="'x7'"></top-winners>
      """
  },
  {
    path: '/lotto-x6p'
    component:
      template: """
        <top-winners :game="'lotto'" :winners="'x6p'"></top-winners>
      """
  },
  {
    path: '/joker-x6'
    component:
      template: """
        <top-winners :game="'joker'" :winners="'x6'"></top-winners>
      """
  },
  {
    path: '/joker-x5'
    component:
      template: """
        <top-winners :game="'joker'" :winners="'x5'"></top-winners>
      """
  },
  {
    path: '/upload/:year/draw/:draw'
    name: 'upload'
    component:
      template: """
        <upload :year="$route.params.year"
           :draw="$route.params.draw">
        </upload>
      """
  },
  {
    path: '/freqs-all'
    component:
      template: "<freqs></freqs>"
  },
  {
    path: '/freqs-venus'
    component:
      template: """<freqs :machine="'venus'"></freqs>"""
  },
  {
    path: '/freqs-stresa'
    component:
      template: """<freqs :machine="'stresa'"></freqs>"""
  },
  {
    path: '/lstats'
    component:
      template: """<lstats></lstats>"""
  },
  {
    path: '/jstats'
    component:
      template: """<jstats></jstats>"""
  },
]

Upload = Vue.component 'upload', {
  template: """
    <div v-if='data'> 
      <pre >{{ info }}</pre>
    </div>
  """
  props: ['year', 'draw']

  data: () ->
    ret =
      data: @getDraw()
      info: null

  methods:
    uploadDrawInfo: (i) ->
      opts =
        method: 'post'
        params: u.serializeDrawInfo(i)
        body: u.serializeDrawInfo(i)
        headers:
          'Content-Type': 'application/x-www-form-urlencoded'
          'Accept':       'application/json'
      @$http.post u.UPLOAD_URL, u.serializeDrawInfo(i), opts
        .then (res) -> # success
          console.log "upload success:", res
          @$parent.$emit 'upload'
        , (res) -> # error
          console.log "upload err:", res
      null

    getDraw: () ->
      params =
        godStr:   @year.toString()
        koloStr:  @draw.toString()
      @$http.post u.L_URL, params
        .then (res) -> # success
          @data = res.body.d
          @info = u.parseL @data
          @uploadDrawInfo @info
        , (res) -> # error
          console.log "post error:", res
          console.log "opts:", opts
      null
}

# stats including freqs 
Vue.component 'freqs', {
  template: """
      <table class='table table-bordered table-striped table-hover table-condensed
             table-responsive roboto' v-if='freqs'>
        <caption>{{ title }}</caption>
        <thead>
          <tr>
            <th v-for='c in header' class='text-center'>{{ c }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for='(r, i) in freqs'>
            <td class='text-center'>{{ i + 1 }}</td>
            <td v-for='v in r' class='text-center'>
              {{ v }}
            </td>
          </tr>
        </tbody>
      </table>
      <p v-else=''>Loading...</p>
  """

  props:
    machine:
      type: String
      default: 'all'

  data: () ->
    ret =
      header: [ 'no.', 'Σ' , '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '+' ]
      freqs: @getFreqs()

  computed:
    title: () ->
      switch @machine
        when 'all'    then 'Frequencies of all drawn numbers'
        when 'venus'  then 'Number frequencies on Venus'
        when 'stresa' then 'Number frequencies on Stresa'

  methods:
    getFreqs: () ->
      q = switch @machine
            when 'all'
              'SELECT X, Y, Z, AA, AB, AC, AD, AE'
            when 'venus'
              "SELECT X, Y, Z, AA, AB, AC, AD, AE WHERE B <= date'#{ u.VENUS_DATE }'"
            when 'stresa'
              "SELECT X, Y, Z, AA, AB, AC, AD, AE WHERE B >= date'#{ u.STRESA_DATE }'"
      @$http.get u.qstr(q)
        .then (res) -> # success
          # parse gs query
          json = u.parseResponse res.bodyText
          return null unless json.status is 'ok'
          nums = u.queryRes json
          console.log "successfully loaded drawn numbers", nums
          # build freqs
          freqs = new Array 34 + 1
          freqs[i] = [0, 0, 0, 0, 0, 0, 0, 0, 0] for i in [1..34]
          for r in nums
            for i in [1 .. 7]
              k = "lwc#{ i }"
              n = r[k]
              freqs[n][0] += 1
              freqs[n][i] += 1
            n = r['lwcp']
            freqs[n][0] += 1
            freqs[n][i] += 1
          freqs.shift()
          @freqs = freqs
        , (res) ->
          console.log "error loading winning columns for machine #{ @machine }"
          null
      null

}

# lotto winner stats
Vue.component 'lstats', {
  template:"""
      <table class='table table-bordered table-striped table-hover table-condensed
             table-responsive roboto' v-if='stats && stats6p && stats6'>
        <caption>Lotto winners stats</caption>
        <thead>
          <tr>
            <th v-for='(v, c) in stats[0]' class='text-center'>{{ c }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for='(r, i) in stats'>
            <td class='text-center'>{{ r.year }}</td>
            <td class='text-center'>{{ r.draws }}</td>
            <td class='text-right'>{{ r.min | round | number }}</td>
            <td class='text-right'>{{ r.avg | round | number }}</td>
            <td class='text-right'>{{ r.max | round | number }}</td>
            <td class='text-center'>{{ r.x7 }}</td>
            <td class='text-center'>{{ r.x6p }}/{{ stats6p[i].drawcnt }}</td>
            <td class='text-center'>{{ r.x6 | round }}
              ({{ (stats6[i].drawcnt / r.draws * 100.0) | round }}%)
            </td>
            <td class='text-center'>{{ r.x5 | round }}</td>
            <td class='text-center'>{{ r.x4 | round | number }}</td>
          </tr>
        </tbody>
      </table>
      <p v-else=''>Loading...</p>
  """

  data: () ->
    ret =
      stats:    @getWStats()
      stats6p:  @get6pStats()
      stats6:   @get6Stats()

  methods:
    getWStats: () ->
      q = """
        SELECT
          YEAR(B), COUNT(A),
          MIN(C), AVG(C), MAX(C),
          SUM(D), SUM(E),
          AVG(F), AVG(G),
          AVG(H)
        GROUP BY YEAR(B)
        ORDER BY YEAR(B)
        LABEL YEAR(B) 'year', COUNT(A) 'draws',
              MIN(C) 'min', AVG(C) 'avg', MAX(C) 'max',
              SUM(D) 'x7', SUM(E) 'x6p',
              AVG(F) 'x6', AVG(G) 'x5',
              AVG(H) 'x4'

      """
      @$http.get u.qstr(q)
        .then (res) -> # success
          json = u.parseResponse res.bodyText
          @stats = u.queryRes json
        , (res) -> # error
          console.log "getWStats() error:", res
          null
      null

    get6pStats: () ->
      q = """
        SELECT
          YEAR(B),
          COUNT(A)
        WHERE E > 0
        GROUP BY YEAR(B)
        ORDER BY YEAR(B)
        LABEL YEAR(B) 'year',
              COUNT(A) 'drawcnt'
      """
      @$http.get u.qstr(q)
        .then (res) -> # success
          json = u.parseResponse res.bodyText
          @stats6p = u.queryRes json
          console.log "stats 6p:", @stats6p
        , (res) -> # error
          console.log "get6pStats() error:", res
          null
      null

    get6Stats: () ->
      q = """
        SELECT
          YEAR(B),
          COUNT(A)
        WHERE F > 0
        GROUP BY YEAR(B)
        ORDER BY YEAR(B)
        LABEL YEAR(B) 'year',
              COUNT(A) 'drawcnt'
      """
      @$http.get u.qstr(q)
        .then (res) -> # success
          json = u.parseResponse res.bodyText
          @stats6 = u.queryRes json
          console.log "stats 6:", @stats6
        , (res) -> # error
          console.log "get6Stats() error:", res
          null
      null

  filters:
    round: (v) -> Math.round v
    number: (v) ->
      if v? and typeof v.toLocaleString is 'function'
        v.toLocaleString()
      else
        ''
}

# joker winner stats
Vue.component 'jstats', {
  template: """
      <table class='table table-bordered table-striped table-hover table-condensed
             table-responsive roboto' v-if='stats && stats5 && stats4'>
        <caption>Joker winners stats</caption>
        <thead>
          <tr>
            <th v-for='(v, c) in stats[0]' class='text-center'>{{ c }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for='(r, i) in stats'>
            <td class='text-center'>{{ r.year }}</td>
            <td class='text-center'>{{ r.draws }}</td>
            <td class='text-right'>{{ r.min | round | number }}</td>
            <td class='text-right'>{{ r.avg | round | number }}</td>
            <td class='text-right'>{{ r.max | round | number }}</td>
            <td class='text-center'>{{ r.x6 }}</td>
            <td class='text-center'>{{ r.x5 }}
              <span v-if='r.x5 > 0'>/{{ stats5[i].drawcnt }}</span>
            </td>
            <td class='text-center'>{{ r.x4 | round }}
                ({{ (stats4[i].drawcnt / r.draws * 100.0) | round }}%)
            </td>
            <td class='text-center'>{{ r.x3 | round }}</td>
            <td class='text-center'>{{ r.x2 | round | number }}</td>
            <td class='text-center'>{{ r.x1 | round | number }}</td>
          </tr>
        </tbody>
      </table>
      <p v-else=''>Loading...</p>
  """

  data: () ->
    ret =
      stats:  @getStats()
      stats5: @getStats5()
      stats4: @getStats4()

  methods:
    getStats: () ->
      q = """
        SELECT
          YEAR(B), COUNT(A),
          MIN(AF), AVG(AF), MAX(AF),
          SUM(AG), SUM(AH),
          AVG(AI), AVG(AJ),
          AVG(AK), AVG(AL)
        GROUP BY YEAR(B)
        ORDER BY YEAR(B)
        LABEL YEAR(B) 'year', COUNT(A) 'draws',
              MIN(AF) 'min', AVG(AF) 'avg', MAX(AF) 'max',
              SUM(AG) 'x6', SUM(AH) 'x5',
              AVG(AI) 'x4', AVG(AJ) 'x3',
              AVG(AK) 'x2', AVG(AL) 'x1'
      """
      @$http.get u.qstr(q)
        .then (res) -> # success
          json = u.parseResponse res.bodyText
          @stats = u.queryRes json
        , (res) -> # error
          console.log "joker getStats() error:", res
          null
      null

    getStats5: () ->
      q = """
        SELECT
          YEAR(B),
          COUNT(A)
        WHERE AH > 0
        GROUP BY YEAR(B)
        ORDER BY YEAR(B)
        LABEL YEAR(B) 'year',
              COUNT(A) 'drawcnt'
      """
      @$http.get u.qstr(q)
        .then (res) -> # success
          json = u.parseResponse res.bodyText
          @stats5 = u.queryRes json
        , (res) -> # error
          console.log "joker getStats5() error:", res
          null
      null

    getStats4: () ->
      q = """
        SELECT
          YEAR(B),
          COUNT(A)
        WHERE AI > 0
        GROUP BY YEAR(B)
        ORDER BY YEAR(B)
        LABEL YEAR(B) 'year',
              COUNT(A) 'drawcnt'
      """

      @$http.get u.qstr(q)
        .then (res) -> # success
          json = u.parseResponse res.bodyText
          @stats4 = u.queryRes json
        , (res) -> # error
          console.log "joker getStats4() error:", res
          null
      null

  filters:
    round: (v) -> Math.round v
    number: (v) ->
      if v? and typeof v.toLocaleString is 'function'
        v.toLocaleString()
      else
        ''
}

# vue vm
app = new Vue {
  el: '#app'
  
  data:
    lastDraw: null, # @getLastDraw() # { date,  drawnum }
    allx7:    null
    version:  Vue.version
    game:     'joker'
    winners:  'x6'

  ready: () ->
    # console.log 'app ready'
    @lastDraw = @getLastDraw()

  created: () ->
    console.log 'created'
    @lastDraw = @getLastDraw()

  computed:
    nextDraw: () ->
      if @lastDraw then u.nextDraw @lastDraw else null

    toUpload: () ->
      today = new Date()
      today = new Date(today.getFullYear(), today.getMonth(),
                    today.getDate())
      if @nextDraw? and @nextDraw.date < today
        true
      else
        false

  methods:
    refreshLastDraw: () ->
      console.log "Last Draw needs refresh!"
      @lastDraw = @getLastDraw()

    gameChanged: () ->
      switch @game
        when 'lotto' then @winners = 'x7'
        when 'joker' then @winners = 'x6'
      console.log "Game is: #{ @game }, winners is: #{ @winners }"

    getLastDraw: () ->
      qry = 'SELECT A, B ORDER BY B DESC LIMIT 1'
      @$http.get u.qstr(qry)
        .then (res) -> # success
          json = u.parseResponse res.bodyText
          return unless json.status is 'ok'
          @lastDraw =
            date: eval "new " + json.table.rows[0].c[1].v
            draw: json.table.rows[0].c[0].v
        , (res) -> # error
          console.log "Last draw err:", res
      null

  router: new VueRouter(routes: routes)

  filters:
    toYMD: (d) -> u.date2YMD d


}
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
