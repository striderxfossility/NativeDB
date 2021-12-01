
public class UsingCoverPSMPrereqState extends PlayerStateMachinePrereqState {

  public let bValue: Bool;

  protected cb func OnStateUpdateBool(value: Bool) -> Bool {
    let checkPassed: Bool;
    let prereq: ref<UsingCoverPSMPrereq> = this.GetPrereq() as UsingCoverPSMPrereq;
    if NotEquals(this.bValue, value) {
      checkPassed = prereq.Evaluate(this.m_owner, value);
      this.OnChanged(checkPassed);
    };
    this.bValue = value;
  }
}

public class UsingCoverPSMPrereq extends PlayerStateMachinePrereq {

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(game).GetLocalInstanced((context as ScriptedPuppet).GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    let castedState: ref<UsingCoverPSMPrereqState> = state as UsingCoverPSMPrereqState;
    if IsDefined(castedState) {
      castedState.m_owner = context as GameObject;
      if IsDefined(bb) {
        castedState.m_listenerInt = bb.RegisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.UsingCover, castedState, n"OnStateUpdateBool");
      };
    };
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let bb: ref<IBlackboard>;
    let castedState: ref<UsingCoverPSMPrereqState> = state as UsingCoverPSMPrereqState;
    if IsDefined(castedState) {
      bb = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().PlayerStateMachine);
      if IsDefined(bb) {
        bb.UnregisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.UsingCover, castedState.m_listenerInt);
      };
    };
  }

  protected const func GetStateMachineEnum() -> String {
    return "";
  }

  protected const func GetCurrentPSMStateIndex(bb: ref<IBlackboard>) -> Int32 {
    let b: Bool = bb.GetBool(GetAllBlackboardDefs().PlayerStateMachine.UsingCover);
    if b {
      return 1;
    };
    return 0;
  }

  protected func Initialize(recordID: TweakDBID) -> Void {
    let b: Bool = TweakDBInterface.GetBool(recordID + t".isInState", true);
    if b {
      this.m_valueToListen = 1;
    } else {
      this.m_valueToListen = 0;
    };
  }

  public final const func Evaluate(owner: ref<GameObject>, value: Bool) -> Bool {
    let b: Bool = this.m_valueToListen == 0 ? false : true;
    let checkPassed: Bool = Equals(value, b);
    return checkPassed;
  }
}
