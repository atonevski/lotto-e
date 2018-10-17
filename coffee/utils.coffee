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

module.exports.GS_KEY       = GS_KEY
module.exports.GS_URL       = GS_URL
module.exports.VENUS_DATE   = VENUS_DATE
module.exports.STRESA_DATE  = STRESA_DATE
module.exports.D20DATE      = D20DATE
module.exports.D20DRAW      = D20DRAW
module.exports.D20YEAR      = D20YEAR
module.exports.VENUS        = VENUS
module.exports.STRESA       = STRESA

module.exports.qstring   = qstring
module.exports.parseResponse = parseResponse
module.exports.qresult = qresult

module.exports.toYMD = toYMD
module.exports.toDMY = toDMY
