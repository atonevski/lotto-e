// Generated by CoffeeScript 2.3.2
// graph-freq.coffee: stacked bars graph

var HEIGHT, WIDTH, drum, https, i, j, lfreq, lq, margins, plot, utils;

utils = require('../js/utils.js');

https = require('https');

// some globals
lfreq = [];

drum = 'BOTH';

WIDTH = 800;

HEIGHT = 500;

margins = {
  top: 20,
  right: 120,
  bottom: 20,
  left: 40
};

for (i = j = 0; j <= 34; i = ++j) {
  lfreq.push([0, 0, 0, 0, 0, 0, 0, 0]);
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

https.get(utils.qstring(lq), (res) => {
  var body;
  body = '';
  res.setEncoding('utf-8');
  res.on('data', function(d) {
    return body += d;
  });
  res.on('error', function(e) {
    return console.log(`query error: ${e}`);
  });
  res.on('end', () => {
    var json, k, len, r, recs;
    json = utils.parseResponse(body);
    recs = utils.qresult(json);
    for (k = 0, len = recs.length; k < len; k++) {
      r = recs[k];
      lfreq[r.lwc1][0] += 1;
      lfreq[r.lwc2][1] += 1;
      lfreq[r.lwc3][2] += 1;
      lfreq[r.lwc4][3] += 1;
      lfreq[r.lwc5][4] += 1;
      lfreq[r.lwc6][5] += 1;
      lfreq[r.lwc7][6] += 1;
      lfreq[r.lwcp][7] += 1;
    }
    return plot();
  });
  return null;
});

plot = function() {
  var color, data, dataIntermediate, keys, l, svg, xAxis, xRange, xmax, xmin, yAxis, yRange, ymax, ymin;
  svg = d3.select('.container').append('svg').attr('class', 'axis').attr('width', WIDTH).attr('height', HEIGHT);
  [xmin, xmax] = [1, 34];
  ymin = 0;
  ymax = d3.max(lfreq.slice(1, 35), function(n) {
    return n.reduce(function(x, s) {
      return x + s;
    }, 0);
  });
  console.log([xmin, xmax]);
  console.log([ymin, ymax]);
  xRange = d3.scaleBand().range([margins.left, WIDTH - margins.right]).domain((function() {
    var results = [];
    for (var k = xmin; xmin <= xmax ? k <= xmax : k >= xmax; xmin <= xmax ? k++ : k--){ results.push(k); }
    return results;
  }).apply(this)).padding(0.2);
  yRange = d3.scaleLinear().range([HEIGHT - margins.top, margins.bottom]).domain([ymin, ymax]);
  xAxis = d3.axisBottom(xRange);
  yAxis = d3.axisLeft(yRange);
  svg.append('g').attr('class', 'x axis').attr('transform', `translate(0, ${HEIGHT - margins.bottom})`).call(xAxis);
  svg.append('g').attr('class', 'y axis').attr('transform', `translate(${margins.left}, 0)`).call(yAxis);
  svg.append('g').append('text').attr('fill', '#93a1a1').attr('x', xRange(Math.round((xmin + xmax) / 2))).attr('y', yRange(ymax)).attr('dy', '-0.35em').attr('text-anchor', 'middle').text('Number frequencies'); // title
  dataIntermediate = lfreq.slice(1, 35).map(function(r, i) {
    var v;
    return v = {
      number: i + 1,
      first: r[0],
      second: r[1],
      third: r[2],
      forth: r[3],
      fifth: r[4],
      sixth: r[5],
      seventh: r[6],
      extra: r[7]
    };
  });
  keys = ['first', 'second', 'third', 'forth', 'fifth', 'sixth', 'seventh', 'extra'];
  data = d3.stack().keys(keys)(dataIntermediate);
  console.log(data);
  color = d3.scaleOrdinal().unknown("#ccc").domain((function() {
    var results = [];
    for (var k = 1; k <= 34; k++){ results.push(k); }
    return results;
  }).apply(this)).range(d3.quantize((function(t) {
    return d3.interpolateSpectral(t * 0.8 + 0.1);
  }), data.length).reverse());
  svg.append('g').selectAll('g').data(data).enter().append('g').attr('fill', function(d, i) {
    return color(i + 1);
  }).selectAll('rect').data(function(d) {
    return d;
  }).enter().append('rect').attr('x', function(d, i) {
    return xRange(i + 1);
  }).attr('y', function(d) {
    return yRange(d[1]);
  }).attr('height', function(d) {
    return yRange(d[0]) - yRange(d[1]);
  }).attr('width', xRange.bandwidth()).append('title').text(function(d, i) {
    return `${i + 1}`;
  });
  l = svg.append('g').attr('transform', `translate(${WIDTH - 25}, ${margins.top})`).selectAll('g').data(keys.reverse()).enter().append('g').attr('transform', function(d, i) {
    return `translate(0, ${i * 20})`;
  });
  l.append('rect').attr('x', -19).attr('width', 19).attr('height', 19).attr('fill', function(d, i) {
    return color(keys.length - i);
  });
  return l.append('text').attr('font-size', '70%').attr('x', -60).attr('y', 9.5).attr('dy', '0.35em').attr('fill', '#93a1a1').text(function(d) {
    return d;
  });
};
