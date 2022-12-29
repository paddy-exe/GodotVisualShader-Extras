shader_type spatial;
// Brick pattern tiling with random texture rotation

// The main texture
uniform sampler2D main_tex;

// The size of the texture in pixels
//uniform vec2 texture_size;

// The number of rows in the tiling
uniform float row_count;

// The number of columns in the tiling
uniform float column_count;

// The amount of rotation to apply to each brick in degrees
uniform float rotation;

// The amount of row shift in pixels
uniform float row_shift;

// The UV coordinates of the texture
varying vec2 texcoord;

vec2 rotate(vec2 v, float angle) {
  float s = sin(radians(angle));
  float c = cos(radians(angle));
  return mat2(vec2(c, -s), vec2(s, c)) * v;
}

void fragment() {
texcoord = UV;

  // Read the size of the main texture
 // vec2 texture_size = textureSize(main_tex);
  vec2 texture_size = vec2( 1.0, 1.0);//textureSize(main_tex,0) );
  
  // Scale the texture coordinates by the number of rows and columns
  vec2 scaled_texcoord = texcoord * vec2(column_count, row_count);
  
  // Calculate the brick coordinates
  vec2 brick_coord = floor(scaled_texcoord / texture_size);
  
  // Calculate the row number
  float row = floor(scaled_texcoord.y / texture_size.y);
  
  // Shift the texture coordinates based on the row number and the row shift amount
  vec2 shifted_texcoord = scaled_texcoord;
  shifted_texcoord.x += mod(row, 2.0) * row_shift * texture_size.x;
  
  // Calculate the position within the brick
  vec2 brick_pos = texcoord - brick_coord * texture_size;
  
  // Scale the brick position by the number of rows and columns
  vec2 scaled_brick_pos = brick_pos / texture_size * vec2(column_count, row_count);
  
  // Generate a random rotation angle for this brick
  float angle = rotation * (fract(sin(dot(brick_coord, vec2(12.9898, 78.233))) * 43758.5453));
  
  // Rotate the texture coordinates
  vec2 rotated_texcoord = rotate(scaled_brick_pos, angle);
  
  // Scale the rotated coordinates by the number of rows and columns
  vec2 scaled_rotated_texcoord = rotated_texcoord * vec2(column_count, row_count);
  
  // Unscale the rotated coordinates
  scaled_rotated_texcoord = scaled_rotated_texcoord / vec2(column_count, row_count) * texture_size;
  
  // Sample the main texture using the rotated and shifted coordinates
  //gl_FragColor = texture(main_tex, (brick_coord + scaled_rotated_texcoord) / vec2(column_count, row_count));
  
  // Sample the main texture using the rotated and shifted coordinates
  ALBEDO = texture(main_tex, (brick_coord + scaled_rotated_texcoord) / vec2(column_count, row_count)).rgb; 
ALBEDO = ((brick_coord + scaled_rotated_texcoord) / vec2(column_count, row_count)).rgg;
}

