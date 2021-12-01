
public class MasterController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class MasterControllerPS extends ScriptableDeviceComponentPS {

  protected let m_clearance: ref<Clearance>;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func OnDeviceDynamicConnectionChange(evt: ref<DeviceDynamicConnectionChange>) -> EntityNotificationType {
    this.OnDeviceDynamicConnectionChange(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func CacheDevices() -> Void;

  public const func GetExpectedSlaveState() -> EDeviceStatus {
    return EDeviceStatus.INVALID;
  }

  protected const func GetClearance() -> ref<Clearance> {
    return Clearance.CreateClearance(1, 100);
  }

  protected func DetermineGameplayViability(context: GetActionsContext, hasActiveActions: Bool) -> Bool {
    return MasterViabilityInterpreter.Evaluate(this, hasActiveActions);
  }

  public func GetWidgetTypeName() -> CName {
    return n"GenericMasterDeviceWidget";
  }

  public final func NetrunnerGiveConnectedDevices() -> array<ref<DeviceComponentPS>> {
    let devices: array<ref<DeviceComponentPS>>;
    let entityID: EntityID = PersistentID.ExtractEntityID(this.GetID());
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetChildren(entityID, devices);
    return devices;
  }

  public const func IsMasterType() -> Bool {
    return true;
  }

  public const func GetAttachedSlaveForPing(opt context: ref<MasterControllerPS>) -> ref<DeviceComponentPS> {
    let i: Int32;
    let slave: ref<ScriptableDeviceComponentPS>;
    let slaves: array<ref<DeviceComponentPS>>;
    if IsDefined(context) {
      slaves = context.GetImmediateSlaves();
    } else {
      slaves = this.GetImmediateSlaves();
    };
    i = 0;
    while i < ArraySize(slaves) {
      slave = slaves[i] as ScriptableDeviceComponentPS;
      if !IsDefined(slave) {
      } else {
        if slave.IsAttachedToGame() {
          if !slave.ShouldRevealDevicesGrid() || slave.HasNetworkBackdoor() {
          } else {
            return slave;
          };
        };
      };
      i += 1;
    };
    return null;
  }

  public const func GetFirstAttachedSlave() -> ref<DeviceComponentPS> {
    let slaves: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(slaves) {
      if slaves[i].IsAttachedToGame() {
        return slaves[i];
      };
      i += 1;
    };
    return null;
  }

  public final const func GetAllDescendants(out outDevices: array<ref<DeviceComponentPS>>) -> Void {
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetAllDescendants(PersistentID.ExtractEntityID(this.GetID()), outDevices);
  }

  public final const func GetPuppets() -> array<ref<PuppetDeviceLinkPS>> {
    let allSlaves: array<ref<DeviceComponentPS>>;
    let i: Int32;
    let puppetLink: ref<PuppetDeviceLinkPS>;
    let puppets: array<ref<PuppetDeviceLinkPS>>;
    this.GetAllDescendants(allSlaves);
    i = 0;
    while i < ArraySize(allSlaves) {
      puppetLink = allSlaves[i] as PuppetDeviceLinkPS;
      if IsDefined(puppetLink) {
        ArrayPush(puppets, puppetLink);
      };
      i += 1;
    };
    return puppets;
  }

  public const func GetImmediateSlaves() -> array<ref<DeviceComponentPS>> {
    let slaves: array<ref<DeviceComponentPS>>;
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetChildren(this.GetMyEntityID(), slaves);
    return slaves;
  }

  public const func GetLazySlaves() -> array<ref<LazyDevice>> {
    let slaves: array<ref<LazyDevice>>;
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetLazyChildren(this.GetMyEntityID(), slaves);
    return slaves;
  }

  public const func HasAnySlave() -> Bool {
    return GameInstance.GetDeviceSystem(this.GetGameInstance()).HasAnyChild(this.GetMyEntityID());
  }

  public final const func GetImmediateDescendants() -> array<ref<DeviceComponentPS>> {
    let immediateDescendants: array<ref<DeviceComponentPS>>;
    let entityID: EntityID = PersistentID.ExtractEntityID(this.GetID());
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetAllDescendants(entityID, immediateDescendants);
    return immediateDescendants;
  }

  public final const func GetLazyDescendants() -> array<ref<LazyDevice>> {
    let descendants: array<ref<LazyDevice>>;
    let entityID: EntityID = PersistentID.ExtractEntityID(this.GetID());
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetLazyAllDescendants(entityID, descendants);
    return descendants;
  }

  protected final func ExtractActionFromSlave(slave: ref<DeviceComponentPS>, actionName: CName, out outAction: ref<DeviceAction>) -> Bool {
    outAction = (slave as ScriptableDeviceComponentPS).GetActionByName(actionName);
    if IsDefined(outAction) {
      return true;
    };
    return false;
  }

  protected final const func SendActionsToAllSlaves(actions: array<ref<ScriptableDeviceAction>>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(actions) {
      this.SendActionToAllSlaves(actions[i]);
      i += 1;
    };
  }

  protected const func SendActionToAllSlaves(action: ref<ScriptableDeviceAction>) -> Void {
    let slaves: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(slaves) {
      this.ExecutePSAction(action, slaves[i]);
      i += 1;
    };
  }

  protected final const func SendEventToAllSlaves(evt: ref<Event>) -> Void {
    let slaves: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(slaves) {
      this.GetPersistencySystem().QueuePSEvent(slaves[i].GetID(), slaves[i].GetClassName(), evt);
      i += 1;
    };
  }

  protected final const func GetQuickHacksFromSlave(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let slaves: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(slaves) {
      (slaves[i] as ScriptableDeviceComponentPS).GetQuickHackActionsExternal(outActions, context);
      i += 1;
    };
  }

  public final func RequestAreaEffectVisualisationUpdateOnSlaves(areaEffectID: CName, show: Bool) -> Void {
    let evt: ref<AreaEffectVisualisationRequest> = new AreaEffectVisualisationRequest();
    evt.show = show;
    evt.areaEffectID = areaEffectID;
    let devices: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(devices) {
      if Equals(this.GetID(), devices[i].GetID()) {
      } else {
        this.GetPersistencySystem().QueueEntityEvent(PersistentID.ExtractEntityID(devices[i].GetID()), evt);
      };
      i += 1;
    };
  }

  public func OnRequestThumbnailWidgetsUpdate(evt: ref<RequestThumbnailWidgetsUpdateEvent>) -> Void {
    this.RequestThumbnailWidgetsUpdate(this.GetBlackboard());
  }

  public func OnRequestDeviceWidgetUpdate(evt: ref<RequestDeviceWidgetUpdateEvent>) -> Void {
    this.RequestDeviceWidgetsUpdate(this.GetBlackboard(), evt.requester);
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return GetAllBlackboardDefs().MasterDeviceBaseBlackboard;
  }

  public func GetThumbnailWidgets() -> array<SThumbnailWidgetPackage> {
    let currentWidget: SThumbnailWidgetPackage;
    let widgetsData: array<SThumbnailWidgetPackage>;
    let devices: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(devices) {
      if Equals(devices[i].GetID(), this.GetID()) {
      } else {
        currentWidget = devices[i].GetThumbnailWidget();
        if currentWidget.isValid {
          ArrayPush(widgetsData, currentWidget);
        };
      };
      i += 1;
    };
    return widgetsData;
  }

  public func GetDeviceWidgets() -> array<SDeviceWidgetPackage> {
    let currentWidget: SDeviceWidgetPackage;
    let widgetsData: array<SDeviceWidgetPackage>;
    let devices: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(devices) {
      currentWidget = devices[i].GetDeviceWidget(this.GenerateContext(gamedeviceRequestType.External, this.GetClearance()));
      if currentWidget.isValid {
        ArrayPush(widgetsData, devices[i].GetDeviceWidget(this.GenerateContext(gamedeviceRequestType.External, this.GetClearance())));
      };
      i += 1;
    };
    return widgetsData;
  }

  public func GetSlaveDeviceWidget(deviceID: PersistentID) -> SDeviceWidgetPackage {
    let widgetData: SDeviceWidgetPackage;
    let devices: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    widgetData.isValid = false;
    let i: Int32 = 0;
    while i < ArraySize(devices) {
      if Equals(devices[i].GetID(), this.GetID()) {
      } else {
        if Equals(devices[i].GetID(), deviceID) {
          widgetData = devices[i].GetDeviceWidget(this.GenerateContext(gamedeviceRequestType.External, this.GetClearance()));
        } else {
          i += 1;
        };
      };
    };
    return widgetData;
  }

  public func RequestThumbnailWidgetsUpdate(blackboard: ref<IBlackboard>) -> Void {
    let widgetsData: array<SThumbnailWidgetPackage> = this.GetThumbnailWidgets();
    if IsDefined(blackboard) && ArraySize(widgetsData) > 0 {
      blackboard.SetVariant(this.GetBlackboardDef() as MasterDeviceBaseBlackboardDef.ThumbnailWidgetsData, ToVariant(widgetsData));
      blackboard.SignalVariant(this.GetBlackboardDef() as MasterDeviceBaseBlackboardDef.ThumbnailWidgetsData);
      blackboard.FireCallbacks();
    };
  }

  public func RequestDeviceWidgetsUpdate(blackboard: ref<IBlackboard>, devices: array<PersistentID>) -> Void {
    let widgetData: SDeviceWidgetPackage;
    let widgetsData: array<SDeviceWidgetPackage>;
    let i: Int32 = 0;
    while i < ArraySize(devices) {
      widgetData = this.GetSlaveDeviceWidget(devices[i]);
      if widgetData.isValid {
        ArrayPush(widgetsData, widgetData);
      };
      i += 1;
    };
    if IsDefined(blackboard) && ArraySize(widgetsData) > 0 {
      blackboard.SetVariant(this.GetBlackboardDef().DeviceWidgetsData, ToVariant(widgetsData));
      blackboard.SignalVariant(this.GetBlackboardDef().DeviceWidgetsData);
      blackboard.FireCallbacks();
    };
  }

  public func RequestDeviceWidgetsUpdate(blackboard: ref<IBlackboard>, deviceID: PersistentID) -> Void {
    let widgetsData: array<SDeviceWidgetPackage>;
    let widgetData: SDeviceWidgetPackage = this.GetSlaveDeviceWidget(deviceID);
    if widgetData.isValid {
      ArrayPush(widgetsData, widgetData);
    };
    if IsDefined(blackboard) && ArraySize(widgetsData) > 0 {
      blackboard.SetVariant(this.GetBlackboardDef().DeviceWidgetsData, ToVariant(widgetsData));
      blackboard.SignalVariant(this.GetBlackboardDef().DeviceWidgetsData);
      blackboard.FireCallbacks();
    };
  }

  public final func RequestAllDevicesWidgetsUpdate(blackboard: ref<IBlackboard>) -> Void {
    let widgetsData: array<SDeviceWidgetPackage> = this.GetDeviceWidgets();
    if IsDefined(blackboard) && ArraySize(widgetsData) > 0 {
      blackboard.SetVariant(this.GetBlackboardDef().DeviceWidgetsData, ToVariant(widgetsData));
      blackboard.SignalVariant(this.GetBlackboardDef().DeviceWidgetsData);
      blackboard.FireCallbacks();
    };
  }

  public final func RefreshSlaves_Event(opt onInitialize: Bool, opt force: Bool) -> Void {
    let evt: ref<RefreshSlavesEvent> = new RefreshSlavesEvent();
    evt.onInitialize = onInitialize;
    evt.force = force;
    this.ProcessDevicesLazy(this.GetLazySlaves(), evt);
  }

  public final func RefreshPowerOnSlaves_Event() -> Void {
    let evt: ref<RefreshPowerOnSlavesEvent> = new RefreshPowerOnSlavesEvent();
    this.ProcessDevicesLazy(this.GetLazySlaves(), evt);
  }

  public final func RefreshDefaultHighlightOnSlaves() -> Void {
    let slaves: array<ref<DeviceComponentPS>> = this.GetImmediateDescendants();
    let evt: ref<ForceUpdateDefaultHighlightEvent> = new ForceUpdateDefaultHighlightEvent();
    let i: Int32 = 0;
    while i < ArraySize(slaves) {
      this.QueuePSEvent(slaves[i], evt);
      i += 1;
    };
  }

  public final func SetSlavesAsQuestImportant(isImportant: Bool) -> Void {
    let i: Int32;
    let slaves: array<ref<DeviceComponentPS>> = this.GetImmediateDescendants();
    let evt: ref<SetAsQuestImportantEvent> = new SetAsQuestImportantEvent();
    evt.SetImportant(isImportant);
    i = 0;
    while i < ArraySize(slaves) {
      this.QueuePSEvent(slaves[i], evt);
      i += 1;
    };
  }

  protected func OnRefreshSlavesEvent(evt: ref<RefreshSlavesEvent>) -> EntityNotificationType {
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnFillTakeOverChainBBoardEvent(evt: ref<FillTakeOverChainBBoardEvent>) -> EntityNotificationType {
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func FillTakeOverChainBB() -> Void {
    let customData: ref<ControlledDeviceData>;
    let i1: Int32;
    let isDuplicated: Bool;
    let newDeviceChainnStruct: SWidgetPackage;
    let chainBlackBoard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().DeviceTakeControl);
    let deviceChain: array<SWidgetPackage> = FromVariant(chainBlackBoard.GetVariant(GetAllBlackboardDefs().DeviceTakeControl.DevicesChain));
    let devices: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let validDeviceNumber: Int32 = ArraySize(deviceChain);
    let i: Int32 = 0;
    while i < ArraySize(devices) {
      if (devices[i] as ScriptableDeviceComponentPS).CanBeInDeviceChain() {
        i1 = 0;
        while i1 < ArraySize(deviceChain) {
          if Equals(deviceChain[i1].ownerID, devices[i].GetID()) {
            isDuplicated = true;
          };
          i1 += 1;
        };
        if isDuplicated {
        } else {
          validDeviceNumber += 1;
          customData = new ControlledDeviceData();
          customData.m_isActive = (devices[i] as ScriptableDeviceComponentPS).IsControlledByPlayer();
          newDeviceChainnStruct.displayName = devices[i].GetDeviceName() + " " + "[" + IntToString(validDeviceNumber) + "]";
          newDeviceChainnStruct.ownerID = devices[i].GetID();
          newDeviceChainnStruct.ownerIDClassName = devices[i].GetClassName();
          newDeviceChainnStruct.customData = customData;
          newDeviceChainnStruct.libraryID = n"device";
          ArrayPush(deviceChain, newDeviceChainnStruct);
        };
      };
      i += 1;
    };
    chainBlackBoard.SetVariant(GetAllBlackboardDefs().DeviceTakeControl.DevicesChain, ToVariant(deviceChain));
  }

  public func RevealDevicesGrid(shouldDraw: Bool, opt ownerEntityPosition: Vector4, opt fxDefault: FxResource, opt isPing: Bool, opt lifetime: Float, opt revealSlave: Bool, opt revealMaster: Bool, opt ignoreRevealed: Bool) -> Void {
    let i: Int32;
    let linkData: SNetworkLinkData;
    let linksData: array<SNetworkLinkData>;
    let networkSystem: ref<NetworkSystem>;
    let registerLinkRequest: ref<RegisterNetworkLinkRequest>;
    let slave: ref<ScriptableDeviceComponentPS>;
    let slaveEntity: ref<Device>;
    let slavePosition: Vector4;
    let slaves: array<ref<DeviceComponentPS>>;
    let unregisterLinkRequest: ref<UnregisterNetworkLinksByIDRequest>;
    if !this.ShouldRevealDevicesGrid() {
      return;
    };
    networkSystem = this.GetNetworkSystem();
    if !shouldDraw {
      if networkSystem.HasNetworkLink(PersistentID.ExtractEntityID(this.GetID())) {
        unregisterLinkRequest = new UnregisterNetworkLinksByIDRequest();
        unregisterLinkRequest.ID = PersistentID.ExtractEntityID(this.GetID());
        networkSystem.QueueRequest(unregisterLinkRequest);
      };
      return;
    };
    if Vector4.IsZero(ownerEntityPosition) {
      return;
    };
    if this.m_fullDepth {
      slaves = this.GetImmediateDescendants();
    } else {
      slaves = this.GetImmediateSlaves();
    };
    if ArraySize(slaves) == 0 {
      return;
    };
    if this.IsUnpowered() && !this.CanRevealDevicesGridWhenUnpowered() || this.IsDisabled() || ignoreRevealed && this.WasRevealedInNetworkPing() {
      return;
    };
    linkData.masterID = PersistentID.ExtractEntityID(this.GetID());
    linkData.masterPos = ownerEntityPosition;
    linkData.linkType = ELinkType.GRID;
    linkData.isPing = isPing;
    linkData.lifetime = lifetime;
    linkData.revealSlave = revealSlave;
    linkData.revealMaster = revealMaster;
    if isPing {
      linkData.permanent = lifetime > 0.00;
    };
    linkData.fxResource = fxDefault;
    i = 0;
    while i < ArraySize(slaves) {
      slave = slaves[i] as ScriptableDeviceComponentPS;
      if slave == null || !slave.ShouldRevealDevicesGrid() || ignoreRevealed && slave.WasRevealedInNetworkPing() || slave.IsUnpowered() && !slave.CanRevealDevicesGridWhenUnpowered() {
      } else {
        slaveEntity = slaves[i].GetOwnerEntityWeak() as Device;
        if !IsDefined(slaveEntity) {
          GameInstance.GetDeviceSystem(this.GetGameInstance()).GetNodePosition(PersistentID.ExtractEntityID(slaves[i].GetID()), slavePosition);
        } else {
          slavePosition = slaveEntity.GetNetworkBeamEndpoint();
        };
        if Vector4.IsZero(slavePosition) {
        } else {
          linkData.slaveID = PersistentID.ExtractEntityID(slaves[i].GetID());
          linkData.slavePos = slavePosition;
          linkData.drawLink = this.m_drawGridLink && slave.ShouldDrawGridLink();
          linkData.isDynamic = this.IsLinkDynamic() || slave.IsLinkDynamic();
          if isPing && !linkData.drawLink {
          } else {
            ArrayPush(linksData, linkData);
          };
        };
      };
      i += 1;
    };
    if ArraySize(linksData) > 0 {
      registerLinkRequest = new RegisterNetworkLinkRequest();
      registerLinkRequest.linksData = linksData;
      networkSystem.QueueRequest(registerLinkRequest);
    };
  }
}
