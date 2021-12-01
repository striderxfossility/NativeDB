
public abstract class SetArguments extends AIbehaviortaskScript {

  public edit let m_argumentVar: CName;

  public func GetDescription(context: ScriptExecutionContext) -> String {
    return this.GetEditorSubCaption();
  }

  public func GetEditorSubCaption() -> String {
    return "Set " + ToString(this.m_argumentVar);
  }
}

public class SetArgumentBoolean extends SetArguments {

  public edit let m_customVar: Bool;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.SetArgumentBool(context, this.m_argumentVar, this.m_customVar);
  }

  public func GetEditorSubCaption() -> String {
    return "Set " + ToString(this.m_argumentVar) + " To " + this.m_customVar ? "TRUE" : "FALSE";
  }
}

public class SetArgumentInt extends SetArguments {

  public edit let m_customVar: Int32;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.SetArgumentInt(context, this.m_argumentVar, this.m_customVar);
  }

  public func GetEditorSubCaption() -> String {
    return "Set " + ToString(this.m_argumentVar) + " To " + ToString(this.m_customVar);
  }
}

public class SetArgumentFloat extends SetArguments {

  public edit let m_customVar: Float;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.SetArgumentFloat(context, this.m_argumentVar, this.m_customVar);
  }

  public func GetEditorSubCaption() -> String {
    return "Set " + ToString(this.m_argumentVar) + " To " + ToString(this.m_customVar);
  }
}

public class SetArgumentName extends SetArguments {

  public edit let m_customVar: CName;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.SetArgumentName(context, this.m_argumentVar, this.m_customVar);
  }

  public func GetEditorSubCaption() -> String {
    return "Set " + ToString(this.m_argumentVar) + " To " + ToString(this.m_customVar);
  }
}

public class SetArgumentVector extends SetArguments {

  public inline edit let m_newValue: ref<AIArgumentMapping>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let newValue: Vector4 = FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_newValue));
    ScriptExecutionContext.SetArgumentVector(context, this.m_argumentVar, newValue);
  }
}

public class ClearArgumentObject extends SetArguments {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.SetArgumentObject(context, this.m_argumentVar, null);
  }

  public func GetEditorSubCaption() -> String {
    return "Clear " + ToString(this.m_argumentVar);
  }
}
