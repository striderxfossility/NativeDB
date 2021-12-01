
public class AITweakParams extends IScriptable {

  public final static func GetStringFromTweak(const actionID: TweakDBID, const paramName: String) -> String {
    let tweakID: TweakDBID = actionID;
    TDBID.Append(tweakID, TDBID.Create("." + paramName));
    return TweakDBInterface.GetString(tweakID, "");
  }

  public final static func GetStringArrayFromTweak(const actionID: TweakDBID, const paramName: String) -> array<String> {
    let tweakID: TweakDBID = actionID;
    TDBID.Append(tweakID, TDBID.Create("." + paramName));
    return TDB.GetStringArray(tweakID);
  }

  public final static func GetCNameFromTweak(const actionID: TweakDBID, const paramName: String) -> CName {
    let tweakID: TweakDBID = actionID;
    TDBID.Append(tweakID, TDBID.Create("." + paramName));
    return TweakDBInterface.GetCName(tweakID, n"");
  }

  public final static func GetCNameArrayFromTweak(const actionID: TweakDBID, const paramName: String) -> array<CName> {
    let tweakID: TweakDBID = actionID;
    TDBID.Append(tweakID, TDBID.Create("." + paramName));
    return TDB.GetCNameArray(tweakID);
  }

  public final static func GetFloatFromTweak(const actionID: TweakDBID, const paramName: String) -> Float {
    let tweakID: TweakDBID = actionID;
    TDBID.Append(tweakID, TDBID.Create("." + paramName));
    return TweakDBInterface.GetFloat(tweakID, -1.00);
  }

  public final static func GetFloatArrayFromTweak(const actionID: TweakDBID, const paramName: String) -> array<Float> {
    let tweakID: TweakDBID = actionID;
    TDBID.Append(tweakID, TDBID.Create("." + paramName));
    return TDB.GetFloatArray(tweakID);
  }

  public final static func GetIntFromTweak(const actionID: TweakDBID, const paramName: String) -> Int32 {
    let tweakID: TweakDBID = actionID;
    TDBID.Append(tweakID, TDBID.Create("." + paramName));
    return TweakDBInterface.GetInt(tweakID, -1);
  }

  public final static func GetIntArrayFromTweak(const actionID: TweakDBID, const paramName: String) -> array<Int32> {
    let tweakID: TweakDBID = actionID;
    TDBID.Append(tweakID, TDBID.Create("." + paramName));
    return TDB.GetIntArray(tweakID);
  }

  public final static func GetVectorFromTweak(const actionID: TweakDBID, const paramName: String) -> Vector3 {
    let tweakID: TweakDBID = actionID;
    TDBID.Append(tweakID, TDBID.Create("." + paramName));
    return TDB.GetVector3(tweakID);
  }

  public final static func GetBoolFromTweak(const actionID: TweakDBID, const paramName: String) -> Bool {
    let tweakID: TweakDBID = actionID;
    TDBID.Append(tweakID, TDBID.Create("." + paramName));
    return TweakDBInterface.GetBool(tweakID, false);
  }
}
