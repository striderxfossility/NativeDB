
public class QuestForceFakeElevatorArrows extends ActionBool {

  public final func SetProperties(property: Bool) -> Void {
    if property {
      this.actionName = n"QuestForceFakeElevatorArrowsUp";
    } else {
      this.actionName = n"QuestForceFakeElevatorArrowsDown";
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceFakeElevatorArrows", property, n"QuestForceFakeElevatorArrows", n"QuestForceFakeElevatorArrows");
  }
}

public class QuestResetFakeElevatorArrows extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestResetFakeElevatorArrows";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestResetFakeElevatorArrows", true, n"QuestResetFakeElevatorArrows", n"QuestResetFakeElevatorArrows");
  }
}

public class TerminalController extends MasterController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class TerminalControllerPS extends MasterControllerPS {

  private persistent let m_terminalSetup: TerminalSetup;

  private inline let m_terminalSkillChecks: ref<HackEngContainer>;

  protected let m_spawnedSystems: array<ref<VirtualSystemPS>>;

  private let m_useKeyloggerHack: Bool;

  @attrib(category, "UI")
  protected let m_shouldShowTerminalTitle: Bool;

  @attrib(category, "Glitch")
  protected let m_defaultGlitchVideoPath: ResRef;

  @attrib(category, "Glitch")
  protected let m_broadcastGlitchVideoPath: ResRef;

  protected persistent let m_state: gameinteractionsReactionState;

