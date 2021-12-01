
public class DropPoint extends BasicDistractionDevice {

  private let m_isShortGlitchActive: Bool;

  private let m_shortGlitchDelayID: DelayID;

  private let m_mappinID: NewMappinID;

  private let m_inventory: ref<Inventory>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"ui", n"IWorldWidgetComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"inventory", n"Inventory", false);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_inventory = EntityResolveComponentsInterface.GetComponent(ri, n"inventory") as Inventory;
    this.m_uiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ui") as IWorldWidgetComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as DropPointController;
  }

  protected func ResolveGameplayState() -> Void {
    let request: ref<AttachVendorRequest>;
    let vendorID: TweakDBID;
    this.ResolveGameplayState();
    if this.IsUIdirty() && this.m_isInsideLogicArea {
      this.RefreshUI();
    };
    vendorID = TDBID.Create((this.GetDevicePS() as DropPointControllerPS).GetVendorRecordPath());
    if TDBID.IsValid(vendorID) {
      request = new AttachVendorRequest();
      request.owner = this;
      request.vendorID = vendorID;
      MarketSystem.GetInstance(this.GetGame()).QueueRequest(request);
    };
    if !this.GetDropPointSystem().IsEnabled() {
      this.TurnOffScreen();
    };
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    if this.GetDropPointSystem().IsEnabled() {
      this.RegisterMappin();
    };
    this.RegisterDropPointMappinInSystem();
  }

  protected cb func OnDetach() -> Bool {
    super.OnDetach();
    this.UnregisterMappin();
  }

  protected func DeactivateDevice() -> Void {
    this.TurnOffDevice();
  }

  protected func CutPower() -> Void {
    this.TurnOffScreen();
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffScreen();
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOnScreen();
  }

  protected final func TurnOffScreen() -> Void {
    this.m_uiComponent.Toggle(false);
  }

  protected final func TurnOnScreen() -> Void {
    this.m_uiComponent.Toggle(true);
  }

  private final func RegisterDropPointMappinInSystem() -> Void {
    let request: ref<RegisterDropPointMappinRequest> = new RegisterDropPointMappinRequest();
    request.ownerID = this.GetEntityID();
    request.position = this.GetWorldPosition();
    request.trackingAlternativeMappinID = this.m_mappinID;
    this.GetDropPointSystem().QueueRequest(request);
  }

  protected cb func OnUpdateDropPointEvent(evt: ref<UpdateDropPointEvent>) -> Bool {
    if evt.isEnabled {
      this.TurnOnScreen();
      this.RegisterMappin();
    } else {
      this.TurnOffScreen();
      this.UnregisterMappin();
    };
    this.DetermineInteractionState();
  }

  public final const func GetDropPointSystem() -> ref<DropPointSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"DropPointSystem") as DropPointSystem;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.ServicePoint;
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void {
    let evt: ref<AdvertGlitchEvent>;
    let glitchData: GlitchData;
    glitchData.state = glitchState;
    glitchData.intensity = intensity;
    if intensity == 0.00 {
      intensity = 1.00;
    };
    evt = new AdvertGlitchEvent();
    evt.SetShouldGlitch(intensity);
    this.QueueEvent(evt);
    this.GetBlackboard().SetVariant(this.GetBlackboardDef().GlitchData, ToVariant(glitchData), true);
    this.GetBlackboard().FireCallbacks();
  }

  protected func StopGlitching() -> Void {
    let glitchData: GlitchData;
    let evt: ref<AdvertGlitchEvent> = new AdvertGlitchEvent();
    evt.SetShouldGlitch(0.00);
    this.QueueEvent(evt);
    glitchData.state = EGlitchState.NONE;
    this.GetBlackboard().SetVariant(this.GetBlackboardDef().GlitchData, ToVariant(glitchData));
    this.GetBlackboard().FireCallbacks();
  }

  protected cb func OnHitEvent(hit: ref<gameHitEvent>) -> Bool {
    super.OnHitEvent(hit);
    this.StartShortGlitch();
  }

  private final func StartShortGlitch() -> Void {
    let evt: ref<StopShortGlitchEvent>;
    if this.GetDevicePS().IsGlitching() {
      return;
    };
    if !this.m_isShortGlitchActive {
      evt = new StopShortGlitchEvent();
      this.StartGlitching(EGlitchState.DEFAULT, 1.00);
      this.m_shortGlitchDelayID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, 0.25);
      this.m_isShortGlitchActive = true;
    };
  }

  protected cb func OnStopShortGlitch(evt: ref<StopShortGlitchEvent>) -> Bool {
    this.m_isShortGlitchActive = false;
    if !this.GetDevicePS().IsGlitching() {
      this.StopGlitching();
    };
  }

  public const func IsDropPoint() -> Bool {
    return true;
  }

  private final func IsMappinRegistered() -> Bool {
    let invalidID: NewMappinID;
    return NotEquals(this.m_mappinID, invalidID);
  }

  private final func RegisterMappin() -> Void {
    let mappinData: MappinData;
    if !this.IsMappinRegistered() {
      mappinData.mappinType = t"Mappins.DropPointDynamicMappin";
      mappinData.variant = gamedataMappinVariant.ServicePointDropPointVariant;
      mappinData.visibleThroughWalls = false;
      this.m_mappinID = this.GetMappinSystem().RegisterMappinWithObject(mappinData, this, n"poi_mappin");
    };
  }

  private final func UnregisterMappin() -> Void {
    let invalidID: NewMappinID;
    if this.IsMappinRegistered() {
      this.GetMappinSystem().UnregisterMappin(this.m_mappinID);
      this.m_mappinID = invalidID;
    };
  }

  private final func GetMappinSystem() -> ref<MappinSystem> {
    return GameInstance.GetMappinSystem(this.GetGame());
  }
}
