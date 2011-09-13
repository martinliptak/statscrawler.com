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

$(function() {
    /**
     * Grid theme for Highcharts JS
     * @author Torstein Hønsi
     */

    Highcharts.theme = {
       colors: ['#058DC7', '#50B432', '#ED561B', '#DDDF00', '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4'],
       chart: {
          /*
          backgroundColor: {
             linearGradient: [0, 0, 500, 500],
             stops: [
                [0, 'rgb(255, 255, 255)'],
                [1, 'rgb(240, 240, 255)']
             ]
          }
    ,
          borderWidth: 2,
          plotBackgroundColor: 'rgba(255, 255, 255, .9)',
          plotShadow: true,
          plotBorderWidth: 1
          */
          plotShadow: true
       },
       title: {
          style: {
             color: '#000',
             font: 'bold 16px "Trebuchet MS", Verdana, sans-serif'
          }
       },
       subtitle: {
          style: {
             color: '#666666',
             font: 'bold 12px "Trebuchet MS", Verdana, sans-serif'
          }
       },
       xAxis: {
          gridLineWidth: 1,
          lineColor: '#000',
          tickColor: '#000',
          labels: {
             style: {
                color: '#000',
                font: '11px Trebuchet MS, Verdana, sans-serif'
             }
          },
          title: {
             style: {
                color: '#333',
                fontWeight: 'bold',
                fontSize: '12px',
                fontFamily: 'Trebuchet MS, Verdana, sans-serif'

             }
          }
       },
       yAxis: {
          minorTickInterval: 'auto',
          lineColor: '#000',
          lineWidth: 1,
          tickWidth: 1,
          tickColor: '#000',
          labels: {
             style: {
                color: '#000',
                font: '11px Trebuchet MS, Verdana, sans-serif'
             }
          },
          title: {
             style: {
                color: '#333',
                fontWeight: 'bold',
                fontSize: '12px',
                fontFamily: 'Trebuchet MS, Verdana, sans-serif'
             }
          }
       },
       legend: {
          itemStyle: {
             font: '9pt Trebuchet MS, Verdana, sans-serif',
             color: 'black'

          },
          itemHoverStyle: {
             color: '#039'
          },
          itemHiddenStyle: {
             color: 'gray'
          }
       },
       labels: {
          style: {
             color: '#99b'
          }
       }
    };

    // Apply the theme
    // var highchartsOptions = Highcharts.setOptions(Highcharts.theme);

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
                }
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
                }
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

});
