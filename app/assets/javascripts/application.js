// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap-sprockets
//= require jquery_ujs
//= require turbolinks
//= require_tree .


// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap-sprockets
//= require jquery_ujs
// = require turbolinks
//= require_tree


function providerNumberMap(providerName) {
    switch(providerName) {
        case "twitter":
            return 1;
        case "google_news":
            return 2;
        case "youtube":
            return 3;
        case "reddit":
            return 4;
        case "wiki":
            return 5;
        default:
            return 6;
    }
}

function providerRadiusMap(providerName) {
    switch(providerName) {
        case "twitter":
            return 1;
        case "google_news":
            return 1.2;
        case "youtube":
            return 1.4;
        case "reddit":
            return 1.6;
        case "wiki":
            return 1.8;
        default:
            return 2.0;
    }
}

function paintBubbleChart(visualData) {
    var data=[];
    for(var i=0; i<visualData.length; i++) {
        data[i] = {name: visualData[i][0], value: visualData[i][1], source: visualData[i][2], uri: visualData[i][3]};
    }
    var nameField = 'name',
        valueField = 'value',
        sourceField = 'source',
        childrenField = 'children',
        width = 750,
        height = 500,
        getColor = d3.scale.linear()
                  .domain([0, 60]);

    d3.select("#bubbleChart").selectAll("*").remove(); // remove content for redrawing
    if (data.length === 0) {
      return;
    }

    var colour = d3.scale.category20();

    d3.format(",d"); // use commas e.g. 10,000

    var bubbleLayout = d3.layout.pack();

    bubbleLayout
      .sort(function() { return Math.random() > 0.5; })
      .children(function (d) { return d[childrenField]; })
      .value(function (d) { return d[valueField]; })
      .size([width, height]) // chart dimensions
      .padding(2);

    var svg = d3.select("#bubbleChart");

    var node = svg.selectAll(".node")
      .data(bubbleLayout.nodes({children: data })
        .filter(function (d) { return !d[childrenField]; })
      )
      .enter()
        .append("g")
          .attr("class", "node")
          .attr("transform",
            function(d) { return "translate(" + d.x + "," + d.y + ")";
          });

    // draw a bubble
    node
      .append("circle")
      .attr("r", function(d) {
        return d.r/providerRadiusMap(d[sourceField]);
      })
      .style("fill", function(d, i) { return colour(providerNumberMap(d[sourceField])); });


    // draw the label
    node.append("text")
      .attr("dy", ".3em")
      .style("font-size", function(d) { return d.r / 5 + "px"; })
      .style("text-anchor", "middle")
      .html(function(d) {
        return d[nameField].substring(0, d.r / providerNumberMap(d[sourceField]));
      });
			
		node.append("title")
		  .text(function(d) { 
				return d[sourceField]; 
		});

    //add the title tag for mouse over
    node.append("a")
			.attr("xlink:href", function(d){return d['uri'];}) 
      .text(function(d) { return d[nameField]; })
		.append("svg:rect")
		  .attr("y", -40 / 2)
			.attr("x", -40 / 2)
		  .attr("height", 40)
		  .attr("width", 100)
			.style("fill-opacity", 0.0);
					
    // rebind data
    svg.data(data).selectAll("circle")
        .data(bubbleLayout.nodes({children: data }));

    // transition chart
    node.transition()
        .duration(1300)
        .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
        .attr("r", function(d) { return d.r; });

}

function paintAllBubbleChart(visualData) {
    var data=[];
    for(var i=0; i<visualData.length; i++) {
        data[i] = {name: visualData[i][0], value: visualData[i][1], source: visualData[i][2], uri: visualData[i][3]};
    }
    var nameField = 'name',
        valueField = 'value',
        sourceField = 'source',
        childrenField = 'children',
        width = 2000,
        height = 2000,
        getColor = d3.scale.linear()
                  .domain([0, 60]);

    d3.select("#bubbleChart").selectAll("*").remove(); // remove content for redrawing
    if (data.length === 0) {
      return;
    }

    var colour = d3.scale.category10();

    d3.format(",d"); // use commas e.g. 10,000

    var bubbleLayout = d3.layout.pack();

    bubbleLayout
      .sort(function() { return Math.random() > 0.5; })
      .children(function (d) { return d[childrenField]; })
      .value(function (d) { return d[valueField]; })
      .size([width, height]) // chart dimensions
      .padding(2);

    var svg = d3.select("#bubbleChart");

    var node = svg.selectAll(".node")
      .data(bubbleLayout.nodes({children: data })
        .filter(function (d) { return !d[childrenField]; })
      )
      .enter()
        .append("g")
          .attr("class", "node")
          .attr("transform",
            function(d) { return "translate(" + d.x + "," + d.y + ")";
          });

    // draw a bubble
    node
      .append("circle")
      .attr("r", function(d) {
        return d.r * d[valueField];
      })
      .style("fill", function(d, i) { return colour(providerNumberMap(d[sourceField])); });

    node.append("title")
		  .text(function(d) { 
				return d[nameField].substring(0, d.r / providerNumberMap(d[sourceField])) + "@" + d[sourceField]; 
		});
					
    // rebind data
    svg.data(data).selectAll("circle")
        .data(bubbleLayout.nodes({children: data }));

    // transition chart
    node.transition()
        .duration(1300)
        .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
        .attr("r", function(d) { return d.r; });

}
