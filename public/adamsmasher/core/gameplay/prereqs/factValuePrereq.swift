
public class FactValuePrereqState extends PrereqState {

  public let m_listenerID: Uint32;

  public final func OnFactChanged(factValue: Int32) -> Void {
    let prereq: ref<FactValuePrereq> = this.GetPrereq() as FactValuePrereq;
    this.OnChanged(prereq.Evaluate(factValue));
  }
}

public class FactValuePrereq extends IScriptablePrereq {

  public let m_fact: CName;

  public let m_value: Int32;

  public let m_comparisonType: EComparisonType;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_fact = TweakDBInterface.GetCName(recordID + t".fact", n"");
    this.m_value = TweakDBInterface.GetInt(recordID + t".value", 0);
    let compType: CName = TweakDBInterface.GetCName(recordID + t".comparisonType", n"");
    this.m_comparisonType = IntEnum(Cast(EnumValueFromName(n"EComparisonType", compType)));
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let castedState: ref<FactValuePrereqState>;
    if IsNameValid(this.m_fact) {
      castedState = state as FactValuePrereqState;
      castedState.m_listenerID = GameInstance.GetQuestsSystem(game).RegisterListener(this.m_fact, castedState, n"OnFactChanged");
    };
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<FactValuePrereqState>;
    if IsNameValid(this.m_fact) {
      castedState = state as FactValuePrereqState;
      GameInstance.GetQuestsSystem(game).UnregisterListener(this.m_fact, castedState.m_listenerID);
    };
  }

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<FactValuePrereqState> = state as FactValuePrereqState;
    castedState.OnChanged(this.IsFulfilled(game, context));
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let result: Bool = false;
    if IsNameValid(this.m_fact) {
      result = this.Evaluate(GameInstance.GetQuestsSystem(game).GetFact(this.m_fact));
    };
    return result;
  }

  public final const func Evaluate(value: Int32) -> Bool {
    return ProcessCompare(this.m_comparisonType, Cast(value), Cast(this.m_value));
  }
}
