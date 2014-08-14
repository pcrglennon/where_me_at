Where Me At
============

[![Build Status](https://travis-ci.org/pcrglennon/wheremeat.svg?branch=master)](https://travis-ci.org/pcrglennon/wheremeat)
[![Coverage Status](https://coveralls.io/repos/pcrglennon/wheremeat/badge.png?branch=master)](https://coveralls.io/r/pcrglennon/wheremeat?branch=master)

## Description
If you have ever wanted to meet your friend, but you couldn't describe where you are, this app is perfect for you!<br>
[Where Me At](http://www.wheremeat.com), you can send your location to your friend, and we will generate directions from his current location to you.

## Usage
1. The map on the homepage centers on where you are (you can drag the marker to adjust it though).<br>
2. Make a map name and enter his email and/or phone number.<br>
3. Click Create.<br>
4. Your friend will now receive a message with a link to see directions from his current location to you! (He can also drag the markers to adjust his starting and end points).

## Technology in our stack
- Customized Google Maps with geolocation to find the user’s current location
- Generated directions with the Google Maps API to direct the user
- Set up Twilio and Mailgun gems to send users links of maps with directions
- Integrated a PostgreSQL database to persist map data

## Development/Contribution
Make a pull request if you're interested in helping develop for this project.

## Authors
- [Justin Kim](https://twitter.com/jusjmkim)
- [Peter Glennon](https://twitter.com/pcrglennon)

## License
Where Me At is MIT Licensed. See LICENSE for details.