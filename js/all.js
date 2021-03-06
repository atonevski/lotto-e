// Generated by CoffeeScript 2.3.2
// all.coffee: list all draws (complete)

var cclass, https, utils, vue;

utils = require('../js/utils.js');

https = require('https');

cclass = {
  draw: 'center',
  date: 'center',
  lsales: 'right',
  lx7: 'center',
  lx6p: 'center',
  lx6: 'center',
  lx5: 'right',
  lx4: 'right',
  lmx7: 'right',
  lmx6p: 'right',
  lmx6: 'right',
  lmx5: 'right',
  lmx4: 'right',
  lfx7: 'right',
  lfx6p: 'right',
  lfx6: 'right',
  lfx5: 'right',
  lfx4: 'right',
  ljx7: 'right',
  ljx6p: 'right',
  ljx6: 'right',
  ljx5: 'right',
  ljx4: 'right',
  lwc1: 'center red-c wc',
  lwc2: 'center green-c wc',
  lwc3: 'center yellow-c wc',
  lwc4: 'center blue-c wc',
  lwc5: 'center magenta-c wc',
  lwc6: 'center light-blue-c wc',
  lwc7: 'center light-magenta-c wc',
  lwcp: 'center white-c wc',
  jsales: 'right',
  jx6: 'center',
  jx5: 'center',
  jx4: 'center',
  jx3: 'right',
  jx2: 'right',
  jx1: 'right',
  jmx6: 'right',
  jmx5: 'right',
  jmx4: 'right',
  jmx3: 'right',
  jmx2: 'right',
  jmx1: 'right',
  jfx6: 'right',
  jfx5: 'right',
  jfx4: 'right',
  jfx3: 'right',
  jfx2: 'right',
  jfx1: 'right',
  jjx6: 'right',
  jjx5: 'right',
  jjx4: 'right',
  jjx3: 'right',
  jjx2: 'right',
  jjx1: 'right',
  jwc: 'center white-c'
};

vue = new Vue({
  el: '#app',
  data: {
    draws: [],
    offset: 0,
    PAGE: 25,
    isLoading: false,
    cclass: cclass
  },
  filters: {
    number: function(v) {
      if ((v != null) && typeof v.toLocaleString === 'function') {
        if (typeof v === 'number') {
          return Math.round(v).toLocaleString();
        } else {
          return v.toLocaleString();
        }
      } else {
        return '';
      }
    },
    toYMD: utils.toYMD,
    toDMY: utils.toDMY
  },
  methods: {
    getMoreDraws: function() {
      var q;
      if (this.isLoading) {
        return;
      }
      this.isLoading = true;
      q = `SELECT\n  *\nLIMIT ${this.PAGE}\nOFFSET ${this.offset}`;
      return https.get(utils.qstring(q), (res) => {
        var body;
        body = '';
        res.setEncoding('utf-8');
        res.on('data', function(d) {
          return body += d;
        });
        res.on('error', (e) => {
          console.log(`query error: ${e}`);
          return this.isLoading = false; // not any more
        });
        return res.on('end', () => {
          var i, json, len, r, rows;
          json = utils.parseResponse(body.toString());
          rows = utils.qresult(json);
          if (rows.length > 0) {
            for (i = 0, len = rows.length; i < len; i++) {
              r = rows[i];
              this.draws.push(r);
            }
            this.offset += rows.length;
            console.log(this.draws);
            console.log(this.offset);
          }
          return this.isLoading = false;
        });
      });
    }
  },
  created: function() {
    this.getMoreDraws();
    return window.onscroll = () => {
      var reachedBottom;
      reachedBottom = document.documentElement.scrollTop + window.innerHeight >= document.documentElement.offsetHeight;
      if (reachedBottom && !this.isLoading) {
        console.log('reached bottom of window');
        return this.getMoreDraws();
      }
    };
  }
});