  protected persistent let m_forcedElevatorArrowsState: EForcedElevatorArrowsState;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "Gameplay-Devices-DisplayNames-Terminal";
    };
  }

  protected func GameAttached() -> Void;

  protected func LogicReady() -> Void {
    this.LogicReady();
    this.InitializeVirtualSystems();
    this.InitializeSkillChecks(this.m_terminalSkillChecks);
  }

  private final func InitializeVirtualSystems_Test() -> Void {
    let data: DeviceCounter;
    let devices: array<ref<DeviceComponentPS>>;
    let i: Int32;
    let k: Int32;
    let systemsData: array<DeviceCounter>;
    if !this.m_terminalSetup.m_shouldForceVirtualSystem {
      return;
    };
    devices = this.GetImmediateSlaves();
    while ArraySize(devices) > 0 {
      i = ArraySize(devices) - 1;
      if this.GetMatchingVirtualSystemsData(devices[i], devices, data) {
        ArrayPush(systemsData, data);
        k = ArraySize(data.devices) - 1;
        while k >= 0 {
          ArrayRemove(devices, data.devices[k]);
          k -= 1;
        };
      } else {
        ArrayErase(devices, i);
      };
    };
    i = 0;
    while i < ArraySize(systemsData) {
      if Equals(systemsData[i].systemType, EVirtualSystem.SurveillanceSystem) {
        this.SpawnSurveillanceSystemUI(systemsData[i].devices);
      } else {
        if Equals(systemsData[i].systemType, EVirtualSystem.SecuritySystem) {
          this.SpawnSecuritySystemUI(systemsData[i].devices);
        } else {
          if Equals(systemsData[i].systemType, EVirtualSystem.DoorSystem) {
            this.SpawnDoorSystemUI(systemsData[i].devices);
          } else {
            if Equals(systemsData[i].systemType, EVirtualSystem.MediaSystem) {
              this.SpawnMediaSystemUI(systemsData[i].devices);
            };
          };
        };
      };
      i += 1;
    };
  }

  private final func InitializeVirtualSystems() -> Void {
    let data: DeviceCounter;
    let devices: array<ref<DeviceComponentPS>>;
    let i: Int32;
    let k: Int32;
    let systemsData: array<DeviceCounter>;
    if !this.m_terminalSetup.m_shouldForceVirtualSystem {
      return;
    };
    devices = this.GetImmediateSlaves();
    while ArraySize(devices) > 0 {
      i = ArraySize(devices) - 1;
      if this.GetMatchingVirtualSystemsData(devices[i], devices, data) {
        ArrayPush(systemsData, data);
        k = ArraySize(data.devices) - 1;
        while k >= 0 {
          ArrayRemove(devices, data.devices[k]);
          k -= 1;
        };
      } else {
        ArrayErase(devices, i);
      };
    };
    i = 0;
    while i < ArraySize(systemsData) {
      if Equals(systemsData[i].systemType, EVirtualSystem.SurveillanceSystem) {
        this.SpawnSurveillanceSystemUI(systemsData[i].devices);
      } else {
        if Equals(systemsData[i].systemType, EVirtualSystem.SecuritySystem) {
          this.SpawnSecuritySystemUI(systemsData[i].devices);
        } else {
          if Equals(systemsData[i].systemType, EVirtualSystem.DoorSystem) {
            this.SpawnDoorSystemUI(systemsData[i].devices);
          } else {
            if Equals(systemsData[i].systemType, EVirtualSystem.MediaSystem) {
              this.SpawnMediaSystemUI(systemsData[i].devices);
            };
          };
        };
      };
      i += 1;
    };
  }

  protected const func GetClearance() -> ref<Clearance> {
    return Clearance.CreateClearance(this.m_terminalSetup.m_minClearance, this.m_terminalSetup.m_maxClearance);
  }

  public final const func ShouldShowTerminalTitle() -> Bool {
    return this.m_shouldShowTerminalTitle;
  }

  public final const func GetDefaultGlitchVideoPath() -> ResRef {
    return this.m_defaultGlitchVideoPath;
  }

  public final const func GetBroadcastGlitchVideoPath() -> ResRef {
    if ResRef.IsValid(this.m_broadcastGlitchVideoPath) {
      return this.m_broadcastGlitchVideoPath;
    };
    return r"base\\movies\\misc\\distraction_generic.bk2";
  }

  protected const func GenerateContext(requestType: gamedeviceRequestType, providedClearance: ref<Clearance>, opt providedProcessInitiator: ref<GameObject>, opt providedRequestor: EntityID) -> GetActionsContext {
    let generatedContext: GetActionsContext = this.GenerateContext(requestType, providedClearance, providedProcessInitiator, providedRequestor);
    generatedContext.ignoresAuthorization = this.m_terminalSetup.m_ignoreSlaveAuthorizationModule;
    return generatedContext;
  }

  private final func GetMatchingVirtualSystemsData(device: ref<DeviceComponentPS>, listToCheck: array<ref<DeviceComponentPS>>, out data: DeviceCounter) -> Bool {
    let i: Int32;
    let returnValue: Bool;
    let type: EVirtualSystem;
    if device == null {
      return false;
    };
    returnValue = false;
    type = device.GetVirtualSystemType();
    if NotEquals(type, IntEnum(0l)) {
      data.systemType = type;
      i = 0;
      while i < ArraySize(listToCheck) {
        if device == listToCheck[i] {
        } else {
          if Equals(listToCheck[i].GetVirtualSystemType(), type) {
            ArrayPush(data.devices, listToCheck[i]);
            returnValue = true;
          };
        };
        i += 1;
      };
    };
    if returnValue {
      ArrayPush(data.devices, device);
    };
    return returnValue;
  }

  private final func HasMatchingVirtualSystemType(device: ref<DeviceComponentPS>, listToCheck: array<ref<DeviceComponentPS>>, out type: EVirtualSystem) -> Bool {
    let i: Int32;
    if device == null {
      return false;
    };
    type = device.GetVirtualSystemType();
    if NotEquals(type, IntEnum(0l)) {
      i = 0;
      while i < ArraySize(listToCheck) {
        if device == listToCheck[i] {
        } else {
          if Equals(listToCheck[i].GetVirtualSystemType(), type) {
            return true;
          };
        };
        i += 1;
      };
    };
    return false;
  }

  public final const func HasAnyVirtualSystem() -> Bool {
    return ArraySize(this.m_spawnedSystems) > 0;
  }

  public final const func GetVirtualSystemsCount() -> Int32 {
    return ArraySize(this.m_spawnedSystems);
  }

  public final const func IsPartOfAnyVirtualSystem(slave: ref<DeviceComponentPS>) -> Bool {
    let vs: ref<VirtualSystemPS>;
    return this.GetVirtualSystem(slave, vs);
  }

  public final const func IsPartOfAnyVirtualSystem(slaveID: PersistentID) -> Bool {
    let vs: ref<VirtualSystemPS>;
    return this.GetVirtualSystem(slaveID, vs);
  }

  public const func GetVirtualSystem(slave: ref<DeviceComponentPS>, out vs: ref<VirtualSystemPS>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_spawnedSystems) {
      if this.m_spawnedSystems[i].IsPartOfSystem(slave) {
        vs = this.m_spawnedSystems[i];
        return true;
      };
      i += 1;
    };
    return false;
  }

  public const func GetVirtualSystem(id: PersistentID, out vs: ref<VirtualSystemPS>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_spawnedSystems) {
      if Equals(id, this.m_spawnedSystems[i].GetID()) || this.m_spawnedSystems[i].IsPartOfSystem(id) {
        vs = this.m_spawnedSystems[i];
        return true;
      };
      i += 1;
    };
    return false;
  }

  public func GetSlaveDeviceWidget(deviceID: PersistentID) -> SDeviceWidgetPackage {
    let vs: ref<VirtualSystemPS>;
    if this.GetVirtualSystem(deviceID, vs) {
      return vs.GetDeviceWidget(this.GenerateContext(gamedeviceRequestType.External, this.GetClearance()));
    };
    return this.GetSlaveDeviceWidget(deviceID);
  }

  public func GetDeviceWidgets() -> array<SDeviceWidgetPackage> {
    let currentWidget: SDeviceWidgetPackage;
    let devices: array<ref<DeviceComponentPS>>;
    let i: Int32;
    let widgetsData: array<SDeviceWidgetPackage>;
    if !this.HasAnyVirtualSystem() {
      return this.GetDeviceWidgets();
    };
    i = 0;
    while i < ArraySize(this.m_spawnedSystems) {
      this.m_spawnedSystems[i].GetDeviceWidget(this.GenerateContext(gamedeviceRequestType.External, this.GetClearance()), widgetsData);
      i += 1;
    };
    devices = this.GetImmediateSlaves();
    i = 0;
    while i < ArraySize(devices) {
      if this.IsPartOfAnyVirtualSystem(devices[i]) {
      } else {
        currentWidget = devices[i].GetDeviceWidget(this.GenerateContext(gamedeviceRequestType.External, this.GetClearance()));
        if currentWidget.isValid {
          ArrayPush(widgetsData, devices[i].GetDeviceWidget(this.GenerateContext(gamedeviceRequestType.External, this.GetClearance())));
        };
      };
      i += 1;
    };
    return widgetsData;
  }

  public func GetThumbnailWidgets() -> array<SThumbnailWidgetPackage> {
    let currentWidget: SThumbnailWidgetPackage;
    let devices: array<ref<DeviceComponentPS>>;
    let i: Int32;
    let widgetsData: array<SThumbnailWidgetPackage>;
    if !this.HasAnyVirtualSystem() {
      return this.GetThumbnailWidgets();
    };
    i = 0;
    while i < ArraySize(this.m_spawnedSystems) {
      ArrayPush(widgetsData, this.m_spawnedSystems[i].GetThumbnailWidget());
      i += 1;
    };
    devices = this.GetImmediateSlaves();
    i = 0;
    while i < ArraySize(devices) {
      if Equals(devices[i].GetID(), this.GetID()) {
      } else {
        if this.IsPartOfAnyVirtualSystem(devices[i]) {
        } else {
          currentWidget = devices[i].GetThumbnailWidget();
          if currentWidget.isValid {
            ArrayPush(widgetsData, currentWidget);
          };
        };
      };
      i += 1;
    };
    return widgetsData;
  }

  private final func SpawnSurveillanceSystemUI(slavesToConnect: array<ref<DeviceComponentPS>>) -> Void {
    let virtualSystem: ref<SurveillanceSystemUIPS> = SpawnVirtualPS(this.GetGameInstance(), this.GetMyEntityID(), n"virtualPS", n"SurveillanceSystemUIPS") as SurveillanceSystemUIPS;
    if IsDefined(virtualSystem) {
      virtualSystem.Initialize(slavesToConnect, this);
      ArrayPush(this.m_spawnedSystems, virtualSystem);
    };
  }

  private final func SpawnSecuritySystemUI(slavesToConnect: array<ref<DeviceComponentPS>>) -> Void {
    let virtualSystem: ref<SecuritySystemUIPS> = SpawnVirtualPS(this.GetGameInstance(), this.GetMyEntityID(), n"virtualPS", n"SecuritySystemUIPS") as SecuritySystemUIPS;
    if IsDefined(virtualSystem) {
      virtualSystem.Initialize(slavesToConnect, this);
      ArrayPush(this.m_spawnedSystems, virtualSystem);
    };
  }

  private final func SpawnDoorSystemUI(slavesToConnect: array<ref<DeviceComponentPS>>) -> Void {
    let virtualSystem: ref<DoorSystemUIPS> = SpawnVirtualPS(this.GetGameInstance(), this.GetMyEntityID(), n"virtualPS", n"DoorSystemUIPS") as DoorSystemUIPS;
    if IsDefined(virtualSystem) {
      virtualSystem.Initialize(slavesToConnect, this);
      ArrayPush(this.m_spawnedSystems, virtualSystem);
    };
  }

  private final func SpawnMediaSystemUI(slavesToConnect: array<ref<DeviceComponentPS>>) -> Void {
    let virtualSystem: ref<MediaSystemUIPS> = SpawnVirtualPS(this.GetGameInstance(), this.GetMyEntityID(), n"virtualPS", n"DoorSystemUIPS") as MediaSystemUIPS;
    if IsDefined(virtualSystem) {
      virtualSystem.Initialize(slavesToConnect, this);
      ArrayPush(this.m_spawnedSystems, virtualSystem);
    };
  }

  public func OnRequestDeviceWidgetUpdate(evt: ref<RequestDeviceWidgetUpdateEvent>) -> Void {
    this.RequestDeviceWidgetsUpdate(this.GetBlackboard(), evt.requester);
  }

  public final func GetForcedElevatorArrowsState() -> EForcedElevatorArrowsState {
    return this.m_forcedElevatorArrowsState;
  }

  public func ActionToggleON() -> ref<ToggleON> {
    let action: ref<ToggleON> = new ToggleON();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOnClearance();
    action.SetUp(this);
    action.SetProperties(this.m_deviceState);
    action.AddDeviceName(this.m_deviceName);
    if this.IsOFF() {
      action.CreateInteraction();
    };
    action.CreateActionWidgetPackage();
    return action;
  }

  protected final func ActionQuestForceFakeElevatorArrows(isArrowsUp: Bool) -> ref<QuestForceFakeElevatorArrows> {
    let action: ref<QuestForceFakeElevatorArrows> = new QuestForceFakeElevatorArrows();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties(isArrowsUp);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionQuestResetFakeElevatorArrows() -> ref<QuestResetFakeElevatorArrows> {
    let action: ref<QuestResetFakeElevatorArrows> = new QuestResetFakeElevatorArrows();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionInstallKeylogger() -> ref<InstallKeylogger> {
    let action: ref<InstallKeylogger> = new InstallKeylogger();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  public func GetActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    if !this.GetActions(outActions, context) {
      return false;
    };
    if this.IsDisabled() {
      return false;
    };
    if BaseDeviceStatus.IsDefaultConditionMet(this, context) {
      ArrayPush(outActions, this.ActionDeviceStatus());
    };
    if this.IsUnpowered() {
      return false;
    };
    if ToggleON.IsDefaultConditionMet(this, context) {
      ArrayPush(outActions, this.ActionToggleON());
    };
    if !this.IsON() {
      return false;
    };
    this.SetActionIllegality(outActions, this.m_illegalActions.regularActions);
    return true;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionInstallKeylogger();
    currentAction.SetObjectActionID(t"DeviceAction.DataExtractionClassHack");
    currentAction.SetInactiveWithReason(this.m_useKeyloggerHack && !this.m_isKeyloggerInstalled, "LocKey#7014");
    ArrayPush(outActions, currentAction);
    currentAction = this.ActionQuickHackToggleOpen();
    currentAction.SetObjectActionID(t"DeviceAction.ToggleStateClassHack");
    currentAction.SetInactiveWithReason(!this.m_useKeyloggerHack && ScriptableDeviceAction.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(outActions, currentAction);
    if !this.IsAuthorizationModuleOn() {
      ScriptableDeviceComponentPS.SetActionsInactiveAll(outActions, "LocKey#7015");
    };
    currentAction = this.ActionGlitchScreen(t"DeviceAction.GlitchScreenSuicide", t"QuickHack.DeviceSuicideHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    currentAction.SetInactiveWithReason(GlitchScreen.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(outActions, currentAction);
    currentAction = this.ActionGlitchScreen(t"DeviceAction.GlitchScreenBlind", t"QuickHack.BlindHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    currentAction.SetInactiveWithReason(GlitchScreen.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(outActions, currentAction);
    currentAction = this.ActionGlitchScreen(t"DeviceAction.GlitchScreenHeartAttack", t"QuickHack.HeartAttackHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    currentAction.SetInactiveWithReason(GlitchScreen.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(outActions, currentAction);
    currentAction = this.ActionGlitchScreen(t"DeviceAction.GlitchScreenGrenade", t"QuickHack.GrenadeHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    currentAction.SetInactiveWithReason(GlitchScreen.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(outActions, currentAction);
    currentAction = this.ActionQuickHackDistraction();
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    currentAction.SetInactiveWithReason(ScriptableDeviceAction.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(outActions, currentAction);
    if this.IsGlitching() || this.IsDistracting() {
      ScriptableDeviceComponentPS.SetActionsInactiveAll(outActions, "LocKey#7004");
    };
    this.FinalizeGetQuickHackActions(outActions, context);
  }

  public func GetQuestActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(outActions, context);
    ArrayPush(outActions, this.ActionQuestForceFakeElevatorArrows(true));
    ArrayPush(outActions, this.ActionQuestForceFakeElevatorArrows(false));
    ArrayPush(outActions, this.ActionQuestResetFakeElevatorArrows());
    return;
  }

  public final func OnQuestForceFakeElevatorArrows(evt: ref<QuestForceFakeElevatorArrows>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetAll();
    this.Notify(notifier, evt);
    if FromVariant(evt.prop.first) {
      this.m_forcedElevatorArrowsState = EForcedElevatorArrowsState.ArrowsUp;
    } else {
      this.m_forcedElevatorArrowsState = EForcedElevatorArrowsState.ArrowsDown;
    };
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  public final func OnQuestResetFakeElevatorArrows(evt: ref<QuestResetFakeElevatorArrows>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetAll();
    this.Notify(notifier, evt);
    this.m_forcedElevatorArrowsState = EForcedElevatorArrowsState.Disabled;
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  protected func ActionQuickHackToggleOpen() -> ref<QuickHackToggleOpen> {
    let action: ref<QuickHackToggleOpen> = new QuickHackToggleOpen();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOpenClearance();
    action.SetUp(this);
    action.SetProperties(false);
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  public final func OnQuickHackToggleOpen(evt: ref<QuickHackToggleOpen>) -> EntityNotificationType {
    this.TurnAuthorizationModuleOFF();
    this.DisbleAuthorizationOnSlaves();
    this.ResolveOtherSkillchecks();
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  public func OnActionEngineering(evt: ref<ActionEngineering>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetAll();
    if !evt.WasPassed() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.OnActionEngineering(evt);
    if evt.IsCompleted() {
      this.DisbleAuthorizationOnSlaves();
      this.ResolveOtherSkillchecks();
      RPGManager.GiveReward(evt.GetExecutor().GetGame(), t"RPGActionRewards.ExtractPartsTerminal");
      this.Notify(notifier, evt);
      return EntityNotificationType.SendPSChangedEventToEntity;
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnActionInstallKeylogger(evt: ref<InstallKeylogger>) -> EntityNotificationType {
    this.m_isKeyloggerInstalled = true;
    this.InstallKeyloggerOnSlaves();
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  public final const func IsOwningSecuritySystem(out secSys: ref<SecuritySystemControllerPS>) -> Bool {
    let i: Int32;
    let slaves: array<ref<DeviceComponentPS>>;
    this.GetChildren(slaves);
    i = 0;
    while i < ArraySize(slaves) {
      if IsDefined(slaves[i] as SecuritySystemControllerPS) {
        secSys = slaves[i] as SecuritySystemControllerPS;
        return true;
      };
      i += 1;
    };
    return false;
  }

  protected func ResolvePersonalLinkConnection(evt: ref<TogglePersonalLink>, abortOperations: Bool) -> Void {
    let secSys: ref<SecuritySystemControllerPS>;
    this.ResolvePersonalLinkConnection(evt, abortOperations);
    if this.IsOwningSecuritySystem(secSys) && this.IsPersonalLinkConnected() {
      this.ExecutePSAction(this.ActionTakeOverSecuritySystem(evt.GetExecutor()), secSys);
    };
  }

  protected func ResolveOtherSkillchecks() -> Void {
    if IsDefined(this.m_skillCheckContainer) {
      if IsDefined(this.m_skillCheckContainer.GetHackingSlot()) && this.m_skillCheckContainer.GetHackingSlot().IsActive() {
        this.m_skillCheckContainer.GetHackingSlot().SetIsActive(false);
        this.m_skillCheckContainer.GetHackingSlot().SetIsPassed(true);
      };
      if IsDefined(this.m_skillCheckContainer.GetEngineeringSlot()) && this.m_skillCheckContainer.GetEngineeringSlot().IsActive() {
        this.m_skillCheckContainer.GetEngineeringSlot().SetIsActive(false);
        this.m_skillCheckContainer.GetEngineeringSlot().SetIsPassed(true);
      };
    };
    this.m_authorizationProperties.m_isAuthorizationModuleOn = false;
  }

  public func OnAuthorizeUser(evt: ref<AuthorizeUser>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetAll();
    if this.UserAuthorizationAttempt(evt.GetExecutor().GetEntityID(), evt.GetEnteredPassword()) {
      this.AuthorizeUserOnSlaves(evt.GetExecutor(), evt.GetEnteredPassword());
      this.ResolveOtherSkillchecks();
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnSetState(evt: ref<TerminalSetState>) -> EntityNotificationType {
    if Equals(evt.state, gameinteractionsReactionState.Starting) || Equals(evt.state, gameinteractionsReactionState.Finishing) || Equals(evt.state, gameinteractionsReactionState.Canceling) {
      this.m_state = evt.state;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final const func QuestCondition_IsStarted() -> Bool {
    return Equals(this.m_state, gameinteractionsReactionState.Starting);
  }

  public final const func QuestCondition_IsFinished() -> Bool {
    return Equals(this.m_state, gameinteractionsReactionState.Finishing) || Equals(this.m_state, gameinteractionsReactionState.Canceling);
  }

  protected final func DisbleAuthorizationOnSlaves() -> Void {
    let extractedAction: ref<ScriptableDeviceAction>;
    let devices: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(devices) {
      if devices[i] == this {
      } else {
        this.ExtractActionFromSlave(devices[i], n"SetAuthorizationModuleOFF", extractedAction);
        if IsDefined(extractedAction) {
          extractedAction.RegisterAsRequester(PersistentID.ExtractEntityID(this.GetID()));
          this.GetPersistencySystem().QueuePSDeviceEvent(extractedAction);
        };
      };
      i += 1;
    };
  }

  protected final func EnableAuthorizationOnSlaves() -> Void {
    let extractedAction: ref<ScriptableDeviceAction>;
    let devices: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(devices) {
      if devices[i] == this {
      } else {
        this.ExtractActionFromSlave(devices[i], n"SetAuthorizationModuleON", extractedAction);
        if IsDefined(extractedAction) {
          extractedAction.RegisterAsRequester(PersistentID.ExtractEntityID(this.GetID()));
          this.GetPersistencySystem().QueuePSDeviceEvent(extractedAction);
        };
      };
      i += 1;
    };
  }

  protected final func AuthorizeUserOnSlaves(userToAuthorize: wref<GameObject>, opt password: CName) -> Void {
    let action: ref<ScriptableDeviceAction>;
    let device: ref<ScriptableDeviceComponentPS>;
    let devices: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(devices) {
      if devices[i] == this {
      } else {
        device = devices[i] as ScriptableDeviceComponentPS;
        if IsDefined(device) {
          action = device.GetActionByName(n"AuthorizeUser", this.GenerateContext(gamedeviceRequestType.External, this.GetClearance(), userToAuthorize, this.GetMyEntityID())) as ScriptableDeviceAction;
          if IsDefined(action) {
            action.RegisterAsRequester(PersistentID.ExtractEntityID(this.GetID()));
            action.SetExecutor(userToAuthorize);
            this.GetPersistencySystem().QueuePSDeviceEvent(action);
          };
        };
      };
      i += 1;
    };
  }

  protected final func InstallKeyloggerOnSlaves() -> Void {
    let devices: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(devices) {
      if devices[i] == this {
      } else {
        if IsDefined(devices[i] as DoorControllerPS) {
          this.ExecutePSAction(this.ActionInstallKeylogger(), devices[i]);
        };
      };
      i += 1;
    };
  }

  public func TurnAuthorizationModuleOFF() -> Void {
    this.TurnAuthorizationModuleOFF();
    this.DisbleAuthorizationOnSlaves();
    this.m_terminalSetup.m_ignoreSlaveAuthorizationModule = true;
  }

  public func OnDisassembleDevice(evt: ref<DisassembleDevice>) -> EntityNotificationType {
    this.TurnAuthorizationModuleOFF();
    this.DisbleAuthorizationOnSlaves();
    return this.OnDisassembleDevice(evt);
  }

  protected func GetInkWidgetTweakDBID(context: GetActionsContext) -> TweakDBID {
    if this.HasActiveStaticHackingSkillcheck() {
      return t"DevicesUIDefinitions.GenericKeypadWidget";
    };
    if !this.IsUserAuthorized(context.processInitiatorObject.GetEntityID()) {
      if this.IsDeviceSecuredWithPassword() {
        return t"DevicesUIDefinitions.GenericKeypadWidget";
      };
      return t"DevicesUIDefinitions.GenericKeypadWidget";
    };
    return t"DevicesUIDefinitions.GenericDeviceWidget";
  }
}
