
public class BaseStatPoolPrereqListener extends CustomValueStatPoolsListener {

  public func RegisterState(state: ref<PrereqState>) -> Void;
}

public class StatPoolPrereqListener extends BaseStatPoolPrereqListener {

  protected let m_state: wref<StatPoolPrereqState>;

  protected cb func OnStatPoolValueReached(oldValue: Float, newValue: Float, percToPoints: Float) -> Bool {
    this.m_state.StatPoolUpdate(oldValue, newValue);
  }

  public func RegisterState(state: ref<PrereqState>) -> Void {
    this.m_state = state as StatPoolPrereqState;
  }
}

public class StatPoolPrereqState extends PrereqState {

  public let m_listener: ref<BaseStatPoolPrereqListener>;

  public func StatPoolUpdate(oldValue: Float, newValue: Float) -> Void {
    let prereq: ref<StatPoolPrereq> = this.GetPrereq() as StatPoolPrereq;
    let checkPassed: Bool = ProcessCompare(prereq.m_comparisonType, newValue, prereq.m_valueToCheck);
    this.OnChanged(checkPassed);
  }
}

public class StatPoolPrereq extends IScriptablePrereq {

  public let m_statPoolType: gamedataStatPoolType;

  public let m_valueToCheck: Float;

  public let m_comparisonType: EComparisonType;

  public let m_skipOnApply: Bool;

  public let m_comparePercentage: Bool;

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject> = context as GameObject;
    let castedState: ref<StatPoolPrereqState> = state as StatPoolPrereqState;
    castedState.m_listener = new StatPoolPrereqListener();
    castedState.m_listener.RegisterState(castedState);
    castedState.m_listener.SetValue(this.m_valueToCheck);
    GameInstance.GetStatPoolsSystem(game).RequestRegisteringListener(Cast(owner.GetEntityID()), this.m_statPoolType, castedState.m_listener);
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let owner: ref<GameObject> = context as GameObject;
    let castedState: ref<StatPoolPrereqState> = state as StatPoolPrereqState;
    GameInstance.GetStatPoolsSystem(game).RequestUnregisteringListener(Cast(owner.GetEntityID()), this.m_statPoolType, castedState.m_listener);
    castedState.m_listener = null;
  }

  protected func Initialize(recordID: TweakDBID) -> Void {
    let record: ref<StatPoolPrereq_Record> = TweakDBInterface.GetStatPoolPrereqRecord(recordID);
    this.m_statPoolType = IntEnum(Cast(EnumValueFromName(n"gamedataStatPoolType", record.StatPoolType())));
    this.m_valueToCheck = record.ValueToCheck();
    this.m_comparisonType = IntEnum(Cast(EnumValueFromName(n"EComparisonType", record.ComparisonType())));
    this.m_skipOnApply = TweakDBInterface.GetBool(recordID + t".skipOnApply", false);
    this.m_comparePercentage = TweakDBInterface.GetBool(recordID + t".comparePercentage", true);
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    return this.CompareValues(context);
  }

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<StatPoolPrereqState>;
    let result: Bool;
    let owner: wref<GameObject> = context as GameObject;
    if this.m_skipOnApply {
      return;
    };
    if GameInstance.GetStatPoolsSystem(game).IsStatPoolAdded(Cast(owner.GetEntityID()), this.m_statPoolType) {
      result = this.CompareValues(context);
      castedState = state as StatPoolPrereqState;
      castedState.OnChanged(result);
    };
  }

  private final const func CompareValues(context: ref<IScriptable>) -> Bool {
    let currentValue: Float;
    let owner: wref<GameObject> = context as GameObject;
    if IsDefined(owner) {
      currentValue = GameInstance.GetStatPoolsSystem(owner.GetGame()).GetStatPoolValue(Cast(owner.GetEntityID()), this.m_statPoolType, this.m_comparePercentage);
      return ProcessCompare(this.m_comparisonType, currentValue, this.m_valueToCheck);
    };
    return false;
  }
}
