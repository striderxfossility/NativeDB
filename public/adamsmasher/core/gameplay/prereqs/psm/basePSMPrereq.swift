
public class PlayerStateMachinePrereqState extends PrereqState {

  public let m_owner: wref<GameObject>;

  public let m_listenerInt: ref<CallbackHandle>;

  public let m_prevValue: Int32;

  protected cb func OnStateUpdate(value: Int32) -> Bool {
    let prereq: ref<PlayerStateMachinePrereq> = this.GetPrereq() as PlayerStateMachinePrereq;
    let checkPassed: Bool = prereq.Evaluate(this.m_owner, value, this.m_prevValue);
    this.m_prevValue = value;
    this.OnChanged(checkPassed);
  }
}

public class PlayerStateMachinePrereq extends IScriptablePrereq {

  private let m_previousState: Bool;

  private let m_isInState: Bool;

  @default(IsPlayerMovingPrereq, true)
  @default(UsingCoverPSMPrereq, true)
  private let m_skipWhenApplied: Bool;

  public let m_valueToListen: Int32;

  public const func Evaluate(owner: ref<GameObject>, newValue: Int32, prevValue: Int32) -> Bool {
    if this.m_previousState {
      if newValue != this.m_valueToListen && prevValue == this.m_valueToListen {
        return true;
      };
    } else {
      if this.m_isInState {
        if newValue == this.m_valueToListen {
          return true;
        };
      } else {
        if newValue != this.m_valueToListen {
          return true;
        };
      };
    };
    return false;
  }

  protected func Initialize(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".stateName", "");
    this.m_valueToListen = Cast(EnumValueFromString(this.GetStateMachineEnum(), str));
    this.m_previousState = TweakDBInterface.GetBool(recordID + t".previousState", false);
    this.m_isInState = TweakDBInterface.GetBool(recordID + t".isInState", false);
    this.m_skipWhenApplied = TweakDBInterface.GetBool(recordID + t".skipWhenApplied", false);
  }

  protected const func GetStateMachineEnum() -> String {
    return "";
  }

  protected const func GetCurrentPSMStateIndex(bb: ref<IBlackboard>) -> Int32 {
    return 0;
  }

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<PlayerStateMachinePrereqState>;
    let owner: wref<GameObject>;
    if this.m_skipWhenApplied {
      return;
    };
    owner = context as GameObject;
    if IsDefined(owner) {
      castedState = state as PlayerStateMachinePrereqState;
      castedState.OnChanged(this.IsFulfilled(owner.GetGame(), context));
    };
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let checkPassed: Bool;
    let owner: wref<GameObject> = context as GameObject;
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(owner.GetGame()).GetLocalInstanced((context as ScriptedPuppet).GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    if !IsDefined(bb) {
      return false;
    };
    checkPassed = this.Evaluate(owner, this.GetCurrentPSMStateIndex(bb), this.GetCurrentPSMStateIndex(bb));
    return checkPassed;
  }
}
