
public class ZonesPSMPrereq extends PlayerStateMachinePrereq {

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(game).GetLocalInstanced((context as ScriptedPuppet).GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    let castedState: ref<ZonesPSMPrereqState> = state as ZonesPSMPrereqState;
    castedState.m_owner = context as GameObject;
    castedState.m_prevValue = bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Zones);
    castedState.m_listenerInt = bb.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Zones, castedState, n"OnStateUpdate");
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(game).GetLocalInstanced((context as ScriptedPuppet).GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    let castedState: ref<ZonesPSMPrereqState> = state as ZonesPSMPrereqState;
    bb.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Zones, castedState.m_listenerInt);
  }

  protected const func GetStateMachineEnum() -> String {
    return "gamePSMZones";
  }

  protected const func GetCurrentPSMStateIndex(bb: ref<IBlackboard>) -> Int32 {
    return bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Zones);
  }
}
