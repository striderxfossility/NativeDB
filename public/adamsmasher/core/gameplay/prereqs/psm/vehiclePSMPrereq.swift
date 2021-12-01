
public class VehiclePSMPrereq extends PlayerStateMachinePrereq {

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(game).GetLocalInstanced((context as ScriptedPuppet).GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    let castedState: ref<VehiclePSMPrereqState> = state as VehiclePSMPrereqState;
    castedState.m_owner = context as GameObject;
    if IsDefined(bb) {
      castedState.m_prevValue = bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle);
      castedState.m_listenerInt = bb.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle, castedState, n"OnStateUpdate");
    };
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let bb: ref<IBlackboard>;
    let castedState: ref<VehiclePSMPrereqState> = state as VehiclePSMPrereqState;
    if IsDefined(castedState) {
      bb = GameInstance.GetBlackboardSystem(game).GetLocalInstanced((context as ScriptedPuppet).GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
      if IsDefined(bb) {
        bb.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle, castedState.m_listenerInt);
      };
    };
  }

  protected const func GetStateMachineEnum() -> String {
    return "gamePSMVehicle";
  }

  protected const func GetCurrentPSMStateIndex(bb: ref<IBlackboard>) -> Int32 {
    return bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle);
  }
}
