
public abstract native class gamePuppetBase extends TimeDilatable {

  public final native const func GetRecordID() -> TweakDBID;

  public final native const func GetTweakDBDisplayName(useDisplayNameAsFallback: Bool) -> String;

  public final native const func GetTweakDBFullDisplayName(useDisplayNameAsFallback: Bool) -> String;

  public final const func GetIntFromCharacterTweak(varName: String, opt defaultValue: Int32) -> Int32 {
    let tweakID: TweakDBID = this.GetRecordID();
    TDBID.Append(tweakID, TDBID.Create("." + varName));
    return TweakDBInterface.GetInt(tweakID, defaultValue);
  }

  public final const func GetFloatFromCharacterTweak(varName: String, opt defaultValue: Float) -> Float {
    let tweakID: TweakDBID = this.GetRecordID();
    TDBID.Append(tweakID, TDBID.Create("." + varName));
    return TweakDBInterface.GetFloat(tweakID, defaultValue);
  }

  public final const func GetStringFromCharacterTweak(varName: String, opt defaultValue: String) -> String {
    let tweakID: TweakDBID = this.GetRecordID();
    TDBID.Append(tweakID, TDBID.Create("." + varName));
    return TweakDBInterface.GetString(tweakID, defaultValue);
  }

  public final const func GetBoolFromCharacterTweak(varName: String, opt defaultValue: Bool) -> Bool {
    let tweakID: TweakDBID = this.GetRecordID();
    TDBID.Append(tweakID, TDBID.Create("." + varName));
    return TweakDBInterface.GetBool(tweakID, defaultValue);
  }

  public final const func GetCNameFromCharacterTweak(varName: String, opt defaultValue: CName) -> CName {
    let tweakID: TweakDBID = this.GetRecordID();
    TDBID.Append(tweakID, TDBID.Create("." + varName));
    return TweakDBInterface.GetCName(tweakID, defaultValue);
  }

  public const func IsIncapacitated() -> Bool {
    return false;
  }
}
