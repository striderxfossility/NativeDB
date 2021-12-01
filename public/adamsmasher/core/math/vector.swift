
public native struct Vector4 {

  public native let X: Float;

  public native let Y: Float;

  public native let Z: Float;

  public native let W: Float;

  public final static native func Dot2D(a: Vector4, b: Vector4) -> Float;

  public final static native func Dot(a: Vector4, b: Vector4) -> Float;

  public final static native func Cross(a: Vector4, b: Vector4) -> Vector4;

  public final static native func Length2D(a: Vector4) -> Float;

  public final static native func LengthSquared(a: Vector4) -> Float;

  public final static native func Length(a: Vector4) -> Float;

  public final static native func Normalize2D(a: Vector4) -> Vector4;

  public final static native func Normalize(a: Vector4) -> Vector4;

  public final static native func Rand2D() -> Vector4;

  public final static native func Rand() -> Vector4;

  public final static func RandRing(minRadius: Float, maxRadius: Float) -> Vector4 {
    let r: Float = RandRangeF(minRadius, maxRadius);
    let angle: Float = RandRangeF(0.00, 6.28);
    return new Vector4(r * CosF(angle), r * SinF(angle), 0.00, 1.00);
  }

  public final static func RandCone(coneDir: Float, coneAngle: Float, minRadius: Float, maxRadius: Float) -> Vector4 {
    let r: Float = RandRangeF(minRadius, maxRadius);
    let angleMin: Float = Deg2Rad(coneDir - coneAngle * 0.50 + 90.00);
    let angleMax: Float = Deg2Rad(coneDir + coneAngle * 0.50 + 90.00);
    let angle: Float = RandRangeF(angleMin, angleMax);
    return new Vector4(r * CosF(angle), r * SinF(angle), 0.00, 1.00);
  }

  public final static func RandRingStatic(seed: Int32, minRadius: Float, maxRadius: Float) -> Vector4 {
    let r: Float = RandNoiseF(seed, maxRadius, minRadius);
    let angle: Float = RandNoiseF(seed, 6.28);
    return new Vector4(r * CosF(angle), r * SinF(angle), 0.00, 1.00);
  }

  public final static native func Mirror(dir: Vector4, normal: Vector4) -> Vector4;

  public final static native func Distance(from: Vector4, to: Vector4) -> Float;

  public final static native func DistanceSquared(from: Vector4, to: Vector4) -> Float;

  public final static native func Distance2D(from: Vector4, to: Vector4) -> Float;

  public final static native func DistanceSquared2D(from: Vector4, to: Vector4) -> Float;

  public final static native func DistanceToEdge(point: Vector4, a: Vector4, b: Vector4) -> Float;

  public final static native func NearestPointOnEdge(point: Vector4, a: Vector4, b: Vector4) -> Vector4;

  public final static native func ToRotation(dir: Vector4) -> EulerAngles;

  public final static native func Heading(dir: Vector4) -> Float;

  public final static native func FromHeading(heading: Float) -> Vector4;

  public final static native func Transform(m: Matrix, point: Vector4) -> Vector4;

  public final static native func TransformDir(m: Matrix, point: Vector4) -> Vector4;

  public final static native func TransformH(m: Matrix, point: Vector4) -> Vector4;

  public final static native func GetAngleBetween(from: Vector4, to: Vector4) -> Float;

  public final static native func GetAngleDegAroundAxis(dirA: Vector4, dirB: Vector4, axis: Vector4) -> Float;

  public final static native func ProjectPointToPlane(p1: Vector4, p2: Vector4, p3: Vector4, toProject: Vector4) -> Vector4;

  public final static native func RotateAxis(vector: Vector4, axis: Vector4, angle: Float) -> Vector4;

  public final static func RotByAngleXY(vec: Vector4, angleDeg: Float) -> Vector4 {
    let angle: Float = Deg2Rad(angleDeg);
    let ret: Vector4 = vec;
    ret.X = vec.X * CosF(-angle) - vec.Y * SinF(-angle);
    ret.Y = vec.X * SinF(-angle) + vec.Y * CosF(-angle);
    return ret;
  }

  public final static func Interpolate(v1: Vector4, v2: Vector4, ratio: Float) -> Vector4 {
    let dir: Vector4 = v2 - v1;
    return v1 + dir * ratio;
  }

  public final static func ToString(vec: Vector4) -> String {
    return FloatToString(vec.X) + " " + FloatToString(vec.Y) + " " + FloatToString(vec.Z) + " " + FloatToString(vec.W);
  }

  public final static func ToStringPrec(vec: Vector4, precision: Int32) -> String {
    return FloatToStringPrec(vec.X, precision) + " " + FloatToStringPrec(vec.Y, precision) + " " + FloatToStringPrec(vec.Z, precision) + " " + FloatToStringPrec(vec.W, precision);
  }

  public final static func Zero(out self: Vector4) -> Void {
    self.X = 0.00;
    self.Y = 0.00;
    self.Z = 0.00;
    self.W = 0.00;
  }

  public final static func IsZero(self: Vector4) -> Bool {
    return self.X == 0.00 && self.Y == 0.00 && self.Z == 0.00 && self.W == 0.00;
  }

  public final static func IsXYZZero(self: Vector4) -> Bool {
    return self.X < 0.00 && self.Y < 0.00 && self.Z < 0.00;
  }

  public final static func IsFloatZero(self: Vector4) -> Bool {
    return self.X < 0.00 && self.Y < 0.00 && self.Z < 0.00 && self.W < 0.00;
  }

  public final static func IsXYZFloatZero(self: Vector4) -> Bool {
    return self.X < 0.00 && self.Y < 0.00 && self.Z < 0.00;
  }

  public final static func EmptyVector() -> Vector4 {
    let vec: Vector4;
    return vec;
  }

  public final static func ClampLength(self: Vector4, min: Float, max: Float) -> Vector4 {
    let length: Float = Vector4.Length(self);
    length = ClampF(length, min, max);
    return Vector4.Normalize(self) * length;
  }

  public final static func Vector3To4(v3: Vector3) -> Vector4 {
    let v4: Vector4;
    v4.X = v3.X;
    v4.Y = v3.Y;
    v4.Z = v3.Z;
    return v4;
  }

  public final static func Vector4To3(v4: Vector4) -> Vector3 {
    let v3: Vector3;
    v3.X = v4.X;
    v3.Y = v4.Y;
    v3.Z = v4.Z;
    return v3;
  }
}

public static func VectorToString(vec: Vector4) -> String {
  let str: String = "x: " + FloatToString(vec.X) + " y: " + FloatToString(vec.Y) + " z: " + FloatToString(vec.Z);
  return str;
}

public static func Cast(v3: Vector3) -> Vector4 {
  let v4: Vector4;
  v4.X = v3.X;
  v4.Y = v3.Y;
  v4.Z = v3.Z;
  v4.W = 0.00;
  return v4;
}

public static func Cast(v4: Vector4) -> Vector3 {
  let v3: Vector3;
  v3.X = v4.X;
  v3.Y = v4.Y;
  v3.Z = v4.Z;
  return v3;
}
