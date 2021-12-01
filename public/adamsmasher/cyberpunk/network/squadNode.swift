
public class CommunityProxyPS extends MasterControllerPS {

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
  }

  protected func Initialize() -> Void {
    this.Initialize();
    this.InitializeConnectionWithCommunity();
  }

  public final func OnCommunityProxyPSPresent(evt: ref<CommunityProxyPSPresentEvent>) -> EntityNotificationType {
    this.InitializeConnectionWithCommunity();
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func QueuePSEvent(deviceLink: DeviceLink, evt: ref<Event>) -> Void {
    this.GetPersistencySystem().QueuePSEvent(DeviceLink.GetLinkID(deviceLink), DeviceLink.GetLinkClassName(deviceLink), evt);
  }

  protected final func InitializeConnectionWithCommunity() -> Void {
    let i: Int32;
    let npcs: array<EntityID> = this.ExtractEntityIDs();
    GameInstance.GetEntitySpawnerEventsBroadcaster(this.GetGameInstance()).RegisterSpawnerEventPSListener(this.GetMyEntityID(), n"", this.GetID(), this.GetClassName());
    i = 0;
    while i < ArraySize(npcs) {
      this.EstablishLink(npcs[i]);
      i += 1;
    };
  }

  public final func OnGameEntitySpawnerEvent(evt: ref<gameEntitySpawnerEvent>) -> EntityNotificationType {
    if Equals(evt.eventType, gameEntitySpawnerEventType.Spawn) {
      this.EstablishLink(evt.spawnedEntityId);
      if !IsFinal() {
        LogDevices(this, EntityID.ToDebugString(this.GetMyEntityID()) + " notified about " + EntityID.ToDebugString(evt.spawnedEntityId) + " spawn");
      };
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final const func EstablishLink(targetID: EntityID) -> Void {
    let request: ref<DeviceLinkRequest> = DeviceLinkRequest.Construct(this.GetID(), this.GetClassName());
    this.GetPersistencySystem().QueueEntityEvent(targetID, request);
  }

  public final const func GetNPCsConnectedToThisAPCount() -> Int32 {
    return 666;
  }

  protected final const func GetPuppetEntity(id: EntityID) -> wref<ScriptedPuppet> {
    return GameInstance.FindEntityByID(this.GetGameInstance(), id) as ScriptedPuppet;
  }

  public final const func IsOfficer(id: EntityID) -> Bool {
    let puppet: ref<ScriptedPuppet> = this.GetPuppetEntity(id);
    if IsDefined(puppet) {
      return puppet.IsOfficer();
    };
    return false;
  }

  public final const func DrawNetworkSquad(shouldDraw: Bool, fxResource: FxResource, memberID: PersistentID, isPing: Bool, revealMaster: Bool, revealSlave: Bool, memberOnly: Bool, opt duration: Float) -> Void {
    let drawNetworkSquadEvent: ref<DrawNetworkSquadEvent> = new DrawNetworkSquadEvent();
    drawNetworkSquadEvent.shouldDraw = shouldDraw;
    drawNetworkSquadEvent.memberID = memberID;
    drawNetworkSquadEvent.fxResource = fxResource;
    drawNetworkSquadEvent.isPing = isPing;
    drawNetworkSquadEvent.revealMaster = revealMaster;
    drawNetworkSquadEvent.revealSlave = revealSlave;
    drawNetworkSquadEvent.memberOnly = memberOnly;
    drawNetworkSquadEvent.duration = duration;
    this.GetPersistencySystem().QueuePSEvent(this.GetID(), this.GetClassName(), drawNetworkSquadEvent);
  }

  public final func OnDrawNetworkSquadEvent(evt: ref<DrawNetworkSquadEvent>) -> EntityNotificationType {
    let newLink: SNetworkLinkData;
    let officerID: EntityID;
    let puppet: ref<ScriptedPuppet>;
    let registerLinkRequest: ref<RegisterNetworkLinkRequest> = new RegisterNetworkLinkRequest();
    let membersIDs: array<EntityID> = this.ExtractEntityIDs();
    let i: Int32 = 0;
    while i < ArraySize(membersIDs) {
      if this.IsOfficer(membersIDs[i]) {
        officerID = membersIDs[i];
        ArrayErase(membersIDs, i);
      } else {
        i += 1;
      };
    };
    puppet = this.GetPuppetEntity(officerID);
    if puppet == null {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    newLink.fxResource = evt.fxResource;
    newLink.masterID = officerID;
    newLink.isDynamic = true;
    newLink.drawLink = evt.shouldDraw;
    newLink.fxResource = evt.fxResource;
    newLink.linkType = ELinkType.NETWORK;
    newLink.isPing = evt.isPing;
    newLink.masterPos = puppet.GetWorldPosition();
    newLink.lifetime = evt.duration;
    newLink.revealMaster = evt.revealMaster;
    newLink.revealSlave = evt.revealSlave;
    i = 0;
    while i < ArraySize(membersIDs) {
      if evt.memberOnly && membersIDs[i] != PersistentID.ExtractEntityID(evt.memberID) {
      } else {
        puppet = this.GetPuppetEntity(membersIDs[i]);
        if puppet == null {
        } else {
          newLink.slaveID = membersIDs[i];
          newLink.slavePos = puppet.GetWorldPosition();
          ArrayPush(registerLinkRequest.linksData, newLink);
        };
      };
      i += 1;
    };
    if ArraySize(registerLinkRequest.linksData) > 0 {
      this.GetNetworkSystem().QueueRequest(registerLinkRequest);
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func OnSecuritySystemOutput(evt: ref<SecuritySystemOutput>) -> EntityNotificationType {
    let npcs: array<EntityID> = this.ExtractEntityIDs();
    let i: Int32 = 0;
    while i < ArraySize(npcs) {
      this.GetPersistencySystem().QueueEntityEvent(npcs[i], evt);
      i += 1;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func OnSecurityAreaCrossingPerimeter(evt: ref<SecurityAreaCrossingPerimeter>) -> EntityNotificationType {
    let npcs: array<EntityID> = this.ExtractEntityIDs();
    let i: Int32 = 0;
    while i < ArraySize(npcs) {
      if EntityID.IsDefined(npcs[i]) {
        this.GetPersistencySystem().QueueEntityEvent(npcs[i], evt);
      };
      i += 1;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func OnTargetAssessmentRequest(evt: ref<TargetAssessmentRequest>) -> EntityNotificationType {
    let npcs: array<EntityID> = this.ExtractEntityIDs();
    let i: Int32 = 0;
    while i < ArraySize(npcs) {
      if EntityID.IsDefined(npcs[i]) {
        this.GetPersistencySystem().QueueEntityEvent(npcs[i], evt);
      };
      i += 1;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func OnSetExposeQuickHacks(evt: ref<SetExposeQuickHacks>) -> EntityNotificationType {
    this.OnSetExposeQuickHacks(evt);
    this.ForwardActionToNPCs(evt);
    this.ForwardActionToVehicles(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnNPCBreachEvent(evt: ref<NPCBreachEvent>) -> EntityNotificationType {
    let aps: array<ref<AccessPointControllerPS>> = this.GetAccessPoints();
    let i: Int32 = 0;
    while i < ArraySize(aps) {
      GameInstance.GetPersistencySystem(this.GetGameInstance()).QueuePSEvent(aps[i].GetID(), aps[i].GetClassName(), evt);
      i += 1;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final const func ExtractEntityIDs() -> array<EntityID> {
    let communityEntryNames: array<CName>;
    let message: String;
    let spawnerRecordsIDs: array<EntityID>;
    let spawnerID: EntityID = this.GetMyEntityID();
    GetFixedEntityIdsFromSpawnerEntityID(spawnerID, communityEntryNames, this.GetGameInstance(), spawnerRecordsIDs);
    if !IsFinal() && ArraySize(spawnerRecordsIDs) == 0 {
      message = "Attempting to extract NPCs from" + EntityID.ToDebugString(this.GetMyEntityID()) + ". NPCs extracted: " + IntToString(ArraySize(spawnerRecordsIDs));
      LogDevices(this, message, ELogType.ERROR);
    };
    return spawnerRecordsIDs;
  }

  private final const func ForwardActionToNPCs(action: ref<DeviceAction>) -> Void {
    let communityNPCs: array<EntityID> = this.ExtractEntityIDs();
    let i: Int32 = 0;
    while i < ArraySize(communityNPCs) {
      this.GetPersistencySystem().QueuePSEvent(Cast(communityNPCs[i]), n"ScriptedPuppetPS", action);
      i += 1;
    };
  }

  private final const func ForwardActionToVehicles(action: ref<DeviceAction>) -> Void {
    let vehicles: array<EntityID> = this.ExtractEntityIDs();
    let i: Int32 = 0;
    while i < ArraySize(vehicles) {
      this.GetPersistencySystem().QueuePSEvent(CreatePersistentID(vehicles[i], n"controller"), n"VehicleComponentPS", action);
      i += 1;
    };
  }
}
