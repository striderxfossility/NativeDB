
public class LiftDevice extends InteractiveMasterDevice {

  protected const let m_advertismentNames: array<CName>;

  protected let m_advertisments: array<ref<IPlacedComponent>>;

  private let m_movingPlatform: ref<MovingPlatform>;

  private let m_floors: array<ElevatorFloorSetup>;

  protected let QuestSafeguardColliders: array<ref<IPlacedComponent>>;

  protected let QuestSafeguardColliderNames: array<CName>;

  protected let m_frontDoorOccluder: ref<IPlacedComponent>;

  protected let m_backDoorOccluder: ref<IPlacedComponent>;

  protected let m_radioMesh: ref<IPlacedComponent>;

  protected let m_radioDestroyed: ref<IPlacedComponent>;

  protected let m_offMeshConnectionComponent: ref<OffMeshConnectionComponent>;

  private let m_isLoadPerformed: Bool;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    let i: Int32;
    EntityRequestComponentsInterface.RequestComponent(ri, n"FrontDoorOccluder", n"IPlacedComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"BackDoorOccluder", n"IPlacedComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"radioMesh", n"IPlacedComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"radioDestroyed", n"IPlacedComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"movingPlatform", n"MovingPlatform", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"controller", this.m_controllerTypeName, true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"safeguardCollider", n"entColliderComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"offMeshConnection", n"OffMeshConnectionComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ui", n"worlduiWidgetComponent", false);
    i = 0;
    while i < ArraySize(this.m_advertismentNames) {
      EntityRequestComponentsInterface.RequestComponent(ri, this.m_advertismentNames[i], n"IPlacedComponent", false);
      i += 1;
    };
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    let i: Int32;
    this.m_movingPlatform = EntityResolveComponentsInterface.GetComponent(ri, n"movingPlatform") as MovingPlatform;
    this.m_radioMesh = EntityResolveComponentsInterface.GetComponent(ri, n"radioMesh") as IPlacedComponent;
    this.m_radioDestroyed = EntityResolveComponentsInterface.GetComponent(ri, n"radioDestroyed") as IPlacedComponent;
    this.m_frontDoorOccluder = EntityResolveComponentsInterface.GetComponent(ri, n"FrontDoorOccluder") as IPlacedComponent;
    this.m_backDoorOccluder = EntityResolveComponentsInterface.GetComponent(ri, n"BackDoorOccluder") as IPlacedComponent;
    ArrayPush(this.QuestSafeguardColliders, EntityResolveComponentsInterface.GetComponent(ri, n"safeguardCollider") as IPlacedComponent);
    this.m_offMeshConnectionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"offMeshConnection") as OffMeshConnectionComponent;
    this.m_uiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ui") as worlduiWidgetComponent;
    i = 0;
    while i < ArraySize(this.m_advertismentNames) {
      ArrayPush(this.m_advertisments, EntityResolveComponentsInterface.GetComponent(ri, this.m_advertismentNames[i]) as IPlacedComponent);
      i += 1;
    };
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as LiftController;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public final const func IsPlayerInsideLift() -> Bool {
    return (this.GetDevicePS() as LiftControllerPS).IsPlayerInsideLift();
  }

  protected func CreateBlackboard() -> Void {
    this.m_blackboard = IBlackboard.Create(GetAllBlackboardDefs().ElevatorDeviceBlackboard);
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return this.GetDevicePS().GetBlackboardDef();
  }

  protected func IsDeviceMovableScript() -> Bool {
    return true;
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    if !GameInstance.IsRestoringState(this.GetGame()) {
      this.SetMovementState(gamePlatformMovementState.Stopped);
    } else {
      if (this.GetDevicePS() as LiftControllerPS).IsMoving() {
        if !this.m_wasAnimationFastForwarded {
          this.FastForwardAnimations();
        };
      };
    };
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    if IsDefined(this.m_radioMesh) {
      (this.GetDevicePS() as LiftControllerPS).SetHasSpeaker(true);
      this.RefreshSpeaker();
    } else {
      this.PlayRadioStation();
    };
    this.RefreshAdsState();
  }

  protected func DetermineInteractionState(opt context: GetActionsContext) -> Void {
    if IsDefined(context.processInitiatorObject as PlayerPuppet) {
      if Equals(context.requestType, gamedeviceRequestType.Direct) {
        this.RefreshFloorsData_Event();
      };
    };
    this.DetermineInteractionState(context);
  }

