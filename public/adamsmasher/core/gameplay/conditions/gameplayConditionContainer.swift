
public class GameplayConditionContainer extends IScriptable {

  protected let m_logicOperator: ELogicOperator;

  protected inline const let m_conditionGroups: array<ConditionGroupData>;

  public final func Evaluate(requester: ref<GameObject>) -> Bool {
    let i: Int32;
    let passed: Bool;
    if Equals(this.m_logicOperator, ELogicOperator.AND) {
      passed = true;
    };
    i = 0;
    while i < this.GetGroupsAmount() {
      if this.Evaluate(requester, this.m_conditionGroups[i]) {
        if Equals(this.m_logicOperator, ELogicOperator.OR) {
          passed = true;
        } else {
        };
      } else {
        if Equals(this.m_logicOperator, ELogicOperator.AND) {
          passed = false;
        } else {
          i += 1;
        };
      };
    };
    return passed;
  }

  private final func Evaluate(requester: ref<GameObject>, group: ConditionGroupData) -> Bool {
    let i: Int32;
    let passed: Bool;
    if Equals(group.logicOperator, ELogicOperator.AND) {
      passed = true;
    };
    i = 0;
    while i < ArraySize(group.conditions) {
      if group.conditions[i].Evaluate(requester) {
        if Equals(group.logicOperator, ELogicOperator.OR) {
          passed = true;
        } else {
        };
      } else {
        if Equals(group.logicOperator, ELogicOperator.AND) {
          passed = false;
        } else {
          i += 1;
        };
      };
    };
    return passed;
  }

  public final func CreateDescription(obj: ref<GameObject>, entID: EntityID) -> array<ConditionData> {
    let conditionText: Condition;
    let description: array<ConditionData>;
    let groupCondition: ConditionData;
    let k: Int32;
    let i: Int32 = 0;
    while i < this.GetGroupsAmount() {
      groupCondition.conditionOperator = this.m_conditionGroups[i].logicOperator;
      ArrayClear(groupCondition.requirementList);
      k = 0;
      while k < ArraySize(this.m_conditionGroups[i].conditions) {
        this.m_conditionGroups[i].conditions[k].SetEntityID(entID);
        conditionText = this.m_conditionGroups[i].conditions[k].GetDescription(obj);
        ArrayPush(groupCondition.requirementList, conditionText);
        k += 1;
      };
      ArrayPush(description, groupCondition);
      i += 1;
    };
    return description;
  }

  public final const func HasAdditionalRequirements() -> Bool {
    if this.GetGroupsAmount() > 0 {
      return true;
    };
    return false;
  }

  public final const func GetOperator() -> ELogicOperator {
    return this.m_logicOperator;
  }

  public final const func GetGroupsAmount() -> Int32 {
    return ArraySize(this.m_conditionGroups);
  }
}
