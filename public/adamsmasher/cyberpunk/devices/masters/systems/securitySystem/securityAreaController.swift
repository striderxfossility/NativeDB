
public class SecurityAreaEvent extends ActionBool {

  private let m_securityAreaData: SecurityAreaData;

  private let m_whoBreached: wref<GameObject>;

  public final const func GetWhoBreached() -> ref<GameObject> {
    return this.m_whoBreached;
  }

  protected final func SetWhoBreached(whoBreached: ref<GameObject>) -> Void {
    this.m_whoBreached = whoBreached;
  }

  public final func SetAreaData(areaData: SecurityAreaData) -> Void {
    this.m_securityAreaData = areaData;
  }

  public final func GetSecurityAreaData() -> SecurityAreaData {
    return this.m_securityAreaData;
  }

  public final func GetSecurityAreaID() -> PersistentID {
    return this.m_securityAreaData.id;
  }

  public final func ModifyAreaTypeHack(modifiedAreaType: ESecurityAreaType) -> Void {
    this.m_securityAreaData.securityAreaType = modifiedAreaType;
  }
}

public class SecurityAreaCrossingPerimeter extends SecurityAreaEvent {

  private let m_entered: Bool;

  public final func SetProperties(whoBreached: ref<GameObject>, didEnter: Bool) -> Void {
    this.SetWhoBreached(whoBreached);
    this.m_entered = didEnter;
  }

  public final func GetEnteredState() -> Bool {
    return this.m_entered;
  }
}

public class SecurityAreaController extends MasterController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public struct OutputPersistentData {

  public persistent let m_currentSecurityState: ESecuritySystemState;

  public persistent let m_breachOrigin: EBreachOrigin;

  public persistent let m_securityStateChanged: Bool;

  public persistent let m_lastKnownPosition: Vector4;

  public persistent let m_type: ESecurityNotificationType;

  public persistent let m_areaType: ESecurityAreaType;

  public persistent let m_objectOfInterest: EntityID;

  public persistent let m_whoBreached: EntityID;

  public persistent let m_reporter: PersistentID;

  public persistent let m_id: Int32;

  public final static func IsValid(self: OutputPersistentData) -> Bool {
    if EntityID.IsDefined(self.m_whoBreached) || EntityID.IsDefined(self.m_objectOfInterest) {
      return true;
    };
    return false;
  }
}

public class SecurityAreaControllerPS extends MasterControllerPS {

  private let m_system: ref<SecuritySystemControllerPS>;

  private persistent let m_usersInPerimeter: array<AreaEntry>;

  private persistent let m_isPlayerInside: Bool;

  @attrib(tooltip, "Utilized during Authorization only. Determines the list of passwords and keycards that are working in this area. Passwords & Keycards are specified in Security System")
  private let m_securityAccessLevel: ESecurityAccessLevel;

  @attrib(tooltip, "This determines what actions are legal inside this area as well what type of response will be initiated as a countermeasure")
  @default(SecurityAreaControllerPS, ESecurityAreaType.DANGEROUS)
  private persistent let m_securityAreaType: ESecurityAreaType;

  @attrib(tooltip, "[ OPTIONAL ] This determines what kind of events can get out of given area or get inside given area and its agents. By default all events are received and broadcasted")
  private let m_eventsFilters: EventsFilters;

  @attrib(tooltip, "[ OPTIONAL ] If you want your Security Area to change its type regularly (i.e: Store / Alley (day/night) / Arasaka Lobby) here you can control it. TIP: You can perform transitions using SecurityAreaManager Quest Block :) TIP2: UPON TRANSITION, UI PROMPT ABOUT BEING IN AREA X MAY SHOW UP! TIP3: ORDER IS NOT IMPORANT!")
  private let m_areaTransitions: array<AreaTypeTransition>;

  private persistent let m_pendingDisableRequest: Bool;

  private persistent let m_lastOutput: OutputPersistentData;

  private let m_questPlayerHasTriggeredCombat: Bool;

  private let m_hasThisAreaReceivedCombatNotification: Bool;

