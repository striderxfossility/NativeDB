
public class TriggerAttackByChanceEffector extends Effector {

  public let m_owner: wref<GameObject>;

  public let m_attackTDBID: TweakDBID;

  public let m_chance: Float;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    let effectorRecord: ref<TriggerAttackEffector_Record> = TweakDBInterface.GetTriggerAttackEffectorRecord(record);
    this.m_attackTDBID = effectorRecord.AttackRecord().GetID();
    this.m_chance = TweakDBInterface.GetFloat(record + t".chance", 0.00);
  }

  protected func RepeatedAction(owner: ref<GameObject>) -> Void {
    this.ActionOn(owner);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let attack: ref<Attack_GameEffect>;
    let flag: SHitFlag;
    let hitFlags: array<SHitFlag>;
    let i: Int32;
    let tempArr: array<String>;
    let rand: Float = RandF();
    if this.m_chance >= rand {
      tempArr = TweakDBInterface.GetAttackRecord(this.m_attackTDBID).HitFlags();
      i = 0;
      while i < ArraySize(tempArr) {
        flag.flag = IntEnum(Cast(EnumValueFromString("hitFlag", tempArr[i])));
        flag.source = n"Attack";
        ArrayPush(hitFlags, flag);
        i += 1;
      };
      attack = RPGManager.PrepareGameEffectAttack(owner.GetGame(), owner, owner, this.m_attackTDBID, hitFlags, owner);
      attack.StartAttack();
      this.Uninitialize(owner.GetGame());
    };
  }
}
