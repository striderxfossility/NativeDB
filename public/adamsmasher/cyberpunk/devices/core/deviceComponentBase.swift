
public class ScriptableDC extends DeviceComponent {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }

  public const func GetDeviceComponentPS() -> ref<DeviceComponentPS> {
    return this.GetPS() as DeviceComponentPS;
  }

  public final const func GetPSID() -> PersistentID {
    return this.GetPS().GetID();
  }

  public final const func GetPSName() -> CName {
    return this.GetPS().GetClassName();
  }
}

public class SharedGameplayPS extends DeviceComponentPS {

  @default(AOEEffectorControllerPS, EDeviceStatus.OFF)
  @default(ScriptableDeviceComponentPS, EDeviceStatus.ON)
  protected persistent let m_deviceState: EDeviceStatus;

  protected persistent let m_authorizationProperties: AuthorizationData;

  protected persistent let m_wasStateCached: Bool;

  protected persistent let m_wasStateSet: Bool;

  protected persistent let m_cachedDeviceState: EDeviceStatus;

  @attrib(category, "Devices Grid")
  @default(AOEAreaControllerPS, true)
  @default(AOEEffectorControllerPS, true)
  @default(AccessPointControllerPS, false)
  @default(ActionsSequencerControllerPS, false)
  @default(ActivatorControllerPS, true)
  @default(CommunityProxyPS, false)
  @default(FuseControllerPS, false)
  @default(NetworkAreaControllerPS, false)
  @default(PuppetDeviceLinkPS, false)
  @default(ScriptableDeviceComponentPS, true)
  @default(SecurityAreaControllerPS, false)
  @default(SecuritySystemControllerPS, false)
  @default(VentilationAreaControllerPS, true)
  @default(VentilationEffectorControllerPS, true)
  protected let m_revealDevicesGrid: Bool;

  @attrib(category, "Devices Grid")
  protected let m_revealDevicesGridWhenUnpowered: Bool;

  protected persistent let m_wasRevealedInNetworkPing: Bool;

  @attrib(category, "Backdoor Properties")
  @default(AccessPointControllerPS, true)
  @default(CommunityProxyPS, true)
  protected let m_hasNetworkBackdoor: Bool;

  public final const func GetDeviceState() -> EDeviceStatus {
    return this.m_deviceState;
  }

  protected final func CacheDeviceState(state: EDeviceStatus) -> Void {
    this.m_cachedDeviceState = state;
    this.m_wasStateCached = true;
  }

  protected func SetDeviceState(state: EDeviceStatus) -> Void {
    this.m_deviceState = state;
    this.m_wasStateSet = true;
  }

  public func EvaluateDeviceState() -> Void {
    let expectedState: EDeviceStatus;
    let i: Int32;
    let parent: ref<MasterControllerPS>;
    let parents: array<ref<DeviceComponentPS>>;
    if Equals(this.m_deviceState, EDeviceStatus.DISABLED) {
      return;
    };
    parents = this.GetImmediateParents();
    i = 0;
    while i < ArraySize(parents) {
      parent = parents[i] as MasterControllerPS;
      if IsDefined(parent) {
        expectedState = parent.GetExpectedSlaveState();
        if NotEquals(expectedState, EDeviceStatus.INVALID) {
          this.SetDeviceState(expectedState);
          return;
        };
      };
      i += 1;
    };
  }

  protected final const func QueuePSEvent(targetPS: wref<PersistentState>, evt: ref<Event>) -> Void {
    if !IsDefined(targetPS) {
      return;
    };
    GameInstance.GetPersistencySystem(this.GetGameInstance()).QueuePSEvent(targetPS.GetID(), targetPS.GetClassName(), evt);
  }

  protected final const func QueuePSEvent(targetID: PersistentID, psClassName: CName, evt: ref<Event>) -> Void {
    if IsDefined(evt as BaseScriptableAction) {
      if !EntityID.IsDefined((evt as BaseScriptableAction).GetRequesterID()) {
        (evt as BaseScriptableAction).RegisterAsRequester(this.GetMyEntityID());
      };
    };
    GameInstance.GetPersistencySystem(this.GetGameInstance()).QueuePSEvent(targetID, psClassName, evt);
  }

