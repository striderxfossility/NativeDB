
public class StatPoolSpentPrereqListener extends BaseStatPoolPrereqListener {

  protected let m_state: wref<StatPoolSpentPrereqState>;

  protected let m_overallSpentValue: Float;

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    let spent: Float = oldValue * percToPoints - newValue * percToPoints;
    if spent > 0.00 {
      this.m_overallSpentValue += spent;
      if this.m_overallSpentValue >= this.m_state.GetThreshold() {
        this.m_state.OnChangedRepeated();
        this.m_overallSpentValue = 0.00;
      };
    };
  }

  public func RegisterState(state: ref<PrereqState>) -> Void {
    this.m_state = state as StatPoolSpentPrereqState;
  }
}

public class StatPoolSpentPrereqState extends PrereqState {

  public let m_neededValue: Float;

  public let m_listener: ref<BaseStatPoolPrereqListener>;

  public final const func GetThreshold() -> Float {
    return this.m_neededValue;
  }

  public final func SetThreshold(v: Float) -> Void {
    this.m_neededValue = v;
  }
}

public class StatPoolSpentPrereq extends IScriptablePrereq {

  public let m_statPoolType: gamedataStatPoolType;

  public let m_valueToCheck: Float;

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject> = context as GameObject;
    let castedState: ref<StatPoolSpentPrereqState> = state as StatPoolSpentPrereqState;
    castedState.SetThreshold(this.m_valueToCheck);
    castedState.m_listener = new StatPoolSpentPrereqListener();
    castedState.m_listener.RegisterState(castedState);
    castedState.m_listener.SetValue(this.m_valueToCheck);
    GameInstance.GetStatPoolsSystem(game).RequestRegisteringListener(Cast(owner.GetEntityID()), this.m_statPoolType, castedState.m_listener);
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let owner: ref<GameObject> = context as GameObject;
    let castedState: ref<StatPoolSpentPrereqState> = state as StatPoolSpentPrereqState;
    GameInstance.GetStatPoolsSystem(game).RequestUnregisteringListener(Cast(owner.GetEntityID()), this.m_statPoolType, castedState.m_listener);
    castedState.m_listener = null;
  }

  protected func Initialize(recordID: TweakDBID) -> Void {
    let record: ref<StatPoolPrereq_Record> = TweakDBInterface.GetStatPoolPrereqRecord(recordID);
    this.m_statPoolType = IntEnum(Cast(EnumValueFromName(n"gamedataStatPoolType", record.StatPoolType())));
    this.m_valueToCheck = record.ValueToCheck();
  }
}
