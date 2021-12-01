
public class ActivatedDeviceTrap extends ActivatedDeviceTransfromAnim {

  protected let m_areaComponent: ref<TriggerComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"area", n"TriggerComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_areaComponent = EntityResolveComponentsInterface.GetComponent(ri, n"area") as TriggerComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as ActivatedDeviceController;
  }

  protected func RefreshAnimation() -> Void {
    if this.GetDevicePS().IsDisabled() {
      this.SendSimpleAnimFeature(true, false, false);
    } else {
      if this.GetDevicePS().IsDistracting() {
        this.SendSimpleAnimFeature(false, true, false);
      } else {
        this.SendSimpleAnimFeature(false, false, false);
      };
    };
    if !this.m_wasAnimationFastForwarded {
      this.FastForwardAnimations();
    };
  }

  protected cb func OnActivateDevice(evt: ref<ActivateDevice>) -> Bool {
    let evnt: ref<TimerEvent> = new TimerEvent();
    super.OnActivateDevice(evt);
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evnt, (this.GetDevicePS() as ActivatedDeviceControllerPS).GetAnimationTime());
  }

  protected cb func OnTimerEvent(evt: ref<TimerEvent>) -> Bool {
    this.DoAttack((this.GetDevicePS() as ActivatedDeviceControllerPS).GetAttackType());
    this.SpawnVFXs((this.GetDevicePS() as ActivatedDeviceControllerPS).GetVFX());
  }

  protected final func DoAttack(attackRecord: TweakDBID) -> Void {
    let attack: ref<Attack_GameEffect>;
    let hitFlags: array<SHitFlag>;
    let npcType: gamedataNPCType;
    let entities: array<ref<Entity>> = this.GetEntitiesInArea();
    let i: Int32 = 0;
    while i < ArraySize(entities) {
      if IsDefined(entities[i] as NPCPuppet) {
        npcType = (entities[i] as NPCPuppet).GetNPCType();
        if StatusEffectSystem.ObjectHasStatusEffect(entities[i] as NPCPuppet, t"BaseStatusEffect.Unconscious") {
          StatusEffectHelper.ApplyStatusEffect(entities[i] as NPCPuppet, t"BaseStatusEffect.ForceKill", this.GetEntityID());
        } else {
          if Equals(npcType, gamedataNPCType.Human) || Equals(npcType, gamedataNPCType.Android) {
            entities[i].QueueEvent(CreateForceRagdollEvent(n"Hit by a trap device - activatedDeviceTrap.script"));
          };
        };
      };
      i += 1;
    };
    attack = RPGManager.PrepareGameEffectAttack(this.GetGame(), GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject(), this, attackRecord, hitFlags);
    if IsDefined(attack) {
      attack.StartAttack();
    };
  }

  protected final func Distract() -> Void {
    let areaEffectData: ref<AreaEffectData>;
    let distractionName: CName = StringToName("distractEffect");
    let i: Int32 = 0;
    while i < this.GetFxResourceMapper().GetAreaEffectDataSize() {
      if Equals(this.GetFxResourceMapper().GetAreaEffectDataByIndex(i).areaEffectID, distractionName) {
        areaEffectData = this.GetFxResourceMapper().GetAreaEffectDataByIndex(i);
        this.TriggerArreaEffectDistraction(areaEffectData);
      } else {
        i += 1;
      };
    };
  }

  public final func GetEntitiesInArea() -> array<ref<Entity>> {
    return this.m_areaComponent.GetOverlappingEntities();
  }

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    if (this.GetDevicePS() as ActivatedDeviceControllerPS).ShouldActivateTrapOnAreaEnter() && !this.GetDevicePS().IsDisabled() {
      this.DoAttack((this.GetDevicePS() as ActivatedDeviceControllerPS).GetAttackType());
      this.SpawnVFXs((this.GetDevicePS() as ActivatedDeviceControllerPS).GetVFX());
    };
  }

  protected func ResolveGameplayState() -> Void {
    let i: Int32;
    this.ResolveGameplayState();
    if IsDefined(this.m_fxResourceMapper) {
      this.m_fxResourceMapper.CreateEffectStructDataFromAttack((this.GetDevicePS() as ActivatedDeviceControllerPS).GetAttackType(), i, n"trapTargets");
    };
  }
}

public class EffectObjectProvider_TrapEntities extends EffectObjectProvider_Scripted {

  public final func Process(ctx: EffectScriptContext, providerCtx: EffectProviderScriptContext) -> Void {
    let entities: array<ref<Entity>> = (EffectScriptContext.GetSource(ctx) as ActivatedDeviceTrap).GetEntitiesInArea();
    let i: Int32 = 0;
    while i < ArraySize(entities) {
      EffectProviderScriptContext.AddTarget(ctx, providerCtx, entities[i]);
      i += 1;
    };
  }
}
