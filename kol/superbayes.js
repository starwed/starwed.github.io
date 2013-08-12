(function() {
  var ChartInput, ChartResult, Parse, ProcessProgress, ProcessResults, YiabData, worker;
  google.load("visualization", "1", {
    packages: ["corechart"]
  });
  google.load('visualization', '1', {
    packages: ['table']
  });
  worker = [];
  YiabData = [
    {
      counts: [6, 51, 337, 541],
      boost: 20
    }, {
      counts: [0, 2, 38, 179],
      boost: 40
    }, {
      counts: [0, 0, 6, 105],
      boost: 50
    }, {
      counts: [1, 48, 332, 606],
      boost: 20
    }, {
      counts: [0, 0, 35, 160],
      boost: 40
    }, {
      counts: [0, 0, 7, 115],
      boost: 50
    }, {
      counts: [2, 45, 354, 536],
      boost: 20
    }, {
      counts: [0, 0, 27, 192],
      boost: 40
    }, {
      counts: [0, 0, 12, 105],
      boost: 50
    }, {
      counts: [0, 41, 355, 567],
      boost: 20
    }, {
      counts: [0, 1, 31, 184],
      boost: 40
    }, {
      counts: [0, 0, 8, 107],
      boost: 50
    }
  ];
  window.UpdateParse = function() {
    var dataset;
    dataset = Parse();
    ChartInput(dataset);
  };
  window.Kill = function() {
    var bar;
    bar = document.getElementById('progress_bar');
    bar.value = 0;
    return worker.terminate();
  };
  window.Run = function(range) {
    var TableData, dataset, oldworker, startMessage, table;
    if (range == null) {
      range = 'FULL';
    }
    if (worker) {
      oldworker = worker;
    }
    dataset = Parse();
    startMessage = {
      type: 'RUN',
      "range": range,
      "dataset": dataset
    };
    worker = new Worker('CalculateBayes.js');
    worker.onmessage = function(event) {
      switch (event.data.type) {
        case 'PROGRESS':
          return ProcessProgress(event.data);
        case 'RESULT':
          return ProcessResults(event.data);
        case 'LOG':
          return console.log(event.data.text);
      }
    };
    TableData = new google.visualization.DataTable();
    table = new google.visualization.Table(document.getElementById('table_div'));
    table.draw(TableData);
    worker.postMessage(startMessage);
    if (oldworker) {
      if (typeof oldworker.terminate === "function") {
        oldworker.terminate();
      }
    }
  };
  ProcessResults = function(data) {
    return ChartResult(data.results);
  };
  ProcessProgress = function(data) {
    var bar;
    bar = document.getElementById('progress_bar');
    return bar.value = data.percent;
  };
  Parse = function() {
    var input, rawdata;
    input = document.getElementById('in');
    rawdata = input.value;
    return eval(rawdata);
  };
  ChartInput = function(input_data) {
    var c, cols, data, i, n, row, run, table, _len, _len2, _len3, _ref, _ref2;
    console.log('Trying to chart shit');
    console.log(input_data);
    console.log('-----------');
    data = new google.visualization.DataTable();
    cols = 2 + input_data[0].counts.length;
    _ref = input_data[0].counts;
    for (i = 0, _len = _ref.length; i < _len; i++) {
      c = _ref[i];
      data.addColumn('number', "" + i);
    }
    data.addColumn('number', 'boost');
    data.addColumn('number', 'flat_boost');
    row = 0;
    for (n = 0, _len2 = input_data.length; n < _len2; n++) {
      run = input_data[n];
      data.addRows(1);
      _ref2 = run.counts;
      for (i = 0, _len3 = _ref2.length; i < _len3; i++) {
        c = _ref2[i];
        data.setValue(n, i, c);
      }
      data.setValue(n, cols - 2, run.boost);
      data.setValue(n, cols - 1, run.flat_boost);
    }
    table = new google.visualization.Table(document.getElementById('input_table_div'));
    return table.draw(data, {
      width: '10em',
      showRowNumber: false
    });
  };
  ChartResult = function(Confidences) {
    var c, data, row, table, _i, _len;
    console.log(Confidences);
    data = new google.visualization.DataTable();
    data.addColumn('number', 'Belief');
    data.addColumn('string', 'Rates');
    row = 0;
    for (_i = 0, _len = Confidences.length; _i < _len; _i++) {
      c = Confidences[_i];
      data.addRows(1);
      data.setValue(row, 0, c.belief);
      data.setValue(row++, 1, ' (' + c.rates.toString() + ')');
    }
    table = new google.visualization.Table(document.getElementById('table_div'));
    return table.draw(data, {
      showRowNumber: false,
      sortColumn: 0,
      sortAscending: false
    });
  };
}).call(this);
