
public class TestBehaviorDelegate extends ScriptBehaviorDelegate {

  public edit let integer: Int32;

  public edit let floatValue: Float;

  public edit const let names: array<CName>;

  public inline edit let command: ref<AICommand>;

  public edit let newProperty2: Bool;

  public edit let newProperty: Bool;

  public edit let newProperty3: Bool;

  public edit let newProperty4: Bool;

  public edit let nodeRef: NodeRef;

  public final func GetGetterValue() -> CName {
    return n"getterValue";
  }

  public final func GetSomethingElse() -> NodeRef {
    return this.nodeRef;
  }

  public final func IsSomething() -> Bool {
    return false;
  }

  public final func TestTask(context: ScriptExecutionContext) -> Void;

  public final func TaskFoo(context: ScriptExecutionContext) -> Void;

  public final func TaskBar() -> Bool {
    return true;
  }
}

public class ActionWeightCondition extends AIbehaviorconditionScript {

  public inline edit let selectedActionIndex: ref<AIArgumentMapping>;

  public edit let thisIndex: Int32;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    if this.thisIndex == FromVariant(ScriptExecutionContext.GetMappingValue(context, this.selectedActionIndex)) {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class ActionWeightManagerDelegate extends ScriptBehaviorDelegate {

  public edit const let actionsConditions: array<CName>;

  public let actionsWeights: array<Int32>;

  public let lowestWeight: Int32;

  public let selectedActionIndex: Int32;

  public final func ProcessActionToPlay(context: ScriptExecutionContext) -> Bool {
    let i: Int32;
    if ArraySize(this.actionsWeights) == 0 && ArraySize(this.actionsConditions) != 0 {
      ArrayResize(this.actionsWeights, ArraySize(this.actionsConditions));
    };
    this.lowestWeight = 999;
    this.selectedActionIndex = 999;
    i = 0;
    while i < ArraySize(this.actionsConditions) {
      if (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().CheckTweakCondition(NameToString(this.actionsConditions[i])) && (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().CheckTweakCondition("MeleeBaseCondition") {
        if this.actionsWeights[i] <= this.lowestWeight {
          this.selectedActionIndex = i;
          this.lowestWeight = this.actionsWeights[i];
        };
      };
      i += 1;
    };
    if this.selectedActionIndex == 999 {
    };
    return true;
  }

  public final func WeightUpdate() -> Bool {
    this.actionsWeights[this.selectedActionIndex] += 1;
    return true;
  }
}
