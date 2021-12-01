
public class CacheAnimationForPotentialRagdoll extends RagdollTask {

  public edit let m_currentBehavior: CName;

  protected func Activate(context: ScriptExecutionContext) -> Void;

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    ScriptedPuppet.SendActionSignal(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, this.m_currentBehavior, 1.00);
  }
}

public class ForceRagdoll extends RagdollTask {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.GetOwner(context).QueueEvent(CreateForceRagdollEvent(n"ForceRagdollTask"));
  }
}
