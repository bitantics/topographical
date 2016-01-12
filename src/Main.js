// module Main

var SimplexNoise = require( 'simplex-noise' ),
    simplex = new SimplexNoise( Math.random );

exports.noise = function noise( x ) {
  return function( y ) {
    return function( z ) {
      return simplex.noise3D( x, y, z );
    };
  };
};

exports.updateImageData = function updateImageData( imgData ) {
  return function( data ) {
    return new ImageData(
      new Uint8ClampedArray( data ),
      imgData.width, imgData.height
    );
  };
};
