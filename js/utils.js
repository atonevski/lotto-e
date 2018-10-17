// Generated by CoffeeScript 2.3.2
// utils.coffee
// Handles google script/sheets

var D20DATE, D20DRAW, D20YEAR, GS_KEY, GS_URL, L_URL, STRESA, STRESA_DATE, VENUS, VENUS_DATE, nextDraw, parseL, parseResponse, qresult, qstring, strip, stripf, toDMY, toYMD;

GS_KEY = "1deUDEVwaNPH1fgy3RlmV98TwgVtHfxQc7gA9YeVs_mc";

GS_URL = "https://docs.google.com";

VENUS_DATE = new Date(Date.parse("2011-09-15")); // date ≤ 15.09.2011

STRESA_DATE = new Date(Date.parse("2011-09-17")); // date ≥ 17.09.2011

D20DATE = new Date(Date.parse("2016-09-10")); // date ≥ 10.09.2016; draw = 73

D20DRAW = 73;

D20YEAR = 2016;

VENUS = 'VENUS';

STRESA = 'STRESA';

L_URL = "http://test.lotarija.mk/Results/WebService.asmx/GetDetailedReport";

qstring = function(qry) {
  return `${GS_URL}/spreadsheets/d/${GS_KEY}/gviz/tq?tqx=out:json&tq=${encodeURI(qry)}`;
};

parseResponse = function(r) {
  return JSON.parse(r.replace(/(^.+?\()|(^\/.*\/$)|\);$/mg, ''));
};

qresult = function(json) {
  var c, h, i, j, k, len, len1, r, ref, ref1, rset;
  rset = [];
  ref = json.table.rows;
  for (j = 0, len = ref.length; j < len; j++) {
    r = ref[j];
    h = {};
    ref1 = json.table.cols;
    for (i = k = 0, len1 = ref1.length; k < len1; i = ++k) {
      c = ref1[i];
      h[c.label] = r.c[i].v;
      if (c.type === 'date') {
        h[c.label] = eval('new ' + h[c.label]);
      }
    }
    rset.push(h);
  }
  return rset;
};

// default separator is '-'
toYMD = function(d) {
  var sep;
  if (!d) {
    return null;
  }
  if (!(d instanceof Date)) {
    d = new Date(Date.parse(d));
  }
  sep = arguments.length > 1 ? arguments[1] : '-';
  return (new Date(d - d.getTimezoneOffset() * 1000 * 60)).toISOString().slice(0, 10).split('-').join(sep);
};

// default separator is '.'
toDMY = function(d) {
  var sep;
  if (!d) {
    return null;
  }
  if (!(d instanceof Date)) {
    d = new Date(Date.parse(d));
  }
  sep = arguments.length > 1 ? arguments[1] : '.';
  return (new Date(d - d.getTimezoneOffset() * 1000 * 60)).toISOString().slice(0, 10).split('-').reverse().join(sep);
};

// parse draw report
strip = function(s) {
  var match, re;
  re = /([\d.]*)/;
  match = re.exec(s);
  return match[1].replace(/\./g, '');
};

// strip float: strip '.' and leave \d only, convert ',' to '.'
stripf = function(s) {
  var match, re;
  re = /([\d.,]*)/;
  match = re.exec(s);
  match = match[1].replace(/\./g, '');
  return match.replace(/,/g, '.');
};

