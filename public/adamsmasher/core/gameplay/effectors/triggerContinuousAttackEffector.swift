
public class TriggerContinuousAttackEffector extends ContinuousEffector {

  public let m_owner: wref<GameObject>;

  public let m_attackTDBID: TweakDBID;

  public let m_attack: ref<Attack_GameEffect>;

  public let m_delayTime: Float;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    let effectorRecord: ref<ContinuousAttackEffector_Record> = TweakDBInterface.GetContinuousAttackEffectorRecord(record);
    this.m_attackTDBID = effectorRecord.AttackRecord().GetID();
    this.m_delayTime = effectorRecord.DelayTime();
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    if IsDefined(this.m_attack) {
      this.m_attack.StopAttack();
      this.m_attack = null;
    };
  }

  protected func ContinuousAction(owner: ref<GameObject>, instigator: ref<GameObject>) -> Void {
    let flag: SHitFlag;
    let hitFlags: array<SHitFlag>;
    let i: Int32;
    let sourceObject: wref<GameObject>;
    let tempArr: array<String>;
    if !IsDefined(this.m_attack) {
      tempArr = TweakDBInterface.GetAttackRecord(this.m_attackTDBID).HitFlags();
      i = 0;
      while i < ArraySize(tempArr) {
        flag.flag = IntEnum(Cast(EnumValueFromString("hitFlag", tempArr[i])));
        flag.source = n"Attack";
        ArrayPush(hitFlags, flag);
        i += 1;
      };
      sourceObject = instigator;
      this.m_attack = RPGManager.PrepareGameEffectAttack(owner.GetGame(), instigator, sourceObject, this.m_attackTDBID, owner.GetWorldPosition(), hitFlags, owner, this.m_delayTime);
      this.m_attack.StartAttackContinous();
    } else {
      this.m_attack.SetAttackPosition(owner.GetWorldPosition());
    };
  }
}
