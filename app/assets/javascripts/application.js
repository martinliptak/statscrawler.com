// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require highcharts

function addSpaces(nStr)
{
	nStr += '';
	x = nStr.split('.');
	x1 = x[0];
	x2 = x.length > 1 ? '.' + x[1] : '';
	var rgx = /(\d+)(\d{3})/;
	while (rgx.test(x1)) {
		x1 = x1.replace(rgx, '$1' + ',' + '$2');
	}
	return x1 + x2;
}

function niceRound(num)
{
    c = 1;

    while (Math.round(num * c) / c == 0)
        c *= 10

    return Math.round(num * c) / c;
}

$(".chart").each(function () {
    var chart = this;

    options = {
     container: chart,
     chart: {
        renderTo: chart,
        defaultSeriesType: $(chart).attr("data-type"),
        zoomType: 'xy'
     },
     title: {
        text: $(chart).attr("title")
     },
     xAxis: {
        type: $(chart).attr("data-type") != 'line' ? null : 'datetime',
        categories: $.parseJSON($(chart).attr("data-categories")),
        title: {
           text: $(chart).attr("data-x-title")
        }
     },
     yAxis: {
        title: {
           text: $(chart).attr("data-y-title")
        },
        min: $(chart).attr("data-min") || null,
        startOnTick: $(chart).attr("data-type") != 'line',
        showFirstLabel: $(chart).attr("data-type") != 'line'
     },
     legend: {
        enabled: false
     },
     tooltip: {
         formatter: function () {
            return eval($(chart).attr("data-tooltip"));
         }
     },
    plotOptions: {
        column: {
            cursor: $(chart).attr("data-no-pointer") ? "" : "pointer",
            point: {
                events: {
                    "click": function () {
                        var m = this.category.match(/<a href="(.*)">/);
                        if (m)
                            window.location = m[1];
                    }
                }
            },
            animation: false
        },
        pie: {
            cursor: $(chart).attr("data-no-pointer") ? "" : "pointer",
            point: {
                events: {
                    "click": function () {
                        var m = this.name.match(/<a href="(.*)">/);
                        if (m)
                            window.location = m[1];
                    }
                }
            }, 
            animation: false
        },
        line: {
            marker: {
               enabled: false,
               states: {
                  hover: {
                     enabled: true
                  }
               }
            }
         }
    },
    series: [],
    credits: {
        enabled: false
    },
    animation: {
        enabled: false
    }
   }

   if ($.parseJSON($(chart).attr("data-series-hash")))
   {
     h = $.parseJSON($(chart).attr("data-series-data"));
     for (s in h)
     {
        options['series'].push({
            type: $(chart).attr("data-type"),
            name: s,
            data: h[s],
            pointInterval: parseInt($(chart).attr("data-series-interval")) || null,
            pointStart: parseInt($(chart).attr("data-series-start")) || null
         });
     }

     options.legend.enabled = true;
   }
   else
   {
     options['series'].push({
        type: $(chart).attr("data-type"),
        data: $.parseJSON($(chart).attr("data-series-data")),
        pointInterval: parseInt($(chart).attr("data-series-interval")) || null,
        pointStart: parseInt($(chart).attr("data-series-start")) || null,
        dataLabels: {
            formatter: function() {
               return this.point.name + ": " + niceRound(this.y) + "%";
            }
         }
     });
   }

   new Highcharts.Chart(options);
});

var refreshInterval;

function refresh()
{
        secs = parseInt($('#refresh-in').html());
        secs -= 1;

        if (secs == 0)
        {
            clearInterval(refreshInterval);
            location.reload(true);
        }
        else
            $('#refresh-in').html(secs);

}

$(function () {

  if ($('#refresh-in').length)
  {
      refreshInterval = setInterval('refresh();', 1000);
  }
});
