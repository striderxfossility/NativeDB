
public class NPCInitTask extends AIbehaviortaskStackScript {

  @default(NPCInitTask, true)
  public edit let m_preventSkippingDeathAnimation: Bool;

  public final func OnActivate(context: ScriptExecutionContext) -> Void {
    let puppet: ref<NPCPuppet>;
    this.SendSetScriptExecutionContextEvent(context);
    if this.NPCWasDeadOnInit(context) {
      ScriptExecutionContext.SetArgumentBool(context, n"WasDeadOnInit", true);
      NPCPuppet.ChangeHighLevelState(ScriptExecutionContext.GetOwner(context), gamedataNPCHighLevelState.Dead);
      puppet = AIBehaviorScriptBase.GetNPCPuppet(context);
      if IsDefined(puppet) {
        if this.m_preventSkippingDeathAnimation {
          puppet.SetSkipDeathAnimation(false);
        };
      };
      puppet.DisableCollision();
      this.SendSignal(context, n"downed", n"death", EAIGateSignalFlags.AIGSF_OverridesSelf, 10.00);
    } else {
      if this.NPCWasAlertedOnInit(context) {
        this.SendSignal(context, n"autonomous", n"alerted", EAIGateSignalFlags.AIGSF_Undefined, 3.00);
      } else {
        NPCPuppet.ChangeHighLevelState(ScriptExecutionContext.GetOwner(context), gamedataNPCHighLevelState.Relaxed);
      };
    };
  }

  private final func NPCWasDeadOnInit(context: script_ref<ScriptExecutionContext>) -> Bool {
    if GameInstance.GetStatPoolsSystem(ScriptExecutionContext.GetOwner(Deref(context)).GetGame()).HasStatPoolValueReachedMin(Cast(ScriptExecutionContext.GetOwner(Deref(context)).GetEntityID()), gamedataStatPoolType.Health) {
      if StatusEffectSystem.ObjectHasStatusEffect(ScriptExecutionContext.GetOwner(Deref(context)), t"WorkspotStatus.Death") {
        return false;
      };
      return true;
    };
    if this.HasHLS(context, gamedataNPCHighLevelState.Dead) {
      return true;
    };
    return false;
  }

  private final func NPCWasAlertedOnInit(context: script_ref<ScriptExecutionContext>) -> Bool {
    return ScriptExecutionContext.GetArgumentBool(Deref(context), n"IsInAlerted");
  }

  private final func HasHLS(context: script_ref<ScriptExecutionContext>, state: gamedataNPCHighLevelState) -> Bool {
    return Equals(state, IntEnum(AIBehaviorScriptBase.GetPuppet(Deref(context)).GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.HighLevel)));
  }

  private final func SendSignal(context: script_ref<ScriptExecutionContext>, tag1: CName, tag2: CName, flag: EAIGateSignalFlags, priority: Float) -> Void {
    let signal: AIGateSignal;
    let signalId: Uint32;
    signal.priority = priority;
    signal.lifeTime = 0.50;
    AIGateSignal.AddTag(signal, tag1);
    AIGateSignal.AddTag(signal, tag2);
    if NotEquals(flag, EAIGateSignalFlags.AIGSF_Undefined) {
      AIGateSignal.AddFlag(signal, Cast(flag));
    };
    signalId = AIBehaviorScriptBase.GetPuppet(Deref(context)).GetSignalHandlerComponent().AddSignal(signal);
    AIBehaviorScriptBase.GetPuppet(Deref(context)).GetSignalHandlerComponent().RemoveSignal(signalId);
  }

  private final func SendSetScriptExecutionContextEvent(context: script_ref<ScriptExecutionContext>) -> Void {
    let evnt: ref<SetScriptExecutionContextEvent> = new SetScriptExecutionContextEvent();
    evnt.scriptExecutionContext = Deref(context);
    ScriptExecutionContext.GetOwner(Deref(context)).QueueEvent(evnt);
  }
}
