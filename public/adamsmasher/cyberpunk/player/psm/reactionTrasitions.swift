
public abstract class ReactionTransition extends DefaultTransition {

  protected final func DrawDebugText(scriptInterface: ref<StateGameScriptInterface>, out textLayerId: Uint32, text: String) -> Void {
    textLayerId = GameInstance.GetDebugVisualizerSystem(scriptInterface.owner.GetGame()).DrawText(new Vector4(500.00, 550.00, 0.00, 0.00), text, gameDebugViewETextAlignment.Left, new Color(255u, 255u, 0u, 255u));
    GameInstance.GetDebugVisualizerSystem(scriptInterface.owner.GetGame()).SetScale(textLayerId, new Vector4(1.00, 1.00, 0.00, 0.00));
  }

  protected final func ClearDebugText(scriptInterface: ref<StateGameScriptInterface>, textLayerId: Uint32) -> Void {
    GameInstance.GetDebugVisualizerSystem(scriptInterface.owner.GetGame()).ClearLayer(textLayerId);
  }
}

public class StaggerDecisions extends ReactionTransition {

  public let m_textLayerId: Uint32;

  public final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return GameInstance.GetStatusEffectSystem(scriptInterface.owner.GetGame()).HasStatusEffect(scriptInterface.ownerEntityID, t"BaseStatusEffect.Stunned");
  }

  public final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !GameInstance.GetStatusEffectSystem(scriptInterface.owner.GetGame()).HasStatusEffect(scriptInterface.ownerEntityID, t"BaseStatusEffect.Stunned");
  }
}

public class Stagger extends ReactionTransition {

  public let m_textLayerId: Uint32;

  protected final func AddImpulse(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let ev: ref<PSMImpulse>;
    let impulseDir: Vector4;
    let direction: Vector4 = scriptInterface.GetOwnerMovingDirection();
    direction.Z = 0.00;
    direction *= -1.00;
    impulseDir = direction * this.GetStaticFloatParameterDefault("moveBackImpulse", 10.00);
    ev = new PSMImpulse();
    ev.id = n"impulse";
    ev.impulse = impulseDir;
    scriptInterface.executionOwner.QueueEvent(ev);
  }

  public final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.AddImpulse(scriptInterface);
    this.StartEffect(scriptInterface, n"skif_buff");
    scriptInterface.SetAnimationParameterFloat(n"hit_strength", 1.00);
    scriptInterface.PushAnimationEvent(n"StaggerHit");
    this.DrawDebugText(scriptInterface, this.m_textLayerId, "PLAYER STAGGER");
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Reaction, EnumInt(gamePSMReaction.Stagger));
  }

  public final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ClearDebugText(scriptInterface, this.m_textLayerId);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Reaction, EnumInt(gamePSMReaction.Default));
  }
}
