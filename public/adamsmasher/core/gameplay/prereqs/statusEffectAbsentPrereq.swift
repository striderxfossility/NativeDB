
public class StatusEffectAbsentPrereqState extends StatusEffectPrereqState {

  public func StatusEffectUpdate(statusEffect: wref<StatusEffect_Record>, isApplied: Bool) -> Void {
    this.OnChanged(!isApplied);
  }
}

public class StatusEffectAbsentPrereq extends StatusEffectPrereq {

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    this.OnRegister(state, game, context);
    return false;
  }

  protected func Initialize(recordID: TweakDBID) -> Void {
    let record: ref<StatusEffectPrereq_Record> = TweakDBInterface.GetStatusEffectPrereqRecord(recordID);
    this.m_statusEffectRecordID = record.StatusEffect().GetID();
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let statusEffectSystem: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(game);
    let owner: ref<GameObject> = context as GameObject;
    return !statusEffectSystem.HasStatusEffect(owner.GetEntityID(), this.m_statusEffectRecordID);
  }

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let owner: wref<GameObject> = context as GameObject;
    let result: Bool = StatusEffectSystem.ObjectHasStatusEffect(owner, this.m_statusEffectRecordID);
    state.OnChanged(!result);
  }
}
