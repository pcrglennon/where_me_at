var map, directionsDisplay,
      directionsService = new google.maps.DirectionsService();

  function initialize() {
    var mapOptions = {
      zoom: 18
    };
    map = new google.maps.Map(document.getElementById('map-canvas'),
        mapOptions);

    // Try HTML5 geolocation
    if(navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(function(position) {
        var pos = new google.maps.LatLng(position.coords.latitude,
                                         position.coords.longitude);

        var infowindow = new google.maps.InfoWindow({
          map: map,
          position: pos
        });

        var marker = new google.maps.Marker({
          position: pos,
          map: map,
          draggable: true,
          title: 'Your Position'
        });

        map.setCenter(pos);
        addToForm(pos.k, pos.B);
        makeDirections();

        google.maps.event.addListener(marker, "dragend", function(event) {
          var lat = event.latLng.k;
          var lng = event.latLng.B;
          updateMap(lat, lng);
        });
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

  function updateMap(latitude, longitude) {
    centerAt = new google.maps.LatLng(latitude, longitude);
    map.setCenter(centerAt);
    addToForm(latitude, longitude);
  }

  function addToForm(latitude, longitude) {
    var latitudeInput = "<input id='map-latitude' type='hidden' value=" + latitude + " name='location[latitude]' />";
    var longitudeInput = "<input id='map-longitude' type='hidden' value=" + longitude + " name='location[longitude]' />";
    $('#map-latitude').remove();
    $('#map-longitude').remove();
    $('form#new-map-form').prepend(latitudeInput + longitudeInput);
  }

  function makeDirections() {
    directionsDisplay = new google.maps.DirectionsRenderer();
    directionsDisplay.setMap(map);
    directionsDisplay.setPanel(document.getElementById('directions-panel'));
    var control = document.getElementById('control');
    control.style.display = 'block';
    map.controls[google.maps.ControlPosition.TOP_CENTER].push(control);
  }

  function calcRoute() {

    // sets start and end variables, which grab the contents 
    // of the elements with an id of 'start' and 'end'
    var start = document.getElementById('start').value;
    var end = document.getElementById('end').value;

    // sets a object literal with an origin of start, destination 
    // of end and the travel mode 
    var request = {
      origin: start,
      destination: end,
      travelMode: google.maps.TravelMode.WALKING
    };

    // this gives the directionsService var a route of the request 
    // object literal, and a callback method that executes upon the 
    // receipt of the response from directionsService.  Learn more 
    // about callbacks here, 
    // http://javascriptissexy.com/understand-javascript-callback-functions-and-use-them/
    directionsService.route(request, function(response, status) {
      if (status == google.maps.DirectionsStatus.OK) {
        directionsDisplay.setDirections(response);
      }
    });
  }

google.maps.event.addDomListener(window, 'load', initialize);