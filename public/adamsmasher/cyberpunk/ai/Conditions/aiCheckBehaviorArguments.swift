
public abstract class CheckArguments extends AIbehaviorconditionScript {

  public edit let m_argumentVar: CName;

  public func GetDescription(context: ScriptExecutionContext) -> String {
    return this.GetDescription(context) + " " + ToString(this.m_argumentVar);
  }
}

public class CheckArgumentBoolean extends CheckArguments {

  public edit let m_customVar: Bool;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast(Equals(ScriptExecutionContext.GetArgumentBool(context, this.m_argumentVar), this.m_customVar));
  }
}

public class CheckArgumentInt extends CheckArguments {

  public edit let m_customVar: Int32;

  public edit let m_comparator: ECompareOp;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast(Compare(this.m_comparator, ScriptExecutionContext.GetArgumentInt(context, this.m_argumentVar), this.m_customVar));
  }
}

public class CheckArgumentFloat extends CheckArguments {

  public edit let m_customVar: Float;

  public edit let m_comparator: ECompareOp;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast(CompareF(this.m_comparator, ScriptExecutionContext.GetArgumentFloat(context, this.m_argumentVar), this.m_customVar));
  }
}

public class CheckArgumentName extends CheckArguments {

  public edit let m_customVar: CName;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast(Equals(ScriptExecutionContext.GetArgumentName(context, this.m_argumentVar), this.m_customVar));
  }
}

public class CheckArgumentObjectSet extends CheckArguments {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast(ScriptExecutionContext.GetArgumentObject(context, this.m_argumentVar) != null);
  }
}
