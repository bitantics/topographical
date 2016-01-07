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
