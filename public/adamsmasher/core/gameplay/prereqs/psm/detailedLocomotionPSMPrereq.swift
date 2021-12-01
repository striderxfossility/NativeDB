
public class DetailedLocomotionPSMPrereq extends PlayerStateMachinePrereq {

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(game).GetLocalInstanced((context as ScriptedPuppet).GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    let castedState: ref<DetailedLocomotionPSMPrereqState> = state as DetailedLocomotionPSMPrereqState;
    castedState.m_owner = context as GameObject;
    if !IsDefined(bb) {
      return false;
    };
    castedState.m_prevValue = bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LocomotionDetailed);
    castedState.m_listenerInt = bb.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.LocomotionDetailed, castedState, n"OnStateUpdate");
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let bb: ref<IBlackboard>;
    let castedState: ref<DetailedLocomotionPSMPrereqState> = state as DetailedLocomotionPSMPrereqState;
    if IsDefined(castedState) {
      bb = GameInstance.GetBlackboardSystem(game).GetLocalInstanced((context as ScriptedPuppet).GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
      if IsDefined(bb) {
        bb.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.LocomotionDetailed, castedState.m_listenerInt);
      };
    };
  }

  protected const func GetStateMachineEnum() -> String {
    return "gamePSMDetailedLocomotionStates";
  }

  protected const func GetCurrentPSMStateIndex(bb: ref<IBlackboard>) -> Int32 {
    return bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LocomotionDetailed);
  }
}
