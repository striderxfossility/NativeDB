
public class StatusEffectPrereqListener extends ScriptStatusEffectListener {

  protected let m_state: wref<StatusEffectPrereqState>;

  public func OnStatusEffectApplied(statusEffect: wref<StatusEffect_Record>) -> Void {
    let statusEffectPrereq: ref<StatusEffectPrereq>;
    if IsDefined(this.m_state) {
      statusEffectPrereq = this.m_state.GetPrereq() as StatusEffectPrereq;
      if IsDefined(statusEffectPrereq) && statusEffectPrereq.Evaluate(statusEffect) {
        this.m_state.StatusEffectUpdate(statusEffect, true);
      };
    };
  }

  public func OnStatusEffectRemoved(statusEffect: wref<StatusEffect_Record>) -> Void {
    let statusEffectPrereq: ref<StatusEffectPrereq>;
    if IsDefined(this.m_state) {
      statusEffectPrereq = this.m_state.GetPrereq() as StatusEffectPrereq;
      if IsDefined(statusEffectPrereq) && statusEffectPrereq.Evaluate(statusEffect) {
        this.m_state.StatusEffectUpdate(statusEffect, false);
      };
    };
  }

  public final func RegisterState(state: ref<PrereqState>) -> Void {
    this.m_state = state as StatusEffectPrereqState;
  }
}

public class StatusEffectPrereqState extends PrereqState {

  public let m_listener: ref<StatusEffectPrereqListener>;

  public func StatusEffectUpdate(statusEffect: wref<StatusEffect_Record>, isApplied: Bool) -> Void {
    this.OnChanged(isApplied);
  }
}

public class StatusEffectPrereq extends IScriptablePrereq {

  @attrib(customEditor, "TweakDBGroupInheritance;StatusEffect")
  public edit let m_statusEffectRecordID: TweakDBID;

  public let m_tag: CName;

  public let m_checkType: String;

  public let m_invert: Bool;

  public let m_fireAndForget: Bool;

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject> = context as GameObject;
    let castedState: ref<StatusEffectPrereqState> = state as StatusEffectPrereqState;
    castedState.m_listener = new StatusEffectPrereqListener();
    castedState.m_listener.RegisterState(castedState);
    GameInstance.GetStatusEffectSystem(game).RegisterListener(owner.GetEntityID(), castedState.m_listener);
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<StatusEffectPrereqState> = state as StatusEffectPrereqState;
    castedState.m_listener = null;
  }

  protected func Initialize(recordID: TweakDBID) -> Void {
    let record: ref<StatusEffectPrereq_Record> = TweakDBInterface.GetStatusEffectPrereqRecord(recordID);
    this.m_statusEffectRecordID = record.StatusEffect().GetID();
    this.m_tag = TweakDBInterface.GetCName(recordID + t".tagToCheck", n"");
    this.m_checkType = TweakDBInterface.GetString(recordID + t".checkType", "");
    this.m_invert = record.Invert();
    this.m_fireAndForget = TweakDBInterface.GetBool(recordID + t".fireAndForget", false);
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let result: Bool;
    let statusEffectSystem: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(game);
    let owner: ref<GameObject> = context as GameObject;
    switch this.m_checkType {
      case "TAG":
        result = statusEffectSystem.HasStatusEffectWithTag(owner.GetEntityID(), this.m_tag);
        break;
      case "TYPE":
        result = StatusEffectSystem.ObjectHasStatusEffectOfType(owner, TweakDBInterface.GetStatusEffectRecord(this.m_statusEffectRecordID).StatusEffectType().Type());
        break;
      case "RECORD":
        result = statusEffectSystem.HasStatusEffect(owner.GetEntityID(), this.m_statusEffectRecordID);
        break;
      default:
        result = statusEffectSystem.HasStatusEffect(owner.GetEntityID(), this.m_statusEffectRecordID);
    };
    if this.m_invert {
      return !result;
    };
    return result;
  }

  public const func Evaluate(statusEffect: wref<StatusEffect_Record>) -> Bool {
    switch this.m_checkType {
      case "TAG":
        return StatusEffectHelper.HasTag(statusEffect, this.m_tag);
      case "TYPE":
        return Equals(TweakDBInterface.GetStatusEffectRecord(this.m_statusEffectRecordID).StatusEffectType().Type(), statusEffect.StatusEffectType().Type());
      case "RECORD":
      default:
        return this.m_statusEffectRecordID == statusEffect.GetID();
    };
  }

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let result: Bool = this.IsFulfilled(game, context);
    let castedState: ref<StatusEffectPrereqState> = state as StatusEffectPrereqState;
    castedState.OnChanged(result);
  }
}
