
public class LiftStatus extends BaseDeviceStatus {

  public let m_libraryName: CName;

  public final func CreateActionWidgetPackage(libraryName: CName, authorizationTextOverride: String) -> Void {
    this.m_libraryName = libraryName;
    this.CreateActionWidgetPackage();
    if NotEquals(authorizationTextOverride, "") {
      this.m_actionWidgetPackage.displayName = authorizationTextOverride;
    } else {
      this.m_actionWidgetPackage.displayName = "LocKey#210";
    };
  }

  public func GetInkWidgetTweakDBID() -> TweakDBID {
    if Equals(this.m_libraryName, n"authorization") {
      return t"DevicesUIDefinitions.AuthorizationBlockedActionWidget";
    };
    return t"DevicesUIDefinitions.LiftDisabledActionWidget";
  }
}

public class GoToFloor extends ActionBool {

  public final func SetProperties(floor: Int32) -> Void {
    this.actionName = n"GoToFloor";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_ElevatorInt(n"floorNumber", floor, floor);
  }

  public const func GetCurrentDisplayString() -> String {
    return this.GetProperDisplayFloorNumber(FromVariant(this.prop.second));
  }

  private final const func GetProperDisplayFloorNumber(floor: Int32) -> String {
    let displayFloor: String;
    if floor < 10 {
      displayFloor = "0" + ToString(floor);
    } else {
      displayFloor = ToString(floor);
    };
    return displayFloor;
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if GoToFloor.IsAvailable(device) && GoToFloor.IsClearanceValid(context.clearance) && GoToFloor.IsContextValid(context) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsDisabled() {
      return false;
    };
    if device.IsUnpowered() {
      return false;
    };
    if device.IsDeviceSecured() {
      return false;
    };
    if !device.IsON() {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetInteractiveClearance()) {
      return true;
    };
    return false;
  }

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    if Equals(context.requestType, gamedeviceRequestType.Internal) {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "go_to_floor";
  }

  public func GetInkWidgetLibraryPath() -> ResRef {
    return r"base\\movies\\misc\\distraction_generic.bk2";
  }

  public final func GetInkWidgetLibraryID(numberOfFloors: Int32) -> CName {
    return n"";
  }

  public final func GetInkWidgetTweakDBID(numberOfFloors: Int32, currentFloor: Int32) -> TweakDBID {
    if currentFloor == FromVariant(this.prop.second) {
      return t"DevicesUIDefinitions.GoToFloorCurrentActionWidget";
    };
    return t"DevicesUIDefinitions.GoToFloorActionWidget";
  }

  public final func CreateActionWidgetPackage(numberOfFloors: Int32, currentFloor: Int32, displayFloor: String, IsAuthorized: Bool, opt actions: array<ref<DeviceAction>>) -> Void {
    this.CreateActionWidgetPackage(actions);
    if !IsStringValid(displayFloor) {
      displayFloor = this.GetCurrentDisplayString();
    };
    this.m_actionWidgetPackage.libraryID = this.GetInkWidgetLibraryID(numberOfFloors);
    this.m_actionWidgetPackage.widgetName = ToString(this.GetActionName()) + displayFloor;
    this.m_actionWidgetPackage.displayName = displayFloor;
    this.m_actionWidgetPackage.widgetTweakDBID = this.GetInkWidgetTweakDBID(numberOfFloors, currentFloor);
    if !IsAuthorized {
      this.m_actionWidgetPackage.isWidgetInactive = true;
      this.m_actionWidgetPackage.widgetTweakDBID = t"DevicesUIDefinitions.GoToFloorActionWidget";
      this.m_actionWidgetPackage.displayName = "LocKey#1312";
    };
    this.ResolveActionWidgetTweakDBData();
  }
}

public class QuestGoToFloor extends ActionInt {

  public final func SetProperties(floor: Int32) -> Void {
    this.actionName = n"GoToFloor";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Int(n"floorNumber", floor);
  }
}

public class QuestForceGoToFloor extends ActionInt {

  public final func SetProperties(floor: Int32) -> Void {
    this.actionName = n"ForceGoToFloor";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Int(n"floorNumber", floor);
  }
}

public class QuestForceTeleportToFloor extends ActionInt {

  public final func SetProperties(floor: Int32) -> Void {
    this.actionName = n"ForceTeleportToFloor";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Int(n"Floor", floor);
  }
}

public class QuestStopElevator extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestStopElevator";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestStopElevator", true, n"QuestStopElevator", n"QuestStopElevator");
  }
}

public class QuestResumeElevator extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestResumeElevator";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestResumeElevator", true, n"QuestResumeElevator", n"QuestResumeElevator");
  }
}

public class QuestShowFloor extends ActionInt {

  public final func SetProperties(floor: Int32) -> Void {
    this.actionName = n"ShowFloor";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Int(n"floorNumber", floor);
  }
}

