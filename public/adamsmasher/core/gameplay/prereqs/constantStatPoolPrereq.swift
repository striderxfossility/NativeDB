
public class ConstantStatPoolPrereqListener extends BaseStatPoolPrereqListener {

  protected let m_state: wref<ConstantStatPoolPrereqState>;

  protected cb func OnStatPoolValueReached(oldValue: Float, newValue: Float, percToPoints: Float) -> Bool {
    this.m_state.StatPoolUpdate(oldValue, newValue);
  }

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    if this.m_state.m_listenConstantly {
      this.m_state.StatPoolConstantUpdate(oldValue, newValue);
    };
  }

  public func RegisterState(state: ref<PrereqState>) -> Void {
    this.m_state = state as ConstantStatPoolPrereqState;
  }
}

public class ConstantStatPoolPrereqState extends StatPoolPrereqState {

  public let m_listenConstantly: Bool;

  public let m_owner: wref<GameObject>;

  public final func StatPoolConstantUpdate(oldValue: Float, newValue: Float) -> Void {
    let checkPassed: Bool;
    let currentState: Bool;
    let fillCells: Int32;
    let fillCellsFloat: Float;
    let maxCells: Int32;
    let prereq: ref<ConstantStatPoolPrereq> = this.GetPrereq() as ConstantStatPoolPrereq;
    if Equals(prereq.m_statPoolType, gamedataStatPoolType.Memory) && !prereq.m_comparePercentage {
      maxCells = FloorF(GameInstance.GetStatsSystem(this.m_owner.GetGame()).GetStatValue(Cast(GameInstance.GetPlayerSystem(this.m_owner.GetGame()).GetLocalPlayerControlledGameObject().GetEntityID()), gamedataStatType.Memory));
      fillCellsFloat = Cast(maxCells) * newValue * 0.01;
      fillCells = RoundF(fillCellsFloat);
      newValue = Cast(fillCells);
    };
    checkPassed = ProcessCompare(prereq.m_comparisonType, newValue, prereq.m_valueToCheck);
    currentState = this.IsFulfilled();
    if NotEquals(currentState, checkPassed) {
      this.OnChanged(checkPassed);
    };
  }
}

public class ConstantStatPoolPrereq extends StatPoolPrereq {

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject> = context as GameObject;
    let castedState: ref<ConstantStatPoolPrereqState> = state as ConstantStatPoolPrereqState;
    castedState.m_listener = new ConstantStatPoolPrereqListener();
    castedState.m_listenConstantly = true;
    castedState.m_owner = owner;
    castedState.m_listener.RegisterState(castedState);
    castedState.m_listener.SetValue(this.m_valueToCheck);
    GameInstance.GetStatPoolsSystem(game).RequestRegisteringListener(Cast(owner.GetEntityID()), this.m_statPoolType, castedState.m_listener);
    return false;
  }
}
