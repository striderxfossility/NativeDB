
public class SmokeMachine extends BasicDistractionDevice {

  protected let m_areaComponent: ref<TriggerComponent>;

  protected let m_highLightActive: Bool;

  protected let m_entities: array<wref<Entity>>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"area", n"TriggerComponent", false);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_areaComponent = EntityResolveComponentsInterface.GetComponent(ri, n"area") as TriggerComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as SmokeMachineController;
  }

  protected cb func OnPersitentStateInitialized(evt: ref<GameAttachedEvent>) -> Bool {
    super.OnPersitentStateInitialized(evt);
  }

  protected cb func OnOverloadDevice(evt: ref<OverloadDevice>) -> Bool {
    if evt.IsStarted() {
      this.GetDevicePS().GetDeviceOperationsContainer().Execute(n"smoke_effect_blind", this);
      this.ApplyStatusEffect();
    } else {
      this.RemoveStatusEffect();
    };
  }

  protected func StartDistraction(opt loopAnimation: Bool) -> Void {
    this.GetDevicePS().GetDeviceOperationsContainer().Execute(n"smoke_effect_distraction", this);
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
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

  public final const func GetEntitiesInArea() -> array<ref<Entity>> {
    return this.m_areaComponent.GetOverlappingEntities();
  }

  protected final func ApplyStatusEffect() -> Void {
    let statusEffectID: TweakDBID = t"BaseStatusEffect.Blind";
    let entities: array<ref<Entity>> = this.GetEntitiesInArea();
    let i: Int32 = 0;
    while i < ArraySize(entities) {
      GameInstance.GetStatusEffectSystem(this.GetGame()).ApplyStatusEffect(entities[i].GetEntityID(), statusEffectID);
      ArrayPush(this.m_entities, entities[i]);
      i += 1;
    };
  }

  protected final func RemoveStatusEffect() -> Void {
    let statusEffectID: TweakDBID = t"BaseStatusEffect.Blind";
    let i: Int32 = 0;
    while i < ArraySize(this.m_entities) {
      GameInstance.GetStatusEffectSystem(this.GetGame()).RemoveStatusEffect(this.m_entities[i].GetEntityID(), statusEffectID);
      i += 1;
    };
    ArrayClear(this.m_entities);
  }

  protected cb func OnRevealDeviceRequest(evt: ref<RevealDeviceRequest>) -> Bool {
    super.OnRevealDeviceRequest(evt);
    if !this.GetDevicePS().ShouldRevealDevicesGrid() {
      return true;
    };
    this.ToggleHighlightOnTargets(evt.shouldReveal);
  }

  protected final func CreateHighlight(highlightType: EFocusForcedHighlightType) -> ref<FocusForcedHighlightData> {
    let highlight: ref<FocusForcedHighlightData> = new FocusForcedHighlightData();
    highlight.sourceID = this.GetEntityID();
    highlight.sourceName = this.GetClassName();
    highlight.highlightType = highlightType;
    highlight.inTransitionTime = 0.00;
    highlight.outTransitionTime = 0.00;
    highlight.priority = EPriority.VeryHigh;
    return highlight;
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

  protected final func ToggleHighlightOnSingleTarget(toggle: Bool, id: EntityID) -> Void {
    let highlight: ref<FocusForcedHighlightData> = this.CreateHighlight(EFocusForcedHighlightType.DISTRACTION);
    let evt: ref<ForceVisionApperanceEvent> = new ForceVisionApperanceEvent();
    evt.apply = toggle;
    evt.forcedHighlight = highlight;
    this.QueueEventForEntityID(id, evt);
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Distract;
  }
}
