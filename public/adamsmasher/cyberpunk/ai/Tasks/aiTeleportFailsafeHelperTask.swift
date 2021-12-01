
public class TeleportFailsafeHelper extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let puppet: wref<ScriptedPuppet>;
    ScriptExecutionContext.DebugLog(context, n"Locomotion", "Failsafe teleportation");
    puppet = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    ScriptExecutionContext.SetArgumentVector(context, n"TeleportDestination", puppet.GetMovePolicesComponent().GetDestination());
  }
}
