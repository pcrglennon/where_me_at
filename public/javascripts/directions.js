var map, directionsDisplay, pos;
var directionsService = new google.maps.DirectionsService();

function initialize() {
  var mapOptions = {
    zoom: 18
  };
  var map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);

  // Try HTML5 geolocation
  if(navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position) {
      pos = new google.maps.LatLng(position.coords.latitude,
                                  position.coords.longitude);
      var infowindow = new google.maps.InfoWindow({
        map: map,
        position: pos
      });

      // var marker = new google.maps.Marker({
      //   position: pos,
      //   map: map,
      //   draggable: true,
      //   title: 'Your Position'
      // });

      map.setCenter(pos);

      // google.maps.event.addListener(marker, "dragend", function(event) {
      //   var lat = event.latLng.k;
      //   var lng = event.latLng.B;
      //   updateMap(lat, lng);
      // });
    google.maps.event.addListener(map, 'tilesloaded', function(){
      // Map has loaded
      console.log('Done Loading');
    });
  }, function() {
    handleNoGeolocation(true);
    });
  } else {
    // Browser doesn't support Geolocation
    handleNoGeolocation(false);
  }

  function handleNoGeolocation(errorFlag) {
    if (errorFlag) {
      var content = 'Error: The Geolocation service failed.';
    } else {
      var content = 'Error: Your browser doesn\'t support geolocation.';
    }

    var options = {
      map: map,
      position: new google.maps.LatLng(60, 105),
      content: content
    };

    var infowindow = new google.maps.InfoWindow(options);
    map.setCenter(options.position);
  }

  var rendererOptions = {draggable: true};

  directionsDisplay = new google.maps.DirectionsRenderer(rendererOptions);
  directionsDisplay.setMap(map);
  directionsDisplay.setPanel(document.getElementById('directions'));
}

function updateMap(latitude, longitude) {
  centerAt = new google.maps.LatLng(latitude, longitude);
  map.setCenter(centerAt);
  addToForm(latitude, longitude);
}

function calcRoute() {
  setTimeout(function() {
    var $end = $('#end').val();
    var parsedEnd = parseCoordinates($end);
    var end = new google.maps.LatLng(parsedEnd[0], parsedEnd[1]);

    var request = {
      origin: pos,
      destination: end,
      travelMode: google.maps.TravelMode.WALKING
    };

    directionsService.route(request, function(response, status) {
      if (status == google.maps.DirectionsStatus.OK) {
        directionsDisplay.setDirections(response);
      }
    });
  }, 4000);
}

function parseCoordinates(coord) {
  var separateCoord = coord.split(", ");
  separateCoord[0] = separateCoord[0].replace("(", "");
  separateCoord[1] = separateCoord[1].replace(")", "");
  var finalCoord = [parseFloat(separateCoord[0]),
                    parseFloat(separateCoord[1])];
  return finalCoord;
}

google.maps.event.addDomListener(window, 'load', initialize);
google.maps.event.addDomListener(window, 'load', calcRoute);