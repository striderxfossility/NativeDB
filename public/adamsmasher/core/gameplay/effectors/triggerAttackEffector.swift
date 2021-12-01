
public class SimpleTriggerAttackEffect extends Effector {

  public let m_owner: wref<GameObject>;

  public let m_attackTDBID: TweakDBID;

  public let m_shouldDelay: Bool;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    let effectorRecord: ref<TriggerAttackEffector_Record> = TweakDBInterface.GetTriggerAttackEffectorRecord(record);
    this.m_attackTDBID = effectorRecord.AttackRecord().GetID();
    this.m_shouldDelay = TweakDBInterface.GetBool(record + t".shouldDelay", false);
  }

  protected func RepeatedAction(owner: ref<GameObject>) -> Void {
    this.ActionOn(owner);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let attack: ref<Attack_GameEffect>;
    let delayEvent: ref<TriggerAttackEffectorWithDelay>;
    let flag: SHitFlag;
    let hitFlags: array<SHitFlag>;
    let tempArr: array<String> = TweakDBInterface.GetAttackRecord(this.m_attackTDBID).HitFlags();
    let i: Int32 = 0;
    while i < ArraySize(tempArr) {
      flag.flag = IntEnum(Cast(EnumValueFromString("hitFlag", tempArr[i])));
      flag.source = n"Attack";
      ArrayPush(hitFlags, flag);
      i += 1;
    };
    attack = RPGManager.PrepareGameEffectAttack(owner.GetGame(), owner, owner, this.m_attackTDBID, hitFlags, owner);
    if this.m_shouldDelay {
      delayEvent = new TriggerAttackEffectorWithDelay();
      delayEvent.attack = attack;
      owner.QueueEvent(delayEvent);
    } else {
      attack.StartAttack();
    };
    this.Uninitialize(owner.GetGame());
  }
}
