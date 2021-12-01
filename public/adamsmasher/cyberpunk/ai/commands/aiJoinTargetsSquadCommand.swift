
public class AIJoinTargetsSquadTask extends AIbehaviortaskScript {

  public inline edit let m_inCommand: ref<AIArgumentMapping>;

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let rawCommand: ref<IScriptable>;
    let smc: ref<SquadMemberBaseComponent>;
    let squadName: CName;
    let ssi: ref<SquadScriptInterface>;
    let target: wref<GameObject>;
    let typedCommand: ref<AIJoinTargetsSquad>;
    if !IsDefined(this.m_inCommand) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    rawCommand = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    typedCommand = rawCommand as AIJoinTargetsSquad;
    if !IsDefined(typedCommand) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !GetGameObjectFromEntityReference(typedCommand.targetPuppetRef, ScriptExecutionContext.GetOwner(context).GetGame(), target) {
      this.CancelCommand(context, typedCommand);
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    smc = target.GetSquadMemberComponent();
    if !IsDefined(smc) {
      this.CancelCommand(context, typedCommand);
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    squadName = smc.MySquadNameCurrentOrRecent(AISquadType.Combat);
    if !IsNameValid(squadName) {
      this.CancelCommand(context, typedCommand);
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    ssi = smc.FindSquad(squadName);
    if !IsDefined(ssi) {
      this.CancelCommand(context, typedCommand);
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if ssi.Join(ScriptExecutionContext.GetOwner(context)) {
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    this.CancelCommand(context, typedCommand);
    return AIbehaviorUpdateOutcome.FAILURE;
  }

  protected final func CancelCommand(context: ScriptExecutionContext, typedCommand: ref<AIJoinTargetsSquad>) -> Void {
    if IsDefined(typedCommand) && Equals(typedCommand.state, AICommandState.Executing) {
      AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().StopExecutingCommand(typedCommand, false);
    };
    ScriptExecutionContext.SetMappingValue(context, this.m_inCommand, ToVariant(null));
  }
}
