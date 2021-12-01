
public class BlindingLight extends BasicDistractionDevice {

  protected let m_areaComponent: ref<TriggerComponent>;

  protected let m_highLightActive: Bool;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"area", n"TriggerComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_areaComponent = EntityResolveComponentsInterface.GetComponent(ri, n"area") as TriggerComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as BlindingLightController;
  }

  protected cb func OnPersitentStateInitialized(evt: ref<GameAttachedEvent>) -> Bool {
    super.OnPersitentStateInitialized(evt);
  }

  protected cb func OnOverloadDevice(evt: ref<OverloadDevice>) -> Bool {
    if evt.IsStarted() {
      this.TurnOnDevice();
      this.GetDevicePS().GetDeviceOperationsContainer().Execute(n"light_cone", this);
      this.ApplyStatusEffect();
      this.RefreshInteraction();
    } else {
      this.RestoreDeviceState();
    };
  }

  protected func StartDistraction(opt loopAnimation: Bool) -> Void {
    this.StartDistraction(loopAnimation);
    this.StartBlinking();
    GameObject.PlaySoundEvent(this, (this.GetDevicePS() as BlindingLightControllerPS).GetDistractionSound());
    this.m_interaction.Toggle(false);
  }

  protected func StopDistraction() -> Void {
    this.StopDistraction();
    this.StopBlinking();
    this.m_interaction.Toggle(true);
    this.RefreshInteraction();
  }

  protected final func StartBlinking() -> Void {
    let evt: ref<ChangeCurveEvent> = new ChangeCurveEvent();
    this.TurnOnLights();
    evt.time = 1.00;
    evt.curve = n"BrokenLamp3";
    evt.loop = true;
    this.QueueEvent(evt);
  }

  protected final func StopBlinking() -> Void {
    let evt: ref<ChangeCurveEvent> = new ChangeCurveEvent();
    this.QueueEvent(evt);
    this.RestoreDeviceState();
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOnLights();
    GameObject.PlaySoundEvent(this, (this.GetDevicePS() as BlindingLightControllerPS).GetTurnOnSound());
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffLights();
    GameObject.PlaySoundEvent(this, (this.GetDevicePS() as BlindingLightControllerPS).GetTurnOffSound());
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

  protected final func TurnOnLights() -> Void {
    let evt: ref<ToggleLightEvent> = new ToggleLightEvent();
    evt.toggle = true;
    this.QueueEvent(evt);
  }

  protected final func TurnOffLights() -> Void {
    let evt: ref<ToggleLightEvent> = new ToggleLightEvent();
    evt.toggle = false;
    this.QueueEvent(evt);
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
      i += 1;
    };
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

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Distract;
  }
}
