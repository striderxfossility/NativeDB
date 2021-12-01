
public class FallPSMPrereq extends PlayerStateMachinePrereq {

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(game).GetLocalInstanced((context as ScriptedPuppet).GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    let castedState: ref<FallPSMPrereqState> = state as FallPSMPrereqState;
    castedState.m_owner = context as GameObject;
    castedState.m_prevValue = bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Fall);
    castedState.m_listenerInt = bb.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Fall, castedState, n"OnStateUpdate");
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(game).GetLocalInstanced((context as ScriptedPuppet).GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    let castedState: ref<FallPSMPrereqState> = state as FallPSMPrereqState;
    bb.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Fall, castedState.m_listenerInt);
  }

  protected const func GetStateMachineEnum() -> String {
    return "gamePSMFallStates";
  }

  protected const func GetCurrentPSMStateIndex(bb: ref<IBlackboard>) -> Int32 {
    return bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Fall);
  }
}
