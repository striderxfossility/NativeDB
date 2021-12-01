
public class TargetNPCTypeHitPrereqCondition extends BaseHitPrereqCondition {

  public let m_type: gamedataNPCType;

  public func SetData(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".npcType", "");
    this.m_type = IntEnum(Cast(EnumValueFromString("gamedataNPCType", str)));
    this.SetData(recordID);
  }

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let result: Bool;
    let objectToCheck: wref<ScriptedPuppet> = hitEvent.target as ScriptedPuppet;
    if IsDefined(objectToCheck) {
      result = Equals(objectToCheck.GetNPCType(), this.m_type);
      return this.m_invert ? !result : result;
    };
    return false;
  }
}
