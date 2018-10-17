# utils.coffee
# Handles google script/sheets
#

GS_KEY = "1deUDEVwaNPH1fgy3RlmV98TwgVtHfxQc7gA9YeVs_mc"
GS_URL = "https://docs.google.com"

VENUS_DATE  = new Date Date.parse "2011-09-15" # date ≤ 15.09.2011
STRESA_DATE = new Date Date.parse "2011-09-17" # date ≥ 17.09.2011
D20DATE     = new Date Date.parse "2016-09-10" # date ≥ 10.09.2016; draw = 73
D20DRAW     = 73
D20YEAR     = 2016
VENUS       = 'VENUS'
STRESA      = 'STRESA'

L_URL = "http://test.lotarija.mk/Results/WebService.asmx/GetDetailedReport"

qstring = (qry) ->
  "#{ GS_URL }/spreadsheets/d/#{ GS_KEY }/gviz/tq?tqx=out:json&tq=#{ encodeURI qry }"

parseResponse = (r) ->
  JSON.parse r.replace(/(^.+?\()|(^\/.*\/$)|\);$/mg,'')

qresult = (json) ->
  rset = []
  for r in json.table.rows
    h = { }
    for c, i in json.table.cols
      h[c.label] = r.c[i].v
      if c.type is 'date'
        h[c.label] = eval 'new ' + h[c.label]
    rset.push h
  rset

# default separator is '-'
toYMD = (d) ->
  return null unless d
  d = new Date(Date.parse d) unless d instanceof Date
  sep = if arguments.length > 1 then arguments[1] else '-'
  (new Date(d - d.getTimezoneOffset()*1000*60))
    .toISOString()[0..9]
    .split('-')
    .join(sep)

# default separator is '.'
toDMY = (d) ->
  return null unless d
  d = new Date(Date.parse d) unless d instanceof Date
  sep = if arguments.length > 1 then arguments[1] else '.'
  (new Date(d - d.getTimezoneOffset()*1000*60))
    .toISOString()[0..9]
    .split('-')
    .reverse()
    .join(sep)

# parse draw report

strip = (s) ->
  re = /([\d.]*)/
  match = re.exec s
  match[1].replace /\./g, ''

# strip float: strip '.' and leave \d only, convert ',' to '.'
stripf = (s) ->
  re = /([\d.,]*)/
  match = re.exec s
  match = match[1].replace /\./g, ''
  match.replace /,/g, '.'

parseL = (text) ->
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
  ret.lsales = parseInt strip match[1]

  t = match[2] # rest of.. (post-match)

  # extract joker sales
  re = /<th>Уплата:<\/th>\s*<td[^>]*>([^>]*)\s*<\/td>/m
  match = re.exec t
  ret.jsales = parseInt strip match[1]

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
        ret.lmx7  = parseFloat stripf(match[3])
      when "6+1 погодоци"
        ret.lx6p  = parseInt match[2]
        ret.lmx6p = parseFloat stripf(match[3])
      when "6 погодоци"
        ret.lx6   = parseInt match[2]
        ret.lmx6  = parseFloat stripf(match[3])
      when "5 погодоци"
        ret.lx5   = parseInt match[2]
        ret.lmx5  = parseFloat stripf(match[3])
      when "4 погодоци"
        ret.lx4   = parseInt match[2]
        ret.lmx4  = parseFloat stripf(match[3])
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
        ret.lfx7  = parseFloat stripf(match[3])
        ret.ljx7  = parseFloat stripf(match[4])
      when "II"
        ret.lfx6p = parseFloat stripf(match[3])
        ret.ljx6p = parseFloat stripf(match[4])
      when "III"
        ret.lfx6  = parseFloat stripf(match[3])
        ret.ljx6  = parseFloat stripf(match[4])
      when "IV"
        ret.lfx5  = parseFloat stripf(match[3])
        ret.ljx5  = parseFloat stripf(match[4])
      when "V"
        ret.lfx4  = parseFloat stripf(match[3])
        ret.ljx4  = parseFloat stripf(match[4])
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
        ret.jmx6 = parseFloat stripf(match[3])
      when "5 погодоци"
        ret.jx5  = parseInt match[2]
        ret.jmx5 = parseFloat stripf(match[3])
      when "4 погодоци"
        ret.jx4  = parseInt match[2]
        ret.jmx4 = parseFloat stripf(match[3])
      when "3 погодоци"
        ret.jx3  = parseInt match[2]
        ret.jmx3 = parseFloat stripf(match[3])
      when "2 погодоци"
        ret.jx2  = parseInt match[2]
        ret.jmx2 = parseFloat stripf(match[3])
      when "1 погодок"
        ret.jx1  = parseInt match[2]
        ret.jmx1 = parseFloat stripf(match[3])
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
        ret.jfx6 = parseFloat stripf(match[3])
        ret.jjx6 = parseFloat stripf(match[4])
      when "II"
        ret.jfx5 = parseFloat stripf(match[3])
        ret.jjx5 = parseFloat stripf(match[4])
      when "III"
        ret.jfx4 = parseFloat stripf(match[3])
        ret.jjx4 = parseFloat stripf(match[4])
      when "IV"
        ret.jfx3 = parseFloat stripf(match[3])
        ret.jjx3 = parseFloat stripf(match[4])
      when "V"
        ret.jfx2 = parseFloat stripf(match[3])
        ret.jjx2 = parseFloat stripf(match[4])
      when "VI"
        ret.jfx1 = parseFloat stripf(match[3])
        ret.jjx1 = parseFloat stripf(match[4])
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

nextDraw = (d) ->
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

# exports
module.exports.GS_KEY       = GS_KEY
module.exports.GS_URL       = GS_URL
module.exports.VENUS_DATE   = VENUS_DATE
module.exports.STRESA_DATE  = STRESA_DATE
module.exports.D20DATE      = D20DATE
module.exports.D20DRAW      = D20DRAW
module.exports.D20YEAR      = D20YEAR
module.exports.VENUS        = VENUS
module.exports.STRESA       = STRESA
module.exports.L_URL        = L_URL

module.exports.qstring   = qstring
module.exports.parseResponse = parseResponse
module.exports.qresult = qresult

module.exports.toYMD = toYMD
module.exports.toDMY = toDMY

module.exports.parseL   = parseL
module.exports.nextDraw = nextDraw