  protected cb func OnInitializeFloorsData(evt: ref<RefreshFloorDataEvent>) -> Bool {
    let floorName: String;
    let arrivedAtEvent: ref<ArrivedAt> = new ArrivedAt();
    let teleportToEvent: ref<TeleportTo> = new TeleportTo();
    this.m_floors = (this.GetDevicePS() as LiftControllerPS).GetFloors();
    let activeFloor: Int32 = (this.GetDevicePS() as LiftControllerPS).GetActiveFloor();
    GameObject.PlayMetadataEvent(this, n"startMusic");
    GameObject.PlayMetadataEvent(this, n"unmuteMusic");
    floorName = ElevatorFloorSetup.GetFloorName(this.m_floors[activeFloor]);
    this.SendLiftDataToUIBlackboard(floorName, true);
    if Equals((this.GetDevicePS() as LiftControllerPS).GetMovementState(), gamePlatformMovementState.Stopped) {
      arrivedAtEvent.destinationName = n"startingFloor";
      arrivedAtEvent.data = activeFloor;
      this.QueueEvent(arrivedAtEvent);
      teleportToEvent.destinationNode = (this.GetDevicePS() as LiftControllerPS).GetFloorMarker(activeFloor);
      teleportToEvent.rootEntityPosition = this.GetWorldPosition();
      this.QueueEvent(teleportToEvent);
    } else {
      if (this.GetDevicePS() as LiftControllerPS).GetCachedGoToFloorAction() != -1 && (this.GetDevicePS() as LiftControllerPS).GetCachedGoToFloorAction() != activeFloor {
        this.SendLiftMovementLoadEvent();
        this.m_isLoadPerformed = true;
      };
    };
  }

  protected cb func OnSlaveStateChanged(evt: ref<PSDeviceChangedEvent>) -> Bool {
    this.RefreshFloorsAuthorizationData_Event();
    super.OnSlaveStateChanged(evt);
  }

  protected func UpdateDeviceState(opt isDelayed: Bool) -> Bool {
    if this.UpdateDeviceState(isDelayed) {
      this.RefreshUI(isDelayed);
      this.NotifyFloors();
      this.EvaluateOffMeshLinks();
      return true;
    };
    return false;
  }

  private final func RefreshFloorsData_Event() -> Void {
    let evt: ref<RefreshFloorDataEvent> = new RefreshFloorDataEvent();
    GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(this.GetDevicePS().GetID(), this.GetDevicePS().GetClassName(), evt);
  }

  private final func RefreshFloorsAuthorizationData_Event() -> Void {
    let evt: ref<RefreshFloorAuthorizationDataEvent> = new RefreshFloorAuthorizationDataEvent();
    GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(this.GetDevicePS().GetID(), this.GetDevicePS().GetClassName(), evt);
  }

  protected cb func OnDetach() -> Bool {
    super.OnDetach();
    GameObject.PlayMetadataEvent(this, n"stopMusic");
    (this.GetDevicePS() as LiftControllerPS).SetStartingFloor((this.GetDevicePS() as LiftControllerPS).GetActiveFloor());
  }

  public final const func GetMovingMode() -> Int32 {
    switch (this.GetDevicePS() as LiftControllerPS).GetMovementState() {
      case gamePlatformMovementState.Stopped:
        return 0;
      case gamePlatformMovementState.MovingUp:
        return 1;
      case gamePlatformMovementState.MovingDown:
        return -1;
      case gamePlatformMovementState.Paused:
        return 2;
    };
  }

  protected final func MoveToFloor(starting: Int32, ending: Int32, type: gameMovingPlatformMovementInitializationType, value: Float, opt destName: CName, opt shouldMuteSound: Bool) -> Void {
    if !(this.GetDevicePS() as LiftControllerPS).IsMoving() {
      if !shouldMuteSound {
        GameObject.PlayMetadataEvent(this, n"startMoving");
      };
      this.SendLiftDepartedEvent((this.GetDevicePS() as LiftControllerPS).GetActiveFloor());
      if starting != ending {
        this.UpdateAnimState(false, false, false);
      };
      this.SetIsMovingFromToFloor(starting, ending, value == 0.00);
      this.SendMoveToFloorEvent(starting, ending, type, value, destName);
    };
  }

