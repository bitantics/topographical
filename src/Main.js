// module Main

var SimplexNoise = require( 'fast-simplex-noise' ),
    simplex = new SimplexNoise();

exports.noise = function noise( x ) {
  return function( y ) {
    return simplex.getRaw2DNoise( x, y );
  };
};

exports.createImageData = function updateImageData( data ) {
  return function( width ) {
    return function( height ) {
      return new ImageData(
        new Uint8ClampedArray( data ),
        width, height
      );
    };
  };
};
