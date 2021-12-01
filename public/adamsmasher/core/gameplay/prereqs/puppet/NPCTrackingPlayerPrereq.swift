
public class NPCTrackingPlayerPrereq extends IScriptablePrereq {

  public let m_invert: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_invert = TweakDBInterface.GetBool(recordID + t".invert", false);
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let castedState: ref<NPCTrackingPlayerPrereqState>;
    let npcOwner: ref<NPCPuppet> = context as NPCPuppet;
    if IsDefined(npcOwner) {
      castedState = state as NPCTrackingPlayerPrereqState;
      castedState.m_listener = new PuppetListener();
      castedState.m_listener.RegisterOwner(castedState);
      ScriptedPuppet.AddListener(npcOwner, castedState.m_listener);
      return false;
    };
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let npcOwner: ref<NPCPuppet> = context as NPCPuppet;
    let castedState: ref<NPCTrackingPlayerPrereqState> = state as NPCTrackingPlayerPrereqState;
    if IsDefined(npcOwner) && IsDefined(castedState.m_listener) {
      ScriptedPuppet.RemoveListener(npcOwner, castedState.m_listener);
    };
    castedState.m_listener = null;
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject> = context as GameObject;
    let targetNPC: wref<NPCPuppet> = owner as NPCPuppet;
    return this.EvaluateCondition(targetNPC.IsPuppetTargetingPlayer());
  }

  public final const func EvaluateCondition(isTrackingPlayer: Bool) -> Bool {
    if !isTrackingPlayer {
      return this.m_invert ? true : false;
    };
    return this.m_invert ? false : true;
  }
}

public class NPCDetectingPlayerPrereqState extends PrereqState {

  public let m_owner: wref<GameObject>;

  public let m_listenerID: ref<CallbackHandle>;

  protected cb func OnStateUpdate(value: Float) -> Bool {
    let prereq: ref<NPCDetectingPlayerPrereq> = this.GetPrereq() as NPCDetectingPlayerPrereq;
    let checkPassed: Bool = prereq.Evaluate(this.m_owner, value);
    this.OnChanged(checkPassed);
  }
}

public class NPCDetectingPlayerPrereq extends IScriptablePrereq {

  public let m_threshold: Float;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_threshold = TweakDBInterface.GetFloat(recordID + t".percentage", 0.00);
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let bb: ref<IBlackboard> = (context as ScriptedPuppet).GetPuppetStateBlackboard();
    let castedState: ref<NPCDetectingPlayerPrereqState> = state as NPCDetectingPlayerPrereqState;
    castedState.m_owner = context as GameObject;
    castedState.m_listenerID = bb.RegisterListenerFloat(GetAllBlackboardDefs().PuppetState.DetectionPercentage, castedState, n"OnStateUpdate");
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<NPCDetectingPlayerPrereqState> = state as NPCDetectingPlayerPrereqState;
    if IsDefined(castedState.m_listenerID) {
      (context as ScriptedPuppet).GetPuppetStateBlackboard().UnregisterListenerFloat(GetAllBlackboardDefs().PuppetState.DetectionPercentage, castedState.m_listenerID);
    };
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject> = context as GameObject;
    let targetNPC: wref<NPCPuppet> = owner as NPCPuppet;
    if targetNPC.GetDetectionPercentage() > this.m_threshold {
      return true;
    };
    return false;
  }

  public final const func Evaluate(owner: ref<GameObject>, percentage: Float) -> Bool {
    if this.m_threshold == 0.00 {
      if percentage > 0.00 {
        return true;
      };
    } else {
      if percentage >= this.m_threshold {
        return true;
      };
    };
    return false;
  }
}
