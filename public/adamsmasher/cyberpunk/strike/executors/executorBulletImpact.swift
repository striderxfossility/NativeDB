
public native class gameEffectExecutor_BulletImpact extends EffectExecutor {

  public final func ShouldProcessImpactOnEntity(ctx: EffectScriptContext, isMeleeAttack: Bool, target: ref<Entity>, hitPosition: Vector4, hitDirection: Vector4) -> Bool {
    let statsSystem: ref<StatsSystem>;
    if isMeleeAttack {
      if DamageManager.IsValidDirectionToDefendMeleeAttack(EffectScriptContext.GetInstigator(ctx).GetWorldForward(), target.GetWorldForward()) {
        statsSystem = GameInstance.GetStatsSystem(EffectScriptContext.GetGameInstance(ctx));
        if statsSystem.GetStatValue(Cast(target.GetEntityID()), gamedataStatType.IsBlocking) == 1.00 || statsSystem.GetStatValue(Cast(target.GetEntityID()), gamedataStatType.IsDeflecting) == 1.00 {
          return false;
        };
      };
    };
    return true;
  }
}
