
public class DataTerm extends InteractiveDevice {

  @attrib(category, "Fast Travel")
  private inline let m_linkedFastTravelPoint: ref<FastTravelPointData>;

  @attrib(category, "Fast Travel")
  private let m_exitNode: NodeRef;

  private let m_fastTravelComponent: ref<FastTravelComponent>;

  private let m_lockColiderComponent: ref<IPlacedComponent>;

  private let m_mappinID: NewMappinID;

  private let m_isShortGlitchActive: Bool;

  private let m_shortGlitchDelayID: DelayID;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"dataTerm_ui", n"worlduiWidgetComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"fastTravel", n"FastTravelComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"lock", n"IPlacedComponent", false);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_uiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"dataTerm_ui") as worlduiWidgetComponent;
    this.m_fastTravelComponent = EntityResolveComponentsInterface.GetComponent(ri, n"fastTravel") as FastTravelComponent;
    this.m_lockColiderComponent = EntityResolveComponentsInterface.GetComponent(ri, n"lock") as IPlacedComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as DataTermController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    (this.GetDevicePS() as DataTermControllerPS).SetLinkedFastTravelPoint(this.m_linkedFastTravelPoint);
    this.ResolveGateApperance();
    this.RegisterFastTravelPoints();
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    if this.GetFastTravelSystem().HasFastTravelPoint(this.m_linkedFastTravelPoint) {
      this.RegisterMappin();
    };
  }

  protected cb func OnDetach() -> Bool {
    super.OnDetach();
    this.UnregisterMappin();
  }

  protected func CreateBlackboard() -> Void {
    this.m_blackboard = IBlackboard.Create(GetAllBlackboardDefs().DataTermDeviceBlackboard);
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return this.GetDevicePS().GetBlackboardDef();
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected cb func OnLogicReady(evt: ref<SetLogicReadyEvent>) -> Bool {
    super.OnLogicReady(evt);
    if this.IsUIdirty() && this.m_isInsideLogicArea {
      this.RefreshUI();
    };
  }

  protected func CutPower() -> Void {
    this.CutPower();
    this.TurnOffScreen();
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffDevice();
    this.TurnOffScreen();
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOnDevice();
    this.TurnOnScreen();
  }

  protected func DeactivateDevice() -> Void {
    this.DeactivateDevice();
    this.ToggleLogicLayer(false);
    this.UnregisterMappin();
  }

  protected func ActivateDevice() -> Void {
    this.ActivateDevice();
    this.ToggleLogicLayer(true);
  }

  protected final func TurnOffScreen() -> Void {
    if IsDefined(this.m_uiComponent) {
      this.m_uiComponent.Toggle(false);
    };
  }

  protected final func TurnOnScreen() -> Void {
    if IsDefined(this.m_uiComponent) {
      this.m_uiComponent.Toggle(true);
    };
  }

  protected cb func OnInteractionActivated(evt: ref<InteractionActivationEvent>) -> Bool {
    super.OnInteractionActivated(evt);
    if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_activate) {
      if Equals(evt.layerData.tag, n"LogicArea") {
        this.RegisterFastTravelPoints();
      };
    };
  }

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    let activator: ref<GameObject>;
    if NotEquals(evt.componentName, n"fastTravelArea") {
      return false;
    };
    if NotEquals((this.GetDevicePS() as DataTermControllerPS).GetFastravelTriggerType(), EFastTravelTriggerType.Auto) {
      return false;
    };
    if this.m_linkedFastTravelPoint == null || IsDefined(this.m_linkedFastTravelPoint) && !this.m_linkedFastTravelPoint.IsValid() {
      return false;
    };
    if this.GetFastTravelSystem().IsFastTravelEnabledOnMap() {
      return false;
    };
    activator = EntityGameInterface.GetEntity(evt.activator) as GameObject;
    if activator.IsPlayer() {
      this.EnableFastTravelOnMap();
      this.TriggerMenuEvent(n"OnOpenFastTravel");
      this.TeleportToExitNode(activator);
    };
  }

  private final func TeleportToExitNode(activator: ref<GameObject>) -> Void {
    let nodeTransform: Transform;
    let position: Vector4;
    let rotation: EulerAngles;
    let globalRef: GlobalNodeRef = ResolveNodeRefWithEntityID(this.m_exitNode, this.GetEntityID());
    if GlobalNodeRef.IsDefined(globalRef) {
      GameInstance.GetNodeTransform(this.GetGame(), globalRef, nodeTransform);
      position = Transform.GetPosition(nodeTransform);
      rotation = Quaternion.ToEulerAngles(Transform.GetOrientation(nodeTransform));
      GameInstance.GetTeleportationFacility(this.GetGame()).Teleport(activator, position, rotation);
    } else {
      GameInstance.GetTeleportationFacility(this.GetGame()).TeleportToNode(activator, this.m_linkedFastTravelPoint.GetMarkerRef());
    };
  }

  private final func ResolveGateApperance() -> Void {
    if Equals((this.GetDevicePS() as DataTermControllerPS).GetFastravelDeviceType(), EFastTravelDeviceType.SubwayGate) {
      if !this.GetFastTravelSystem().IsFastTravelEnabled() {
        this.SetMeshAppearance(n"bars");
        if IsDefined(this.m_lockColiderComponent) && Equals((this.GetDevicePS() as DataTermControllerPS).GetFastravelTriggerType(), EFastTravelTriggerType.Auto) {
          this.m_lockColiderComponent.Toggle(true);
        };
      } else {
        this.SetMeshAppearance(n"default");
        if IsDefined(this.m_lockColiderComponent) && Equals((this.GetDevicePS() as DataTermControllerPS).GetFastravelTriggerType(), EFastTravelTriggerType.Auto) {
          this.m_lockColiderComponent.Toggle(false);
        };
      };
    };
  }

  private final func IsMappinRegistered() -> Bool {
    let invalidID: NewMappinID;
    return NotEquals(this.m_mappinID, invalidID);
  }

  private final func RegisterMappin() -> Void {
    let mappinData: MappinData;
    if this.GetDevicePS().IsDisabled() {
      return;
    };
    if !this.m_linkedFastTravelPoint.ShouldShowMappinInWorld() {
      return;
    };
    if !this.IsMappinRegistered() {
      mappinData.mappinType = t"Mappins.FastTravelDynamicMappin";
      mappinData.variant = gamedataMappinVariant.FastTravelVariant;
      mappinData.visibleThroughWalls = false;
      this.m_mappinID = this.GetMappinSystem().RegisterMappinWithObject(mappinData, this, n"poi_mappin");
    };
  }

  private final func UnregisterMappin() -> Void {
    let invalidID: NewMappinID;
    if !this.m_linkedFastTravelPoint.ShouldShowMappinInWorld() {
      return;
    };
    if this.IsMappinRegistered() {
      this.GetMappinSystem().UnregisterMappin(this.m_mappinID);
      this.m_mappinID = invalidID;
    };
  }

  private final func GetMappinSystem() -> ref<MappinSystem> {
    return GameInstance.GetMappinSystem(this.GetGame());
  }

  private final func RegisterFastTravelPoints() -> Void {
    let evt: ref<RegisterFastTravelPointsEvent>;
    if this.GetDevicePS().IsDisabled() {
      return;
    };
    evt = new RegisterFastTravelPointsEvent();
    ArrayPush(evt.fastTravelNodes, this.m_linkedFastTravelPoint);
    this.QueueEvent(evt);
    this.RegisterMappin();
  }

  protected cb func OnFastTravelPointsUpdated(evt: ref<FastTravelPointsUpdated>) -> Bool {
    let invalidID: NewMappinID;
    if evt.updateTrackingAlternative && NotEquals(this.m_linkedFastTravelPoint.mappinID, invalidID) {
      this.GetMappinSystem().SetMappinTrackingAlternative(this.m_linkedFastTravelPoint.mappinID, this.m_mappinID);
    };
    this.GetBlackboard().SetVariant(GetAllBlackboardDefs().DataTermDeviceBlackboard.fastTravelPoint, ToVariant(this.m_linkedFastTravelPoint), true);
    this.DetermineInteractionState();
    this.RefreshUI();
    this.ResolveGateApperance();
  }

  protected cb func OnOpenWorldMapAction(evt: ref<OpenWorldMapDeviceAction>) -> Bool {
    this.EnableFastTravelOnMap();
    this.TriggerMenuEvent(n"OnOpenFastTravel");
    this.ProcessFastTravelTutorial();
  }

  protected final func ProcessFastTravelTutorial() -> Void {
    if GameInstance.GetQuestsSystem(this.GetGame()).GetFact(n"tutorial_fast_travel") == 0 {
      GameInstance.GetQuestsSystem(this.GetGame()).SetFact(n"tutorial_fast_travel", 1);
    };
  }

  private final func EnableFastTravelOnMap() -> Void {
    let request: ref<ToggleFastTravelAvailabilityOnMapRequest> = new ToggleFastTravelAvailabilityOnMapRequest();
    request.isEnabled = true;
    if this.m_linkedFastTravelPoint != null {
      request.pointRecord = this.m_linkedFastTravelPoint.GetPointRecord();
    };
    this.GetFastTravelSystem().QueueRequest(request);
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.FastTravel;
  }

  public const func IsGameplayRoleValid(role: EGameplayRole) -> Bool {
    if !this.IsGameplayRoleValid(role) {
      return false;
    };
    if this.m_linkedFastTravelPoint != null && this.m_linkedFastTravelPoint.IsValid() {
      return true;
    };
    return false;
  }

  public const func IsFastTravelPoint() -> Bool {
    return true;
  }

  protected cb func OnHitEvent(hit: ref<gameHitEvent>) -> Bool {
    super.OnHitEvent(hit);
    this.StartShortGlitch();
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void {
    let evt: ref<AdvertGlitchEvent>;
    if intensity == 0.00 {
      intensity = 1.00;
    };
    evt = new AdvertGlitchEvent();
    evt.SetShouldGlitch(1.00);
    this.QueueEvent(evt);
  }

  protected func StopGlitching() -> Void {
    let evt: ref<AdvertGlitchEvent> = new AdvertGlitchEvent();
    evt.SetShouldGlitch(0.00);
    this.QueueEvent(evt);
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

  public final const func GetFastravelPointData() -> ref<FastTravelPointData> {
    return this.m_linkedFastTravelPoint;
  }
}
