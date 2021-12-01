
public class AISetCombatPresetTask extends AIbehaviortaskScript {

  public inline edit let m_inCommand: ref<AIArgumentMapping>;

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let rawCommand: ref<IScriptable>;
    let typedCommand: ref<AISetCombatPresetCommand>;
    if !IsDefined(this.m_inCommand) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    rawCommand = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    typedCommand = rawCommand as AISetCombatPresetCommand;
    if !IsDefined(typedCommand) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !this.RemovePresets(ScriptExecutionContext.GetOwner(context)) {
      this.CancelCommand(context, typedCommand);
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    switch typedCommand.combatPreset {
      case EAICombatPreset.IsReckless:
        RPGManager.ApplyAbility(ScriptExecutionContext.GetOwner(context), TweakDBInterface.GetGameplayAbilityRecord(t"Ability.IsReckless"));
        break;
      case EAICombatPreset.IsAggressive:
        RPGManager.ApplyAbility(ScriptExecutionContext.GetOwner(context), TweakDBInterface.GetGameplayAbilityRecord(t"Ability.IsAggressive"));
        break;
      case EAICombatPreset.IsBalanced:
        RPGManager.ApplyAbility(ScriptExecutionContext.GetOwner(context), TweakDBInterface.GetGameplayAbilityRecord(t"Ability.IsBalanced"));
        break;
      case EAICombatPreset.IsDefensive:
        RPGManager.ApplyAbility(ScriptExecutionContext.GetOwner(context), TweakDBInterface.GetGameplayAbilityRecord(t"Ability.IsDefensive"));
        break;
      case EAICombatPreset.IsCautious:
        RPGManager.ApplyAbility(ScriptExecutionContext.GetOwner(context), TweakDBInterface.GetGameplayAbilityRecord(t"Ability.IsCautious"));
        break;
      default:
    };
    ScriptedPuppet.SendActionSignal(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, n"InterruptCoverSelection", 0.50);
    return AIbehaviorUpdateOutcome.SUCCESS;
  }

  protected final func RemovePresets(owner: wref<GameObject>) -> Bool {
    if !IsDefined(owner) {
      return false;
    };
    RPGManager.RemoveAbility(owner, TweakDBInterface.GetGameplayAbilityRecord(t"Ability.IsReckless"));
    RPGManager.RemoveAbility(owner, TweakDBInterface.GetGameplayAbilityRecord(t"Ability.IsAggressive"));
    RPGManager.RemoveAbility(owner, TweakDBInterface.GetGameplayAbilityRecord(t"Ability.IsBalanced"));
    RPGManager.RemoveAbility(owner, TweakDBInterface.GetGameplayAbilityRecord(t"Ability.IsDefensive"));
    RPGManager.RemoveAbility(owner, TweakDBInterface.GetGameplayAbilityRecord(t"Ability.IsCautious"));
    return true;
  }

  protected final func CancelCommand(context: ScriptExecutionContext, typedCommand: ref<AISetCombatPresetCommand>) -> Void {
    if IsDefined(typedCommand) && Equals(typedCommand.state, AICommandState.Executing) {
      AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().StopExecutingCommand(typedCommand, false);
    };
    ScriptExecutionContext.SetMappingValue(context, this.m_inCommand, ToVariant(null));
  }
}
