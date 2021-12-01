
public static func OperatorEqual(l1: DeviceLink, l2: DeviceLink) -> Bool {
  return Equals(DeviceLink.GetLinkID(l1), DeviceLink.GetLinkID(l2)) && Equals(DeviceLink.GetLinkClassName(l1), DeviceLink.GetLinkClassName(l2));
}

public static func OperatorEqual(ps: ref<PersistentState>, link: DeviceLink) -> Bool {
  return Equals(ps.GetID(), DeviceLink.GetLinkID(link)) && Equals(ps.GetClassName(), DeviceLink.GetLinkClassName(link));
}

public static func OperatorEqual(link: DeviceLink, ps: ref<PersistentState>) -> Bool {
  return ps == link;
}

public class DeviceLinkRequest extends Event {

  private let deviceLink: DeviceLink;

  public final static func Construct(id: PersistentID, _className: CName) -> ref<DeviceLinkRequest> {
    let request: ref<DeviceLinkRequest> = new DeviceLinkRequest();
    request.deviceLink = DeviceLink.Construct(id, _className);
    return request;
  }

  public final const func GetLink() -> DeviceLink {
    return this.deviceLink;
  }
}

public struct DeviceLink {

  private persistent let PSID: PersistentID;

  private persistent let className: CName;

  public final static func Construct(ps: ref<PersistentState>) -> DeviceLink {
    return DeviceLink.Construct(ps.GetID(), ps.GetClassName());
  }

  public final static func Construct(id: PersistentID, _className: CName) -> DeviceLink {
    let psRef: DeviceLink;
    if PersistentID.IsDefined(id) {
      psRef.PSID = id;
      psRef.className = _className;
      return psRef;
    };
    return new DeviceLink();
  }

  public final static func Construct(persistentStates: array<ref<PersistentState>>) -> array<DeviceLink> {
    let links: array<DeviceLink>;
    let i: Int32 = 0;
    while i < ArraySize(persistentStates) {
      ArrayPush(links, DeviceLink.Construct(persistentStates[i]));
      i += 1;
    };
    return links;
  }

  public final static func GetLinkID(s: script_ref<DeviceLink>) -> PersistentID {
    return Deref(s).PSID;
  }

  public final static func GetLinkClassName(s: script_ref<DeviceLink>) -> CName {
    return Deref(s).className;
  }

  public final static func IsValid(s: script_ref<DeviceLink>) -> Bool {
    return PersistentID.IsDefined(Deref(s).PSID) && IsNameValid(Deref(s).className);
  }
}

public class DeviceLinkComponentPS extends SharedGameplayPS {

  private persistent let m_parentDevice: DeviceLink;

  private persistent let m_isConnected: Bool;

  protected persistent let m_ownerEntityID: EntityID;

  public final static func CreateAndAcquireDeviceLink(game: GameInstance, entityID: EntityID) -> ref<DeviceLinkComponentPS> {
    let linkPSID: PersistentID = DeviceLinkComponentPS.GenerateID(entityID);
    let link: ref<DeviceLinkComponentPS> = GameInstance.GetPersistencySystem(game).GetConstAccessToPSObject(linkPSID, n"DeviceLinkComponentPS") as DeviceLinkComponentPS;
    if IsDefined(link) {
      return link;
    };
    return null;
  }

  public final static func AcquireDeviceLink(game: GameInstance, entityID: EntityID) -> ref<DeviceLinkComponentPS> {
    let link: ref<DeviceLinkComponentPS> = DeviceLinkComponentPS.CreateAndAcquireDeviceLink(game, entityID);
    if IsDefined(link) && link.IsConnected() {
      return link;
    };
    return null;
  }

  protected final const func GetParentDeviceLink() -> DeviceLink {
    return this.m_parentDevice;
  }

  public final const func GetParentDevice() -> wref<SharedGameplayPS> {
    let deviceRef: wref<SharedGameplayPS>;
    if this.IsConnected() {
      deviceRef = this.GetPersistencySystem().GetConstAccessToPSObject(DeviceLink.GetLinkID(this.GetParentDeviceLink()), DeviceLink.GetLinkClassName(this.GetParentDeviceLink())) as SharedGameplayPS;
      if IsDefined(deviceRef) {
        return deviceRef;
      };
      return null;
    };
    return null;
  }