public class QuestHideFloor extends ActionInt {

  public final func SetProperties(floor: Int32) -> Void {
    this.actionName = n"HideFloor";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Int(n"floorNumber", floor);
  }
}

public class QuestSetFloorActive extends ActionInt {

  public final func SetProperties(floor: Int32) -> Void {
    this.actionName = n"SetFloorActive";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Int(n"floorNumber", floor);
  }
}

public class QuestSetFloorInactive extends ActionInt {

  public final func SetProperties(floor: Int32) -> Void {
    this.actionName = n"SetFloorInactive";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Int(n"floorNumber", floor);
  }
}

public class QuestSetLiftSpeed extends ActionFloat {

  public final func SetProperties(speed: Float) -> Void {
    this.actionName = n"SetLiftSpeed";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Float(n"LiftSpeed", speed);
  }
}

public class QuestSetLiftTravelTimeOverride extends ActionFloat {

  public final func SetProperties(speed: Float) -> Void {
    this.actionName = n"QuestSetLiftTravelTimeOverride";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Float(n"LiftTravelTimeOverride", speed);
  }
}

public class QuestEnableLiftTravelTimeOverride extends ActionBool {

  public final func SetProperties(toggle: Bool) -> Void {
    this.actionName = n"QuestEnableLiftTravelTimeOverride";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestEnableLiftTravelTimeOverride", toggle, n"QuestEnableLiftTravelTimeOverride", n"QuestEnableLiftTravelTimeOverride");
  }
}

public class QuestDisableLiftTravelTimeOverride extends ActionBool {

  public final func SetProperties(toggle: Bool) -> Void {
    this.actionName = n"QuestDisableLiftTravelTimeOverride";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestDisableLiftTravelTimeOverride", toggle, n"QuestDisableLiftTravelTimeOverride", n"QuestDisableLiftTravelTimeOverride");
  }
}

public class LiftController extends MasterController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class LiftControllerPS extends MasterControllerPS {

  protected persistent let m_liftSetup: LiftSetup;

  private persistent let m_activeFloor: Int32;

  @default(LiftControllerPS, -1)
  private let m_targetFloor: Int32;

  private persistent let m_movementState: gamePlatformMovementState;

  private persistent let m_floors: array<ElevatorFloorSetup>;

  private persistent let m_floorIDs: array<EntityID>;

  private persistent let m_floorPSIDs: array<PersistentID>;

  private persistent let m_floorsAuthorization: array<Bool>;

  private persistent let m_timeOnPause: Float;

  private persistent let m_isPlayerInsideLift: Bool;

  private persistent let m_isSpeakerDestroyed: Bool;

  private let m_hasSpeaker: Bool;

  protected let m_stations: array<RadioStationsMap>;

  @default(LiftControllerPS, -1)
  private persistent let m_cachedGoToFloorAction: Int32;

  private persistent let m_isAllDoorsClosed: Bool;

