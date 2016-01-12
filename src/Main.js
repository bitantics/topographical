// module Main

var SimplexNoise = require( 'simplex-noise' ),
    simplex = new SimplexNoise( Math.random );

exports.noise = function noise( x ) {
  return function( y ) {
    return simplex.noise2D( x, y );
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