  public final const func IsConnected() -> Bool {
    return this.m_isConnected;
  }

  protected func OnDeviceLinkRequest(evt: ref<DeviceLinkRequest>) -> EntityNotificationType {
    let agentSpawned: ref<SecurityAgentSpawnedEvent>;
    let deviceAttachment: ref<DeviceLinkEstablished>;
    let secSys: ref<SecuritySystemControllerPS>;
    if this.IsConnected() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    if DeviceLink.IsValid(evt.GetLink()) {
      this.m_parentDevice = evt.GetLink();
      this.m_isConnected = true;
      this.m_ownerEntityID = this.GetMyEntityID();
      deviceAttachment = new DeviceLinkEstablished();
      deviceAttachment.deviceLinkPS = this;
      this.EstablishLink(true);
      this.GetPersistencySystem().QueueEntityEvent(this.m_ownerEntityID, deviceAttachment);
      secSys = this.GetSecuritySystem();
      if IsDefined(secSys) {
        agentSpawned = SecurityAgentSpawnedEvent.Construct(DeviceLink.Construct(this), gameEntitySpawnerEventType.Spawn, this.GetSecurityAreas(true));
        this.QueuePSEvent(secSys, agentSpawned);
      };
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func OnDestroyLink(evt: ref<DestroyLink>) -> EntityNotificationType {
    let notification: ref<SecurityAgentSpawnedEvent>;
    let secSys: ref<SecuritySystemControllerPS>;
    if !this.IsConnected() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    secSys = this.GetSecuritySystem();
    if IsDefined(secSys) {
      notification = new SecurityAgentSpawnedEvent();
      notification.spawnedAgent = DeviceLink.Construct(this);
      notification.eventType = gameEntitySpawnerEventType.Despawn;
      this.QueuePSEvent(secSys, notification);
    };
    this.EstablishLink(false);
    this.GetPersistencySystem().ForgetObject(this.GetID(), false);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public const func GetParents(out outDevices: array<ref<DeviceComponentPS>>) -> Void {
    if this.IsConnected() {
      GameInstance.GetDeviceSystem(this.GetGameInstance()).GetParents(PersistentID.ExtractEntityID(DeviceLink.GetLinkID(this.GetParentDeviceLink())), outDevices);
    };
  }

  public const func GetAncestors(out outDevices: array<ref<DeviceComponentPS>>) -> Void {
    if this.IsConnected() {
      GameInstance.GetDeviceSystem(this.GetGameInstance()).GetAllAncestors(PersistentID.ExtractEntityID(DeviceLink.GetLinkID(this.GetParentDeviceLink())), outDevices);
    };
  }

  private final const func EstablishLink(connect: Bool) -> Void {
    let ancestors: array<ref<DeviceComponentPS>>;
    this.GetParentDevice().GetParents(ancestors);
    if connect {
      this.Connect(ancestors);
    } else {
      this.Disconnect(ancestors);
    };
  }

  private final const func Disconnect(links: array<ref<DeviceComponentPS>>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(links) {
      this.Disconnect(links[i]);
      i += 1;
    };
  }

  private final const func Disconnect(link: ref<DeviceComponentPS>) -> Void {
    GameInstance.GetDeviceSystem(this.GetGameInstance()).RemoveDynamicConnection(this.GetID(), link.GetID());
  }

  private final const func Connect(links: array<ref<DeviceComponentPS>>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(links) {
      this.Connect(links[i]);
      i += 1;
    };
  }

  private final const func Connect(link: ref<DeviceComponentPS>) -> Void {
    GameInstance.GetDeviceSystem(this.GetGameInstance()).AddDynamicConnection(this.GetID(), this.GetClassName(), link.GetID(), link.GetClassName());
  }

  public final static func GenerateID(id: EntityID) -> PersistentID {
    return CreatePersistentID(id, n"deviceLink");
  }

  public const func HasNetworkBackdoor() -> Bool {
    return this.GetParentDevice().HasNetworkBackdoor();
  }

  public final const func ActionSecurityBreachNotification(lastKnownPosition: Vector4, whoBreached: ref<GameObject>, type: ESecurityNotificationType, opt stimType: gamedataStimType) -> ref<SecuritySystemInput> {
    let canPerformReprimand: Bool;
    let isOfficer: Bool = (this.GetOwnerEntityWeak() as ScriptedPuppet).IsOfficer();
    let action: ref<SecuritySystemInput> = new SecuritySystemInput();
    action.SetUp(this);
    if IsDefined(whoBreached) {
      canPerformReprimand = true;
    } else {
      canPerformReprimand = false;
    };
    action.SetProperties(lastKnownPosition, whoBreached, this, type, canPerformReprimand, isOfficer, stimType);
    action.AddDeviceName("DebugNPC");
    action.SetPuppetCharacterRecord((this.GetOwnerEntityWeak() as ScriptedPuppet).GetRecordID());
    return action;
  }

  public const func TriggerSecuritySystemNotification(lastKnownPosition: Vector4, whoBreached: ref<GameObject>, type: ESecurityNotificationType, opt stimType: gamedataStimType) -> Void {
    let secSys: ref<SecuritySystemControllerPS>;
    if this.IsConnected() {
      secSys = this.GetSecuritySystem();
      if !IsDefined(secSys) {
        return;
      };
      secSys.ReportPotentialSituation(this.ActionSecurityBreachNotification(lastKnownPosition, whoBreached, type, stimType));
      return;
    };
  }

  protected final func OnSecuritySystemEnabled(evt: ref<SecuritySystemEnabled>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnSecuritySystemDisabled(evt: ref<SecuritySystemDisabled>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func OnSecuritySystemOutput(evt: ref<SecuritySystemOutput>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnSecurityAreaCrossingPerimeter(evt: ref<SecurityAreaCrossingPerimeter>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnTargetAssessmentRequest(evt: ref<TargetAssessmentRequest>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  public const func WasRevealedInNetworkPing() -> Bool {
    return this.GetParentDevice().WasRevealedInNetworkPing();
  }

  public const func SetRevealedInNetworkPing(wasRevealed: Bool) -> Void {
    return this.GetParentDevice().SetRevealedInNetworkPing(wasRevealed);
  }

  public final const func GetDevice(deviceLink: DeviceLink) -> wref<DeviceComponentPS> {
    let device: ref<DeviceComponentPS> = this.GetPersistencySystem().GetConstAccessToPSObject(DeviceLink.GetLinkID(deviceLink), DeviceLink.GetLinkClassName(deviceLink)) as SharedGameplayPS;
    return device;
  }

  protected final const func QueuePSEvent(deviceLink: DeviceLink, evt: ref<Event>) -> Void {
    this.GetPersistencySystem().QueuePSEvent(DeviceLink.GetLinkID(deviceLink), DeviceLink.GetLinkClassName(deviceLink), evt);
  }

  public final const func PingDevicesNetwork() -> Void {
    let actionPing: ref<PingDevice>;
    let aps: array<ref<AccessPointControllerPS>>;
    let i: Int32;
    if this.IsConnected() {
      aps = this.GetAccessPoints();
      i = 0;
      while i < ArraySize(aps) {
        actionPing = this.ActionDevicePing(aps[i]);
        this.QueuePSEvent(aps[i], actionPing);
        i += 1;
      };
    };
  }

  private final const func ActionDevicePing(const ps: ref<PersistentState>) -> ref<PingDevice> {
    let action: ref<PingDevice> = new PingDevice();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(ps);
    action.SetProperties();
    action.SetShouldForward(false);
    action.SetObjectActionID(t"DeviceAction.PingDevice");
    return action;
  }
}

public class PuppetDeviceLinkPS extends DeviceLinkComponentPS {

  private persistent let m_securitySystemData: SecuritySystemData;

  public final static func CreateAndAcquirePuppetDeviceLinkPS(game: GameInstance, id: EntityID) -> ref<PuppetDeviceLinkPS> {
    let linkPSID: PersistentID = DeviceLinkComponentPS.GenerateID(id);
    let link: ref<PuppetDeviceLinkPS> = GameInstance.GetPersistencySystem(game).GetConstAccessToPSObject(linkPSID, n"PuppetDeviceLinkPS") as PuppetDeviceLinkPS;
    if IsDefined(link) {
      return link;
    };
    return null;
  }

  public final static func AcquirePuppetDeviceLink(game: GameInstance, entityID: EntityID) -> ref<PuppetDeviceLinkPS> {
    let link: ref<PuppetDeviceLinkPS> = PuppetDeviceLinkPS.CreateAndAcquirePuppetDeviceLinkPS(game, entityID);
    if IsDefined(link) && link.IsConnected() {
      return link;
    };
    return null;
  }

  protected func OnDeviceLinkRequest(evt: ref<DeviceLinkRequest>) -> EntityNotificationType {
    this.OnDeviceLinkRequest(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final const func AreIncomingEventsSuppressed() -> Bool {
    return SecuritySystemData.AreIncomingEventsSuppressed(this.m_securitySystemData);
  }

  public final const func AreOutgoingEventsSuppressed() -> Bool {
    return SecuritySystemData.AreOutgoingEventsSuppressed(this.m_securitySystemData);
  }

  public const func TriggerSecuritySystemNotification(lastKnownPosition: Vector4, whoBreached: ref<GameObject>, type: ESecurityNotificationType, opt stimType: gamedataStimType) -> Void {
    if this.AreOutgoingEventsSuppressed() {
      return;
    };
    this.TriggerSecuritySystemNotification(lastKnownPosition, whoBreached, type, stimType);
  }

  protected func OnSecuritySystemOutput(evt: ref<SecuritySystemOutput>) -> EntityNotificationType {
    if this.m_securitySystemData.suppressIncomingEvents {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func OnSuppressNPCInSecuritySystem(evt: ref<SuppressNPCInSecuritySystem>) -> EntityNotificationType {
    this.m_securitySystemData.suppressIncomingEvents = evt.suppressIncomingEvents;
    this.m_securitySystemData.suppressOutgoingEvents = evt.suppressOutgoingEvents;
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func OnSecuritySystemSupport(evt: ref<SecuritySystemSupport>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final const func PerformNPCBreach(state: HackingMinigameState) -> Void {
    let npcBreachEvent: ref<NPCBreachEvent>;
    if this.IsConnected() {
      npcBreachEvent = new NPCBreachEvent();
      npcBreachEvent.state = state;
      this.QueuePSEvent(this.GetParentDeviceLink(), npcBreachEvent);
    };
  }

  public final const func NotifyAboutSpottingPlayer(doSee: Bool) -> Void {
    let playerSpotted: ref<PlayerSpotted>;
    let secSys: ref<SecuritySystemControllerPS> = this.GetSecuritySystem();
    if !IsDefined(secSys) {
      return;
    };
    playerSpotted = PlayerSpotted.Construct(true, this.GetID(), doSee, this.GetSecurityAreas());
    this.QueuePSEvent(secSys, playerSpotted);
  }

  public final const func PingSquadNetwork() -> Void {
    let evt: ref<ExecutePuppetActionEvent>;
    if this.IsConnected() {
      evt = new ExecutePuppetActionEvent();
      evt.actionID = t"QuickHack.PingHack";
      evt.action = this.ActionPingSquad();
      this.QueueEntityEvent(this.GetMyEntityID(), evt);
    };
  }

  private final const func ActionPingSquad() -> ref<PingSquad> {
    let action: ref<PingSquad> = new PingSquad();
    action.SetShouldForward(false);
    return action;
  }

  public const func IsPuppet() -> Bool {
    return true;
  }
}

public class VehicleDeviceLinkPS extends DeviceLinkComponentPS {

  public final static func CreateAndAcquirVehicleDeviceLinkPS(game: GameInstance, entityID: EntityID) -> ref<VehicleDeviceLinkPS> {
    let linkPSID: PersistentID = DeviceLinkComponentPS.GenerateID(entityID);
    let link: ref<VehicleDeviceLinkPS> = GameInstance.GetPersistencySystem(game).GetConstAccessToPSObject(linkPSID, n"VehicleDeviceLinkPS") as VehicleDeviceLinkPS;
    if IsDefined(link) {
      return link;
    };
    return null;
  }

  public final static func AcquireVehicleDeviceLink(game: GameInstance, entityID: EntityID) -> ref<VehicleDeviceLinkPS> {
    let link: ref<VehicleDeviceLinkPS> = VehicleDeviceLinkPS.CreateAndAcquirVehicleDeviceLinkPS(game, entityID);
    if IsDefined(link) && link.IsConnected() {
      return link;
    };
    return null;
  }

  protected func OnDeviceLinkRequest(evt: ref<DeviceLinkRequest>) -> EntityNotificationType {
    this.OnDeviceLinkRequest(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }
}
