
public class StatusEffectRemovedPrereqState extends StatusEffectPrereqState {

  public func StatusEffectUpdate(statusEffect: wref<StatusEffect_Record>, isApplied: Bool) -> Void {
    let checkPassed: Bool;
    let prereq: ref<StatusEffectRemovedPrereq>;
    if !isApplied {
      prereq = this.GetPrereq() as StatusEffectRemovedPrereq;
      checkPassed = prereq.Evaluate(statusEffect);
      if prereq.m_fireAndForget {
        if checkPassed {
          this.OnChangedRepeated(false);
        };
      } else {
        this.OnChanged(checkPassed);
      };
    };
  }
}

public class StatusEffectRemovedPrereq extends StatusEffectPrereq {

  protected func Initialize(recordID: TweakDBID) -> Void {
    let record: ref<StatusEffectPrereq_Record> = TweakDBInterface.GetStatusEffectPrereqRecord(recordID);
    this.m_statusEffectRecordID = record.StatusEffect().GetID();
    this.m_checkType = TweakDBInterface.GetString(recordID + t".checkType", "");
    this.m_fireAndForget = TweakDBInterface.GetBool(recordID + t".fireAndForget", false);
  }

  public const func Evaluate(statusEffect: wref<StatusEffect_Record>) -> Bool {
    let result: Bool;
    switch this.m_checkType {
      case "Record":
        result = this.m_statusEffectRecordID == statusEffect.GetID();
        break;
      case "Type":
        result = Equals(TweakDBInterface.GetStatusEffectRecord(this.m_statusEffectRecordID).StatusEffectType().Type(), statusEffect.StatusEffectType().Type());
        break;
      default:
        return false;
    };
    return result;
  }
}
