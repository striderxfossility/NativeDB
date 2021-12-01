
public class NPCHitReactionTypePrereq extends IScriptablePrereq {

  public let m_hitReactionType: animHitReactionType;

  public let m_invert: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".hitReactionType", "");
    this.m_hitReactionType = IntEnum(Cast(EnumValueFromString("animHitReactionType", str)));
    this.m_invert = TweakDBInterface.GetBool(recordID + t".invert", false);
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let castedState: ref<NPCHitReactionTypePrereqState>;
    let puppet: ref<ScriptedPuppet> = context as ScriptedPuppet;
    if IsDefined(puppet) {
      castedState = state as NPCHitReactionTypePrereqState;
      castedState.m_listener = new PuppetListener();
      castedState.m_listener.RegisterOwner(castedState);
      ScriptedPuppet.AddListener(puppet, castedState.m_listener);
      return false;
    };
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let puppet: ref<ScriptedPuppet> = context as ScriptedPuppet;
    let castedState: ref<NPCHitReactionTypePrereqState> = state as NPCHitReactionTypePrereqState;
    if IsDefined(puppet) && IsDefined(castedState.m_listener) {
      ScriptedPuppet.RemoveListener(puppet, castedState.m_listener);
    };
    castedState.m_listener = null;
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject> = context as GameObject;
    let targetPuppet: ref<ScriptedPuppet> = owner as ScriptedPuppet;
    let hitReactionComponent: ref<HitReactionComponent> = targetPuppet.GetHitReactionComponent();
    if !IsDefined(targetPuppet) {
      return false;
    };
    return this.EvaluateCondition(hitReactionComponent.GetHitReactionData().hitType);
  }

  public final const func EvaluateCondition(hitType: Int32) -> Bool {
    if hitType != EnumInt(this.m_hitReactionType) {
      return this.m_invert ? true : false;
    };
    return this.m_invert ? false : true;
  }
}
