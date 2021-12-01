
public class HitIsRarityPrereqState extends GenericHitPrereqState {

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let prereq: ref<HitIsRarityPrereq> = this.GetPrereq() as HitIsRarityPrereq;
    let objectToCheck: wref<ScriptedPuppet> = hitEvent.target as ScriptedPuppet;
    let result: Bool = Equals(objectToCheck.GetPuppetRarityEnum(), prereq.m_rarity);
    if prereq.m_invert {
      return !result;
    };
    return result;
  }
}

public class HitIsRarityPrereq extends GenericHitPrereq {

  public let m_invert: Bool;

  public let m_rarity: gamedataNPCRarity;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".rarity", "");
    this.m_rarity = IntEnum(Cast(EnumValueFromString("gamedataNPCRarity", str)));
    this.m_invert = TweakDBInterface.GetBool(recordID + t".invert", false);
  }
}
