
public final class TDB extends TweakDBInterface {

  public final static func GetInt(path: TweakDBID) -> Int32 {
    return TweakDBInterface.GetIntDefault(path);
  }

  public final static func GetIntArray(path: TweakDBID) -> array<Int32> {
    return TweakDBInterface.GetIntArrayDefault(path);
  }

  public final static func GetFloat(path: TweakDBID) -> Float {
    return TweakDBInterface.GetFloatDefault(path);
  }

  public final static func GetFloatArray(path: TweakDBID) -> array<Float> {
    return TweakDBInterface.GetFloatArrayDefault(path);
  }

  public final static func GetString(path: TweakDBID) -> String {
    return TweakDBInterface.GetStringDefault(path);
  }

  public final static func GetStringArray(path: TweakDBID) -> array<String> {
    return TweakDBInterface.GetStringArrayDefault(path);
  }

  public final static func GetBool(path: TweakDBID) -> Bool {
    return TweakDBInterface.GetBoolDefault(path);
  }

  public final static func GetBoolArray(path: TweakDBID) -> array<Bool> {
    return TweakDBInterface.GetBoolArrayDefault(path);
  }

  public final static func GetCName(path: TweakDBID) -> CName {
    return TweakDBInterface.GetCNameDefault(path);
  }

  public final static func GetCNameArray(path: TweakDBID) -> array<CName> {
    return TweakDBInterface.GetCNameArrayDefault(path);
  }

  public final static func GetLocKey(path: TweakDBID) -> CName {
    return TweakDBInterface.GetLocKeyDefault(path);
  }

  public final static func GetLocKeyArray(path: TweakDBID) -> array<CName> {
    return TweakDBInterface.GetLocKeyArrayDefault(path);
  }

  public final static func GetColor(path: TweakDBID) -> Color {
    return TweakDBInterface.GetColorDefault(path);
  }

  public final static func GetColorArray(path: TweakDBID) -> array<Color> {
    return TweakDBInterface.GetColorArrayDefault(path);
  }

  public final static func GetVector2(path: TweakDBID) -> Vector2 {
    return TweakDBInterface.GetVector2Default(path);
  }

  public final static func GetVector2Array(path: TweakDBID) -> array<Vector2> {
    return TweakDBInterface.GetVector2ArrayDefault(path);
  }

  public final static func GetVector3(path: TweakDBID) -> Vector3 {
    return TweakDBInterface.GetVector3Default(path);
  }

  public final static func GetVector3Array(path: TweakDBID) -> array<Vector3> {
    return TweakDBInterface.GetVector3ArrayDefault(path);
  }

  public final static func GetEulerAngles(path: TweakDBID) -> EulerAngles {
    return TweakDBInterface.GetEulerAnglesDefault(path);
  }

  public final static func GetEulerAnglesArray(path: TweakDBID) -> array<EulerAngles> {
    return TweakDBInterface.GetEulerAnglesArrayDefault(path);
  }

  public final static func GetQuaternion(path: TweakDBID) -> Quaternion {
    return TweakDBInterface.GetQuaternionDefault(path);
  }

  public final static func GetQuaternionArray(path: TweakDBID) -> array<Quaternion> {
    return TweakDBInterface.GetQuaternionArrayDefault(path);
  }

  public final static func GetResRef(path: TweakDBID) -> ResRef {
    return TweakDBInterface.GetResRefDefault(path);
  }

  public final static func GetResRefArray(path: TweakDBID) -> array<ResRef> {
    return TweakDBInterface.GetResRefArrayDefault(path);
  }
}
