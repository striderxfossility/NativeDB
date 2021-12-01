
public class TemporalPrereqDelayCallback extends DelayCallback {

  protected let m_state: wref<TemporalPrereqState>;

  public func Call() -> Void {
    this.m_state.CallbackRecall();
  }

  public final func RegisterState(state: ref<PrereqState>) -> Void {
    this.m_state = state as TemporalPrereqState;
  }
}

public class TemporalPrereqState extends PrereqState {

  public let m_delaySystem: ref<DelaySystem>;

  public let m_callback: ref<TemporalPrereqDelayCallback>;

  public let m_lapsedTime: Float;

  public let m_delayID: DelayID;

  public func RegisterDealyCallback(delayTime: Float) -> Void {
    this.m_delayID = this.m_delaySystem.DelayCallback(this.m_callback, delayTime);
  }

  public func CallbackRecall() -> Void {
    let prereq: ref<TemporalPrereq> = this.GetPrereq() as TemporalPrereq;
    let newState: Bool = this.m_lapsedTime >= prereq.m_totalDuration;
    this.OnChanged(newState);
    this.m_lapsedTime += prereq.m_totalDuration;
    if !this.IsFulfilled() {
      this.RegisterDealyCallback(prereq.m_totalDuration);
    };
  }
}

public class TemporalPrereq extends IScriptablePrereq {

  public let m_totalDuration: Float;

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let castedState: ref<TemporalPrereqState> = state as TemporalPrereqState;
    castedState.m_delaySystem = GameInstance.GetDelaySystem(game);
    castedState.m_callback = new TemporalPrereqDelayCallback();
    castedState.m_callback.RegisterState(castedState);
    castedState.m_lapsedTime = 0.00;
    castedState.RegisterDealyCallback(0.00);
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<TemporalPrereqState> = state as TemporalPrereqState;
    GameInstance.GetDelaySystem(game).CancelCallback(castedState.m_delayID);
    castedState.m_callback = null;
  }

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_totalDuration = TweakDBInterface.GetFloat(recordID + t".duration", 0.00);
    let randRange: Float = TweakDBInterface.GetFloat(recordID + t".randRange", 0.00);
    if randRange > 0.00 {
      this.m_totalDuration = RandRangeF(this.m_totalDuration - randRange, this.m_totalDuration + randRange);
    };
  }
}

public class PlayerVehicleStatePrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let bboard: ref<IBlackboard>;
    let playerVehState: Bool;
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
    if IsDefined(playerPuppet) {
      bboard = GameInstance.GetBlackboardSystem(game).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
      playerVehState = bboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle) == 0;
    } else {
      playerVehState = true;
    };
    return playerVehState;
  }
}
