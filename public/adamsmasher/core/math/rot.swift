
public static func GetOppositeRotation180(rot: EulerAngles) -> EulerAngles {
  let ret: EulerAngles;
  ret.Pitch = AngleNormalize180(rot.Pitch + 180.00);
  ret.Yaw = AngleNormalize180(rot.Yaw + 180.00);
  ret.Roll = AngleNormalize180(rot.Roll + 180.00);
  return ret;
}
