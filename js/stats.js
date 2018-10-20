// Generated by CoffeeScript 1.10.0
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
    getStats: function() {
      var jq, jq4, jq5, q, q6, q6p;
      q = 'SELECT\n  YEAR(B),\n  COUNT(B),\n  MIN(C),AVG(C), MAX(C),\n  SUM(D), SUM(E),\n  AVG(F), AVG(G), AVG(H)\nGROUP BY YEAR(B)\nORDER BY YEAR(B)\nLABEL YEAR(B) \'year\', COUNT(B) \'draws\',\n      MIN(C) \'minLsales\', AVG(C) \'avgLsales\', MAX(C) \'maxLsales\',\n      SUM(D) \'x7\', SUM(E) \'x6p\',\n      AVG(F) \'x6\', AVG(G) \'x5\', AVG(H) \'x4\'';
      q6p = 'SELECT\n  YEAR(B),\n  COUNT(E)\nWHERE\n  E > 0\nGROUP BY YEAR(B)\nORDER BY YEAR(B)\nLABEL YEAR(B) \'year\', COUNT(E) \'x6pDraws\'';
      q6 = 'SELECT\n  YEAR(B),\n  COUNT(F)\nWHERE\n  F > 0\nGROUP BY YEAR(B)\nORDER BY YEAR(B)\nLABEL YEAR(B) \'year\', COUNT(F) \'x6Draws\'';
      this.lstats = [];
      this.lstats6p = [];
      this.lstats6 = [];
      https.get(utils.qstring(q), (function(_this) {
        return function(res) {
          var body;
          body = '';
          res.setEncoding('utf-8');
          res.on('data', function(d) {
            return body += d;
          });
          res.on('error', function(e) {
            return console.log("query error: " + e);
          });
          return res.on('end', function() {
            var json;
            json = utils.parseResponse(body);
            return _this.lstats = utils.qresult(json);
          });
        };
      })(this));
      https.get(utils.qstring(q6p), (function(_this) {
        return function(res) {
          var body;
          body = '';
          res.setEncoding('utf-8');
          res.on('data', function(d) {
            return body += d;
          });
          res.on('error', function(e) {
            return console.log("query error: " + e);
          });
          return res.on('end', function() {
            var json;
            json = utils.parseResponse(body);
            return _this.lstats6p = utils.qresult(json);
          });
        };
      })(this));
      https.get(utils.qstring(q6), (function(_this) {
        return function(res) {
          var body;
          body = '';
          res.setEncoding('utf-8');
          res.on('data', function(d) {
            return body += d;
          });
          res.on('error', function(e) {
            return console.log("query error: " + e);
          });
          return res.on('end', function() {
            var json;
            json = utils.parseResponse(body);
            return _this.lstats6 = utils.qresult(json);
          });
        };
      })(this));
      jq = 'SELECT\n  YEAR(B),\n  COUNT(B),\n  MIN(AF),AVG(AF), MAX(AF),\n  SUM(AG), SUM(AH),\n  AVG(AI), AVG(AJ), AVG(AK), AVG(AL)\nGROUP BY YEAR(B)\nORDER BY YEAR(B)\nLABEL YEAR(B) \'year\', COUNT(B) \'draws\',\n      MIN(AF) \'minJsales\', AVG(AF) \'avgJsales\', MAX(AF) \'maxJsales\',\n      SUM(AG) \'x6\', SUM(AH) \'x5\',\n      AVG(AI) \'x4\', AVG(AJ) \'x3\', AVG(AK) \'x2\', AVG(AL) \'x1\'';
      jq5 = 'SELECT\n  YEAR(B),\n  COUNT(AH)\nWHERE\n  AH > 0\nGROUP BY YEAR(B)\nORDER BY YEAR(B)\nLABEL YEAR(B) \'year\', COUNT(AH) \'x5Draws\'';
      jq4 = 'SELECT\n  YEAR(B),\n  COUNT(AI)\nWHERE\n  AI > 0\nGROUP BY YEAR(B)\nORDER BY YEAR(B)\nLABEL YEAR(B) \'year\', COUNT(AI) \'x4Draws\'';
      this.jstats = [];
      this.jstats5 = [];
      this.jstats4 = [];
      https.get(utils.qstring(jq), (function(_this) {
        return function(res) {
          var body;
          body = '';
          res.setEncoding('utf-8');
          res.on('data', function(d) {
            return body += d;
          });
          res.on('error', function(e) {
            return console.log("query error: " + e);
          });
          return res.on('end', function() {
            var json;
            json = utils.parseResponse(body);
            return _this.jstats = utils.qresult(json);
          });
        };
      })(this));
      https.get(utils.qstring(jq5), (function(_this) {
        return function(res) {
          var body;
          body = '';
          res.setEncoding('utf-8');
          res.on('data', function(d) {
            return body += d;
          });
          res.on('error', function(e) {
            return console.log("query error: " + e);
          });
          return res.on('end', function() {
            var json;
            json = utils.parseResponse(body);
            return _this.jstats5 = utils.qresult(json);
          });
        };
      })(this));
      return https.get(utils.qstring(jq4), (function(_this) {
        return function(res) {
          var body;
          body = '';
          res.setEncoding('utf-8');
          res.on('data', function(d) {
            return body += d;
          });
          res.on('error', function(e) {
            return console.log("query error: " + e);
          });
          return res.on('end', function() {
            var json;
            json = utils.parseResponse(body);
            return _this.jstats4 = utils.qresult(json);
          });
        };
      })(this));
    },
    getLastDraw: function() {
      var q;
      q = 'SELECT A, B\nORDER BY B DESC\nLIMIT 1\nLABEL A \'number\', B \'date\'';
      return https.get(utils.qstring(q), (function(_this) {
        return function(res) {
          var body;
          body = '';
          res.setEncoding('utf-8');
          res.on('data', function(d) {
            return body += d;
          });
          res.on('error', function(e) {
            return console.log("query error: " + e);
          });
          return res.on('end', function() {
            var json;
            json = utils.parseResponse(body.toString());
            return _this.lastDraw = (utils.qresult(json))[0];
          });
        };
      })(this));
    },
    getTotalDraws: function() {
      var q;
      q = 'SELECT COUNT(A)\nLABEL COUNT(A) \'count\' ';
      return https.get(utils.qstring(q), (function(_this) {
        return function(res) {
          var body;
          body = '';
          res.setEncoding('utf-8');
          res.on('data', function(d) {
            return body += d;
          });
          res.on('error', function(e) {
            return console.log("query error: " + e);
          });
          return res.on('end', function() {
            var json;
            json = utils.parseResponse(body);
            return _this.count = (utils.qresult(json))[0].count;
          });
        };
      })(this));
    }
  },
  data: {
    count: null,
    lastDraw: {},
    lstats: [],
    lstats6p: [],
    lstats6: [],
    jstats: [],
    jstats5: [],
    jstats4: []
  },
  created: function() {
    this.getTotalDraws();
    this.getLastDraw();
    return this.getStats();
  }
});
