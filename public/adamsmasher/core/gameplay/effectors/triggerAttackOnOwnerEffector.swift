
public class TriggerAttackOnOwnerEffect extends Effector {

  public let m_owner: wref<GameObject>;

  public let m_attackTDBID: TweakDBID;

  public let m_playerAsInstigator: Bool;

  public let m_triggerHitReaction: Bool;

  public let m_attackPositionSlotName: CName;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    let effectorRecord: ref<TriggerAttackEffector_Record> = TweakDBInterface.GetTriggerAttackEffectorRecord(record);
    this.m_attackTDBID = effectorRecord.AttackRecord().GetID();
    this.m_playerAsInstigator = TweakDBInterface.GetBool(record + t".playerAsInstigator", false);
    this.m_triggerHitReaction = TweakDBInterface.GetBool(record + t".triggerHitReaction", false);
    this.m_attackPositionSlotName = TweakDBInterface.GetCName(record + t".attackPositionSlotName", n"Chest");
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.RepeatedAction(owner);
  }

  protected func RepeatedAction(owner: ref<GameObject>) -> Void {
    let attack: ref<Attack_GameEffect>;
    let flag: SHitFlag;
    let hitFlags: array<SHitFlag>;
    let instigator: wref<GameObject>;
    let tempArr: array<String> = TweakDBInterface.GetAttackRecord(this.m_attackTDBID).HitFlags();
    let i: Int32 = 0;
    while i < ArraySize(tempArr) {
      flag.flag = IntEnum(Cast(EnumValueFromString("hitFlag", tempArr[i])));
      flag.source = n"Attack";
      ArrayPush(hitFlags, flag);
      i += 1;
    };
    if this.m_playerAsInstigator {
      instigator = GetPlayer(owner.GetGame());
    } else {
      instigator = owner;
    };
    attack = RPGManager.PrepareGameEffectAttack(owner.GetGame(), instigator, instigator, this.m_attackTDBID, this.GetAttackPosition(owner), hitFlags, owner);
    attack.StartAttack();
    if this.m_triggerHitReaction {
      AISubActionForceHitReaction_Record_Implementation.SendForcedHitDataToAIBehavior(owner, 4, 0, 3, 2, 0, 0, 0);
    };
    this.Uninitialize(owner.GetGame());
  }

  private final func GetAttackPosition(obj: wref<GameObject>) -> Vector4 {
    let slotTransform: WorldTransform;
    let ownerLocation: Vector4 = obj.GetWorldPosition();
    let ownerPuppet: ref<ScriptedPuppet> = obj as ScriptedPuppet;
    if IsDefined(ownerPuppet.GetSlotComponent()) {
      if ownerPuppet.GetSlotComponent().GetSlotTransform(this.m_attackPositionSlotName, slotTransform) {
        ownerLocation = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(slotTransform));
        return ownerLocation;
      };
    };
    return obj.GetWorldPosition();
  }
}
