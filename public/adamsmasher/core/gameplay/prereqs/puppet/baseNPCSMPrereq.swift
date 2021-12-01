
public class NPCStatePrereqState extends PrereqState {

  public let m_owner: wref<GameObject>;

  public let m_listenerInt: ref<CallbackHandle>;

  public let m_prevValue: Int32;

  protected cb func OnStateUpdate(value: Int32) -> Bool {
    let prereq: ref<NPCStatePrereq> = this.GetPrereq() as NPCStatePrereq;
    let checkPassed: Bool = prereq.Evaluate(this.m_owner, value, this.m_prevValue);
    this.m_prevValue = value;
    this.OnChanged(checkPassed);
  }
}

public class NPCStatePrereq extends IScriptablePrereq {

  private let m_previousState: Bool;

  private let m_isInState: Bool;

  private let m_skipWhenApplied: Bool;

  public final const func Evaluate(owner: ref<GameObject>, newValue: Int32, prevValue: Int32) -> Bool {
    let stateToCheck: Int32 = this.GetStateToCheck();
    if this.m_previousState {
      if newValue != stateToCheck && prevValue == stateToCheck {
        return true;
      };
    } else {
      if this.m_isInState {
        if newValue == stateToCheck {
          return true;
        };
      } else {
        if newValue != stateToCheck {
          return true;
        };
      };
    };
    return false;
  }

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_previousState = TweakDBInterface.GetBool(recordID + t".previousState", false);
    this.m_isInState = TweakDBInterface.GetBool(recordID + t".isInState", false);
    this.m_skipWhenApplied = TweakDBInterface.GetBool(recordID + t".skipWhenApplied", false);
  }

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<NPCStatePrereqState>;
    let owner: wref<GameObject>;
    if this.m_skipWhenApplied {
      return;
    };
    owner = context as GameObject;
    if IsDefined(owner) {
      castedState = state as NPCStatePrereqState;
      castedState.OnChanged(this.Evaluate(owner, castedState.m_prevValue, castedState.m_prevValue));
    };
  }

  protected final const func GetStateName(recordID: TweakDBID) -> String {
    return TweakDBInterface.GetString(recordID + t".stateName", "");
  }

  protected const func GetStateToCheck() -> Int32 {
    return -1;
  }
}
