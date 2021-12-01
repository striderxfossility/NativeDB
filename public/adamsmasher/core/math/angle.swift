
public static func AngleNormalize180(a: Float) -> Float {
  if a >= -180.00 && a <= 180.00 {
    return a;
  };
  if a < -360.00 || a > 360.00 {
    a = AngleNormalize(a);
  };
  if a > 180.00 {
    a -= 360.00;
  } else {
    if a < -180.00 {
      a += 360.00;
    };
  };
  return a;
}

public static func LerpAngleF(alpha: Float, a: Float, b: Float) -> Float {
  return a + AngleDistance(b, a) * alpha;
}