  private let m_pendingNotifyPlayerAboutTransition: Bool;

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
  }

  protected func GameAttached() -> Void {
    this.UpdateMiniMapRepresentation();
  }

  public final const quest func HasPlayerBeenSpottedAndTriggeredCombat() -> Bool {
    return this.m_questPlayerHasTriggeredCombat;
  }

  public final const quest func HasThisAreaReceivedCombatNotification() -> Bool {
    return this.m_hasThisAreaReceivedCombatNotification;
  }

  public final const func GetIncomingFilter() -> EFilterType {
    return this.m_eventsFilters.incomingEventsFilter;
  }

  public final const func GetOutgoingFilter() -> EFilterType {
    return this.m_eventsFilters.outgoingEventsFilter;
  }

  public final func RegisterTimeSystemListeners(entity: ref<Entity>) -> Void {
    let hour: GameTime;
    let i: Int32;
    let transitionEvent: ref<Transition>;
    this.UnregisterTimeSystemListeners();
    i = 0;
    while i < ArraySize(this.m_areaTransitions) {
      transitionEvent = new Transition();
      hour = GameTime.MakeGameTime(0, this.m_areaTransitions[i].transitionHour, 0, 0);
      this.m_areaTransitions[i].listenerID = GameInstance.GetTimeSystem(this.GetGameInstance()).RegisterListener(entity, transitionEvent, hour, -1, true);
      transitionEvent.listenerID = this.m_areaTransitions[i].listenerID;
      i += 1;
    };
  }

  public final func UnregisterTimeSystemListeners() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_areaTransitions) {
      GameInstance.GetTimeSystem(this.GetGameInstance()).UnregisterListener(this.m_areaTransitions[i].listenerID);
      this.m_areaTransitions[i].listenerID = 0u;
      i += 1;
    };
  }

  private final func ResolveSecurityAreaType() -> Void {
    let cachedTransitionHour: Int32 = 25;
    let hourOfTheDay: Int32 = GameTime.Hours(GameInstance.GetGameTime(this.GetGameInstance()));
    let mostRelevantTransition: Uint32 = 0u;
    let i: Int32 = 0;
    while i < ArraySize(this.m_areaTransitions) {
      if this.m_areaTransitions[i].transitionHour < hourOfTheDay {
        if cachedTransitionHour > this.m_areaTransitions[i].transitionHour {
          cachedTransitionHour = this.m_areaTransitions[i].transitionHour;
          mostRelevantTransition = this.m_areaTransitions[i].listenerID;
        };
      };
      i += 1;
    };
    if mostRelevantTransition == 0u {
      return;
    };
    this.ApplyTransition(mostRelevantTransition);
  }

  public final func ApplyTransition(listenerIndex: Uint32) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_areaTransitions) {
      if this.m_areaTransitions[i].listenerID == listenerIndex {
        return this.ApplyTransition(this.m_areaTransitions[i]);
      };
      i += 1;
    };
    return false;
  }

  private final func ApplyTransition(transition: AreaTypeTransition) -> Bool {
    let evt: ref<PendingSecuritySystemDisable>;
    let i: Int32;
    let turrets: array<ref<SecurityTurretControllerPS>>;
    if Equals(this.m_securityAreaType, transition.transitionTo) {
      return false;
    };
    if Equals(transition.transitionTo, ESecurityAreaType.DISABLED) {
      if !this.IsDisableAllowed(turrets) {
        this.PostponeAreaDisabling(turrets);
        return false;
      };
    } else {
      if this.m_pendingDisableRequest {
        this.GetTurrets(turrets);
        i = 0;
        while i < ArraySize(turrets) {
          evt = new PendingSecuritySystemDisable();
          evt.isPending = false;
          this.QueuePSEvent(turrets[i], evt);
          i += 1;
        };
        this.m_pendingDisableRequest = false;
      };
    };
    if Equals(transition.transitionMode, ETransitionMode.FORCED) {
      this.SetSecurityAreaType(transition.transitionTo);
      if this.IsPlayerInside() {
        if !this.GetSecuritySystem().IsSystemInCombat() {
          this.NotifySystemAboutCrossingPerimeter(this.GetLocalPlayerControlledGameObject(), true);
        } else {
          this.m_pendingNotifyPlayerAboutTransition = true;
        };
      };
      return true;
    };
    if this.GetSecuritySystem().IsSystemSafe() {
      this.SetSecurityAreaType(transition.transitionTo);
      if this.IsPlayerInside() {
        this.NotifySystemAboutCrossingPerimeter(this.GetLocalPlayerControlledGameObject(), true);
      };
      return true;
    };
    return false;
  }

  private final func PostponeAreaDisabling(turrets: array<ref<SecurityTurretControllerPS>>) -> Void {
    let evt: ref<PendingSecuritySystemDisable>;
    let i: Int32 = 0;
    while i < ArraySize(turrets) {
      evt = new PendingSecuritySystemDisable();
      evt.isPending = true;
      this.QueuePSEvent(turrets[i], evt);
      i += 1;
    };
    this.m_pendingDisableRequest = true;
  }

  private final func OnSecurityTurretOffline(evt: ref<SecurityTurretOffline>) -> EntityNotificationType {
    let transition: AreaTypeTransition;
    let turrets: array<ref<SecurityTurretControllerPS>>;
    if this.m_pendingDisableRequest {
      if this.IsDisableAllowed(turrets) {
        this.m_pendingDisableRequest = false;
        transition.transitionTo = ESecurityAreaType.DISABLED;
        transition.transitionMode = ETransitionMode.FORCED;
        this.ApplyTransition(transition);
      } else {
        this.PostponeAreaDisabling(turrets);
      };
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final const func GetTurrets(turrets: script_ref<array<ref<SecurityTurretControllerPS>>>) -> Void {
    let turret: ref<SecurityTurretControllerPS>;
    let slaves: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(slaves) {
      turret = slaves[i] as SecurityTurretControllerPS;
      if IsDefined(turret) {
        ArrayPush(Deref(turrets), turret);
      };
      i += 1;
    };
    if ArraySize(Deref(turrets)) == 0 {
      this.GetSecuritySystem().GetTurrets(this, turrets);
    };
  }

  private final const func IsDisableAllowed(turrets: script_ref<array<ref<SecurityTurretControllerPS>>>) -> Bool {
    let i: Int32;
    let isAllowed: Bool = true;
    this.GetTurrets(turrets);
    i = 0;
    while i < ArraySize(Deref(turrets)) {
      if Deref(turrets)[i].IsTurretOperationalUnderSecuritySystem() {
        isAllowed = false;
      };
      i += 1;
    };
    return isAllowed;
  }

  private final func UpdateMiniMapRepresentation() -> Void {
    let secSys: ref<SecuritySystemControllerPS> = this.GetSecuritySystem();
    if IsDefined(secSys) && secSys.IsHidden() {
      GameInstance.GetMappinSystem(this.GetGameInstance()).OnAreaTypeChanged(PersistentID.ExtractEntityID(this.GetID()), SecurityAreaControllerPS.SecurityAreaTypeEnumToName(ESecurityAreaType.DISABLED));
      return;
    };
    if ArraySize(this.m_areaTransitions) > 0 {
      this.ResolveSecurityAreaType();
    } else {
      GameInstance.GetMappinSystem(this.GetGameInstance()).OnAreaTypeChanged(PersistentID.ExtractEntityID(this.GetID()), SecurityAreaControllerPS.SecurityAreaTypeEnumToName(this.m_securityAreaType));
    };
  }

  public const func GetDeviceName() -> String {
    if IsStringValid(this.m_deviceName) {
      return this.m_deviceName;
    };
    return "";
  }

  public final func AreaEntered(evt: ref<AreaEnteredEvent>) -> Void {
    let obj: ref<GameObject> = EntityGameInterface.GetEntity(evt.activator) as GameObject;
    if !this.IsActive() || !EntityID.IsDefined(obj.GetEntityID()) {
      return;
    };
    this.ProcessOnEnterRequest(obj);
  }

  public final func AreaExited(obj: ref<GameObject>) -> Void {
    let userIndex: Int32;
    if !EntityID.IsDefined(obj.GetEntityID()) {
      return;
    };
    userIndex = this.FindEntryIndex(obj.GetEntityID());
    if userIndex == -1 && !this.IsActive() {
      return;
    };
    ArrayErase(this.m_usersInPerimeter, userIndex);
    if obj.IsPlayerControlled() {
      this.m_isPlayerInside = false;
      this.m_system = null;
    };
    this.NotifySystemAboutCrossingPerimeter(obj, false);
  }

  private final func ProcessOnEnterRequest(objectToProcess: ref<GameObject>) -> Void {
    let newEntry: AreaEntry;
    if !IsDefined(objectToProcess) {
      return;
    };
    newEntry.user = objectToProcess.GetEntityID();
    if this.IsUserInside(newEntry.user) {
    } else {
      this.PushUniqueEntry(newEntry);
    };
    if objectToProcess.IsPlayerControlled() {
      this.m_isPlayerInside = true;
      if NotEquals(this.m_securityAreaType, ESecurityAreaType.DISABLED) {
        this.m_system = this.GetSecuritySystem();
      };
      if NotEquals(this.m_securityAreaType, ESecurityAreaType.DISABLED) {
        this.NotifySystemAboutCrossingPerimeter(objectToProcess, true);
      };
    };
  }

  private final func ActionSecurityAreaCrossingPerimeter(whoEntered: ref<GameObject>, entered: Bool) -> ref<SecurityAreaCrossingPerimeter> {
    let action: ref<SecurityAreaCrossingPerimeter> = new SecurityAreaCrossingPerimeter();
    action.SetUp(this);
    action.SetProperties(whoEntered, entered);
    action.AddDeviceName(this.GetDeviceName());
    action.SetAreaData(this.GetSecurityAreaData());
    return action;
  }

  private final func NotifySystemAboutCrossingPerimeter(tresspasser: ref<GameObject>, entering: Bool) -> Void {
    let tresspassingEvent: ref<SecurityAreaCrossingPerimeter>;
    if entering {
      if !IsFinal() {
        LogDevices(this, "Entity: " + EntityID.ToDebugString(tresspasser.GetEntityID()) + " entered");
      };
    } else {
      if !IsFinal() {
        LogDevices(this, "Entity: " + EntityID.ToDebugString(tresspasser.GetEntityID()) + " left");
      };
    };
    if !entering && tresspasser.IsPlayerControlled() {
      this.m_pendingNotifyPlayerAboutTransition = false;
    };
    if this.GetSecuritySystem().IsUserAuthorized(tresspasser.GetEntityID(), this.GetSecurityAccessLevel()) {
      return;
    };
    tresspassingEvent = this.ActionSecurityAreaCrossingPerimeter(tresspasser, entering);
    this.SendActionToAllSlaves(tresspassingEvent);
    this.NotifySecuritySystem(tresspassingEvent);
  }

  public final func OnQuestAddTransition(evt: ref<QuestAddTransition>) -> EntityNotificationType {
    let registerEvent: ref<RegisterTimeListeners>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_areaTransitions) {
      if this.m_areaTransitions[i].transitionHour == evt.transition.transitionHour {
        return EntityNotificationType.DoNotNotifyEntity;
      };
      i += 1;
    };
    ArrayPush(this.m_areaTransitions, evt.transition);
    registerEvent = new RegisterTimeListeners();
    this.QueueEntityEvent(this.GetMyEntityID(), registerEvent);
    if !IsFinal() {
      LogDevices(this, "SECURITY AREA MANAGER: New Transition added");
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnQuestRemoveTransition(evt: ref<QuestRemoveTransition>) -> EntityNotificationType {
    let i: Int32 = 0;
    while i < ArraySize(this.m_areaTransitions) {
      if this.m_areaTransitions[i].transitionHour == evt.removeTransitionFrom {
        GameInstance.GetTimeSystem(this.GetGameInstance()).UnregisterListener(this.m_areaTransitions[i].listenerID);
        ArrayErase(this.m_areaTransitions, i);
        if !IsFinal() {
          LogDevices(this, "SECURITY AREA MANAGER: Transition removed");
        };
      };
      i += 1;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnQuestExecuteTransition(evt: ref<QuestExecuteTransition>) -> EntityNotificationType {
    this.ApplyTransition(evt.transition);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnQuestIllegalActionAreaNotification(evt: ref<QuestIllegalActionAreaNotification>) -> EntityNotificationType {
    let LKP: Vector4;
    let actionSecuritySystemInput: ref<SecuritySystemInput>;
    let playerPup: ref<GameObject>;
    if Equals(evt.revealPlayerSettings.revealPlayer, ERevealPlayerType.REVEAL_ONCE) {
      playerPup = this.GetPlayerMainObject();
      if IsDefined(playerPup) {
        LKP = playerPup.GetWorldPosition();
      };
    };
    actionSecuritySystemInput = this.ActionSecurityBreachNotification(LKP, playerPup, ESecurityNotificationType.ILLEGAL_ACTION);
    this.ExecutePSAction(actionSecuritySystemInput, this);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final const func OnQuestCombatActionAreaNotification(evt: ref<QuestCombatActionAreaNotification>) -> EntityNotificationType {
    let LKP: Vector4;
    let actionSecuritySystemInput: ref<SecuritySystemInput>;
    let playerPup: ref<GameObject>;
    if Equals(evt.revealPlayerSettings.revealPlayer, ERevealPlayerType.REVEAL_ONCE) {
      playerPup = this.GetLocalPlayerControlledGameObject();
      if IsDefined(playerPup) {
        LKP = playerPup.GetWorldPosition();
      };
    };
    actionSecuritySystemInput = this.ActionSecurityBreachNotification(LKP, playerPup, ESecurityNotificationType.COMBAT);
    this.ExecutePSAction(actionSecuritySystemInput, this);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnQuestModifyFilter(evt: ref<QuestModifyFilters>) -> EntityNotificationType {
    if NotEquals(evt.incomingFilters, EQuestFilterType.DONT_CHANGE) {
      this.m_eventsFilters.incomingEventsFilter = IntEnum(EnumInt(evt.incomingFilters) - 1);
    };
    if NotEquals(evt.outgoingFilters, EQuestFilterType.DONT_CHANGE) {
      this.m_eventsFilters.outgoingEventsFilter = IntEnum(EnumInt(evt.outgoingFilters) - 1);
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func NotifySecuritySystem(tresspassingEvent: ref<SecurityAreaCrossingPerimeter>) -> Void {
    this.QueuePSEvent(this.GetSecuritySystem(), tresspassingEvent);
  }

  public const func GetSecurityAccessLevel() -> ESecurityAccessLevel {
    return this.m_securityAccessLevel;
  }

  public final const func GetSecurityAreaType() -> ESecurityAreaType {
    return this.m_securityAreaType;
  }

  public const func IsConnectedToSystem() -> Bool {
    return this.IsPartOfSystem(ESystems.SecuritySystem);
  }

  public final const func GetUsersInPerimeter() -> array<AreaEntry> {
    return this.m_usersInPerimeter;
  }

  protected final const func IsPlayerInside() -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_usersInPerimeter) {
      if this.m_usersInPerimeter[i].user == this.GetLocalPlayerControlledGameObject().GetEntityID() {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func GetSecurityAreaTypeAsUint32() -> Uint32 {
    if IsDefined(this.GetSecuritySystem()) {
      return this.GetSecuritySystem().IsHidden() ? 0u : EnumInt(this.GetSecurityAreaType());
    };
    return 0u;
  }

  public const func IsConnectedToSecuritySystem(out level: ESecurityAccessLevel) -> Bool {
    let i: Int32;
    let parents: array<ref<DeviceComponentPS>>;
    this.GetParents(parents);
    level = this.GetSecurityAccessLevel();
    i = 0;
    while i < ArraySize(parents) {
      if IsDefined(parents[i] as SecuritySystemControllerPS) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func SetSecurityAreaType(newType: ESecurityAreaType) -> Void {
    let manageAreaComponent: ref<ManageAreaComponent>;
    let notification: ref<SecurityAreaTypeChangedNotification>;
    if Equals(this.m_securityAreaType, newType) {
      return;
    };
    if Equals(newType, ESecurityAreaType.DISABLED) {
      this.m_system = null;
      manageAreaComponent = new ManageAreaComponent();
      manageAreaComponent.enable = false;
      this.QueueEntityEvent(this.GetMyEntityID(), manageAreaComponent);
    };
    if Equals(this.m_securityAreaType, ESecurityAreaType.DISABLED) {
      this.m_system = this.GetSecuritySystem();
      manageAreaComponent = new ManageAreaComponent();
      manageAreaComponent.enable = true;
      this.QueueEntityEvent(this.GetMyEntityID(), manageAreaComponent);
    };
    notification = new SecurityAreaTypeChangedNotification();
    notification.area = this;
    notification.previousType = this.m_securityAreaType;
    this.m_securityAreaType = newType;
    notification.currentType = this.m_securityAreaType;
    this.QueuePSEvent(this.GetSecuritySystem(), notification);
    if this.GetSecuritySystem().IsHidden() {
      GameInstance.GetMappinSystem(this.GetGameInstance()).OnAreaTypeChanged(PersistentID.ExtractEntityID(this.GetID()), SecurityAreaControllerPS.SecurityAreaTypeEnumToName(ESecurityAreaType.DISABLED));
    } else {
      GameInstance.GetMappinSystem(this.GetGameInstance()).OnAreaTypeChanged(PersistentID.ExtractEntityID(this.GetID()), SecurityAreaControllerPS.SecurityAreaTypeEnumToName(this.m_securityAreaType));
    };
  }

  private final func ProcessOnExitRequest(entryToProcess: AreaEntry) -> Void;

  public final const func IsActive() -> Bool {
    return NotEquals(this.m_securityAreaType, ESecurityAreaType.DISABLED);
  }

  public final const func IsUserInside(userToBeChecked: EntityID) -> Bool {
    let index: Int32 = this.FindEntryIndex(userToBeChecked);
    if index < 0 {
      return false;
    };
    return true;
  }

  public final const quest func IsAreaCompromised() -> Bool {
    let i: Int32;
    let secSys: ref<SecuritySystemControllerPS> = this.GetSecuritySystem();
    if !IsDefined(secSys) {
      if !IsFinal() {
        LogDevices(this, "No security system found by security area. This setup is not supported", ELogType.ERROR);
      };
      return false;
    };
    i = 0;
    while i < ArraySize(this.m_usersInPerimeter) {
      if secSys.IsEntityBlacklisted(this.m_usersInPerimeter[i].user) || !secSys.IsUserAuthorized(this.m_usersInPerimeter[i].user, this.GetSecurityAccessLevel()) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func PushUniqueEntry(entryToPush: AreaEntry) -> Void {
    ArrayPush(this.m_usersInPerimeter, entryToPush);
  }

  private final const func FindEntryIndex(userToFind: EntityID) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_usersInPerimeter) {
      if this.m_usersInPerimeter[i].user == userToFind {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final const func ExtractSquadProxies() -> array<ref<CommunityProxyPS>> {
    let devices: array<ref<DeviceComponentPS>>;
    let i: Int32;
    let proxies: array<ref<CommunityProxyPS>>;
    let myEntityID: EntityID = PersistentID.ExtractEntityID(this.GetID());
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetChildren(myEntityID, devices);
    i = 0;
    while i < ArraySize(devices) {
      if IsDefined(devices[i] as CommunityProxyPS) {
        ArrayPush(proxies, devices[i] as CommunityProxyPS);
      };
      i += 1;
    };
    return proxies;
  }

  public final const func GetSecurityAreaData() -> SecurityAreaData {
    let data: SecurityAreaData;
    data.securityArea = this;
    data.securityAreaType = this.GetSecurityAreaType();
    data.accessLevel = this.GetSecurityAccessLevel();
    data.zoneName = this.GetDeviceName();
    data.id = this.GetID();
    data.incomingFilters = this.m_eventsFilters.incomingEventsFilter;
    data.outgoingFilters = this.m_eventsFilters.outgoingEventsFilter;
    return data;
  }

  public final const func GetSecurityAreaAgents() -> array<EntityID> {
    let agents: array<EntityID>;
    let npcs: array<EntityID> = this.GetNPCs();
    let devices: array<EntityID> = this.GetDevices();
    let i: Int32 = 0;
    while i < ArraySize(npcs) {
      ArrayPush(agents, npcs[i]);
      i += 1;
    };
    i = 0;
    while i < ArraySize(devices) {
      ArrayPush(agents, devices[i]);
      i += 1;
    };
    return agents;
  }

  public final const func GetNPCs() -> array<EntityID> {
    let npcs: array<EntityID>;
    let proxies: array<ref<CommunityProxyPS>> = this.ExtractSquadProxies();
    let i: Int32 = 0;
    while i < ArraySize(proxies) {
      i += 1;
    };
    return npcs;
  }

  public const func GetSecuritySystem() -> ref<SecuritySystemControllerPS> {
    if IsDefined(this.m_system) {
      return this.m_system;
    };
    return this.GetSecuritySystem();
  }

  public final const func GetDevices() -> array<EntityID> {
    let devicesIDs: array<EntityID>;
    let slaves: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(slaves) {
      if IsDefined(slaves[i] as CommunityProxyPS) {
      } else {
        ArrayPush(devicesIDs, PersistentID.ExtractEntityID(slaves[i].GetID()));
      };
      i += 1;
    };
    return devicesIDs;
  }

  public final const func GetLastOutput() -> ref<SecuritySystemOutput> {
    return this.RestoreLastOutput();
  }

  private final const func RestoreLastOutput() -> ref<SecuritySystemOutput> {
    let recreatedOutput: ref<SecuritySystemOutput>;
    let reporter: ref<GameObject>;
    let whoBreached: ref<GameObject>;
    if OutputPersistentData.IsValid(this.m_lastOutput) {
      if EntityID.IsDefined(this.m_lastOutput.m_whoBreached) {
        whoBreached = GameInstance.FindEntityByID(this.GetGameInstance(), this.m_lastOutput.m_whoBreached) as GameObject;
      } else {
        if EntityID.IsDefined(this.m_lastOutput.m_objectOfInterest) {
          whoBreached = GameInstance.FindEntityByID(this.GetGameInstance(), this.m_lastOutput.m_objectOfInterest) as GameObject;
        };
      };
      reporter = GameInstance.FindEntityByID(this.GetGameInstance(), PersistentID.ExtractEntityID(this.m_lastOutput.m_reporter)) as GameObject;
      recreatedOutput = new SecuritySystemOutput();
      recreatedOutput = this.GetSecuritySystem().ActionSecuritySystemBreachResponse(ScriptedPuppetPS.ActionSecurityBreachNotificationStatic(this.m_lastOutput.m_lastKnownPosition, whoBreached, reporter, this.m_lastOutput.m_type));
      recreatedOutput.SetCachedSecuritySystemState(this.m_lastOutput.m_currentSecurityState);
      recreatedOutput.SetBreachOrigin(this.m_lastOutput.m_breachOrigin);
      recreatedOutput.SetSecurityStateChanged(this.m_lastOutput.m_securityStateChanged);
      recreatedOutput.GetOriginalInputEvent().ModifyNotificationType(this.m_lastOutput.m_type);
      recreatedOutput.GetOriginalInputEvent().ModifyAreaTypeHack(this.m_lastOutput.m_areaType);
      recreatedOutput.GetOriginalInputEvent().SetID(this.m_lastOutput.m_id);
    };
    return recreatedOutput;
  }

  public final func OnGameEntitySpawnerEvent(evt: ref<gameEntitySpawnerEvent>) -> EntityNotificationType {
    let recreatedOutput: ref<SecuritySystemOutput> = this.RestoreLastOutput();
    if IsDefined(recreatedOutput) {
      this.QueueEntityEvent(evt.spawnedEntityId, recreatedOutput);
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func OnSecuritySystemOutput(breachEvent: ref<SecuritySystemOutput>) -> EntityNotificationType {
    let debugMessage: String;
    let systemState: ESecuritySystemState = this.GetSecuritySystem().GetSecurityState();
    if this.m_pendingNotifyPlayerAboutTransition && NotEquals(systemState, ESecuritySystemState.COMBAT) {
      this.NotifySystemAboutCrossingPerimeter(this.GetLocalPlayerControlledGameObject(), true);
      this.m_pendingNotifyPlayerAboutTransition = false;
    };
    if !this.IsActive() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    debugMessage = "Input received";
    if IsDefined(breachEvent.GetOriginalInputEvent()) && IsDefined(breachEvent.GetOriginalInputEvent().GetWhoBreached()) && this.IsUserInside(breachEvent.GetOriginalInputEvent().GetWhoBreached().GetEntityID()) {
      debugMessage += " User Inside - Breach = LOCAL";
      breachEvent.SetBreachOrigin(EBreachOrigin.LOCAL);
      if Equals(systemState, ESecuritySystemState.COMBAT) && breachEvent.GetOriginalInputEvent().GetWhoBreached() == this.GetLocalPlayerControlledGameObject() {
        this.m_questPlayerHasTriggeredCombat = true;
        this.m_hasThisAreaReceivedCombatNotification = true;
      };
    } else {
      if Equals(breachEvent.GetOriginalInputEvent().GetNotificationType(), ESecurityNotificationType.ALARM) && this.IsUserInside(breachEvent.GetOriginalInputEvent().GetObjectOfInterest().GetEntityID()) {
        debugMessage += " ALARM ORIGINATED IN THIS AREA - BREACH - LOCAL";
        breachEvent.SetBreachOrigin(EBreachOrigin.LOCAL);
      } else {
        if Equals(this.m_eventsFilters.incomingEventsFilter, EFilterType.ALLOW_NONE) {
          debugMessage += " Area does not accept external events. Ignoring Event";
          if !IsFinal() {
            LogDevices(this, breachEvent.GetOriginalInputEvent().GetID(), debugMessage);
          };
          return EntityNotificationType.DoNotNotifyEntity;
        };
        if Equals(this.m_eventsFilters.incomingEventsFilter, EFilterType.ALLOW_COMBAT_ONLY) {
          if NotEquals(breachEvent.GetCachedSecurityState(), ESecuritySystemState.COMBAT) {
            debugMessage += " Area accepts only COMBAT events. Ignoring event.";
            if !IsFinal() {
              LogDevices(this, breachEvent.GetOriginalInputEvent().GetID(), debugMessage);
            };
            return EntityNotificationType.DoNotNotifyEntity;
          };
          this.m_hasThisAreaReceivedCombatNotification = true;
        };
        debugMessage += " User NOT Inside - Breach = EXTERNAL";
        breachEvent.SetBreachOrigin(EBreachOrigin.EXTERNAL);
      };
    };
    debugMessage += " Forwarding event to slaves";
    if !IsFinal() {
      LogDevices(this, breachEvent.GetOriginalInputEvent().GetID(), debugMessage);
    };
    this.StoreLastOutputPersistentData(breachEvent);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func StoreLastOutputPersistentData(breachEvent: ref<SecuritySystemOutput>) -> Void {
    this.m_lastOutput.m_currentSecurityState = breachEvent.GetCachedSecurityState();
    this.m_lastOutput.m_breachOrigin = breachEvent.GetBreachOrigin();
    this.m_lastOutput.m_securityStateChanged = breachEvent.GetSecurityStateChanged();
    this.m_lastOutput.m_lastKnownPosition = breachEvent.GetOriginalInputEvent().GetLastKnownPosition();
    this.m_lastOutput.m_type = breachEvent.GetOriginalInputEvent().GetNotificationType();
    this.m_lastOutput.m_areaType = this.GetSecurityAreaType();
    if IsDefined(breachEvent.GetOriginalInputEvent().GetObjectOfInterest()) {
      this.m_lastOutput.m_objectOfInterest = breachEvent.GetOriginalInputEvent().GetObjectOfInterest().GetEntityID();
    };
    if IsDefined(breachEvent.GetOriginalInputEvent().GetWhoBreached()) {
      this.m_lastOutput.m_whoBreached = breachEvent.GetOriginalInputEvent().GetWhoBreached().GetEntityID();
    };
    if IsDefined(breachEvent.GetOriginalInputEvent().GetNotifierHandle()) {
      this.m_lastOutput.m_reporter = breachEvent.GetOriginalInputEvent().GetNotifierHandle().GetID();
    };
    this.m_lastOutput.m_id = breachEvent.GetOriginalInputEvent().GetID();
  }

  public func OnSecuritySystemForceAttitudeChange(evt: ref<SecuritySystemForceAttitudeChange>) -> EntityNotificationType {
    this.SendActionToAllSlaves(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func OnTargetAssessmentRequest(evt: ref<TargetAssessmentRequest>) -> EntityNotificationType {
    this.SendActionToAllSlaves(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func OnFullSystemRestart(evt: ref<FullSystemRestart>) -> EntityNotificationType {
    this.SendActionToAllSlaves(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final static func SecurityAreaTypeEnumToName(type: ESecurityAreaType) -> CName {
    switch type {
      case ESecurityAreaType.DISABLED:
        return n"DISABLED";
      case ESecurityAreaType.SAFE:
        return n"SAFE";
      case ESecurityAreaType.RESTRICTED:
        return n"RESTRICTED";
      case ESecurityAreaType.DANGEROUS:
        return n"DANGEROUS";
    };
    return n"";
  }

  public const func GetDebugTags() -> String {
    let tags: String = this.GetDebugTags();
    return tags;
  }

  public func OnMaraudersMapDeviceDebug(sink: ref<MaraudersMapDevicesSink>) -> Void {
    sink.BeginCategory("securityAreaControllerPS Specific");
    sink.PushString("AREA TYPE", ToString(this.m_securityAreaType));
    sink.PushString("PLAYER INSIDE: ", BoolToString(this.m_isPlayerInside));
    sink.PushString("ACCESS LEVEL", ToString(this.m_securityAccessLevel));
    sink.PushString("RECEIVED COMBAT OUTPUT: ", BoolToString(this.m_hasThisAreaReceivedCombatNotification));
    sink.EndCategory();
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.SecuritySystemDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.SecuritySystemDeviceBackground";
  }
}
