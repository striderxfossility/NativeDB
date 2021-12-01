
public class VentilationArea extends InteractiveMasterDevice {

  protected let m_areaComponent: ref<TriggerComponent>;

  @default(VentilationArea, false)
  protected let m_RestartGameEffectOnAttach: Bool;

  @default(VentilationArea, Attacks.FragGrenade)
  protected let m_AttackRecord: String;

  private edit let m_gameEffectRef: EffectRef;

  private let m_gameEffect: ref<EffectInstance>;

  private let m_highLightActive: Bool;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"area", n"TriggerComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_areaComponent = EntityResolveComponentsInterface.GetComponent(ri, n"area") as TriggerComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as VentilationAreaController;
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    if (this.GetDevicePS() as VentilationAreaControllerPS).IsAreaActive() && this.m_RestartGameEffectOnAttach {
      this.PlayGameEffect();
    };
  }

  protected cb func OnDetach() -> Bool {
    super.OnDetach();
    this.StopGameEffect();
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected cb func OnActivateDevice(evt: ref<ActivateDevice>) -> Bool {
    this.PlayGameEffect();
  }

  protected cb func OnRevealDeviceRequest(evt: ref<RevealDeviceRequest>) -> Bool {
    super.OnRevealDeviceRequest(evt);
    if !this.GetDevicePS().ShouldRevealDevicesGrid() {
      return true;
    };
    this.ToggleHighlightOnTargets(evt.shouldReveal);
  }

  private final func ToggleHighlightOnTargets(toogle: Bool) -> Void {
    let entities: array<ref<Entity>> = this.GetEntitiesInArea();
    this.m_highLightActive = toogle;
    let i: Int32 = 0;
    while i < ArraySize(entities) {
      if (entities[i] as NPCPuppet) != null {
        this.ToggleHighlightOnSingleTarget(toogle, entities[i].GetEntityID());
      };
      i += 1;
    };
  }

  private final func ToggleHighlightOnSingleTarget(toogle: Bool, id: EntityID) -> Void {
    let highlight: ref<FocusForcedHighlightData> = this.CreateHighlight(EFocusForcedHighlightType.DISTRACTION);
    let evt: ref<ForceVisionApperanceEvent> = new ForceVisionApperanceEvent();
    evt.apply = toogle;
    evt.forcedHighlight = highlight;
    this.QueueEventForEntityID(id, evt);
  }

  private final func CreateHighlight(highlightType: EFocusForcedHighlightType) -> ref<FocusForcedHighlightData> {
    let highlight: ref<FocusForcedHighlightData> = new FocusForcedHighlightData();
    highlight.sourceID = this.GetEntityID();
    highlight.sourceName = this.GetClassName();
    highlight.highlightType = highlightType;
    highlight.inTransitionTime = 0.00;
    highlight.outTransitionTime = 0.00;
    highlight.priority = EPriority.VeryHigh;
    return highlight;
  }

  private final func PlayGameEffect() -> Void {
    let attackContext: AttackInitContext;
    let explosionAttack: ref<Attack_GameEffect>;
    let hitFlags: array<hitFlag>;
    let statMods: array<ref<gameStatModifierData>>;
    if !IsDefined(this.m_gameEffect) {
      this.m_gameEffect = GameInstance.GetGameEffectSystem(this.GetGame()).CreateEffect(this.m_gameEffectRef, GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject(), this);
      attackContext.record = TweakDBInterface.GetAttackRecord(TDBID.Create(this.m_AttackRecord));
      attackContext.instigator = GetPlayer(this.GetGame());
      attackContext.source = this;
      explosionAttack = IAttack.Create(attackContext) as Attack_GameEffect;
      explosionAttack.GetStatModList(statMods);
      ArrayPush(hitFlags, hitFlag.FriendlyFire);
      EffectData.SetVector(this.m_gameEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, this.GetWorldPosition());
      EffectData.SetVariant(this.m_gameEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.flags, ToVariant(hitFlags));
      EffectData.SetVariant(this.m_gameEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attack, ToVariant(explosionAttack));
      EffectData.SetVariant(this.m_gameEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attackStatModList, ToVariant(statMods));
    };
    switch (this.GetDevicePS() as VentilationAreaControllerPS).GetAreaEffect() {
      case ETrapEffects.SmokeScreen:
        this.ApplyStatusEffect("BaseStatusEffect.SmokeScreen");
        break;
      case ETrapEffects.Explosion:
        this.m_gameEffect.Run();
        break;
      case ETrapEffects.SmokeScreen:
        this.ApplyStatusEffect("BaseStatusEffect.SmokeScreen");
        break;
      case ETrapEffects.Bleeding:
        this.ApplyStatusEffect("BaseStatusEffect.Bleeding");
        break;
      case ETrapEffects.Burning:
        this.ApplyStatusEffect("BaseStatusEffect.Burning");
        break;
      case ETrapEffects.Blind:
        this.ApplyStatusEffect("BaseStatusEffect.Blind");
        break;
      case ETrapEffects.Stun:
        this.ApplyStatusEffect("BaseStatusEffect.Stun");
    };
  }

  private final func StopGameEffect() -> Void {
    if IsDefined(this.m_gameEffect) {
      this.m_gameEffect.Terminate();
      this.m_gameEffect = null;
    };
  }

  public final const func GetEntitiesInArea() -> array<ref<Entity>> {
    return this.m_areaComponent.GetOverlappingEntities();
  }

  protected final func ApplyStatusEffect(effectTDBID: String) -> Void {
    let statusEffectID: TweakDBID = TDBID.Create(effectTDBID);
    let entities: array<ref<Entity>> = this.GetEntitiesInArea();
    let i: Int32 = 0;
    while i < ArraySize(entities) {
      GameInstance.GetStatusEffectSystem(this.GetGame()).ApplyStatusEffect(entities[i].GetEntityID(), statusEffectID);
      i += 1;
    };
  }

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    let activator: wref<NPCPuppet>;
    super.OnAreaEnter(evt);
    activator = EntityGameInterface.GetEntity(evt.activator) as NPCPuppet;
    if activator != null && this.m_highLightActive {
      this.ToggleHighlightOnSingleTarget(true, activator.GetEntityID());
    };
  }

  protected cb func OnAreaExit(evt: ref<AreaExitedEvent>) -> Bool {
    let activator: wref<NPCPuppet>;
    super.OnAreaExit(evt);
    activator = EntityGameInterface.GetEntity(evt.activator) as NPCPuppet;
    if activator != null && this.m_highLightActive {
      this.ToggleHighlightOnSingleTarget(false, activator.GetEntityID());
    };
  }

  public const func GetDefaultHighlight() -> ref<FocusForcedHighlightData> {
    return null;
  }

  public func GetStimTarget() -> ref<GameObject> {
    let children: array<ref<DeviceComponentPS>>;
    let entity: wref<Entity>;
    let i: Int32;
    this.GetDevicePS().GetChildren(children);
    i = 0;
    while i <= ArraySize(children) {
      if Equals(children[i].GetDeviceName(), "ActivatedDevice") {
        entity = children[i].GetOwnerEntityWeak();
        return entity as GameObject;
      };
      i += 1;
    };
    return this;
  }

  public func GetDistractionControllerSource(opt effectData: ref<AreaEffectData>) -> ref<Entity> {
    let ancestors: array<ref<DeviceComponentPS>>;
    let i: Int32;
    this.GetDevicePS().GetAncestors(ancestors);
    i = 0;
    while i <= ArraySize(ancestors) {
      if Equals(ancestors[i].GetDeviceName(), "Activator") {
        return ancestors[i].GetOwnerEntityWeak();
      };
      i += 1;
    };
    return this;
  }
}

public class EffectObjectProvider_VentilationAreaEntities extends EffectObjectProvider_Scripted {

  public final func Process(ctx: EffectScriptContext, providerCtx: EffectProviderScriptContext) -> Void {
    let entities: array<ref<Entity>> = (EffectScriptContext.GetWeapon(ctx) as VentilationArea).GetEntitiesInArea();
    let i: Int32 = 0;
    while i < ArraySize(entities) {
      EffectProviderScriptContext.AddTarget(ctx, providerCtx, entities[i]);
      i += 1;
    };
  }
}
