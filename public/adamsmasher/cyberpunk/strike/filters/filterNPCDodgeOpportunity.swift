
public class FilterNPCDodgeOpportunity extends EffectObjectGroupFilter_Scripted {

  @default(FilterNPCDodgeOpportunity, false)
  private edit let m_applyToTechWeapons: Bool;

  @default(FilterNPCDodgeOpportunity, true)
  private edit let m_doDodgingTargetsGetFilteredOut: Bool;

  public final func Process(ctx: EffectScriptContext, out filterCtx: EffectGroupFilterScriptContext) -> Bool {
    let aiHumanComponent: ref<AIHumanComponent>;
    let dodged: Bool;
    let dodgingIndices: array<Int32>;
    let gameInstance: GameInstance;
    let i: Int32;
    let instigatorPuppet: ref<ScriptedPuppet>;
    let newResults: array<Int32>;
    let numAgents: Int32;
    let targetNPC: ref<NPCPuppet>;
    let weapon: ref<WeaponObject>;
    let instigator: ref<GameObject> = EffectScriptContext.GetInstigator(ctx) as GameObject;
    if !IsDefined(instigator) {
      return true;
    };
    weapon = EffectScriptContext.GetWeapon(ctx) as WeaponObject;
    if !this.m_applyToTechWeapons && Equals(weapon.GetWeaponRecord().Evolution().Type(), gamedataWeaponEvolution.Tech) {
      return true;
    };
    numAgents = EffectGroupFilterScriptContext.GetNumAgents(filterCtx);
    gameInstance = EffectScriptContext.GetGameInstance(ctx);
    i = 0;
    while i < numAgents {
      targetNPC = EffectGroupFilterScriptContext.GetEntity(filterCtx, i) as NPCPuppet;
      if IsDefined(targetNPC) {
        aiHumanComponent = targetNPC.GetAIControllerComponent();
        if IsDefined(aiHumanComponent) {
          dodged = false;
          if IsDefined(instigator as PlayerPuppet) {
            if GameInstance.GetTargetingSystem(gameInstance).IsVisibleTarget(instigator, targetNPC) {
              dodged = aiHumanComponent.TryBulletDodgeOpportunity() && !GameInstance.GetTimeSystem(gameInstance).IsTimeDilationActive();
            };
          } else {
            if GameInstance.GetSenseManager(gameInstance).IsObjectVisible(instigator.GetEntityID(), targetNPC.GetEntityID()) && NotEquals(GameObject.GetAttitudeBetween(instigator, targetNPC), EAIAttitude.AIA_Friendly) {
              instigatorPuppet = instigator as ScriptedPuppet;
              dodged = aiHumanComponent.TryBulletDodgeOpportunity() && !instigatorPuppet.HasIndividualTimeDilation();
            };
          };
          if dodged && this.m_doDodgingTargetsGetFilteredOut {
            ArrayPush(dodgingIndices, i);
          };
        };
      };
      i = i + 1;
    };
    if ArraySize(dodgingIndices) > 0 {
      i = 0;
      while i < numAgents {
        if !ArrayContains(dodgingIndices, i) {
          ArrayPush(newResults, i);
        };
        i = i + 1;
      };
      filterCtx.resultIndices = newResults;
    };
    return true;
  }
}
