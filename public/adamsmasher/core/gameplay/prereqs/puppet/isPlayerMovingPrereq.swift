
public class IsPlayerMovingPrereqState extends PlayerStateMachinePrereqState {

  public let bbValue: Bool;

  protected cb func OnStateUpdateBool(value: Bool) -> Bool {
    let checkPassed: Bool;
    let prereq: ref<IsPlayerMovingPrereq> = this.GetPrereq() as IsPlayerMovingPrereq;
    if NotEquals(this.bbValue, value) {
      checkPassed = prereq.Evaluate(this.m_owner, value);
      this.OnChanged(checkPassed);
    };
    this.bbValue = value;
  }
}

public class IsPlayerMovingPrereq extends PlayerStateMachinePrereq {

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(game).GetLocalInstanced((context as ScriptedPuppet).GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    let castedState: ref<IsPlayerMovingPrereqState> = state as IsPlayerMovingPrereqState;
    castedState.m_owner = context as GameObject;
    castedState.m_listenerInt = bb.RegisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.IsMovingHorizontally, castedState, n"OnStateUpdateBool");
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<IsPlayerMovingPrereqState> = state as IsPlayerMovingPrereqState;
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(game).GetLocalInstanced((context as ScriptedPuppet).GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    bb.UnregisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.IsMovingHorizontally, castedState.m_listenerInt);
  }

  protected const func GetStateMachineEnum() -> String {
    return "";
  }

  protected const func GetCurrentPSMStateIndex(bb: ref<IBlackboard>) -> Int32 {
    let b: Bool = bb.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsMovingHorizontally);
    if b {
      return 1;
    };
    return 0;
  }

  protected func Initialize(recordID: TweakDBID) -> Void {
    let b: Bool = TweakDBInterface.GetBool(recordID + t".isMoving", true);
    if b {
      this.m_valueToListen = 1;
    } else {
      this.m_valueToListen = 0;
    };
    this.Initialize(recordID);
  }

  public final const func Evaluate(owner: ref<GameObject>, value: Bool) -> Bool {
    let b: Bool = this.m_valueToListen == 0 ? false : true;
    let checkPassed: Bool = Equals(value, b);
    return checkPassed;
  }
}
