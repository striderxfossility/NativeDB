
public static func Pi() -> Float {
  return 3.14;
}

public static func HalfPi() -> Float {
  return 1.57;
}

public static func SgnF(a: Float) -> Float {
  if a > 0.00 {
    return 1.00;
  };
  return -1.00;
}

public static func ModF(a: Float, b: Float) -> Float {
  if b <= 0.00 || a <= 0.00 {
    return 0.00;
  };
  return a - Cast(FloorF(a / b)) * b;
}

public static func ProportionalClampF(inMin: Float, inMax: Float, v: Float, outMin: Float, outMax: Float) -> Float {
  let lerp: Float;
  let inputRange: Float = inMax - inMin;
  v = ClampF(v, inMin, inMax);
  if AbsF(inputRange) > 0.00 {
    lerp = (v - inMin) / inputRange;
  } else {
    lerp = 0.00;
  };
  v = LerpF(lerp, outMin, outMax);
  return v;
}

public static func RoundMath(f: Float) -> Int32 {
  if f == 0.00 {
    return Cast(f);
  };
  if f > 0.00 {
    if f - Cast(FloorF(f)) >= 0.50 {
      return CeilF(f);
    };
    return FloorF(f);
  };
  if f + Cast(FloorF(f)) >= -0.50 {
    return FloorF(f);
  };
  return CeilF(f);
}

public static func RoundTo(f: Float, decimal: Int32) -> Float {
  let digit: Int32;
  let i: Int32;
  let isNeg: Bool;
  let ret: Float;
  if decimal < 0 {
    decimal = 0;
  };
  ret = Cast(FloorF(AbsF(f)));
  isNeg = false;
  if f < 0.00 {
    isNeg = true;
    f *= -1.00;
  };
  f -= ret;
  i = 0;
  while i < decimal {
    f *= 10.00;
    digit = FloorF(f);
    ret += Cast(digit) / PowF(10.00, Cast(i + 1));
    f -= Cast(digit);
    i += 1;
  };
  if isNeg {
    ret *= -1.00;
  };
  return ret;
}

public static func FloatIsEqual(f: Float, to: Float) -> Bool {
  return AbsF(f - to) <= 0.00;
}
