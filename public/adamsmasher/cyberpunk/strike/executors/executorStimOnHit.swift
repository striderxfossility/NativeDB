
public class GameEffectExecutor_StimOnHit extends EffectExecutor_Scripted {

  public edit let stimType: gamedataStimType;

  public edit let silentStimType: gamedataStimType;

  public edit const let suppressedByStimTypes: array<gamedataStimType>;

  private final func CreateStim(ctx: EffectScriptContext, stimuliType: gamedataStimType, position: Vector4, radius: Float) -> Bool {
    let stimInfo: StimuliMergeInfo;
    let stimSystem: ref<StimuliSystem> = GameInstance.GetStimuliSystem(EffectScriptContext.GetGameInstance(ctx));
    let stimRecord: ref<Stim_Record> = stimSystem.GetStimRecord(stimuliType);
    if radius <= 0.00 {
      radius = stimRecord.Radius();
    };
    stimInfo.position = position;
    stimInfo.instigator = EffectScriptContext.GetInstigator(ctx) as GameObject;
    stimInfo.radius = radius;
    stimInfo.type = stimuliType;
    stimInfo.propagationType = gamedataStimPropagation.Audio;
    stimSystem.BroadcastMergeableStimuli(stimInfo, this.suppressedByStimTypes);
    return true;
  }

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let weapon: ref<WeaponObject>;
    let position: Vector4 = EffectExecutionScriptContext.GetHitPosition(applierCtx);
    if !Vector4.IsZero(position) && !this.IsMuted(ctx, applierCtx) {
      if GameInstance.GetStatsSystem(EffectScriptContext.GetGameInstance(ctx)).GetStatValue(Cast(EffectScriptContext.GetWeapon(ctx).GetEntityID()), gamedataStatType.CanSilentKill) > 0.00 {
        if !this.CreateStim(ctx, this.silentStimType, position, -1.00) {
          return false;
        };
        weapon = EffectScriptContext.GetWeapon(ctx) as WeaponObject;
        if IsDefined(weapon) && Equals(WeaponObject.GetWeaponType(weapon.GetItemID()), gamedataItemType.Wea_SniperRifle) {
          if !this.CreateStim(ctx, this.stimType, position, 5.00) {
            return false;
          };
        };
      } else {
        if !this.CreateStim(ctx, this.stimType, position, -1.00) {
          return false;
        };
        if !this.CreateStim(ctx, this.silentStimType, position, 20.00) {
          return false;
        };
      };
      return true;
    };
    return false;
  }

  private final func IsMuted(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let sourceMuted: Bool = GameInstance.GetStatusEffectSystem(EffectScriptContext.GetGameInstance(ctx)).HasStatusEffect(EffectScriptContext.GetSource(ctx).GetEntityID(), t"BaseStatusEffect.PersonalSoundSilencerPlayerBuff");
    return sourceMuted;
  }
}
