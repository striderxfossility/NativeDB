
public class AOEArea extends InteractiveMasterDevice {

  protected let m_areaComponent: ref<TriggerComponent>;

  private let m_gameEffect: ref<EffectInstance>;

  private let m_highLightActive: Bool;

  private let m_visionBlockerComponent: ref<IComponent>;

  private let m_obstacleComponent: ref<InfluenceObstacleComponent>;

  private let m_activeStatusEffects: array<wref<StatusEffect_Record>>;

  @default(AOEArea, 1.3f)
  private let m_extendPercentAABB: Float;

  @default(AOEArea, false)
  private let m_isAABBExtended: Bool;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"area", n"TriggerComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"vision_blocker", n"entColliderComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"obstacle_component", n"InfluenceObstacleComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_areaComponent = EntityResolveComponentsInterface.GetComponent(ri, n"area") as TriggerComponent;
    this.m_visionBlockerComponent = EntityResolveComponentsInterface.GetComponent(ri, n"vision_blocker");
    this.m_obstacleComponent = EntityResolveComponentsInterface.GetComponent(ri, n"obstacle_component") as InfluenceObstacleComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as AOEAreaController;
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    if (this.GetDevicePS() as AOEAreaControllerPS).IsAreaActive() {
      this.ActivateEffect();
    };
  }

  protected cb func OnDetach() -> Bool {
    super.OnDetach();
    this.StopGameEffect();
  }

  public const func IsGameplayRelevant() -> Bool {
    return true;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  public final func GetObstacleComponent() -> ref<IComponent> {
    return this.m_obstacleComponent;
  }

  public final func GetVisionBlockerComponent() -> ref<IComponent> {
    return this.m_visionBlockerComponent;
  }

  protected cb func OnActivateDevice(evt: ref<ActivateDevice>) -> Bool {
    this.ActivateArea();
  }

  protected cb func OnDeactivateDevice(evt: ref<DeactivateDevice>) -> Bool {
    this.DeactivateArea();
  }

  protected cb func OnRevealDeviceRequest(evt: ref<RevealDeviceRequest>) -> Bool {
    super.OnRevealDeviceRequest(evt);
    if !this.GetDevicePS().ShouldRevealDevicesGrid() {
      return true;
    };
    this.ToggleHighlightOnTargets(evt.shouldReveal);
  }

  private final func ToggleHighlightOnTargets(toggle: Bool) -> Void {
    let entities: array<ref<Entity>> = this.GetEntitiesInArea();
    this.m_highLightActive = toggle;
    let i: Int32 = 0;
    while i < ArraySize(entities) {
      if (entities[i] as NPCPuppet) != null {
        this.ToggleHighlightOnSingleTarget(toggle, entities[i].GetEntityID());
      };
      i += 1;
    };
  }

  private final func ToggleHighlightOnSingleTarget(toggle: Bool, id: EntityID) -> Void {
    let highlight: ref<FocusForcedHighlightData> = this.CreateHighlight(EFocusForcedHighlightType.DISTRACTION);
    let evt: ref<ForceVisionApperanceEvent> = new ForceVisionApperanceEvent();
    evt.apply = toggle;
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

  private final func ActivateArea() -> Void {
    this.ActivateEffect();
    if (this.GetDevicePS() as AOEAreaControllerPS).IsDangerous() && IsDefined(this.m_obstacleComponent) {
      this.m_visionBlockerComponent.Toggle(true);
      this.m_obstacleComponent.Toggle(true);
      this.m_visionBlockerComponent.Toggle(false);
      if !this.m_isAABBExtended {
        this.ExtendBoundingBox();
      };
    };
    if (this.GetDevicePS() as AOEAreaControllerPS).BlocksVisibility() && IsDefined(this.m_visionBlockerComponent) {
      this.m_visionBlockerComponent.Toggle(true);
    };
  }

  private final func DeactivateArea() -> Void {
    this.StopGameEffect();
    if IsDefined(this.m_visionBlockerComponent) {
      this.m_visionBlockerComponent.Toggle(false);
    };
    if IsDefined(this.m_obstacleComponent) {
      this.m_obstacleComponent.Toggle(false);
    };
  }

  private final func ActivateEffect() -> Void {
    let attack: ref<Attack_GameEffect>;
    let attackContext: AttackInitContext;
    let i: Int32;
    let statusEffectRecords: array<wref<StatusEffectAttackData_Record>>;
    if !IsDefined(this.m_gameEffect) {
      attackContext.record = TweakDBInterface.GetAttackRecord((this.GetDevicePS() as AOEAreaControllerPS).GetAreaEffect());
      attackContext.instigator = GetPlayer(this.GetGame());
      attackContext.source = this;
      attack = IAttack.Create(attackContext) as Attack_GameEffect;
      this.m_gameEffect = attack.PrepareAttack(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject());
      EffectData.SetVector(this.m_gameEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, this.GetWorldPosition());
      EffectData.SetVariant(this.m_gameEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attack, ToVariant(attack));
      attack.StartAttack();
      TweakDBInterface.GetAttackRecord((this.GetDevicePS() as AOEAreaControllerPS).GetAreaEffect()).StatusEffects(statusEffectRecords);
      i = 0;
      while i < ArraySize(statusEffectRecords) {
        ArrayPush(this.m_activeStatusEffects, statusEffectRecords[i].StatusEffect());
        i += 1;
      };
    };
  }

  private final func StopGameEffect() -> Void {
    let currentlyOverlappingEntities: array<ref<Entity>>;
    let i: Int32;
    if IsDefined(this.m_gameEffect) {
      this.m_gameEffect.Terminate();
      this.m_gameEffect = null;
      if (this.GetDevicePS() as AOEAreaControllerPS).EffectsOnlyActiveInArea() {
        currentlyOverlappingEntities = this.GetEntitiesInArea();
        i = 0;
        while i < ArraySize(currentlyOverlappingEntities) {
          this.RemoveActiveStatusEffectsFromEntity(currentlyOverlappingEntities[i].GetEntityID());
          i += 1;
        };
      };
      ArrayClear(this.m_activeStatusEffects);
    };
  }

  public final const func GetEntitiesInArea() -> array<ref<Entity>> {
    return this.m_areaComponent.GetOverlappingEntities();
  }

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    let activator: wref<NPCPuppet>;
    super.OnAreaEnter(evt);
    activator = EntityGameInterface.GetEntity(evt.activator) as NPCPuppet;
    if activator != null && this.m_highLightActive {
      this.ToggleHighlightOnSingleTarget(true, activator.GetEntityID());
    };
    if (this.GetDevicePS() as AOEAreaControllerPS).EffectsOnlyActiveInArea() {
      this.ApplyActiveStatusEffectsToEntity(EntityGameInterface.GetEntity(evt.activator).GetEntityID());
    };
    if IsDefined(activator) {
      this.UpdateWillingInvestigator();
    };
  }

  protected cb func OnAreaExit(evt: ref<AreaExitedEvent>) -> Bool {
    let activator: wref<NPCPuppet>;
    super.OnAreaExit(evt);
    activator = EntityGameInterface.GetEntity(evt.activator) as NPCPuppet;
    if activator != null && this.m_highLightActive {
      this.ToggleHighlightOnSingleTarget(false, activator.GetEntityID());
    };
    if (this.GetDevicePS() as AOEAreaControllerPS).EffectsOnlyActiveInArea() {
      this.RemoveActiveStatusEffectsFromEntity(EntityGameInterface.GetEntity(evt.activator).GetEntityID());
    };
    if IsDefined(activator) {
      this.UpdateWillingInvestigator();
    };
  }

  protected final func UpdateWillingInvestigator() -> Void {
    let closestNavDist: Float;
    let j: Int32;
    let lastDistance: Float;
    let navDistance: Float;
    let newDistance: Float;
    let path: ref<NavigationPath>;
    let sourcePos: Vector4;
    let target: ref<Entity>;
    let targetPos: Vector4;
    let posSources: array<Vector4> = this.GetNodePosition();
    let targets: array<ref<Entity>> = this.GetEntitiesInArea();
    let i: Int32 = 0;
    while i < ArraySize(targets) {
      if (targets[i] as GameObject).IsPlayer() {
      } else {
        targetPos = targets[i].GetWorldPosition();
        j = 0;
        while j < ArraySize(posSources) {
          navDistance = Vector4.DistanceSquared(posSources[j], targetPos);
          path = GameInstance.GetNavigationSystem(this.GetGame()).CalculatePathOnlyHumanNavmesh(targetPos, posSources[j], NavGenAgentSize.Human, 0.00);
          if !IsDefined(path) {
          } else {
            if navDistance < closestNavDist || closestNavDist == 0.00 {
              closestNavDist = navDistance;
              sourcePos = posSources[j];
            };
          };
          j += 1;
        };
        path = GameInstance.GetNavigationSystem(this.GetGame()).CalculatePathOnlyHumanNavmesh(targetPos, sourcePos, NavGenAgentSize.Human, 0.00);
        newDistance = path.CalculateLength();
        if (lastDistance == 0.00 || lastDistance > newDistance) && newDistance != 0.00 {
          target = targets[i];
          lastDistance = newDistance;
        };
      };
      i += 1;
    };
    if IsDefined(target) {
      this.GetDevicePS().AddWillingInvestigator(target.GetEntityID());
    } else {
      this.GetDevicePS().ClearWillingInvestigators();
    };
  }

  protected final func ApplyActiveStatusEffectsToEntity(entityID: EntityID) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_activeStatusEffects) {
      GameInstance.GetStatusEffectSystem(this.GetGame()).ApplyStatusEffect(entityID, this.m_activeStatusEffects[i].GetID());
      i += 1;
    };
  }

  protected final func RemoveActiveStatusEffectsFromEntity(entityID: EntityID) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_activeStatusEffects) {
      GameInstance.GetStatusEffectSystem(this.GetGame()).RemoveStatusEffect(entityID, this.m_activeStatusEffects[i].GetID());
      i += 1;
    };
  }

  public const func GetDefaultHighlight() -> ref<FocusForcedHighlightData> {
    return null;
  }

  public func GetStimTarget() -> ref<GameObject> {
    return this;
  }

  public func GetDistractionControllerSource(opt effectData: ref<AreaEffectData>) -> ref<Entity> {
    let ancestors: array<ref<DeviceComponentPS>>;
    let controller: ref<Entity>;
    let i: Int32;
    if IsDefined(effectData) {
      controller = this.GetEntityFromNode(effectData.controllerSource);
    };
    if IsDefined(controller) {
      return controller;
    };
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

  public func GetDistractionStimLifetime(defaultValue: Float) -> Float {
    return (this.GetDevicePS() as AOEAreaControllerPS).GetEffectDuration();
  }

  private final func ExtendBoundingBox() -> Void {
    let aabb: Box = this.m_obstacleComponent.GetBoundingBox();
    aabb.Min *= this.m_extendPercentAABB;
    aabb.Max *= this.m_extendPercentAABB;
    this.m_obstacleComponent.SetBoundingBox(aabb);
    this.m_isAABBExtended = true;
  }
}

public class EffectObjectProvider_AOEAreaEntities extends EffectObjectProvider_Scripted {

  public final func Process(ctx: EffectScriptContext, providerCtx: EffectProviderScriptContext) -> Void {
    let entities: array<ref<Entity>> = (EffectScriptContext.GetSource(ctx) as AOEArea).GetEntitiesInArea();
    let i: Int32 = 0;
    while i < ArraySize(entities) {
      EffectProviderScriptContext.AddTarget(ctx, providerCtx, entities[i]);
      i += 1;
    };
  }
}
