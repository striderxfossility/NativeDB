
public class SetSearchInfluenceTask extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let puppet: wref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    GameInstance.GetInfluenceMapSystem(puppet.GetGame()).SetSearchValueSquad(puppet.GetWorldPosition(), 15.00, puppet);
  }
}