  protected final const func QueuePSEventWithDelay(targetPS: wref<PersistentState>, evt: ref<Event>, delay: Float) -> Void {
    if !IsDefined(targetPS) {
      return;
    };
    GameInstance.GetDelaySystem(this.GetGameInstance()).DelayPSEvent(targetPS.GetID(), targetPS.GetClassName(), evt, delay);
  }

  protected final const func QueuePSEventWithDelay(targetID: PersistentID, psClassName: CName, evt: ref<Event>, delay: Float) -> Void {
    GameInstance.GetDelaySystem(this.GetGameInstance()).DelayPSEvent(targetID, psClassName, evt, delay);
  }

  protected final const func QueueEntityEvent(entityID: EntityID, evt: ref<Event>) -> Void {
    GameInstance.GetPersistencySystem(this.GetGameInstance()).QueueEntityEvent(entityID, evt);
  }

  public const func IsPartOfSystem(systemType: ESystems) -> Bool {
    switch systemType {
      case ESystems.SecuritySystem:
        return this.IsConnectedToSecuritySystem();
      case ESystems.AccessPoints:
        return this.IsConnectedToBackdoorDevice();
    };
  }

  public final const func IsConnectedToSecuritySystem() -> Bool {
    let secSys: ref<SecuritySystemControllerPS> = this.GetSecuritySystem();
    if IsDefined(secSys) {
      return true;
    };
    return false;
  }

  public const func IsConnectedToSecuritySystem(out level: ESecurityAccessLevel) -> Bool {
    level = this.GetSecurityAccessLevel();
    let secSys: ref<SecuritySystemControllerPS> = this.GetSecuritySystem();
    if IsDefined(secSys) {
      return true;
    };
    return false;
  }

  public const func GetSecurityAccessLevel() -> ESecurityAccessLevel {
    return this.FindHighestSecurityAccessLevel(this.GetSecurityAreas());
  }

  protected final const func FindHighestSecurityAccessLevel(securityAreas: array<ref<SecurityAreaControllerPS>>) -> ESecurityAccessLevel {
    let highestLevel: ESecurityAccessLevel = ESecurityAccessLevel.ESL_NONE;
    let i: Int32 = 0;
    while i < ArraySize(securityAreas) {
      if EnumInt(securityAreas[i].GetSecurityAccessLevel()) > EnumInt(highestLevel) {
        highestLevel = securityAreas[i].GetSecurityAccessLevel();
      };
      i += 1;
    };
    if Equals(highestLevel, ESecurityAccessLevel.ESL_NONE) {
      highestLevel = this.m_authorizationProperties.m_authorizationDataEntry.m_level;
    };
    return highestLevel;
  }

  public const func IsBreached() -> Bool {
    let aps: array<ref<AccessPointControllerPS>> = this.GetAccessPoints();
    let i: Int32 = 0;
    while i < ArraySize(aps) {
      if aps[i].IsNetworkBreached() {
        return true;
      };
      i += 1;
    };
    if !IsFinal() {
      LogDevices(this, "UNSUPPORTED AMOUNT OF ACCESS POINTS FOR THIS BACKDOOR DEVICE!", ELogType.ERROR);
    };
    return false;
  }

  public const func HasNetworkBackdoor() -> Bool {
    let ap: ref<AccessPointControllerPS>;
    if this.m_hasNetworkBackdoor && EnumInt(this.GetDeviceState()) > EnumInt(EDeviceStatus.UNPOWERED) {
      ap = this.GetBackdoorAccessPoint();
      if IsDefined(ap) {
        return true;
      };
    };
    return false;
  }

