//= require jquery.gmap
//= require markermanager

function map()
{
    if ($("#map").length)
    {
        $("#map").gMap({
            latitude: 40,
            longitude: -40,
            zoom: 2,
            controls: ['GLargeMapControl3D', 'GMenuMapTypeControl'],
            scrollwheel: false,
            markers: $.parseJSON($("#map").attr("data-markers"))
        });
    }
}

setTimeout('map()', 300);