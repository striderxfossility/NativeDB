
public class HitDamageOverTimePrereqState extends GenericHitPrereqState {

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let attackRecord: ref<Attack_GameEffect_Record>;
    let attackTag: CName;
    let prereq: ref<HitDamageOverTimePrereq> = this.GetPrereq() as HitDamageOverTimePrereq;
    if Equals(hitEvent.attackData.GetAttackType(), gamedataAttackType.Effect) {
      attackRecord = hitEvent.attackData.GetAttackDefinition().GetRecord() as Attack_GameEffect_Record;
      if IsDefined(attackRecord) {
        attackTag = attackRecord.AttackTag();
      };
      return Equals(IntEnum(Cast(EnumValueFromName(n"gamedataStatusEffectType", attackTag))), prereq.m_dotType);
    };
    return false;
  }
}

public class HitDamageOverTimePrereq extends GenericHitPrereq {

  public let m_dotType: gamedataStatusEffectType;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".dotType", "");
    this.m_dotType = IntEnum(Cast(EnumValueFromString("gamedataStatusEffectType", str)));
    str = TweakDBInterface.GetString(recordID + t".pipelineStage", "");
    this.m_pipelineStage = IntEnum(Cast(EnumValueFromString("gameDamagePipelineStage", str)));
    str = TweakDBInterface.GetString(recordID + t".callbackType", "");
    this.m_callbackType = IntEnum(Cast(EnumValueFromString("gameDamageCallbackType", str)));
  }
}