  public const func IsConnectedToBackdoorDevice() -> Bool {
    let i: Int32;
    let parents: array<ref<DeviceComponentPS>>;
    this.GetParents(parents);
    i = 0;
    while i < ArraySize(parents) {
      if (parents[i] as ScriptableDeviceComponentPS).HasNetworkBackdoor() {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public const func GetBackdoorAccessPoint() -> ref<AccessPointControllerPS> {
    let aps: array<ref<AccessPointControllerPS>>;
    let backdoorAP: ref<AccessPointControllerPS>;
    if !this.m_hasNetworkBackdoor {
      if !IsFinal() {
        LogDevices(this, "GetBackdoorAccessPoint called on a device that does not have network backdoor", ELogType.ERROR);
      };
      return null;
    };
    aps = this.GetAccessPoints();
    if ArraySize(aps) > 0 {
      backdoorAP = aps[0];
      return backdoorAP;
    };
    if !IsFinal() {
      LogDevices(this, "UNSUPPORTED AMOUNT OF ACCESS POINTS FOR THIS BACKDOOR DEVICE!", ELogType.ERROR);
    };
    return null;
  }

  public final const func GetAccessPoints() -> array<ref<AccessPointControllerPS>> {
    let ap: ref<AccessPointControllerPS>;
    let aps: array<ref<AccessPointControllerPS>>;
    let i: Int32;
    let parents: array<ref<DeviceComponentPS>>;
    this.GetParents(parents);
    i = 0;
    while i < ArraySize(parents) {
      if IsDefined(parents[i] as AccessPointControllerPS) {
        ap = parents[i] as AccessPointControllerPS;
        ArrayPush(aps, ap);
      };
      i += 1;
    };
    return aps;
  }

  public const func GetNetworkName() -> String {
    let networkName: String;
    let aps: array<ref<AccessPointControllerPS>> = this.GetAccessPoints();
    if ArraySize(aps) > 0 {
      networkName = aps[0].GetNetworkName();
      if IsStringValid(networkName) {
        return networkName;
      };
      return "LOCAL NETWORK";
    };
    if !IsFinal() {
      LogDevices(this, "Illegal callback", ELogType.ERROR);
    };
    return "";
  }

  public final const func CheckMasterConnectedClassTypes() -> ConnectedClassTypes {
    let data: ConnectedClassTypes;
    let emptyData: ConnectedClassTypes;
    let processedData: ConnectedClassTypes;
    let aps: array<ref<AccessPointControllerPS>> = this.GetAccessPoints();
    let i: Int32 = 0;
    while i < ArraySize(aps) {
      processedData = emptyData;
      processedData = aps[i].CheckConnectedClassTypes();
      if Equals(processedData.surveillanceCamera, true) {
        data.surveillanceCamera = true;
      };
      if Equals(processedData.securityTurret, true) {
        data.securityTurret = true;
      };
      if Equals(processedData.puppet, true) {
        data.puppet = true;
      };
      i += 1;
    };
    return data;
  }

  public const func WasRevealedInNetworkPing() -> Bool {
    return this.m_wasRevealedInNetworkPing;
  }

  public const func SetRevealedInNetworkPing(wasRevealed: Bool) -> Void {
    let evt: ref<SetRevealedInNetwork>;
    if Equals(this.m_wasRevealedInNetworkPing, wasRevealed) {
      return;
    };
    evt = new SetRevealedInNetwork();
    evt.wasRevealed = wasRevealed;
    this.QueuePSEvent(this.GetID(), this.GetClassName(), evt);
  }

  private final func OnSetRevealedInNetwork(evt: ref<SetRevealedInNetwork>) -> EntityNotificationType {
    let notifyNetworkSystem: ref<MarkBackdoorAsRevealedRequest>;
    if Equals(this.m_wasRevealedInNetworkPing, evt.wasRevealed) {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.m_wasRevealedInNetworkPing = evt.wasRevealed;
    if this.HasNetworkBackdoor() {
      notifyNetworkSystem = new MarkBackdoorAsRevealedRequest();
      notifyNetworkSystem.device = this;
      this.GetNetworkSystem().QueueRequest(notifyNetworkSystem);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public const func IsPuppet() -> Bool {
    return false;
  }
}

public native class DeviceComponentPS extends GameComponentPS {

  @attrib(category, "Quest")
  protected persistent let m_markAsQuest: Bool;

  @attrib(category, "Quest")
  @default(DeviceComponentPS, true)
  protected persistent let m_autoToggleQuestMark: Bool;

  @attrib(category, "Quest")
  protected persistent let m_factToDisableQuestMark: CName;

  @attrib(category, "Quest")
  protected let m_callbackToDisableQuestMarkID: Uint32;

  @attrib(category, "Quest")
  protected inline persistent let m_backdoorObjectiveData: ref<BackDoorObjectiveData>;

  @attrib(category, "Quest")
  protected inline persistent let m_controlPanelObjectiveData: ref<ControlPanelObjectiveData>;

  protected let m_blackboard: wref<IBlackboard>;

  @default(C4ControllerPS, true)
  @default(DeviceComponentPS, false)
  protected persistent let m_isScanned: Bool;

  @default(DeviceComponentPS, false)
  private let m_isBeingScanned: Bool;

  @default(C4ControllerPS, true)
  @default(DeviceComponentPS, false)
  @default(VehicleComponentPS, false)
  protected persistent let m_exposeQuickHacks: Bool;

  protected let m_isAttachedToGame: Bool;

  protected let m_isLogicReady: Bool;

  @default(DeviceComponentPS, 10)
  protected let m_maxDevicesToExtractInOneFrame: Int32;

  protected final func ProcessDevicesLazy(lazyDevices: array<ref<LazyDevice>>, opt eventToSendOnCompleted: ref<ProcessDevicesEvent>) -> Void {
    let evt: ref<ExtractDevicesEvent> = new ExtractDevicesEvent();
    evt.lazyDevices = lazyDevices;
    evt.eventToSendOnCompleted = eventToSendOnCompleted;
    this.ResolveExtractDevicesEvent(evt);
  }

  protected func OnExtractDevicesEvent(evt: ref<ExtractDevicesEvent>) -> EntityNotificationType {
    this.ResolveExtractDevicesEvent(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func ResolveExtractDevicesEvent(evt: ref<ExtractDevicesEvent>) -> Void {
    let currentIdex: Int32;
    let devicePS: ref<DeviceComponentPS>;
    let extractedDevicesCount: Int32;
    let i: Int32;
    if evt == null {
      return;
    };
    if evt.lastExtractedIndex > 0 {
      currentIdex = evt.lastExtractedIndex + 1;
    } else {
      currentIdex = 0;
    };
    i = currentIdex;
    while i < ArraySize(evt.lazyDevices) {
      extractedDevicesCount += 1;
      devicePS = evt.lazyDevices[i].ExtractDevice(this.GetGameInstance());
      if IsDefined(devicePS) {
        ArrayPush(evt.devices, devicePS);
      };
      if i == ArraySize(evt.lazyDevices) - 1 {
        if IsDefined(evt.eventToSendOnCompleted) {
          evt.eventToSendOnCompleted.devices = evt.devices;
          this.GetPersistencySystem().QueuePSEvent(this.GetID(), this.GetClassName(), evt.eventToSendOnCompleted);
        };
      } else {
        if extractedDevicesCount >= this.m_maxDevicesToExtractInOneFrame {
          evt.lastExtractedIndex = i;
          GameInstance.GetDelaySystem(this.GetGameInstance()).DelayPSEventNextFrame(this.GetID(), this.GetClassName(), evt);
        } else {
          i += 1;
        };
      };
    };
  }

  public final const func GetPS(deviceLink: DeviceLink) -> ref<DeviceComponentPS> {
    return this.GetPersistencySystem().GetConstAccessToPSObject(DeviceLink.GetLinkID(deviceLink), DeviceLink.GetLinkClassName(deviceLink)) as DeviceComponentPS;
  }

  public const func IsStatic() -> Bool {
    return false;
  }

  public final const func IsAttachedToGame() -> Bool {
    return this.m_isAttachedToGame;
  }

  public final const func IsLogicReady() -> Bool {
    return this.m_isLogicReady;
  }

  public native const func GetClearance() -> ref<Clearance>;

  public final native func GetNativeActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void;

  public func GetActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetNativeActions(outActions, context);
    return true;
  }

  public func GetQuestActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void;

  public func GetQuestActionByName(actionName: CName) -> ref<DeviceAction> {
    return null;
  }

  public final func GetActionsToNative(context: GetActionsContext) -> array<ref<DeviceAction>> {
    let actions: array<ref<DeviceAction>>;
    this.GetActions(actions, context);
    return actions;
  }

  public final func GetQuestActionsToNative(context: GetActionsContext) -> array<ref<DeviceAction>> {
    let actions: array<ref<DeviceAction>>;
    this.GetQuestActions(actions, context);
    return actions;
  }

  public func GetQuestActionByNameToNative(actionName: CName) -> ref<DeviceAction> {
    return this.GetQuestActionByName(actionName);
  }

  public func OnMaraudersMapDeviceDebug(sink: ref<MaraudersMapDevicesSink>) -> Void {
    sink.PushString("I\'m a", "Computer");
    sink.PushString("I\'m a", "Computery guy");
    sink.PushString("Everything made out", "");
    sink.PushString("of buttons", "and wires");
  }

  public const func GetFirstAttachedSlave() -> ref<DeviceComponentPS> {
    return null;
  }

  public const func GetAttachedSlaveForPing(opt context: ref<MasterControllerPS>) -> ref<DeviceComponentPS> {
    return null;
  }

  public final const func GetBackdoorObjectiveData() -> ref<BackDoorObjectiveData> {
    return this.m_backdoorObjectiveData;
  }

  public final const func GetControlPanelObjectiveData() -> ref<ControlPanelObjectiveData> {
    return this.m_controlPanelObjectiveData;
  }

  public final func InitializeGameplayObjectives() -> Void {
    if IsDefined(this.m_backdoorObjectiveData) {
      this.m_backdoorObjectiveData.SetOwnerID(PersistentID.ExtractEntityID(this.GetID()));
    };
    if IsDefined(this.m_controlPanelObjectiveData) {
      this.m_controlPanelObjectiveData.SetOwnerID(PersistentID.ExtractEntityID(this.GetID()));
    };
  }

  public final func InitializeQuestDBCallbacksForQuestmark() -> Void {
    let factName: CName = this.GetFactToDisableQuestMarkName();
    if IsNameValid(factName) {
      this.m_callbackToDisableQuestMarkID = GameInstance.GetQuestsSystem(this.GetGameInstance()).RegisterEntity(factName, PersistentID.ExtractEntityID(this.GetID()));
    };
  }

  public final func UnInitializeQuestDBCallbacksForQuestmark() -> Void {
    let factName: CName = this.GetFactToDisableQuestMarkName();
    if IsNameValid(factName) && this.m_callbackToDisableQuestMarkID > 0u {
      GameInstance.GetQuestsSystem(this.GetGameInstance()).UnregisterEntity(factName, this.m_callbackToDisableQuestMarkID);
    };
  }

  public final const func GetOwnerEntityWeak() -> wref<Entity> {
    return GameInstance.FindEntityByID(this.GetGameInstance(), this.GetMyEntityID());
  }

  protected final const func GetNetworkSystem() -> ref<NetworkSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"NetworkSystem") as NetworkSystem;
  }

  protected final func ExposeQuickHacks(shouldExpose: Bool) -> Void {
    if shouldExpose {
      this.ExposeQuickHacks();
    } else {
      this.m_exposeQuickHacks = false;
    };
  }

  private final func ExposeQuickHacks() -> Void {
    this.m_exposeQuickHacks = true;
    this.m_isScanned = true;
  }

  public final const func IsQuickHacksExposed() -> Bool {
    if this.GetNetworkSystem().QuickHacksExposedByDefault() {
      return true;
    };
    return this.m_exposeQuickHacks;
  }

  public final func IsScanned() -> Bool {
    return this.m_isScanned;
  }

  public const func GetSecurityAreas(opt includeInactive: Bool, opt returnOnlyDirectlyConnected: Bool) -> array<ref<SecurityAreaControllerPS>> {
    let areas: array<ref<SecurityAreaControllerPS>>;
    let i: Int32;
    let parents: array<ref<DeviceComponentPS>>;
    let systemFound: Bool;
    this.GetParents(parents);
    i = 0;
    while i < ArraySize(parents) {
      if IsDefined(parents[i] as SecurityAreaControllerPS) {
        if (parents[i] as SecurityAreaControllerPS).IsActive() {
          ArrayPush(areas, parents[i] as SecurityAreaControllerPS);
        } else {
          if includeInactive {
            ArrayPush(areas, parents[i] as SecurityAreaControllerPS);
          };
        };
      };
      if IsDefined(parents[i] as SecuritySystemControllerPS) {
        systemFound = true;
      };
      i += 1;
    };
    if returnOnlyDirectlyConnected {
      return areas;
    };
    if ArraySize(areas) > 0 {
      return areas;
    };
    if systemFound {
      areas = this.GetSecuritySystem().GetSecurityAreas(includeInactive);
    };
    return areas;
  }

  public const func GetSecuritySystem() -> ref<SecuritySystemControllerPS> {
    let ancestors: array<ref<DeviceComponentPS>>;
    let i: Int32;
    let secSys: ref<SecuritySystemControllerPS>;
    this.GetAncestors(ancestors);
    i = 0;
    while i < ArraySize(ancestors) {
      if IsDefined(ancestors[i] as SecuritySystemControllerPS) {
        secSys = ancestors[i] as SecuritySystemControllerPS;
        if IsDefined(secSys) && !secSys.IsDisabled() {
          return secSys;
        };
      };
      i += 1;
    };
    return null;
  }

  public func GetPersistentStateName() -> CName {
    return this.GetClassName();
  }

  public const func GetChildren(out outDevices: array<ref<DeviceComponentPS>>) -> Void {
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetChildren(this.GetMyEntityID(), outDevices);
  }

  public const func GetLazyChildren(out outDevices: array<ref<LazyDevice>>) -> Void {
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetLazyChildren(this.GetMyEntityID(), outDevices);
  }

  public const func GetParents(out outDevices: array<ref<DeviceComponentPS>>) -> Void {
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetParents(this.GetMyEntityID(), outDevices);
  }

  public const func GetImmediateParents() -> array<ref<DeviceComponentPS>> {
    let masters: array<ref<DeviceComponentPS>>;
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetParents(this.GetMyEntityID(), masters);
    return masters;
  }

  public const func GetLazyParents() -> array<ref<LazyDevice>> {
    let masters: array<ref<LazyDevice>>;
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetLazyParents(this.GetMyEntityID(), masters);
    return masters;
  }

  public const func GetAncestors(out outDevices: array<ref<DeviceComponentPS>>) -> Void {
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetAllAncestors(this.GetMyEntityID(), outDevices);
  }

  public const func GetLazyAncestors() -> array<ref<LazyDevice>> {
    let ancestors: array<ref<LazyDevice>>;
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetLazyAllAncestors(this.GetMyEntityID(), ancestors);
    return ancestors;
  }

  public const func HasAnySlave() -> Bool {
    return false;
  }

  public const func HasAnyDeviceConnection() -> Bool {
    return this.HasAnySlave() || GameInstance.GetDeviceSystem(this.GetGameInstance()).HasAnyAncestor(this.GetMyEntityID());
  }

  public native const func GetDeviceName() -> String;

  public native const func GetDeviceStatus() -> String;

  public const func IsMasterType() -> Bool {
    return false;
  }

  public func HackGetOwner() -> ref<Entity> {
    let ent: ref<Entity> = new Entity();
    return ent;
  }

  public final const func IsBeingScanned() -> Bool {
    return this.m_isBeingScanned;
  }

  public final const func IsMarkedAsQuest() -> Bool {
    return this.m_markAsQuest;
  }

  public final const func IsAutoTogglingQuestMark() -> Bool {
    return this.m_autoToggleQuestMark;
  }

  public final const func GetFactToDisableQuestMarkName() -> CName {
    return this.m_factToDisableQuestMark;
  }

  public final const func IsAnyMasterFlaggedAsQuest() -> Bool {
    let i: Int32;
    let outDevices: array<ref<DeviceComponentPS>>;
    this.GetAncestors(outDevices);
    i = 0;
    while i < ArraySize(outDevices) {
      if outDevices[i].IsMarkedAsQuest() {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public native func GetWidgetTypeName() -> CName;

  public native func GetDeviceIconPath() -> String;

  public const func GetVirtualSystemType() -> EVirtualSystem {
    return IntEnum(0l);
  }

  public func GetDeviceIconID() -> CName {
    return n"";
  }

  public func GetDeviceWidget(context: GetActionsContext) -> SDeviceWidgetPackage {
    let widgetData: SDeviceWidgetPackage;
    return widgetData;
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return GetAllBlackboardDefs().DeviceBaseBlackboard;
  }

  public const func GetBlackboard() -> ref<IBlackboard> {
    return this.m_blackboard;
  }

  protected func GetInkWidgetLibraryPath() -> ResRef {
    return r"base\\movies\\misc\\distraction_generic.bk2";
  }

  protected func GetInkWidgetLibraryID(context: GetActionsContext) -> CName {
    return n"";
  }

  protected func GetInkWidgetTweakDBID(context: GetActionsContext) -> TweakDBID {
    return t"DevicesUIDefinitions.GenericDeviceWidget";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.GenenericDeviceBackground";
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.GenenericDeviceIcon";
  }

  public func GetThumbnailWidget() -> SThumbnailWidgetPackage {
    let widgetData: SThumbnailWidgetPackage;
    return widgetData;
  }

  protected func GetActionWidgets(context: GetActionsContext) -> array<SActionWidgetPackage> {
    let widgetsData: array<SActionWidgetPackage>;
    return widgetsData;
  }

  public func GetThumbnailAction() -> ref<ThumbnailUI> {
    return this.ActionThumbnailUI();
  }

  public final func SetIsMarkedAsQuest(isQuest: Bool) -> Void {
    this.m_markAsQuest = isQuest;
  }

  public final func SetIsBeingScannedFlag(isBeingScanned: Bool) -> Void {
    this.m_isBeingScanned = isBeingScanned;
  }

  public final func SetIsScanComplete(isComplete: Bool) -> Void {
    this.m_isScanned = isComplete;
  }

  public func DetermineInteractionState(interactionComponent: ref<InteractionComponent>, context: GetActionsContext) -> Void;

  public final func PassBlackboard(blackboard: ref<IBlackboard>) -> Void {
    this.m_blackboard = blackboard;
  }

  public const func GetVirtualSystem(slave: ref<DeviceComponentPS>, out vs: ref<VirtualSystemPS>) -> Bool {
    return false;
  }

  public const func GetVirtualSystem(id: PersistentID, out vs: ref<VirtualSystemPS>) -> Bool {
    return false;
  }

  public const func GetVirtualSystem(out vs: ref<VirtualSystemPS>) -> Bool {
    return false;
  }

  public func ResloveUIOnAction(action: ref<ScriptableDeviceAction>) -> Void;

  public func RefreshUI(blackboard: ref<IBlackboard>) -> Void;

  public func RequestBreadCrumbUpdate(blackboard: ref<IBlackboard>, data: SBreadCrumbUpdateData) -> Void;

  public func RequestActionWidgetsUpdate(blackboard: ref<IBlackboard>) -> Void;

  protected func ActionThumbnailUI() -> ref<ThumbnailUI> {
    let action: ref<ThumbnailUI> = new ThumbnailUI();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.GetDeviceName());
    action.CreateThumbnailWidgetPackage("LocKey#42210");
    return action;
  }

  protected final const func GetMyEntityID() -> EntityID {
    return PersistentID.ExtractEntityID(this.GetID());
  }
}

public static func BasicAvailabilityTest(device: ref<ScriptableDeviceComponentPS>) -> Bool {
  if device.IsDisabled() {
    return false;
  };
  if device.IsUnpowered() {
    return false;
  };
  if device.IsOFF() {
    return false;
  };
  return true;
}
