
public class StatPrereqListener extends ScriptStatsListener {

  protected let m_state: wref<StatPrereqState>;

  public func OnStatChanged(ownerID: StatsObjectID, statType: gamedataStatType, diff: Float, total: Float) -> Void {
    this.m_state.StatUpdate(diff, total);
  }

  public final func RegisterState(state: ref<PrereqState>) -> Void {
    this.m_state = state as StatPrereqState;
  }
}

public class StatPrereqState extends PrereqState {

  public let m_listener: ref<StatPrereqListener>;

  public func StatUpdate(diff: Float, total: Float) -> Void {
    let prereq: ref<StatPrereq> = this.GetPrereq() as StatPrereq;
    let checkPassed: Bool = ProcessCompare(prereq.m_comparisonType, total, prereq.m_valueToCheck);
    if prereq.m_fireAndForget {
      this.OnChangedRepeated(false);
    } else {
      this.OnChanged(checkPassed);
    };
  }
}

public class StatPrereq extends IScriptablePrereq {

  public let m_fireAndForget: Bool;

  public edit let m_statType: gamedataStatType;

  public edit let m_valueToCheck: Float;

  public edit let m_comparisonType: EComparisonType;

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject> = context as GameObject;
    let castedState: ref<StatPrereqState> = state as StatPrereqState;
    castedState.m_listener = new StatPrereqListener();
    castedState.m_listener.RegisterState(castedState);
    castedState.m_listener.SetStatType(this.m_statType);
    GameInstance.GetStatsSystem(game).RegisterListener(Cast(owner.GetEntityID()), castedState.m_listener);
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let owner: ref<GameObject> = context as GameObject;
    let castedState: ref<StatPrereqState> = state as StatPrereqState;
    GameInstance.GetStatsSystem(game).UnregisterListener(Cast(owner.GetEntityID()), castedState.m_listener);
    castedState.m_listener = null;
  }

  protected func Initialize(recordID: TweakDBID) -> Void {
    let record: ref<StatPrereq_Record> = TweakDBInterface.GetStatPrereqRecord(recordID);
    this.m_statType = IntEnum(Cast(EnumValueFromName(n"gamedataStatType", record.StatType())));
    this.m_valueToCheck = record.ValueToCheck();
    this.m_comparisonType = IntEnum(Cast(EnumValueFromName(n"EComparisonType", record.ComparisonType())));
    this.m_fireAndForget = TweakDBInterface.GetBool(recordID + t".fireAndForget", false);
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject> = context as GameObject;
    let currentValue: Float = GameInstance.GetStatsSystem(game).GetStatValue(Cast(owner.GetEntityID()), this.m_statType);
    return ProcessCompare(this.m_comparisonType, currentValue, this.m_valueToCheck);
  }

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let owner: wref<GameObject> = context as GameObject;
    let castedState: ref<StatPrereqState> = state as StatPrereqState;
    let statValue: Float = GameInstance.GetStatsSystem(owner.GetGame()).GetStatValue(Cast((context as Entity).GetEntityID()), this.m_statType);
    castedState.StatUpdate(0.00, statValue);
  }
}
