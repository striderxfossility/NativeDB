
public class GameTimePrereqState extends PrereqState {

  public let m_listener: Uint32;

  public func UpdatePrereq() -> Void {
    this.OnChanged(true);
  }
}

public class GameTimePrereq extends IScriptablePrereq {

  public let m_delay: Float;

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let castedState: ref<GameTimePrereqState> = state as GameTimePrereqState;
    let evt: ref<DelayPrereqEvent> = new DelayPrereqEvent();
    evt.m_state = castedState;
    castedState.m_listener = GameInstance.GetTimeSystem(game).RegisterDelayedListener(context as GameObject, evt, GameInstance.GetTimeSystem(game).RealTimeSecondsToGameTime(this.m_delay), 1, false);
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    GameInstance.GetTimeSystem(game).UnregisterListener(state as GameTimePrereqState.m_listener);
  }

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_delay = TweakDBInterface.GetFloat(recordID + t".delay", 0.00);
  }
}