  private persistent let m_isAdsDisabled: Bool;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#101";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
    this.m_activeFloor = this.m_liftSetup.m_startingFloorTerminal;
  }

  protected func GameAttached() -> Void {
    this.InitializeFloorsData();
  }

  private final func InitializeRadioStations() -> Void {
    ArrayPush(this.m_stations, this.CreateRadioStation(n"radio_station_02_aggro_ind", "Gameplay-Devices-Radio-RadioStationAggroIndie"));
    ArrayPush(this.m_stations, this.CreateRadioStation(n"radio_station_03_elec_ind", "Gameplay-Devices-Radio-RadioStationElectroIndie"));
    ArrayPush(this.m_stations, this.CreateRadioStation(n"radio_station_04_hiphop", "Gameplay-Devices-Radio-RadioStationHipHop"));
    ArrayPush(this.m_stations, this.CreateRadioStation(n"radio_station_07_aggro_techno", "Gameplay-Devices-Radio-RadioStationAggroTechno"));
    ArrayPush(this.m_stations, this.CreateRadioStation(n"radio_station_09_downtempo", "Gameplay-Devices-Radio-RadioStationDownTempo"));
    ArrayPush(this.m_stations, this.CreateRadioStation(n"radio_station_01_att_rock", "Gameplay-Devices-Radio-RadioStationAttRock"));
    ArrayPush(this.m_stations, this.CreateRadioStation(n"radio_station_05_pop", "Gameplay-Devices-Radio-RadioStationPop"));
    ArrayPush(this.m_stations, this.CreateRadioStation(n"radio_station_10_latino", "Gameplay-Devices-Radio-RadioStationLatino"));
    ArrayPush(this.m_stations, this.CreateRadioStation(n"radio_station_11_metal", "Gameplay-Devices-Radio-RadioStationMetal"));
  }

  private final func CreateRadioStation(SoundEvt: CName, ChannelName: String) -> RadioStationsMap {
    let station: RadioStationsMap;
    station.soundEvent = SoundEvt;
    station.channelName = ChannelName;
    return station;
  }

  public final func GetStationByIndex(index: Int32) -> RadioStationsMap {
    let invalidStation: RadioStationsMap;
    if ArraySize(this.m_stations) == 0 {
      this.InitializeRadioStations();
    };
    if index < 0 || index >= ArraySize(this.m_stations) {
      return invalidStation;
    };
    return this.m_stations[index];
  }

  public const func IsPlayerAuthorized() -> Bool {
    if PreventionSystem.IsChasingPlayer(this.GetGameInstance()) {
      return false;
    };
    return this.IsPlayerAuthorized();
  }

  protected func GetInkWidgetTweakDBID(context: GetActionsContext) -> TweakDBID {
    return t"DevicesUIDefinitions.ElevatorFloorDeviceWidget";
  }

  public final const func GetStartingFloor() -> Int32 {
    return this.m_liftSetup.m_startingFloorTerminal;
  }

  public final func SetStartingFloor(terminalNumber: Int32) -> Void {
    this.m_liftSetup.m_startingFloorTerminal = terminalNumber;
  }

  public final const func GetLiftSpeed() -> Float {
    if this.IsPlayerInsideLift() {
      return this.m_liftSetup.m_liftSpeed;
    };
    return this.m_liftSetup.m_emptyLiftSpeedMultiplier * this.m_liftSetup.m_liftSpeed;
  }

  public final const func GetLiftTravelTimeOverride() -> Float {
    return this.m_liftSetup.m_liftTravelTimeOverride;
  }

  public final const func HasSpeaker() -> Bool {
    return this.m_hasSpeaker;
  }

  public final const func IsAdsDisabled() -> Bool {
    return this.m_isAdsDisabled;
  }

  public final const func IsAdsEnabled() -> Bool {
    return !this.m_isAdsDisabled;
  }

  public final func SetHasSpeaker(value: Bool) -> Void {
    this.m_hasSpeaker = value;
  }

  public final const func GetCachedGoToFloorAction() -> Int32 {
    return this.m_cachedGoToFloorAction;
  }

  public final func SetCachedGoToFloorAction(value: Int32) -> Void {
    this.m_cachedGoToFloorAction = value;
  }

  public final func GetSpeakerDestroyedQuestFact() -> CName {
    return this.m_liftSetup.m_speakerDestroyedQuestFact;
  }

  public final func GetSpeakerDestroyedVFX() -> CName {
    return this.m_liftSetup.m_speakerDestroyedVFX;
  }

  public final func IsAllDoorsClosed() -> Bool {
    return this.m_isAllDoorsClosed;
  }

  public final func IsSpeakerDestroyed() -> Bool {
    return this.m_isSpeakerDestroyed;
  }

  public final func SetSpeakerDestroyed(value: Bool) -> Void {
    this.m_isSpeakerDestroyed = value;
  }

  public final const func GetActiveRadioStationNumber() -> Int32 {
    return this.m_liftSetup.m_radioStationNumer;
  }

  public final const quest func IsLiftTravelTimeOverride() -> Bool {
    return this.m_liftSetup.m_isLiftTravelTimeOverride;
  }

  public final const func GetLiftStartingDelay() -> Float {
    return this.m_liftSetup.m_liftStartingDelay;
  }

  public final const func GetFloorID(number: Int32) -> EntityID {
    return this.m_floorIDs[number];
  }

  public final const func GetFloorPSID(number: Int32) -> PersistentID {
    return this.m_floorPSIDs[number];
  }

  public final const func GetFloors() -> array<ElevatorFloorSetup> {
    return this.m_floors;
  }

  public final const func GetFloorMarker(floorNumber: Int32) -> NodeRef {
    return this.m_floors[floorNumber].m_floorMarker;
  }

  public final func SetIsPlayerInsideLift(state: Bool) -> Void {
    this.m_isPlayerInsideLift = state;
  }

  public final const quest func IsPlayerInsideLift() -> Bool {
    return this.m_isPlayerInsideLift;
  }

  public final func ChangeActiveFloor(newFloor: Int32) -> Void {
    this.m_activeFloor = newFloor;
    this.m_targetFloor = -1;
    this.ForcePersistentStateChanged();
  }

  public final func ActionGoToFloor(numberOfFloors: Int32, currentFloor: Int32, floor: Int32, displayFloor: String, IsAuthorized: Bool) -> ref<GoToFloor> {
    let action: ref<GoToFloor> = new GoToFloor();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(floor);
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage(numberOfFloors, currentFloor, displayFloor, IsAuthorized);
    return action;
  }

  private final func ActionCallElevator(isElevatorAtThisFloor: Bool, destination: Int32) -> ref<CallElevator> {
    let action: ref<CallElevator> = new CallElevator();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(destination);
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage(isElevatorAtThisFloor);
    return action;
  }

  public final func ActionQuickHackAuthorization() -> ref<QuickHackAuthorization> {
    let action: ref<QuickHackAuthorization> = new QuickHackAuthorization();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  public final func ActionQuestShowFloor() -> ref<QuestShowFloor> {
    let action: ref<QuestShowFloor> = new QuestShowFloor();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties(-9999);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func ActionQuestHideFloor() -> ref<QuestHideFloor> {
    let action: ref<QuestHideFloor> = new QuestHideFloor();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties(-9999);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func ActionQuestSetFloorActive() -> ref<QuestSetFloorActive> {
    let action: ref<QuestSetFloorActive> = new QuestSetFloorActive();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties(-9999);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func ActionQuestSetFloorInactive() -> ref<QuestSetFloorInactive> {
    let action: ref<QuestSetFloorInactive> = new QuestSetFloorInactive();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties(-9999);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func ActionQuestSetRadioStation() -> ref<QuestSetRadioStation> {
    let action: ref<QuestSetRadioStation> = new QuestSetRadioStation();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties(-9999);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func ActionQuestDisableRadio() -> ref<QuestDisableRadio> {
    let action: ref<QuestDisableRadio> = new QuestDisableRadio();
    action.SetUp(this);
    action.AddDeviceName(this.m_deviceName);
    action.SetProperties(true);
    return action;
  }

  public final func ActionQuestCloseAllDoors(value: Bool) -> ref<QuestCloseAllDoors> {
    let action: ref<QuestCloseAllDoors> = new QuestCloseAllDoors();
    action.SetUp(this);
    action.AddDeviceName(this.m_deviceName);
    action.SetProperties(value);
    return action;
  }

  public final func ActionQuestToggleAds(value: Bool) -> ref<QuestToggleAds> {
    let action: ref<QuestToggleAds> = new QuestToggleAds();
    action.SetUp(this);
    action.AddDeviceName(this.m_deviceName);
    action.SetProperties(value);
    return action;
  }

  public final func ActionQuestGoToFloor() -> ref<QuestGoToFloor> {
    let action: ref<QuestGoToFloor> = new QuestGoToFloor();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties(-9999);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func ActionQuestForceGoToFloor() -> ref<QuestForceGoToFloor> {
    let action: ref<QuestForceGoToFloor> = new QuestForceGoToFloor();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties(-9999);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func ActionQuestForceTeleportToFloor() -> ref<QuestForceTeleportToFloor> {
    let action: ref<QuestForceTeleportToFloor> = new QuestForceTeleportToFloor();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties(-9999);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func ActionQuestStopElevator() -> ref<QuestStopElevator> {
    let action: ref<QuestStopElevator> = new QuestStopElevator();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func ActionQuestResumeElevator() -> ref<QuestResumeElevator> {
    let action: ref<QuestResumeElevator> = new QuestResumeElevator();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func ActionQuestSetLiftSpeed() -> ref<QuestSetLiftSpeed> {
    let action: ref<QuestSetLiftSpeed> = new QuestSetLiftSpeed();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties(-9999.00);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func ActionQuestSetLiftTravelTimeOverride() -> ref<QuestSetLiftTravelTimeOverride> {
    let action: ref<QuestSetLiftTravelTimeOverride> = new QuestSetLiftTravelTimeOverride();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties(-9999.00);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func ActionQuestEnableLiftTravelTimeOverride() -> ref<QuestEnableLiftTravelTimeOverride> {
    let action: ref<QuestEnableLiftTravelTimeOverride> = new QuestEnableLiftTravelTimeOverride();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties(Cast(-9999));
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func ActionQuestDisableLiftTravelTimeOverride() -> ref<QuestDisableLiftTravelTimeOverride> {
    let action: ref<QuestDisableLiftTravelTimeOverride> = new QuestDisableLiftTravelTimeOverride();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties(Cast(-9999));
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionLiftStatus(opt libraryName: CName) -> ref<LiftStatus> {
    let action: ref<LiftStatus> = new LiftStatus();
    action.clearanceLevel = DefaultActionsParametersHolder.GetStatusClearance();
    action.SetUp(this);
    action.SetProperties(this);
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage(libraryName, this.m_liftSetup.m_authorizationTextOverride);
    return action;
  }

  protected func ActionAuthorizeUser() -> ref<AuthorizeUser> {
    let action: ref<AuthorizeUser> = new AuthorizeUser();
    action.clearanceLevel = DefaultActionsParametersHolder.GetAuthorizeUserClearance();
    action.SetUp(this);
    action.SetProperties(this.GetPasswords());
    action.AddDeviceName(this.GetDeviceName());
    if PreventionSystem.IsChasingPlayer(this.GetGameInstance()) {
      action.CreateActionWidgetPackage(n"elevator", "LocKey#45384");
    } else {
      action.CreateActionWidgetPackage(n"elevator", this.m_liftSetup.m_authorizationTextOverride);
    };
    return action;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    let floorName: String;
    let i: Int32;
    let scriptableAction: ref<ScriptableDeviceAction>;
    if Equals(this.m_deviceState, EDeviceStatus.OFF) || Equals(this.m_deviceState, EDeviceStatus.UNPOWERED) || Equals(this.m_deviceState, EDeviceStatus.DISABLED) {
      ArrayPush(actions, this.ActionSetExposeQuickHacks());
      ArrayPush(actions, this.ActionLiftStatus());
      ArrayPush(actions, this.ActionSetDevicePowered());
      return false;
    };
    if !this.IsPlayerAuthorized() && !context.ignoresAuthorization {
      if Equals(context.requestType, gamedeviceRequestType.Internal) {
        ArrayPush(actions, this.ActionAuthorizeUser());
      } else {
        if Equals(context.requestType, gamedeviceRequestType.External) {
          scriptableAction = this.ActionLiftStatus(n"authorization");
          scriptableAction.SetDurationValue(0.70);
          ArrayPush(actions, scriptableAction);
        };
      };
      return false;
    };
    this.GetActions(actions, context);
    i = ArraySize(actions) - 1;
    while i >= 0 {
      if Equals(actions[i].actionName, n"TogglePower") || Equals(actions[i].actionName, n"AuthorizeUser") {
        ArrayErase(actions, i);
      };
      i -= 1;
    };
    if NotEquals(this.m_movementState, gamePlatformMovementState.Stopped) {
      return false;
    };
    if Equals(context.requestType, gamedeviceRequestType.Internal) {
      i = ArraySize(this.m_floors) - 1;
      while i >= 0 {
        if !this.m_floors[i].m_isHidden {
          floorName = ElevatorFloorSetup.GetFloorName(this.m_floors[i]);
          if this.m_floors[i].m_isInactive {
            scriptableAction = this.ActionGoToFloor(ArraySize(this.m_floors), this.GetActiveFloor(), i, floorName, this.m_floorsAuthorization[i]);
            scriptableAction.SetInactiveWithReason(false, "LocKey#42213");
            ArrayPush(actions, scriptableAction);
          } else {
            ArrayPush(actions, this.ActionGoToFloor(ArraySize(this.m_floors), this.GetActiveFloor(), i, floorName, this.m_floorsAuthorization[i]));
          };
        };
        i -= 1;
      };
    } else {
      if Equals(context.requestType, gamedeviceRequestType.External) {
        i = ArraySize(this.m_floors) - 1;
        while i >= 0 {
          if context.requestorID == this.m_floorIDs[i] {
            if this.GetActiveFloor() == i {
              ArrayPush(actions, this.ActionCallElevator(true, i));
            } else {
              ArrayPush(actions, this.ActionCallElevator(false, i));
            };
          };
          i -= 1;
        };
      };
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionQuickHackAuthorization();
    currentAction.SetObjectActionID(t"DeviceAction.OverrideAttitudeClassHack");
    currentAction.SetInactiveWithReason(!this.WasQuickHacked(), "LocKey#7004");
    ArrayPush(actions, currentAction);
    this.FinalizeGetQuickHackActions(actions, context);
  }

  public func GetQuestActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(outActions, context);
    if Clearance.IsInRange(context.clearance, DefaultActionsParametersHolder.GetQuestClearance()) {
      ArrayPush(outActions, this.ActionQuestGoToFloor());
      ArrayPush(outActions, this.ActionQuestForceGoToFloor());
      ArrayPush(outActions, this.ActionQuestForceTeleportToFloor());
      ArrayPush(outActions, this.ActionQuestStopElevator());
      ArrayPush(outActions, this.ActionQuestResumeElevator());
      ArrayPush(outActions, this.ActionQuestShowFloor());
      ArrayPush(outActions, this.ActionQuestHideFloor());
      ArrayPush(outActions, this.ActionQuestSetFloorActive());
      ArrayPush(outActions, this.ActionQuestSetFloorInactive());
      ArrayPush(outActions, this.ActionQuestSetLiftSpeed());
      ArrayPush(outActions, this.ActionQuestSetLiftTravelTimeOverride());
      ArrayPush(outActions, this.ActionQuestEnableLiftTravelTimeOverride());
      ArrayPush(outActions, this.ActionQuestDisableLiftTravelTimeOverride());
      ArrayPush(outActions, this.ActionQuestSetRadioStation());
      ArrayPush(outActions, this.ActionQuestDisableRadio());
      ArrayPush(outActions, this.ActionQuestCloseAllDoors(true));
      ArrayPush(outActions, this.ActionQuestCloseAllDoors(false));
      ArrayPush(outActions, this.ActionQuestToggleAds(true));
      ArrayPush(outActions, this.ActionQuestToggleAds(false));
    };
  }

  public final func OnGoToFloor(evt: ref<GoToFloor>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus>;
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    cachedStatus = this.GetDeviceStatusAction();
    if this.IsUnpowered() || this.IsDisabled() || !this.IsON() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Unpowered, Disabled or Off");
    };
    this.GetFloorAuthorizationFromSlaves();
    if !this.m_floorsAuthorization[FromVariant(evt.prop.first)] {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Not Authorized");
    };
    if this.m_activeFloor == FromVariant(evt.prop.first) {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "OnGoToFloor: Lift is on given floor");
    };
    this.m_targetFloor = FromVariant(evt.prop.first);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnCallElevator(evt: ref<CallElevator>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus>;
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    cachedStatus = this.GetDeviceStatusAction();
    if this.IsUnpowered() || this.IsDisabled() || !this.IsON() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Unpowered, Disabled or Off");
    };
    this.m_targetFloor = FromVariant(evt.prop.first);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnQuickHackAuthorization(evt: ref<QuickHackAuthorization>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus>;
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    cachedStatus = this.GetDeviceStatusAction();
    this.TurnAuthorizationModuleOFF();
    this.m_wasQuickHacked = true;
    this.SendSetAuthorizationModuleOFFToSlaves();
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func SendSetAuthorizationModuleOFFToSlaves() -> Void {
    let evt: ref<SetAuthorizationModuleOFF> = new SetAuthorizationModuleOFF();
    let devices: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(devices) {
      if IsDefined(devices[i] as ElevatorFloorTerminalControllerPS) {
        this.GetPersistencySystem().QueuePSEvent(devices[i].GetID(), devices[i].GetClassName(), evt);
      };
      i += 1;
    };
  }

  public final func OnQuestGoToFloor(evt: ref<QuestGoToFloor>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    this.m_targetFloor = FromVariant(evt.prop.first);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.ProcessUnstreamedLiftMovement(FromVariant(evt.prop.first));
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnQuestShowFloor(evt: ref<QuestShowFloor>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    this.m_floors[FromVariant(evt.prop.first)].m_isHidden = false;
    this.SyncDataWithFloorTerminal(FromVariant(evt.prop.first));
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  public final func OnQuestSetRadioStation(evt: ref<QuestSetRadioStation>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.Notify(notifier, evt);
    this.m_liftSetup.m_radioStationNumer = FromVariant(evt.prop.first);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnQuestDisableRadio(evt: ref<QuestDisableRadio>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.Notify(notifier, evt);
    this.m_liftSetup.m_radioStationNumer = -1;
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnQuestCloseAllDoors(evt: ref<QuestCloseAllDoors>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.Notify(notifier, evt);
    this.m_isAllDoorsClosed = FromVariant(evt.prop.first);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnQuestToggleAds(evt: ref<QuestToggleAds>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.Notify(notifier, evt);
    this.m_isAdsDisabled = !FromVariant(evt.prop.first);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnQuestHideFloor(evt: ref<QuestHideFloor>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    this.m_floors[FromVariant(evt.prop.first)].m_isHidden = true;
    this.SyncDataWithFloorTerminal(FromVariant(evt.prop.first));
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  public final func OnQuestSetFloorActive(evt: ref<QuestSetFloorActive>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    this.m_floors[FromVariant(evt.prop.first)].m_isInactive = false;
    this.SyncDataWithFloorTerminal(FromVariant(evt.prop.first));
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  public final func OnQuestSetFloorInactive(evt: ref<QuestSetFloorInactive>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus>;
    let ndx: Int32 = -1;
    if IsDefined(evt.prop) && VariantIsValid(evt.prop.first) {
      ndx = FromVariant(evt.prop.first);
    };
    cachedStatus = this.GetDeviceStatusAction();
    if ndx >= 0 && ndx < ArraySize(this.m_floors) {
      this.m_floors[ndx].m_isInactive = true;
      this.SyncDataWithFloorTerminal(ndx);
    };
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  public final func OnQuestForceGoToFloor(evt: ref<QuestForceGoToFloor>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    this.m_targetFloor = FromVariant(evt.prop.first);
    this.LogActionDetails(evt, cachedStatus);
    this.ProcessUnstreamedLiftMovement(FromVariant(evt.prop.first));
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnQuestForceTeleportToFloor(evt: ref<QuestForceTeleportToFloor>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.ProcessUnstreamedLiftMovement(FromVariant(evt.prop.first));
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ProcessUnstreamedLiftMovement(floor: Int32) -> Void {
    if !IsDefined(this.GetOwnerEntityWeak()) {
      this.SendLiftDepartedEvent(this.m_activeFloor);
      this.SetStartingFloor(floor);
      this.m_activeFloor = floor;
    };
  }

  public final func OnQuestStopElevator(evt: ref<QuestStopElevator>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnQuestResumeElevator(evt: ref<QuestResumeElevator>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnQuestSetLiftSpeed(evt: ref<QuestSetLiftSpeed>) -> EntityNotificationType {
    let newSpeed: Float;
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    newSpeed = FromVariant(evt.prop.first);
    this.m_liftSetup.m_liftSpeed = newSpeed;
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnQuestSetLiftTravelTimeOverride(evt: ref<QuestSetLiftTravelTimeOverride>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.m_liftSetup.m_liftTravelTimeOverride = FromVariant(evt.prop.first);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnQuestEnableLiftTravelTimeOverride(evt: ref<QuestEnableLiftTravelTimeOverride>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.m_liftSetup.m_isLiftTravelTimeOverride = true;
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnQuestDisableLiftTravelTimeOverride(evt: ref<QuestDisableLiftTravelTimeOverride>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.m_liftSetup.m_isLiftTravelTimeOverride = false;
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnLiftStatus(evt: ref<LiftStatus>) -> EntityNotificationType {
    if evt.IsStarted() {
      this.ExecutePSActionWithDelay(evt, this, evt.GetDurationValue());
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.UseNotifier(evt);
    if this.IsPlayerAuthorized() {
      return EntityNotificationType.SendPSChangedEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func SyncDataWithFloorTerminal(terminalNumber: Int32) -> Void {
    let syncEvent: ref<LiftFloorSyncDataEvent>;
    if terminalNumber >= 0 && terminalNumber < ArraySize(this.m_floors) {
      syncEvent = new LiftFloorSyncDataEvent();
      syncEvent.isHidden = this.m_floors[terminalNumber].m_isHidden;
      syncEvent.isInactive = this.m_floors[terminalNumber].m_isInactive;
      this.GetPersistencySystem().QueuePSEvent(this.m_floorPSIDs[terminalNumber], n"ElevatorFloorTerminalControllerPS", syncEvent);
    };
  }

  public final const func GetActiveFloor() -> Int32 {
    return this.m_activeFloor;
  }

  public final const func GetActiveFloorDisplayName() -> String {
    return ElevatorFloorSetup.GetFloorName(this.m_floors[this.m_activeFloor]);
  }

  public final const quest func IsAtFloor(floorNumber: Int32) -> Bool {
    return this.m_activeFloor == floorNumber;
  }

  public final const quest func IsMoving() -> Bool {
    if Equals(this.m_movementState, gamePlatformMovementState.Stopped) || Equals(this.m_movementState, gamePlatformMovementState.Paused) {
      return false;
    };
    return true;
  }

  public final const quest func IsFloorSelected(floor: Int32) -> Bool {
    return this.m_targetFloor == floor;
  }

  public func GetDeviceIconPath() -> String {
    return "";
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return GetAllBlackboardDefs().ElevatorDeviceBlackboard;
  }

  public final const func GetMovementState() -> gamePlatformMovementState {
    return this.m_movementState;
  }

  public final func SetTimeWhenPaused(time: Float) -> Void {
    this.m_timeOnPause = time;
  }

  public final func GetTimeWhenPaused() -> Float {
    return this.m_timeOnPause;
  }

  public final func GetFloorDataFromSlaves() -> Void {
    let floorName: String;
    let floorSetup: ElevatorFloorSetup;
    let floors: array<ElevatorFloorSetup>;
    let i: Int32;
    let devices: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    ArrayClear(this.m_floorIDs);
    ArrayClear(this.m_floorPSIDs);
    i = 0;
    while i < ArraySize(devices) {
      floorSetup = (devices[i] as ElevatorFloorTerminalControllerPS).GetElevatorFloorSetup();
      floorName = ElevatorFloorSetup.GetFloorName(floorSetup);
      if !IsStringValid(floorName) {
        if i < 10 {
          floorName = "0" + ToString(i);
        } else {
          floorName = ToString(i);
        };
        floorSetup.m_floorDisplayName = StringToName(floorName);
        if !IsStringValid(floorSetup.m_floorName) {
          floorSetup.m_floorName = floorName;
        };
      };
      ArrayPush(floors, floorSetup);
      ArrayPush(this.m_floorIDs, PersistentID.ExtractEntityID((devices[i] as ElevatorFloorTerminalControllerPS).GetID()));
      ArrayPush(this.m_floorPSIDs, (devices[i] as ElevatorFloorTerminalControllerPS).GetID());
      i += 1;
    };
    this.m_floors = floors;
  }

  public final func GetFloorAuthorizationFromSlaves() -> Void {
    let i: Int32;
    let termimnal: ref<ElevatorFloorTerminalControllerPS>;
    let devices: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    ArrayClear(this.m_floorsAuthorization);
    i = 0;
    while i < ArraySize(devices) {
      if IsDefined(devices[i] as ElevatorFloorTerminalControllerPS) {
        termimnal = devices[i] as ElevatorFloorTerminalControllerPS;
        if termimnal == null {
        } else {
          if this.WasQuickHacked() {
            ArrayPush(this.m_floorsAuthorization, true);
          } else {
            ArrayPush(this.m_floorsAuthorization, termimnal.IsPlayerAuthorized());
          };
        };
      };
      i += 1;
    };
  }

  private final func InitializeFloorsData() -> Void {
    this.RefreshFloorsData_Event(true);
  }

  private final func EvaluateFloors() -> Void {
    this.RefreshFloorsData_Event(false);
  }

  private final func RefreshFloorsData_Event(passToEntity: Bool) -> Void {
    let evt: ref<RefreshFloorDataEvent> = new RefreshFloorDataEvent();
    evt.passToEntity = passToEntity;
    this.GetPersistencySystem().QueuePSEvent(this.GetID(), this.GetClassName(), evt);
  }

  private final func RefreshFloorsAuthorizationData_Event(passToEntity: Bool) -> Void {
    let evt: ref<RefreshFloorAuthorizationDataEvent> = new RefreshFloorAuthorizationDataEvent();
    evt.passToEntity = passToEntity;
    this.GetPersistencySystem().QueuePSEvent(this.GetID(), this.GetClassName(), evt);
  }

  public final func SetMovementState(state: gamePlatformMovementState) -> Void {
    this.m_movementState = state;
  }

  protected final func OnLiftSetMovementStateEvent(evt: ref<LiftSetMovementStateEvent>) -> EntityNotificationType {
    this.m_movementState = evt.movementState;
    this.RefreshUI(this.GetBlackboard());
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnSetIsPlayerInsideLiftEvent(evt: ref<SetIsPlayerInsideLiftEvent>) -> EntityNotificationType {
    this.m_isPlayerInsideLift = evt.value;
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnRefreshFloorsData(evt: ref<RefreshFloorDataEvent>) -> EntityNotificationType {
    this.GetFloorDataFromSlaves();
    this.GetFloorAuthorizationFromSlaves();
    this.RefreshUI(this.GetBlackboard());
    if evt.passToEntity {
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnRefreshFloorsAuthorizationData(evt: ref<RefreshFloorAuthorizationDataEvent>) -> EntityNotificationType {
    this.GetFloorAuthorizationFromSlaves();
    this.RefreshUI(this.GetBlackboard());
    if evt.passToEntity {
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnRefreshPlayerAuthorizationEvent(evt: ref<RefreshPlayerAuthorizationEvent>) -> EntityNotificationType {
    this.UseNotifier(this.ActionAuthorizeUser());
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func GetDeviceWidget(context: GetActionsContext) -> SDeviceWidgetPackage {
    let widgetData: SDeviceWidgetPackage = this.GetDeviceWidget(context);
    widgetData.displayName = this.GetActiveFloorDisplayName();
    let customData: ref<LiftWidgetCustomData> = new LiftWidgetCustomData();
    customData.SetMovementState(this.GetMovementState());
    widgetData.customData = customData;
    return widgetData;
  }

  private final func SendLiftDepartedEvent(activeFloor: Int32) -> Void {
    let floorID: PersistentID = this.GetFloorPSID(activeFloor);
    let evt: ref<LiftDepartedEvent> = new LiftDepartedEvent();
    evt.floor = this.GetActiveFloorDisplayName();
    GameInstance.GetPersistencySystem(this.GetGameInstance()).QueuePSEvent(floorID, n"ElevatorFloorTerminalControllerPS", evt);
  }
}

public class QuestSetRadioStation extends ActionInt {

  public final func SetProperties(station: Int32) -> Void {
    this.actionName = n"QuestSetRadioStation";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Int(n"RadioStation", station);
  }
}

public class QuestDisableRadio extends ActionBool {

  public final func SetProperties(toggle: Bool) -> Void {
    this.actionName = n"QuestDisableRadio";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestDisableRadio", toggle, n"QuestDisableRadio", n"QuestDisableRadio");
  }
}

public class QuestCloseAllDoors extends ActionBool {

  public final func SetProperties(toggle: Bool) -> Void {
    if toggle {
      this.actionName = n"QuestForceCloseAllDoors";
    } else {
      this.actionName = n"QuestForceOpenAllDoors";
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestCloseAllDoors", toggle, n"QuestCloseAllDoors", n"QuestCloseAllDoors");
  }
}

public class QuestToggleAds extends ActionBool {

  public final func SetProperties(toggle: Bool) -> Void {
    if toggle {
      this.actionName = n"QuestTurnAdsOn";
    } else {
      this.actionName = n"QuestForceAdsOff";
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestToggleAds", toggle, n"QuestToggleAds", n"QuestToggleAds");
  }
}
