
public class UseWorkspotCommandDelegate extends ScriptBehaviorDelegate {

  public inline edit let m_inCommand: ref<AIArgumentMapping>;

  public let movementType: moveMovementType;

  public final func DoSetupUseWorkspotCommand(context: ScriptExecutionContext) -> Bool {
    let rawCommand: ref<IScriptable>;
    let typedCommand: ref<AIBaseUseWorkspotCommand>;
    if IsDefined(this.m_inCommand) {
      rawCommand = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
      typedCommand = rawCommand as AIBaseUseWorkspotCommand;
    };
    if !IsDefined(typedCommand) {
      return false;
    };
    this.movementType = typedCommand.movementType;
    return true;
  }

  public final func DoCleanUp() -> Bool {
    return true;
  }
}
