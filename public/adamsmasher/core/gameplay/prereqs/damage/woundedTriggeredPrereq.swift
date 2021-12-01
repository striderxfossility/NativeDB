
public class WoundedTriggeredPrereqState extends PrereqState {

  public let m_owner: wref<GameObject>;

  public let m_listenerInt: ref<CallbackHandle>;

  protected cb func OnStateUpdate(value: Uint32) -> Bool {
    let prereq: ref<WoundedTriggeredPrereq> = this.GetPrereq() as WoundedTriggeredPrereq;
    let checkPassed: Bool = prereq.Evaluate(this.m_owner, value);
    this.OnChanged(checkPassed);
  }
}

public class WoundedTriggeredPrereq extends IScriptablePrereq {

  @default(WoundedTriggeredPrereq, 0)
  public let m_currValue: Uint32;

  public final const func Evaluate(owner: ref<GameObject>, value: Uint32) -> Bool {
    let checkPassed: Bool = value != this.m_currValue;
    return checkPassed;
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let bb: ref<IBlackboard>;
    let castedState: ref<WoundedTriggeredPrereqState> = state as WoundedTriggeredPrereqState;
    castedState.m_owner = context as GameObject;
    let player: wref<PlayerPuppet> = context as PlayerPuppet;
    if IsDefined(player) {
      bb = GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().PlayerPerkData);
      castedState.m_listenerInt = bb.RegisterListenerUint(GetAllBlackboardDefs().PlayerPerkData.WoundedInstigated, castedState, n"OnStateUpdate");
    };
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let bb: ref<IBlackboard>;
    let castedState: ref<WoundedTriggeredPrereqState>;
    let player: wref<PlayerPuppet> = context as PlayerPuppet;
    if IsDefined(player) {
      bb = GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().PlayerPerkData);
      castedState = state as WoundedTriggeredPrereqState;
      bb.UnregisterListenerUint(GetAllBlackboardDefs().PlayerPerkData.WoundedInstigated, castedState.m_listenerInt);
    };
  }

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let bb: ref<IBlackboard>;
    let castedState: ref<WoundedTriggeredPrereqState>;
    let player: wref<PlayerPuppet> = context as PlayerPuppet;
    if IsDefined(player) {
      bb = GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().PlayerPerkData);
      castedState = state as WoundedTriggeredPrereqState;
      castedState.OnChanged(this.Evaluate(player, bb.GetUint(GetAllBlackboardDefs().PlayerPerkData.WoundedInstigated)));
    };
  }
}
