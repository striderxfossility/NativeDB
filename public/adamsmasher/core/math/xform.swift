
public native struct Transform {

  public native let position: Vector4;

  public native let orientation: Quaternion;

  public final static func Create(position: Vector4, opt orientation: Quaternion) -> Transform {
    let t: Transform;
    t.position = position;
    t.orientation = orientation;
    return t;
  }

  public final static native func TransformPoint(xform: Transform, v: Vector4) -> Vector4;

  public final static native func TransformVector(xform: Transform, v: Vector4) -> Vector4;

  public final static native func ToEulerAngles(xform: Transform) -> EulerAngles;

  public final static native func ToMatrix(xform: Transform) -> Matrix;

  public final static native func GetForward(xform: Transform) -> Vector4;

  public final static native func GetRight(xform: Transform) -> Vector4;

  public final static native func GetUp(xform: Transform) -> Vector4;

  public final static native func GetPitch(xform: Transform) -> Float;

  public final static native func GetYaw(xform: Transform) -> Float;

  public final static native func GetRoll(xform: Transform) -> Float;

  public final static native func SetIdentity(xform: Transform) -> Void;

  public final static native func SetInverse(xform: Transform) -> Void;

  public final static native func GetInverse(xform: Transform) -> Transform;

  public final static native func GetPosition(xform: Transform) -> Vector4;

  public final static native func GetOrientation(xform: Transform) -> Quaternion;

  public final static native func SetPosition(xform: Transform, v: Vector4) -> Void;

  public final static native func SetOrientation(xform: Transform, quat: Quaternion) -> Void;

  public final static native func SetOrientationEuler(xform: Transform, euler: EulerAngles) -> Void;

  public final static native func SetOrientationFromDir(xform: Transform, direction: Vector4) -> Void;
}