parseL = function(text) {
  var lwcol, match, re, ret, t, tab;
  ret = {};
  // extract draw date
  re = /<th>Датум на извлекување:<\/th>\s*<td[^>]*>([^>]*)\s*<\/td>/m;
  match = re.exec(text);
  re = /^(\d\d).(\d\d).(\d\d\d\d)$/;
  match = re.exec(match[1]);
  ret.date = new Date(match.slice(1, 4).reverse().join('-'));
  // extract draw number
  re = /br>\s*(\d+)\.[^<]*<\/h2>/m;
  match = re.exec(text);
  ret.draw = parseInt(match[1]);
  // extract lotto sales
  re = /<th>Уплата:<\/th>\s*<td[^>]*>([^>]*)\s*<\/td>(.*)/m;
  match = re.exec(text);
  ret.lsales = parseInt(strip(match[1]));
  t = match[2];
  
  // extract joker sales
  re = /<th>Уплата:<\/th>\s*<td[^>]*>([^>]*)\s*<\/td>/m;
  match = re.exec(t);
  ret.jsales = parseInt(strip(match[1]));
  // extract lotto winners
  re = /<table\s+class="nl734"\s*>(.*?)<\/table>/gm;
  tab = text.match(re);
  tab = tab[1];
  re = /<tbody>\s*(.*?)\s*<\/tbody>/m;
  tab = re.exec(tab);
  re = /<tr>\s*<th>\s*(.*?)\s*<\/th>\s*<td>\s*(.*?)\s*<\/td>\s*<td>\s*(.*?)\s*<\/td>\s*<\/tr>(.*)/m;
  match = re.exec(tab[1]);
  while (match) {
    switch (match[1]) {
      case "7 погодоци":
        ret.lx7 = parseInt(match[2]);
        ret.lmx7 = parseFloat(stripf(match[3]));
        break;
      case "6+1 погодоци":
        ret.lx6p = parseInt(match[2]);
        ret.lmx6p = parseFloat(stripf(match[3]));
        break;
      case "6 погодоци":
        ret.lx6 = parseInt(match[2]);
        ret.lmx6 = parseFloat(stripf(match[3]));
        break;
      case "5 погодоци":
        ret.lx5 = parseInt(match[2]);
        ret.lmx5 = parseFloat(stripf(match[3]));
        break;
      case "4 погодоци":
        ret.lx4 = parseInt(match[2]);
        ret.lmx4 = parseFloat(stripf(match[3]));
    }
    tab = match[4];
    match = re.exec(tab);
  }
  // extract lotto funds, and jackpots
  re = /<table\s+class="nl734"\s*>(.*?)<\/table>/gm;
  tab = text.match(re);
  tab = tab[0];
  re = /<tbody>\s*(.*?)\s*<\/tbody>/m;
  tab = re.exec(tab);
  re = /<tr>\s*<th>\s*(.*?)\s*<\/th>\s*<th\s*(.*?)\s*<\/th>\s*<td\s*>\s*(.*?)\s*<\/td>\s*<td\s*>\s*(.*?)\s*<\/td>\s*<td\s*>\s*(.*?)\s*<\/td>\s*<\/tr>(.*)/m;
  match = re.exec(tab[1]);
  while (match) {
    switch (match[1]) {
      case "I":
        ret.lfx7 = parseFloat(stripf(match[3]));
        ret.ljx7 = parseFloat(stripf(match[4]));
        break;
      case "II":
        ret.lfx6p = parseFloat(stripf(match[3]));
        ret.ljx6p = parseFloat(stripf(match[4]));
        break;
      case "III":
        ret.lfx6 = parseFloat(stripf(match[3]));
        ret.ljx6 = parseFloat(stripf(match[4]));
        break;
      case "IV":
        ret.lfx5 = parseFloat(stripf(match[3]));
        ret.ljx5 = parseFloat(stripf(match[4]));
        break;
      case "V":
        ret.lfx4 = parseFloat(stripf(match[3]));
        ret.ljx4 = parseFloat(stripf(match[4]));
    }
    tab = match[6];
    match = re.exec(tab);
  }
  // extract joker winners
  re = /<table\s+class="j734"\s*>(.*?)<\/table>/gm;
  tab = text.match(re);
  if (!tab) {
    raise("can't extract joker winners!");
  }
  tab = tab[1];
  re = /<tbody>\s*(.*?)\s*<\/tbody>/m;
  tab = re.exec(tab);
  re = /<tr>\s*<th>\s*(.*?)\s*<\/th>\s*<td>\s*.*?\s*<\/td>\s*<td>\s*(.*?)\s*<\/td>\s*<td>\s*(.*?)\s*<\/td>\s*<\/tr>(.*)/m;
  match = re.exec(tab[1]);
  while (match) {
    switch (match[1]) {
      case "6 погодоци":
        ret.jx6 = parseInt(match[2]);
        ret.jmx6 = parseFloat(stripf(match[3]));
        break;
      case "5 погодоци":
        ret.jx5 = parseInt(match[2]);
        ret.jmx5 = parseFloat(stripf(match[3]));
        break;
      case "4 погодоци":
        ret.jx4 = parseInt(match[2]);
        ret.jmx4 = parseFloat(stripf(match[3]));
        break;
      case "3 погодоци":
        ret.jx3 = parseInt(match[2]);
        ret.jmx3 = parseFloat(stripf(match[3]));
        break;
      case "2 погодоци":
        ret.jx2 = parseInt(match[2]);
        ret.jmx2 = parseFloat(stripf(match[3]));
        break;
      case "1 погодок":
        ret.jx1 = parseInt(match[2]);
        ret.jmx1 = parseFloat(stripf(match[3]));
    }
    tab = match[4];
    match = re.exec(tab);
  }
  // extract joker winners
  re = /<table\s+class="j734"\s*>(.*?)<\/table>/gm;
  tab = text.match(re);
  if (!tab) {
    raise("can't extract joker winners!");
  }
  tab = tab[0];
  re = /<tbody>\s*(.*?)\s*<\/tbody>/m;
  tab = re.exec(tab);
  re = /<tr>\s*<th>\s*(.*?)\s*<\/th>\s*<th\s*(.*?)\s*<\/th>\s*<td>\s*(.*?)\s*<\/td>\s*<td>\s*(.*?)\s*<\/td>\s*<td>\s*(.*?)\s*<\/td>\s*<\/tr>(.*)/m;
  match = re.exec(tab[1]);
  while (match) {
    switch (match[1]) {
      case "I":
        ret.jfx6 = parseFloat(stripf(match[3]));
        ret.jjx6 = parseFloat(stripf(match[4]));
        break;
      case "II":
        ret.jfx5 = parseFloat(stripf(match[3]));
        ret.jjx5 = parseFloat(stripf(match[4]));
        break;
      case "III":
        ret.jfx4 = parseFloat(stripf(match[3]));
        ret.jjx4 = parseFloat(stripf(match[4]));
        break;
      case "IV":
        ret.jfx3 = parseFloat(stripf(match[3]));
        ret.jjx3 = parseFloat(stripf(match[4]));
        break;
      case "V":
        ret.jfx2 = parseFloat(stripf(match[3]));
        ret.jjx2 = parseFloat(stripf(match[4]));
        break;
      case "VI":
        ret.jfx1 = parseFloat(stripf(match[3]));
        ret.jjx1 = parseFloat(stripf(match[4]));
    }
    tab = match[6];
    match = re.exec(tab);
  }
  // extract lotto winning columns
  re = /<p>Редослед на извлекување:\s*([\d,]+)\.?\s*<\/p>/m;
  match = re.exec(text);
  if (!match) {
    throw "can't extract lotto winning column!";
  }
  lwcol = match[1].split(/\s*,\s*/).map(function(e) {
    return parseInt(e);
  });
  [ret.lwc1, ret.lwc2, ret.lwc3, ret.lwc4, ret.lwc5, ret.lwc6, ret.lwc7, ret.lwcp] = lwcol;
  // joker winnig column
  re = /<div\s+id="joker">\s*(\d+)\s*<\/div>/m;
  match = re.exec(text);
  ret.jwc = match[1];
  // return result
  return ret;
};

