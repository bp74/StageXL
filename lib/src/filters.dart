/// Filters are used to change the visual appearance of your display objects.
/// Add drop shadows, blur effects, color transformations or other effects
/// in real time (only available if WebGL is available).
///
/// It is recommended to use filters only if WebGL is available. If WebGL is
/// not available and you have to use the Canvas2D renderer, filters are only
/// visible if you apply a cache to your display objects. This is a time
/// consuming operation performed on the CPU.
///
/// Sample: <http://www.stagexl.org/samples/filter/>

library stagexl.filters;

export 'filters/alpha_mask_filter.dart' show AlphaMaskFilter;
export 'filters/blur_filter.dart' show BlurFilter;
export 'filters/chroma_key_filter.dart' show ChromaKeyFilter;
export 'filters/color_matrix_filter.dart' show ColorMatrixFilter;
export 'filters/displacement_map_filter.dart' show DisplacementMapFilter;
export 'filters/drop_shadow_filter.dart' show DropShadowFilter;
export 'filters/flatten_filter.dart' show FlattenFilter;
export 'filters/glow_filter.dart' show GlowFilter;
export 'filters/normal_map_filter.dart' show NormalMapFilter;
export 'filters/tint_filter.dart' show TintFilter;