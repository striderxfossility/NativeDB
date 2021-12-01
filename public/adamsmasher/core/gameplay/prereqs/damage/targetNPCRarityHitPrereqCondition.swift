
public class TargetNPCRarityHitPrereqCondition extends BaseHitPrereqCondition {

  public let m_rarity: gamedataNPCRarity;

  public func SetData(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".rarity", "");
    this.m_rarity = IntEnum(Cast(EnumValueFromString("gamedataNPCRarity", str)));
    this.SetData(recordID);
  }

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let rarity: gamedataNPCRarity;
    let result: Bool;
    let objectToCheck: wref<ScriptedPuppet> = hitEvent.target as ScriptedPuppet;
    if IsDefined(objectToCheck) {
      rarity = objectToCheck.GetPuppetRarityEnum();
      result = Equals(rarity, this.m_rarity);
      return this.m_invert ? !result : result;
    };
    return false;
  }
}
