
public class TriggerAttackOnTargetEffect extends Effector {

  public let m_isRandom: Bool;

  public let m_applicationChance: Float;

  public let m_owner: wref<GameObject>;

  public let m_attackTDBID: TweakDBID;

  public let m_attack: ref<Attack_GameEffect>;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_isRandom = TweakDBInterface.GetBool(record + t".isRandom", false);
    this.m_applicationChance = TweakDBInterface.GetFloat(record + t".applicationChance", 0.00);
    let effectorRecord: ref<TriggerAttackEffector_Record> = TweakDBInterface.GetTriggerAttackEffectorRecord(record);
    this.m_attackTDBID = effectorRecord.AttackRecord().GetID();
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let flag: SHitFlag;
    let hitFlags: array<SHitFlag>;
    let target: wref<GameObject>;
    let tempArr: array<String> = TweakDBInterface.GetAttackRecord(this.m_attackTDBID).HitFlags();
    let i: Int32 = 0;
    while i < ArraySize(tempArr) {
      flag.flag = IntEnum(Cast(EnumValueFromString("hitFlag", tempArr[i])));
      flag.source = n"Attack";
      ArrayPush(hitFlags, flag);
      i += 1;
    };
    target = GameInstance.GetTargetingSystem(owner.GetGame()).GetLookAtObject(owner, true);
    if !IsDefined(target) {
      return;
    };
    this.m_attack = RPGManager.PrepareGameEffectAttack(owner.GetGame(), owner, owner, this.m_attackTDBID, target.GetWorldPosition(), hitFlags);
    this.Uninitialize(owner.GetGame());
  }

  protected func RepeatedAction(owner: ref<GameObject>) -> Void {
    let rand: Float;
    this.ActionOn(owner);
    if this.m_isRandom {
      rand = RandF();
      if rand <= this.m_applicationChance {
        this.m_attack.StartAttack();
      };
    };
  }
}
