
public native class AIbehaviortaskStackScript extends AIBehaviorScriptBase {

  public func GetInstanceTypeName() -> CName {
    return n"";
  }
}

public class TestStackScript extends AIbehaviortaskStackScript {

  public func GetInstanceTypeName() -> CName {
    return n"script_ref:TestStackScriptData";
  }

  public final func OnActivate(context: ScriptExecutionContext, data: script_ref<TestStackScriptData>) -> Void {
    Deref(data).testVar = 1337;
    Deref(data).anotherVar = n"mySuperName";
  }

  public final func OnDeactivate(context: ScriptExecutionContext, data: script_ref<TestStackScriptData>) -> Void {
    Deref(data).testVar = 0;
    Deref(data).anotherVar = n"";
  }

  public final func OnUpdate(context: ScriptExecutionContext, data: script_ref<TestStackScriptData>) -> AIbehaviorUpdateOutcome {
    Deref(data).testVar += 1;
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final func GetDescription(data: script_ref<TestStackScriptData>) -> String {
    return NameToString(Deref(data).anotherVar) + ToString(Deref(data).testVar);
  }
}

public class TestStackPassiveExpression extends AIbehaviorStackScriptPassiveExpressionDefinition {

  public edit let SomeNameProperty: CName;

  public final func CalculateValue(context: ScriptExecutionContext, data: script_ref<TestStackScriptData>) -> Variant {
    return ToVariant(true);
  }
}
