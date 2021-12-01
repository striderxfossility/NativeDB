
public class PlayerCombatStateTimePrereqState extends PrereqState {

  public let m_owner: wref<GameObject>;

  public let m_listener: ref<CallbackHandle>;

  protected cb func OnStateUpdate(value: Float) -> Bool {
    let prereq: ref<PlayerCombatStateTimePrereq> = this.GetPrereq() as PlayerCombatStateTimePrereq;
    let checkPassed: Bool = prereq.Evaluate(this.m_owner, value);
    this.OnChanged(checkPassed);
  }
}

public class PlayerCombatStateTimePrereq extends IScriptablePrereq {

  @default(PlayerCombatStateTimePrereq, -1.f)
  private let m_minTime: Float;

  @default(PlayerCombatStateTimePrereq, -1.f)
  private let m_maxTime: Float;

  public final const func Evaluate(owner: ref<GameObject>, value: Float) -> Bool {
    let minCheck: Bool = false;
    let maxCheck: Bool = false;
    minCheck = this.m_minTime < 0.00 || value >= this.m_minTime;
    maxCheck = this.m_maxTime < 0.00 || value < this.m_maxTime;
    return minCheck && maxCheck;
  }

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_minTime = TweakDBInterface.GetFloat(recordID + t".minTime", -1.00);
    this.m_maxTime = TweakDBInterface.GetFloat(recordID + t".maxTime", -1.00);
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let bb: ref<IBlackboard>;
    let castedState: ref<PlayerCombatStateTimePrereqState> = state as PlayerCombatStateTimePrereqState;
    castedState.m_owner = context as GameObject;
    let player: wref<PlayerPuppet> = context as PlayerPuppet;
    if IsDefined(player) {
      bb = GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().PlayerPerkData);
      castedState.m_listener = bb.RegisterListenerFloat(GetAllBlackboardDefs().PlayerPerkData.CombatStateTime, castedState, n"OnStateUpdate");
    };
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let bb: ref<IBlackboard>;
    let castedState: ref<PlayerCombatStateTimePrereqState>;
    let player: wref<PlayerPuppet> = context as PlayerPuppet;
    if IsDefined(player) {
      bb = GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().PlayerPerkData);
      castedState = state as PlayerCombatStateTimePrereqState;
      bb.UnregisterListenerFloat(GetAllBlackboardDefs().PlayerPerkData.CombatStateTime, castedState.m_listener);
    };
  }

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<PlayerCombatStateTimePrereqState>;
    let player: wref<PlayerPuppet> = context as PlayerPuppet;
    if IsDefined(player) {
      castedState = state as PlayerCombatStateTimePrereqState;
      castedState.OnChanged(this.IsFulfilled(player.GetGame(), context));
    };
  }

  protected const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let player: wref<PlayerPuppet> = context as PlayerPuppet;
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().PlayerPerkData);
    let checkPassed: Bool = this.Evaluate(player, bb.GetFloat(GetAllBlackboardDefs().PlayerPerkData.CombatStateTime));
    return checkPassed;
  }
}