  protected final func SendMoveToFloorEvent(starting: Int32, ending: Int32, type: gameMovingPlatformMovementInitializationType, value: Float, opt destName: CName) -> Void {
    let moveToEvent: ref<MoveTo> = new MoveTo();
    let dynamicMov: ref<MovingPlatformMovementDynamic> = new MovingPlatformMovementDynamic();
    dynamicMov.curveName = n"cosine";
    dynamicMov.SetInitData(type, value, (this.GetDevicePS() as LiftControllerPS).GetFloorMarker(starting), (this.GetDevicePS() as LiftControllerPS).GetFloorMarker(ending));
    moveToEvent.movement = dynamicMov;
    moveToEvent.data = ending;
    if NotEquals(destName, n"") {
      moveToEvent.destinationName = destName;
    };
    this.QueueEvent(moveToEvent);
    this.ToggleOccluders(true);
  }

  protected final func PauseMovement() -> Void {
    let timeWhenPaused: Float = this.m_movingPlatform.Pause();
    (this.GetDevicePS() as LiftControllerPS).SetTimeWhenPaused(timeWhenPaused);
    this.SetMovementState(gamePlatformMovementState.Paused);
    this.SetIsPausedBlackboard(true);
  }

  protected final func UnpauseMovement() -> Void {
    let timeWhenPaused: Float = (this.GetDevicePS() as LiftControllerPS).GetTimeWhenPaused();
    let movementState: gamePlatformMovementState = this.m_movingPlatform.Unpause(timeWhenPaused);
    this.SetMovementState(movementState);
    (this.GetDevicePS() as LiftControllerPS).SetTimeWhenPaused(0.00);
    this.SetIsPausedBlackboard(false);
  }

  protected final func StopMovement() -> Void {
    let moveToEvent: ref<MoveTo> = new MoveTo();
    let dynamicMov: ref<MovingPlatformMovementDynamic> = new MovingPlatformMovementDynamic();
    dynamicMov.curveName = n"cosine";
    dynamicMov.SetInitData(gameMovingPlatformMovementInitializationType.Speed, 0.00, (this.GetDevicePS() as LiftControllerPS).GetFloorMarker(0), (this.GetDevicePS() as LiftControllerPS).GetFloorMarker(0));
    moveToEvent.movement = dynamicMov;
    moveToEvent.data = 0;
    this.QueueEvent(moveToEvent);
  }