nextDraw = function(d) {
  var date;
  if (!d) {
    throw "nextDraw(); argument error";
  }
  if (!((d.draw != null) || (d.date != null))) {
    throw `Not a valid draw: ${d}`;
  }
  date = new Date(d.date);
  switch (date.getDay()) {
    case 3:
      date.setDate(date.getDate() + 3);
      break;
    case 6:
      date.setDate(date.getDate() + 4);
      break;
    default:
      throw `Invalid draw date: ${d.date}`;
  }
  if (date.getFullYear() === d.date.getFullYear()) {
    return {
      draw: d.draw + 1,
      date: date
    };
  } else {
    return {
      draw: 1,
      date: date
    };
  }
};

// exports
module.exports.GS_KEY = GS_KEY;

module.exports.GS_URL = GS_URL;

module.exports.VENUS_DATE = VENUS_DATE;

module.exports.STRESA_DATE = STRESA_DATE;

module.exports.D20DATE = D20DATE;

module.exports.D20DRAW = D20DRAW;

module.exports.D20YEAR = D20YEAR;

module.exports.VENUS = VENUS;

module.exports.STRESA = STRESA;

module.exports.L_URL = L_URL;

module.exports.qstring = qstring;

module.exports.parseResponse = parseResponse;

module.exports.qresult = qresult;

module.exports.toYMD = toYMD;

module.exports.toDMY = toDMY;

module.exports.parseL = parseL;

module.exports.nextDraw = nextDraw;
