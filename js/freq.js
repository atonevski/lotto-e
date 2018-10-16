// Generated by CoffeeScript 2.3.2
// cat
// cat2.coffee: 2nd category winners

var https, utils, vue;

utils = require('../js/utils.js');

https = require('https');

vue = new Vue({
  el: '#app',
  filters: {
    number: function(v) {
      if ((v != null) && typeof v.toLocaleString === 'function') {
        return v.toLocaleString();
      } else {
        return '';
      }
    },
    toYMD: utils.toYMD,
    toDMY: utils.toDMY
  },
  methods: {
    getLastDraw: function() {
      var q;
      q = 'SELECT A, B\nORDER BY B DESC\nLIMIT 1\nLABEL A \'number\', B \'date\'';
      return https.get(utils.qstring(q), (res) => {
        var body;
        body = '';
        res.setEncoding('utf-8');
        res.on('data', function(d) {
          return body += d;
        });
        res.on('error', function(e) {
          return console.log(`query error: ${e}`);
        });
        return res.on('end', () => {
          var json;
          json = utils.parseResponse(body.toString());
          return this.lastDraw = (utils.qresult(json))[0];
        });
      });
    },
    getTotalDraws: function() {
      var q;
      q = 'SELECT COUNT(A)\nLABEL COUNT(A) \'count\'';
      return https.get(utils.qstring(q), (res) => {
        var body;
        body = '';
        res.setEncoding('utf-8');
        res.on('data', function(d) {
          return body += d;
        });
        res.on('error', function(e) {
          return console.log(`query error: ${e}`);
        });
        return res.on('end', () => {
          var json;
          json = utils.parseResponse(body);
          return this.count = (utils.qresult(json))[0].count;
        });
      });
    },
    getFreq: function() { // drum: options argument
      var drum, i, j, lq;
      this.lfreq = [];
      for (i = j = 0; j <= 34; i = ++j) {
        this.lfreq.push([0, 0, 0, 0, 0, 0, 0, 0]);
      }
      drum = null;
      if (arguments.length > 0) {
        drum = arguments[0];
      }
      lq = 'SELECT X, Y, Z, AA, AB, AC, AD, AE\n:filter';
      lq = (function() {
        switch (drum) {
          case utils.VENUS:
            return lq.replace(/\:filter/, `WHERE B <= date '${utils.toYMD(utils.VENUS_DATE)}'`);
          case utils.STRESA:
            return lq.replace(/\:filter/, `WHERE B >= date '${utils.toYMD(utils.STRESA_DATE)}'`);
          default:
            return lq.replace(/\:filter/, '');
        }
      })();
      return https.get(utils.qstring(lq), (res) => {
        var body;
        body = '';
        res.setEncoding('utf-8');
        res.on('data', function(d) {
          return body += d;
        });
        res.on('error', function(e) {
          return console.log(`query error: ${e}`);
        });
        return res.on('end', () => {
          var json, k, len, r, recs;
          json = utils.parseResponse(body);
          recs = utils.qresult(json);
          for (k = 0, len = recs.length; k < len; k++) {
            r = recs[k];
            this.lfreq[r.lwc1][0] += 1;
            this.lfreq[r.lwc2][1] += 1;
            this.lfreq[r.lwc3][2] += 1;
            this.lfreq[r.lwc4][3] += 1;
            this.lfreq[r.lwc5][4] += 1;
            this.lfreq[r.lwc6][5] += 1;
            this.lfreq[r.lwc7][6] += 1;
            this.lfreq[r.lwcp][7] += 1;
          }
          return console.log(this.lfreq);
        });
      });
    }
  },
  data: {
    count: null,
    lastDraw: {},
    lfreq: [],
    jfreq: [],
    colors: ['red-c', 'green-c', 'yellow-c', 'blue-c', 'magenta-c', 'cyan-c', 'light-gray-c', 'light-red-c', 'light-green-c', 'light-yellow-c', 'light-blue-c', 'light-magenta-c', 'light-cyan-c', 'white-c']
  },
  created: function() {
    this.getTotalDraws();
    this.getLastDraw();
    return this.getFreq();
  }
});


//   draw no., date
//   A         B
//   lsales, lx7, lx6p, lx6, lx5, lx4, lmx7, lmx6p, lmx6, lmx5, lmx4,
//   C       D    E     F    G    H    I     J     K      L     M
//           lfx7, lfx6p, lfx6, lfx5, lfx4, ljx7, ljx6p, ljx6, ljx5, ljx4,
//           N      O     P     Q     R     S      T     U     V     W
//           lwc1, lwc2, lwc3, lwc4, lwc5, lwc6, lwc7, lwcp
//           X     Y     Z     AA    AB    AC    AD     AE
//   jsales, jx6, jx5, jx4, jx3, jx2, jx1, jmx6, jmx5, jmx4, jmx3, jmx2, jmx1,
//   AF      AG   AH   AI   AJ   AK   AL   AM    AN    AO    AP    AQ    AR
//           jfx6, jfx5, jfx4, jfx3, jfx2, jfx1, jjx6, jjx5, jjx4, jjx3, jjx2, jjx1,
//           AS    AT    AU    AV    AW    AX    AY    AZ    BA    BB    BC    BD
//           jwc
//           BE

//     qry = <<-QRY
//       SELECT X, Y, Z, AA, AB, AC, AD, AE
//     QRY

//     qry = case opts["drum"]
//           when "stresa"
//             "#{ qry } WHERE B >= date '%s'" % Gs::STRESA_DATE.to_s(Gs::YMD_FMT)
//           when "venus"
//             "#{ qry } WHERE B <= date '%s'" % Gs::VENUS_DATE.to_s(Gs::YMD_FMT)
//           else
//             qry
//           end
//     r = Gs.execute qry
//     freq = [] of Array(Int64)

//     unless r.nil?
//       Colorize.on_tty_only!
//       (34+1).times { freq << [0_i64, 0_i64, 0_i64, 0_i64, 0_i64, 0_i64, 0_i64, 0_i64] }
//       r.each do |r|
//y
//       end
//       tmpl = FreqTemp.new freq, opts["drum"].as(String)

//       puts tmpl