  protected cb func OnGoToFloor(evt: ref<GoToFloor>) -> Bool {
    GameObject.PlayMetadataEvent(this, n"ui_generic_set_14_positive");
    if FromVariant(evt.prop.first) != (this.GetDevicePS() as LiftControllerPS).GetActiveFloor() && !(this.GetDevicePS() as LiftControllerPS).IsMoving() {
      StatusEffectHelper.ApplyStatusEffect(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), t"BaseStatusEffect.TemporarilyBlockMovement");
      this.SendLiftStartDelayedEvent(FromVariant(evt.prop.first));
    };
  }

  protected final func SendLiftStartDelayedEvent(target: Int32) -> Void {
    let delayEvent: ref<LiftStartDelayEvent> = new LiftStartDelayEvent();
    delayEvent.targetFloor = target;
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, delayEvent, (this.GetDevicePS() as LiftControllerPS).GetLiftStartingDelay());
    (this.GetDevicePS() as LiftControllerPS).SetCachedGoToFloorAction(target);
    this.ToggleSafeguardColliders(true);
    GameObject.PlayMetadataEvent(this, n"startMoving");
    GameObject.PlayMetadataEvent(this, n"floorSelection");
    this.SendLiftDepartedEvent((this.GetDevicePS() as LiftControllerPS).GetActiveFloor());
    this.SetIsMovingFromToFloor((this.GetDevicePS() as LiftControllerPS).GetActiveFloor(), delayEvent.targetFloor, false);
    this.SendLiftDataToUIBlackboard(ElevatorFloorSetup.GetFloorName(this.m_floors[target]));
    this.UpdateAnimState(false, false, false);
  }

  protected final func PlayHandAnimationOnPlayer() -> Void {
    let adHocAnimEvent: ref<AdHocAnimationEvent> = new AdHocAnimationEvent();
    adHocAnimEvent.animationIndex = 3;
    adHocAnimEvent.useBothHands = false;
    adHocAnimEvent.unequipWeapon = false;
    GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject().QueueEvent(adHocAnimEvent);
  }

  protected cb func OnLiftStartDelayEvent(evt: ref<LiftStartDelayEvent>) -> Bool {
    let activeFloor: Int32 = (this.GetDevicePS() as LiftControllerPS).GetActiveFloor();
    if (this.GetDevicePS() as LiftControllerPS).IsLiftTravelTimeOverride() {
      this.SendMoveToFloorEvent(activeFloor, evt.targetFloor, gameMovingPlatformMovementInitializationType.Time, (this.GetDevicePS() as LiftControllerPS).GetLiftTravelTimeOverride());
    } else {
      this.SendMoveToFloorEvent(activeFloor, evt.targetFloor, gameMovingPlatformMovementInitializationType.Speed, (this.GetDevicePS() as LiftControllerPS).GetLiftSpeed());
    };
    (this.GetDevicePS() as LiftControllerPS).SetCachedGoToFloorAction(-1);
  }

  protected cb func OnQuestGoToFloor(evt: ref<QuestGoToFloor>) -> Bool {
    if FromVariant(evt.prop.first) != (this.GetDevicePS() as LiftControllerPS).GetActiveFloor() && !(this.GetDevicePS() as LiftControllerPS).IsMoving() {
      this.SendLiftStartDelayedEvent(FromVariant(evt.prop.first));
    };
  }

  protected cb func OnQuestForceGoToFloor(evt: ref<QuestForceGoToFloor>) -> Bool {
    if FromVariant(evt.prop.first) != (this.GetDevicePS() as LiftControllerPS).GetActiveFloor() && !(this.GetDevicePS() as LiftControllerPS).IsMoving() {
      this.SendLiftStartDelayedEvent(FromVariant(evt.prop.first));
    };
  }

  protected cb func OnQuestForceTeleportToFloor(evt: ref<QuestForceTeleportToFloor>) -> Bool {
    this.MoveToFloor(FromVariant(evt.prop.first), FromVariant(evt.prop.first));
  }

  protected final func MoveToFloor(start: Int32, target: Int32) -> Void {
    if (this.GetDevicePS() as LiftControllerPS).IsLiftTravelTimeOverride() {
      this.MoveToFloor(start, target, gameMovingPlatformMovementInitializationType.Time, (this.GetDevicePS() as LiftControllerPS).GetLiftTravelTimeOverride());
    } else {
      this.MoveToFloor(start, target, gameMovingPlatformMovementInitializationType.Speed, (this.GetDevicePS() as LiftControllerPS).GetLiftSpeed());
    };
  }

  protected cb func OnQuestStopElevator(evt: ref<QuestStopElevator>) -> Bool {
    this.PauseMovement();
    this.RefreshUI();
    GameObject.PlayMetadataEvent(this, n"stopMoving");
  }

  protected cb func OnQuestResumeElevator(evt: ref<QuestResumeElevator>) -> Bool {
    this.UnpauseMovement();
    this.RefreshUI();
    GameObject.PlayMetadataEvent(this, n"startMoving");
  }

  protected cb func OnQuestCloseAllDoors(evt: ref<QuestCloseAllDoors>) -> Bool {
    let shouldOpen: Bool = !FromVariant(evt.prop.first);
    this.UpdateAnimState(shouldOpen, shouldOpen, shouldOpen);
    if shouldOpen {
      this.ToggleSafeguardColliders(!shouldOpen);
      this.ToggleOccluders(!shouldOpen);
    };
  }

  protected cb func OnQuestToggleAds(evt: ref<QuestToggleAds>) -> Bool {
    this.RefreshAdsState();
  }

  protected final func RefreshAdsState() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_advertisments) {
      this.m_advertisments[i].Toggle((this.GetDevicePS() as LiftControllerPS).IsAdsEnabled());
      i += 1;
    };
  }

  protected cb func OnQuestSetRadioStation(evt: ref<QuestSetRadioStation>) -> Bool {
    this.PlayRadioStation();
  }

  protected cb func OnDisableRadio(evt: ref<QuestDisableRadio>) -> Bool {
    this.PlayRadioStation();
  }

  protected cb func OnCallElevator(evt: ref<CallElevator>) -> Bool {
    let activeFloor: Int32 = (this.GetDevicePS() as LiftControllerPS).GetActiveFloor();
    let caller: Int32 = evt.m_destination;
    if caller == activeFloor || Equals(ElevatorFloorSetup.GetFloorName(this.m_floors[caller]), ElevatorFloorSetup.GetFloorName(this.m_floors[activeFloor])) {
      this.UpdateAnimState(this.m_floors[activeFloor].doorShouldOpenFrontLeftRight[0], this.m_floors[activeFloor].doorShouldOpenFrontLeftRight[1], this.m_floors[activeFloor].doorShouldOpenFrontLeftRight[2]);
      this.SendArrivedAtFloorEvent((this.GetDevicePS() as LiftControllerPS).GetStartingFloor());
      return false;
    };
    this.MoveToFloor(activeFloor, caller);
  }

  private final func SendArrivedAtFloorEvent(activeFloor: Int32) -> Void {
    let floorID: PersistentID = (this.GetDevicePS() as LiftControllerPS).GetFloorPSID(activeFloor);
    let evt: ref<LiftArrivedEvent> = new LiftArrivedEvent();
    evt.floor = (this.GetDevicePS() as LiftControllerPS).GetActiveFloorDisplayName();
    GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(floorID, n"ElevatorFloorTerminalControllerPS", evt);
  }

  private final func SendLiftDepartedEvent(activeFloor: Int32) -> Void {
    let floorID: PersistentID = (this.GetDevicePS() as LiftControllerPS).GetFloorPSID(activeFloor);
    let evt: ref<LiftDepartedEvent> = new LiftDepartedEvent();
    evt.floor = (this.GetDevicePS() as LiftControllerPS).GetActiveFloorDisplayName();
    GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(floorID, n"ElevatorFloorTerminalControllerPS", evt);
  }

  private final func NotifyFloors() -> Void {
    let deviceChangedEvent: ref<PSDeviceChangedEvent> = new PSDeviceChangedEvent();
    deviceChangedEvent.persistentID = this.GetDevicePS().GetID();
    deviceChangedEvent.className = this.GetClassName();
    let i: Int32 = 0;
    while i < ArraySize(this.m_floors) {
      this.GetDevicePS().GetPersistencySystem().QueueEntityEvent((this.GetDevicePS() as LiftControllerPS).GetFloorID(i), deviceChangedEvent);
      i += 1;
    };
  }

  protected cb func OnLiftSetMovementStateEvent(evt: ref<LiftSetMovementStateEvent>) -> Bool {
    this.NotifyFloors();
  }

  protected cb func OnArrivedAt(evt: ref<ArrivedAt>) -> Bool {
    let activeFloor: Int32;
    (this.GetDevicePS() as LiftControllerPS).ChangeActiveFloor(evt.data);
    this.SendArrivedAtFloorEvent(evt.data);
    activeFloor = (this.GetDevicePS() as LiftControllerPS).GetActiveFloor();
    this.SetIsMovingFromToFloor(0, 0, false);
    this.RefreshUI();
    if !(this.GetDevicePS() as LiftControllerPS).IsAllDoorsClosed() {
      this.UpdateAnimState(this.m_floors[activeFloor].doorShouldOpenFrontLeftRight[0], this.m_floors[activeFloor].doorShouldOpenFrontLeftRight[1], this.m_floors[activeFloor].doorShouldOpenFrontLeftRight[2]);
      this.ToggleSafeguardColliders(false);
      this.ToggleOccluders(false);
    };
    GameObject.PlayMetadataEvent(this, n"destinationFloor");
    GameObject.PlayMetadataEvent(this, n"stopMoving");
    if (this.GetDevicePS() as LiftControllerPS).GetCachedGoToFloorAction() != -1 && (this.GetDevicePS() as LiftControllerPS).GetCachedGoToFloorAction() != evt.data && !this.m_isLoadPerformed {
      this.SendLiftMovementLoadEvent();
    };
  }

  protected cb func OnBeforeArrivedAt(evt: ref<BeforeArrivedAt>) -> Bool {
    GameObject.PlayMetadataEvent(this, n"preStopMoving");
  }

  private final func SetUsesSleepMode(allowSleepState: Bool) -> Void {
    AnimationControllerComponent.SetUsesSleepMode(this, allowSleepState);
  }

  private final func PlayRadioStation() -> Void {
    let station: RadioStationsMap;
    let stationIndex: Int32;
    if (this.GetDevicePS() as LiftControllerPS).IsSpeakerDestroyed() {
      GameObject.AudioSwitch(this, n"radio_station", n"station_none", n"radio");
      return;
    };
    stationIndex = (this.GetDevicePS() as LiftControllerPS).GetActiveRadioStationNumber();
    if stationIndex == -1 {
      GameObject.AudioSwitch(this, n"radio_station", n"station_none", n"radio");
    } else {
      station = (this.GetDevicePS() as LiftControllerPS).GetStationByIndex(stationIndex);
      GameObject.AudioSwitch(this, n"radio_station", station.soundEvent, n"radio");
    };
  }

  private final func UpdateAnimState(isOpenFront: Bool, isOpenLeft: Bool, isOpenRight: Bool) -> Void {
    let animFeature: ref<AnimFeature_SimpleDevice> = new AnimFeature_SimpleDevice();
    animFeature.isOpen = isOpenFront;
    animFeature.isOpenLeft = isOpenLeft;
    animFeature.isOpenRight = isOpenRight;
    AnimationControllerComponent.ApplyFeature(this, n"ElevatorInnerDoor", animFeature);
    if !this.m_wasAnimationFastForwarded {
      this.FastForwardAnimations();
    };
  }

  protected final func RefreshSpeaker() -> Void {
    this.m_radioMesh.Toggle(!(this.GetDevicePS() as LiftControllerPS).IsSpeakerDestroyed());
    this.m_radioDestroyed.Toggle((this.GetDevicePS() as LiftControllerPS).IsSpeakerDestroyed());
    this.PlayRadioStation();
  }

  protected final func SendLiftDataToUIBlackboard(displayFloor: String, opt force: Bool) -> Void {
    let activeFloor: Int32 = (this.GetDevicePS() as LiftControllerPS).GetActiveFloor();
    if !IsStringValid(displayFloor) {
      displayFloor = this.GetProperDisplayFloorNumber(activeFloor);
    };
    this.GetBlackboard().SetString(GetAllBlackboardDefs().ElevatorDeviceBlackboard.CurrentFloor, displayFloor, force);
  }

  private final func GetProperDisplayFloorNumber(floor: Int32) -> String {
    let displayFloor: String;
    if floor < 10 {
      displayFloor = "0" + ToString(floor);
    } else {
      displayFloor = ToString(floor);
    };
    return displayFloor;
  }

  protected final func SetMovementState(movementState: gamePlatformMovementState) -> Void {
    let movementStateEvent: ref<LiftSetMovementStateEvent> = new LiftSetMovementStateEvent();
    movementStateEvent.movementState = movementState;
    this.SendEventToDefaultPS(movementStateEvent);
  }

  protected final func SetIsPlayerInsideLift(value: Bool) -> Void {
    let evt: ref<SetIsPlayerInsideLiftEvent> = new SetIsPlayerInsideLiftEvent();
    evt.value = value;
    this.SendEventToDefaultPS(evt);
  }

  protected final func SetIsPausedBlackboard(value: Bool) -> Void {
    this.GetBlackboard().SetBool(GetAllBlackboardDefs().ElevatorDeviceBlackboard.isPaused, value, true);
    this.GetBlackboard().FireCallbacks();
  }

  protected final func SetIsPlayerScannedBlackboard(value: Bool) -> Void {
    let evt: ref<ScanPlayerDelayEvent>;
    let ui_scanningTime: Float;
    if !value {
      this.GetBlackboard().SetBool(GetAllBlackboardDefs().ElevatorDeviceBlackboard.isPlayerScanned, false, true);
      this.GetBlackboard().FireCallbacks();
    } else {
      evt = new ScanPlayerDelayEvent();
      ui_scanningTime = TweakDBInterface.GetFloat(this.GetTweakDBRecord() + t".UI_PlayerScanningTime", 2.00);
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, ui_scanningTime, true);
    };
  }

  protected final func SendLiftMovementLoadEvent() -> Void {
    let evt: ref<LiftMovementLoadEvent> = new LiftMovementLoadEvent();
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, 0.40, true);
  }

  protected cb func OnLiftMovementLoadEvent(evt: ref<LiftMovementLoadEvent>) -> Bool {
    this.SendLiftStartDelayedEvent((this.GetDevicePS() as LiftControllerPS).GetCachedGoToFloorAction());
    (this.GetDevicePS() as LiftControllerPS).SetCachedGoToFloorAction(-1);
    this.FastForwardAnimations();
  }

  protected cb func OnScanPlayerDelayEvent(evt: ref<ScanPlayerDelayEvent>) -> Bool {
    if (this.GetDevicePS() as LiftControllerPS).IsPlayerInsideLift() {
      this.GetBlackboard().SetBool(GetAllBlackboardDefs().ElevatorDeviceBlackboard.isPlayerScanned, true);
      this.GetBlackboard().FireCallbacks();
    };
  }

  private final func SetIsMovingFromToFloor(startingFloor: Int32, destinationFloor: Int32, teleport: Bool) -> Void {
    let isElevatorMoving: Bool;
    let movementStateEvent: ref<LiftSetMovementStateEvent> = new LiftSetMovementStateEvent();
    if teleport {
      movementStateEvent.movementState = gamePlatformMovementState.Stopped;
    } else {
      if startingFloor < destinationFloor {
        movementStateEvent.movementState = gamePlatformMovementState.MovingUp;
        isElevatorMoving = true;
      } else {
        if startingFloor > destinationFloor {
          movementStateEvent.movementState = gamePlatformMovementState.MovingDown;
          isElevatorMoving = true;
        } else {
          movementStateEvent.movementState = gamePlatformMovementState.Stopped;
        };
      };
    };
    if (this.GetDevicePS() as LiftControllerPS).IsPlayerInsideLift() {
      this.SetPlayerInsideElevatorBlackboard(true, isElevatorMoving);
    };
    this.SendEventToDefaultPS(movementStateEvent);
    (this.GetDevicePS() as LiftControllerPS).SetMovementState(movementStateEvent.movementState);
    return;
  }

  private func InitializeScreenDefinition() -> Void {
    if !TDBID.IsValid(this.m_screenDefinition.screenDefinition) {
      this.m_screenDefinition.screenDefinition = t"DevicesUIDefinitions.Terminal_9x16";
    };
    if !TDBID.IsValid(this.m_screenDefinition.style) {
      this.m_screenDefinition.style = t"DevicesUIStyles.Zetatech";
    };
  }

  protected cb func OnAreaEnter(trigger: ref<AreaEnteredEvent>) -> Bool {
    this.SetPlayerInsideElevatorBlackboard(true);
    this.SetIsPlayerInsideLift(true);
    this.SetIsPlayerScannedBlackboard(true);
  }

  protected cb func OnAreaExit(trigger: ref<AreaExitedEvent>) -> Bool {
    this.SetPlayerInsideElevatorBlackboard(false);
    this.SetIsPlayerInsideLift(false);
    this.SetIsPlayerScannedBlackboard(false);
  }

  private final func SetPlayerInsideElevatorBlackboard(isInside: Bool, opt isElevatorMoving: Bool) -> Void {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.GetGame());
    let blackboard: ref<IBlackboard> = blackboardSystem.GetLocalInstanced(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject().GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    blackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsPlayerInsideElevator, isInside);
    blackboard.SetVariant(GetAllBlackboardDefs().PlayerStateMachine.CurrentElevator, ToVariant(this));
    if !isInside {
      isElevatorMoving = false;
    };
    blackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsPlayerInsideMovingElevator, isElevatorMoving);
  }

  private final func GetPlayerInsideElevatorBlackboard() -> Bool {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.GetGame());
    let blackboard: ref<IBlackboard> = blackboardSystem.GetLocalInstanced(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject().GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return blackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsPlayerInsideElevator);
  }

  protected final func ToggleSafeguardColliders(value: Bool) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.QuestSafeguardColliders) {
      if Equals(this.QuestSafeguardColliders[i].IsEnabled(), value) {
        return;
      };
      this.QuestSafeguardColliders[i].Toggle(value);
      i += 1;
    };
  }

  public final static func IsPlayerInsideElevator(game: GameInstance) -> Bool {
    let blackboard: ref<IBlackboard>;
    let blackboardSystem: ref<BlackboardSystem>;
    if !GameInstance.IsValid(game) {
      return false;
    };
    blackboardSystem = GameInstance.GetBlackboardSystem(game);
    blackboard = blackboardSystem.GetLocalInstanced(GameInstance.GetPlayerSystem(game).GetLocalPlayerControlledGameObject().GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return blackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsPlayerInsideElevator);
  }

  public final static func GetCurrentElevator(game: GameInstance, out elevator: wref<GameObject>) -> Bool {
    let blackboard: ref<IBlackboard>;
    let blackboardSystem: ref<BlackboardSystem>;
    if !GameInstance.IsValid(game) {
      elevator = null;
      return false;
    };
    blackboardSystem = GameInstance.GetBlackboardSystem(game);
    blackboard = blackboardSystem.GetLocalInstanced(GameInstance.GetPlayerSystem(game).GetLocalPlayerControlledGameObject().GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    if blackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsPlayerInsideElevator) {
      elevator = FromVariant(blackboard.GetVariant(GetAllBlackboardDefs().PlayerStateMachine.CurrentElevator));
    };
    if IsDefined(elevator) {
      return true;
    };
    return false;
  }

  protected final func ToggleOccluders(toggle: Bool) -> Void {
    let hasBackDoor: Bool;
    let hasFrontDoor: Bool;
    if IsDefined(this.m_frontDoorOccluder) {
      hasFrontDoor = true;
    };
    if IsDefined(this.m_backDoorOccluder) {
      hasBackDoor = true;
    };
    if toggle {
      if hasFrontDoor {
        this.m_frontDoorOccluder.Toggle(true);
      };
      if hasBackDoor {
        this.m_backDoorOccluder.Toggle(true);
      };
    } else {
      if this.m_floors[(this.GetDevicePS() as LiftControllerPS).GetActiveFloor()].doorShouldOpenFrontLeftRight[0] {
        if hasFrontDoor {
          this.m_frontDoorOccluder.Toggle(false);
        };
      };
      if this.m_floors[(this.GetDevicePS() as LiftControllerPS).GetActiveFloor()].doorShouldOpenFrontLeftRight[1] {
        if hasBackDoor {
          this.m_backDoorOccluder.Toggle(false);
        };
      };
    };
  }

  public func OnMaraudersMapDeviceDebug(sink: ref<MaraudersMapDevicesSink>) -> Void {
    let iter: Int32;
    let keycards: array<TweakDBID>;
    let persistentFloors: array<ElevatorFloorSetup>;
    this.OnMaraudersMapDeviceDebug(sink);
    sink.BeginCategory("LIFT DEVICE");
    sink.EndCategory();
    persistentFloors = (this.GetDevicePS() as LiftControllerPS).GetFloors();
    keycards = this.GetDevicePS().GetKeycards();
    sink.PushString("StartingFloor - ", ToString((this.GetDevicePS() as LiftControllerPS).GetStartingFloor()));
    sink.PushString("Movement State - ", ToString((this.GetDevicePS() as LiftControllerPS).GetMovementState()));
    sink.PushString("Has Speaker - ", ToString((this.GetDevicePS() as LiftControllerPS).HasSpeaker()));
    sink.PushString("Speaker Fact - ", ToString((this.GetDevicePS() as LiftControllerPS).GetSpeakerDestroyedQuestFact()));
    iter = 0;
    while iter < ArraySize(persistentFloors) {
      sink.PushString("FloorData ", ToString(iter));
      sink.PushBool("Is Inactive", persistentFloors[iter].m_isInactive);
      sink.PushBool("Is Hidden", persistentFloors[iter].m_isHidden);
      sink.PushString("Floor Name", persistentFloors[iter].m_floorName);
      sink.PushString("Floor Marker", ToString(persistentFloors[iter].m_floorMarker));
      iter = iter + 1;
    };
    sink.PushString("KEYCARDS: ", "");
    iter = 0;
    while iter < ArraySize(keycards) {
      sink.PushString("Keycard" + IntToString(iter) + " ", TDBID.ToStringDEBUG(keycards[iter]));
      iter = iter + 1;
    };
  }

  protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
    if (this.GetDevicePS() as LiftControllerPS).HasSpeaker() && !(this.GetDevicePS() as LiftControllerPS).IsSpeakerDestroyed() {
      if this.m_radioMesh == evt.hitComponent {
        (this.GetDevicePS() as LiftControllerPS).SetSpeakerDestroyed(true);
        this.RefreshSpeaker();
        SetFactValue(this.GetGame(), (this.GetDevicePS() as LiftControllerPS).GetSpeakerDestroyedQuestFact(), 1);
        GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.Start, (this.GetDevicePS() as LiftControllerPS).GetSpeakerDestroyedVFX());
      };
    };
  }

  protected cb func OnRefreshPlayerAuthorizationEvent(evt: ref<RefreshPlayerAuthorizationEvent>) -> Bool {
    GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(this.GetDevicePS().GetID(), this.GetDevicePS().GetClassName(), evt);
  }

  private final func EvaluateOffMeshLinks() -> Void {
    let ps: ref<LiftControllerPS>;
    if this.m_offMeshConnectionComponent == null {
      return;
    };
    ps = this.GetDevicePS() as LiftControllerPS;
    if ps.IsDisabled() || ps.IsOFF() || ps.IsUnpowered() {
      this.DisableOffMeshConnections();
    } else {
      if ps.IsON() {
        this.EnableOffMeshConnections();
      };
    };
  }

  protected final func EnableOffMeshConnections() -> Void {
    if this.m_offMeshConnectionComponent != null {
      this.m_offMeshConnectionComponent.EnableForPlayer();
    };
  }

  protected final func DisableOffMeshConnections() -> Void {
    if this.m_offMeshConnectionComponent != null {
      this.m_offMeshConnectionComponent.DisableForPlayer();
    };
  }
}
