
public class SendEquipWeaponCommand extends AIbehaviortaskScript {

  public edit let m_secondary: Bool;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let cmd: ref<AICommand>;
    if this.m_secondary {
      cmd = new AISwitchToSecondaryWeaponCommand();
    } else {
      cmd = new AISwitchToPrimaryWeaponCommand();
    };
    AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().SendCommand(cmd);
  }
}
