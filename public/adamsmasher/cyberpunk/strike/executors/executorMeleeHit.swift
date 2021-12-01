
public class MeleeHitAnimEventExecutor extends EffectExecutor_Scripted {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let isCleavingHit: Bool;
    let meleeHitEvent: ref<MeleeHitEvent>;
    let target: ref<Entity> = EffectExecutionScriptContext.GetTarget(applierCtx);
    let targetID: EntityID = target.GetEntityID();
    let statSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(GetGameInstance());
    let instigatorEntity: ref<Entity> = EffectScriptContext.GetInstigator(ctx);
    let instigatorEntityID: EntityID = instigatorEntity.GetEntityID();
    EffectData.GetBool(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.meleeCleave, isCleavingHit);
    meleeHitEvent = new MeleeHitEvent();
    meleeHitEvent.instigator = instigatorEntity as GameObject;
    meleeHitEvent.target = target as GameObject;
    meleeHitEvent.isStrongAttack = isCleavingHit;
    if IsDefined(target as WeakspotObject) {
      target = (target as WeakspotObject).GetOwner();
    };
    if IsDefined(target as ScriptedPuppet) {
      if statSystem.GetStatValue(Cast(targetID), gamedataStatType.IsBlocking) == 1.00 || statSystem.GetStatValue(Cast(targetID), gamedataStatType.IsDeflecting) == 1.00 {
        WeaponObject.TriggerWeaponEffects(this.GetTargetWeapon(target as ScriptedPuppet), gamedataFxAction.MeleeBlock);
        meleeHitEvent.hitBlocked = true;
        AnimationControllerComponent.PushEvent(EffectScriptContext.GetInstigator(ctx) as GameObject, n"MeleeHitStatic");
        AnimationControllerComponent.PushEvent(EffectScriptContext.GetWeapon(ctx) as GameObject, n"MeleeHitStatic");
      } else {
        AnimationControllerComponent.PushEvent(EffectScriptContext.GetInstigator(ctx) as GameObject, n"MeleeHitNPC");
        AnimationControllerComponent.PushEvent(EffectScriptContext.GetWeapon(ctx) as GameObject, n"MeleeHitNPC");
      };
    } else {
      if IsDefined(target as SensorDevice) {
        AnimationControllerComponent.PushEvent(EffectScriptContext.GetInstigator(ctx) as GameObject, n"MeleeHitNPC");
        AnimationControllerComponent.PushEvent(EffectScriptContext.GetWeapon(ctx) as GameObject, n"MeleeHitNPC");
      } else {
        AnimationControllerComponent.PushEvent(EffectScriptContext.GetInstigator(ctx) as GameObject, n"MeleeHitStatic");
        AnimationControllerComponent.PushEvent(EffectScriptContext.GetWeapon(ctx) as GameObject, n"MeleeHitStatic");
      };
    };
    instigatorEntity.QueueEventForEntityID(instigatorEntityID, meleeHitEvent);
    instigatorEntity.QueueEventForEntityID(EffectScriptContext.GetWeapon(ctx).GetEntityID(), meleeHitEvent);
    this.TriggerSingleStimuliOnHit(ctx, applierCtx, gamedataStimType.SoundDistraction);
    return true;
  }

  private final func GetTargetWeapon(target: wref<ScriptedPuppet>) -> wref<WeaponObject> {
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(target.GetGame());
    let item: wref<ItemObject> = transactionSystem.GetItemInSlot(target, t"AttachmentSlots.WeaponRight");
    if !IsDefined(item) {
      item = transactionSystem.GetItemInSlot(target, t"AttachmentSlots.WeaponLeft");
    };
    return item as WeaponObject;
  }

  private final func TriggerSingleStimuliOnHit(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext, stimToSend: gamedataStimType) -> Void {
    let effect: ref<EffectInstance>;
    let stimuliEvent: ref<StimuliEvent>;
    let position: Vector4 = EffectExecutionScriptContext.GetHitPosition(applierCtx);
    if !Vector4.IsZero(position) && !this.IsMuted(ctx, applierCtx) {
      stimuliEvent = new StimuliEvent();
      stimuliEvent.sourcePosition = position;
      stimuliEvent.sourceObject = EffectScriptContext.GetInstigator(ctx) as GameObject;
      stimuliEvent.SetStimType(stimToSend);
      this.GetStimuliData("stims." + EnumValueToString("gamedataStimType", Cast(EnumInt(stimToSend))) + "Stimuli", stimuliEvent);
      effect = GameInstance.GetGameEffectSystem(GetGameInstance()).CreateEffectStatic(n"stimuli", n"stimuli_range", EffectScriptContext.GetSource(ctx));
      EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.stimuliEvent, ToVariant(stimuliEvent));
      EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position);
      EffectData.SetBool(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.stimuliRaycastTest, false);
      EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, stimuliEvent.radius);
      GameInstance.GetStimuliSystem(GetGameInstance()).BroadcastStimuli(effect);
    };
  }

  private final func GetStimuliData(path: String, out stimToProcess: ref<StimuliEvent>) -> Void {
    let sid: TweakDBID = TDBID.Create(path);
    let stimRecord: ref<Stim_Record> = TweakDBInterface.GetStimRecord(sid);
    stimToProcess.stimRecord = stimRecord;
    stimToProcess.radius = stimRecord.Radius();
    stimToProcess.stimPropagation = stimRecord.Propagation().Type();
  }

  private final func IsMuted(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let sourceMuted: Bool = GameInstance.GetStatusEffectSystem(EffectScriptContext.GetGameInstance(ctx)).HasStatusEffect(EffectScriptContext.GetSource(ctx).GetEntityID(), t"BaseStatusEffect.MuteAudioStims");
    return sourceMuted;
  }
}

public class MeleeHitTerminateGameEffectExecutor extends EffectExecutor_Scripted {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let isCleavingHit: Bool;
    if IsDefined(EffectScriptContext.GetInstigator(ctx) as PlayerPuppet) {
      EffectData.GetBool(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.meleeCleave, isCleavingHit);
      return !isCleavingHit;
    };
    return true;
  }
}
