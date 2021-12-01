
public class SetGlitchOnUIEvent extends Event {

  @attrib(rangeMax, "1.f")
  @attrib(rangeMin, "0.f")
  public edit let intensity: Float;

  public final func GetFriendlyDescription() -> String {
    return "Set Glitch On UI";
  }
}

public static exec func ForceOutline(gameInstance: GameInstance, isGreen: String, opacity: String) -> Void {
  let distance: EulerAngles;
  let dbgOutlineEvent: ref<DebugOutlineEvent> = new DebugOutlineEvent();
  let shouldBeGreen: Bool = StringToBool(isGreen);
  let opacityValue: Float = StringToFloat(opacity);
  let targetSystem: ref<TargetingSystem> = GameInstance.GetTargetingSystem(gameInstance);
  let target: ref<GameObject> = targetSystem.GetObjectClosestToCrosshair(GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject(), distance, TSQ_NPC());
  if shouldBeGreen {
    dbgOutlineEvent.type = EOutlineType.GREEN;
  } else {
    dbgOutlineEvent.type = EOutlineType.RED;
  };
  dbgOutlineEvent.opacity = opacityValue;
  dbgOutlineEvent.requester = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject().GetEntityID();
  target.QueueEvent(dbgOutlineEvent);
}

public static exec func PlayRumble(gameInstance: GameInstance, presetName: String) -> Void {
  let rumbleName: CName = TDB.GetCName(TDBID.Create("rumble.local." + presetName));
  GameObject.PlaySound(GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject() as PlayerPuppet, rumbleName);
}

public class OutlineRequest extends IScriptable {

  private let m_requester: CName;

  private let m_shouldAdd: Bool;

  private let m_outlineDuration: Float;

  private let m_outlineData: OutlineData;

  public final static func CreateRequest(requester: CName, shouldAdd: Bool, data: OutlineData, opt exepectedDuration: Float) -> ref<OutlineRequest> {
    let newRequest: ref<OutlineRequest> = new OutlineRequest();
    newRequest.m_requester = requester;
    newRequest.m_shouldAdd = shouldAdd;
    if exepectedDuration == 0.00 {
      exepectedDuration = 0.10;
    };
    newRequest.m_outlineDuration = exepectedDuration;
    if data.outlineStrength < 0.20 {
      data.outlineStrength = 0.20;
    };
    newRequest.m_outlineData = data;
    return newRequest;
  }

  public final const func GetRequester() -> CName {
    return this.m_requester;
  }

  public final const func ShouldAdd() -> Bool {
    return this.m_shouldAdd;
  }

  public final const func GetData() -> OutlineData {
    return this.m_outlineData;
  }

  public final const func GetRequestType() -> EOutlineType {
    return this.m_outlineData.outlineType;
  }

  public final const func GetRequestStrength() -> Float {
    return this.m_outlineData.outlineStrength;
  }

  public final const func GetOutlineDuration() -> Float {
    return this.m_outlineDuration;
  }

  public final func UpdateData(newData: OutlineData) -> Void {
    this.m_outlineData = newData;
  }

  public final func SetShouldAdd(b: Bool) -> Void {
    this.m_shouldAdd = b;
  }
}

public class OutlineRequestManager extends IScriptable {

  private let m_requestsList: array<ref<OutlineRequest>>;

  private let m_owner: wref<GameObject>;

  private let m_isBlocked: Bool;

  private let m_dbgRequests: array<ref<OutlineRequest>>;

  public final func BlockRequests() -> Void {
    this.m_isBlocked = true;
  }

  public final func Initialize(owner: wref<GameObject>) -> Void {
    this.m_owner = owner;
  }

  public final func PushRequest(freshRequest: ref<OutlineRequest>) -> Void {
    if this.m_isBlocked {
      return;
    };
    if this.DoesRequestAlreadyExist(freshRequest) {
      this.ProcessExistingRequest(freshRequest);
      return;
    };
    this.AddNewRequest(freshRequest);
  }

  public final func ClearAllRequests() -> Void {
    ArrayClear(this.m_requestsList);
  }

  public final func HasAnyOutlineRequest() -> Bool {
    if ArraySize(this.m_requestsList) > 0 {
      return true;
    };
    return false;
  }

  public final func HasOutlineOfType(type: EOutlineType) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_requestsList) {
      if this.m_requestsList[i].ShouldAdd() && Equals(this.m_requestsList[i].GetRequestType(), type) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func FindStrongestRequest() -> Float {
    let currentValue: Float;
    let highestValue: Float = 0.00;
    let i: Int32 = 0;
    while i < ArraySize(this.m_requestsList) {
      currentValue = this.m_requestsList[i].GetRequestStrength();
      if currentValue > highestValue {
        highestValue = currentValue;
      };
      i += 1;
    };
    return highestValue;
  }

  private final func DoesRequestAlreadyExist(requestToCheck: ref<OutlineRequest>) -> Bool {
    let index: Int32 = this.FindRequestIndex(requestToCheck);
    if index == -1 {
      return false;
    };
    return true;
  }

  private final func FindRequestIndex(request: ref<OutlineRequest>) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_requestsList) {
      if Equals(this.m_requestsList[i].GetRequester(), request.GetRequester()) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final func ProcessExistingRequest(freshRequest: ref<OutlineRequest>) -> Void {
    let index: Int32 = this.FindRequestIndex(freshRequest);
    if !freshRequest.ShouldAdd() {
      this.RemoveRequest(index);
      return;
    };
    this.ModifyRequestData(freshRequest.GetData(), index);
  }

  private final func AddNewRequest(freshRequest: ref<OutlineRequest>) -> Void {
    ArrayPush(this.m_requestsList, freshRequest);
  }

  private final func RemoveRequest(index: Int32) -> Void {
    ArrayErase(this.m_requestsList, index);
  }

  private final func ModifyRequestData(newData: OutlineData, index: Int32) -> Void {
    this.m_requestsList[index].UpdateData(newData);
  }

  private final func HandleRequestSuppression(request: ref<OutlineRequest>) -> Void {
    let suppressAfter: Float = request.GetOutlineDuration();
    let suppressEvent: ref<SuppressOutlineEvent> = new SuppressOutlineEvent();
    suppressEvent.requestToSuppress = request;
    GameInstance.GetDelaySystem(this.m_owner.GetGame()).DelayEvent(this.m_owner, suppressEvent, suppressAfter);
  }
}

public class GameObjectListener extends IScriptable {

  public let prereqOwner: ref<PrereqState>;

  public let e3HackBlock: Bool;

  public final func RegisterOwner(owner: ref<PrereqState>) -> Bool {
    if !IsDefined(this.prereqOwner) {
      this.prereqOwner = owner;
      return true;
    };
    return false;
  }

  public final func ModifyOwner(owner: ref<PrereqState>) -> Void {
    this.prereqOwner = owner;
  }

  public final func E3BlockHack() -> Void {
    this.e3HackBlock = true;
  }

  public final func OnRedOutlineStateChanged(isRevealed: Bool) -> Void {
    if IsDefined(this.prereqOwner as GameObjectRevealedRedPrereqState) {
      if isRevealed && this.e3HackBlock {
        return;
      };
      this.prereqOwner.OnChanged(isRevealed);
    };
  }

  public final func OnGreenOutlineStateChanged(isOn: Bool) -> Void {
    if IsDefined(this.prereqOwner as GameObjectRevealedGreenPrereqState) {
      if isOn && this.e3HackBlock {
        return;
      };
      this.prereqOwner.OnChanged(isOn);
    };
  }

  public final func OnRevealAccessPoint(shouldReveal: Bool) -> Void {
    if IsDefined(this.prereqOwner as RevealAccessPointPrereqState) {
      this.prereqOwner.OnChanged(shouldReveal);
    };
  }

  public final func OnStatusEffectTrigger(shouldTrigger: Bool) -> Void {
    if IsDefined(this.prereqOwner as StatPoolPrereqState) {
      this.prereqOwner.OnChanged(shouldTrigger);
    };
  }
}

public native class GameObject extends GameEntity {

  @attrib(category, "HUD Manager")
  protected let m_forceRegisterInHudManager: Bool;

  protected let m_prereqListeners: array<ref<GameObjectListener>>;

  protected let m_statusEffectListeners: array<ref<StatusEffectTriggerListener>>;

  protected let m_outlineRequestsManager: ref<OutlineRequestManager>;

  protected let m_outlineFadeCounter: Int32;

  protected let m_fadeOutStarted: Bool;

  private let m_lastEngineTime: Float;

  private let m_accumulatedTimePasssed: Float;

  protected let m_scanningComponent: ref<ScanningComponent>;

  protected let m_visionComponent: ref<VisionModeComponent>;

  protected let m_isHighlightedInFocusMode: Bool;

  protected let m_statusEffectComponent: ref<StatusEffectComponent>;

  private let m_lastFrameGreen: ref<OutlineRequest>;

  private let m_lastFrameRed: ref<OutlineRequest>;

  protected let m_markAsQuest: Bool;

  protected let m_e3HighlightHackStarted: Bool;

  private let m_e3ObjectRevealed: Bool;

  protected let m_forceHighlightSource: EntityID;

  protected let m_workspotMapper: ref<WorkspotMapperComponent>;

  protected let m_stimBroadcaster: ref<StimBroadcasterComponent>;

  protected native let uiSlotComponent: ref<SlotComponent>;

  protected let m_squadMemberComponent: ref<SquadMemberBaseComponent>;

  private let m_sourceShootComponent: ref<SourceShootComponent>;

  private let m_targetShootComponent: ref<TargetShootComponent>;

  protected let m_receivedDamageHistory: array<DamageHistoryEntry>;

  @default(GameObject, false)
  protected let m_forceDefeatReward: Bool;

  @default(GameObject, false)
  protected let m_killRewardDisabled: Bool;

  @default(GameObject, false)
  protected let m_willDieSoon: Bool;

  private let m_isScannerDataDirty: Bool;

  private let m_hasVisibilityForcedInAnimSystem: Bool;

  protected let m_isDead: Bool;

  public final native const func GetName() -> CName;

  public final native const func GetGame() -> GameInstance;

  public final native func RegisterInputListener(listener: ref<IScriptable>, opt name: CName) -> Void;

  public final native func RegisterInputListenerWithOwner(listener: ref<IScriptable>, name: CName) -> Void;

  public final native func UnregisterInputListener(listener: ref<IScriptable>, opt name: CName) -> Void;

  public final native func GetCurveValue(out x: Float, out y: Float, curveName: CName, isDebug: Bool) -> Void;

  public final native const func IsSelectedForDebugging() -> Bool;

  public final native func GetTracedActionName() -> String;

  public final native const func IsPlayerControlled() -> Bool;

  public final native func GetOwner() -> wref<GameObject>;

  public final native const func GetCurrentContext() -> CName;

  public final native const func PlayerLastUsedPad() -> Bool;

  public final native const func PlayerLastUsedKBM() -> Bool;

  public final native func TriggerEvent(eventName: CName, opt data: ref<IScriptable>, opt flags: Int32) -> Bool;

  protected native const func GetPS() -> ref<GameObjectPS>;

  protected final native const func GetBasePS() -> ref<GameObjectPS>;

  public final native const func HasTag(tag: CName) -> Bool;

  protected final native func EnableTransformUpdates(enable: Bool) -> Void;

  protected final func RegisterToHUDManagerByTask(shouldRegister: Bool) -> Void {
    let data: ref<HUDManagerRegistrationTaskData> = new HUDManagerRegistrationTaskData();
    data.shouldRegister = shouldRegister;
    GameInstance.GetDelaySystem(this.GetGame()).QueueTask(this, data, n"RegisterToHUDManagerTask", gameScriptTaskExecutionStage.Any);
  }

  protected final func RegisterToHUDManagerTask(data: ref<ScriptTaskData>) -> Void {
    let registrationTaskData: ref<HUDManagerRegistrationTaskData> = data as HUDManagerRegistrationTaskData;
    if !IsDefined(registrationTaskData) {
      return;
    };
    this.RegisterToHUDManager(registrationTaskData.shouldRegister);
  }

  protected final func RegisterToHUDManager(shouldRegister: Bool) -> Void {
    let register: ref<HUDManagerRegistrationRequest> = new HUDManagerRegistrationRequest();
    register.SetProperties(this, shouldRegister);
    GameInstance.QueueScriptableSystemRequest(this.GetGame(), n"HUDManager", register);
  }

  protected cb func OnDeviceLinkRequest(evt: ref<DeviceLinkRequest>) -> Bool {
    let link: ref<DeviceLinkComponentPS> = DeviceLinkComponentPS.CreateAndAcquireDeviceLink(this.GetGame(), this.GetEntityID());
    if IsDefined(link) {
      GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(link.GetID(), link.GetClassName(), evt);
    };
  }

  public const func GetDeviceLink() -> ref<DeviceLinkComponentPS> {
    return DeviceLinkComponentPS.AcquireDeviceLink(this.GetGame(), this.GetEntityID());
  }

  protected func OnTransformUpdated() -> Void;

  public final const func GetPersistentID() -> PersistentID {
    return Cast(this.GetEntityID());
  }

  public final const func GetPSOwnerData() -> PSOwnerData {
    let psOwnerData: PSOwnerData;
    psOwnerData.id = this.GetPersistentID();
    psOwnerData.className = this.GetClassName();
    return psOwnerData;
  }

  public const func GetPSClassName() -> CName {
    return this.GetPS().GetClassName();
  }

  protected func SendEventToDefaultPS(evt: ref<Event>) -> Void {
    let persistentState: ref<GameObjectPS> = this.GetPS();
    if persistentState == null {
      if !IsFinal() {
        LogError("[SendEventToDefaultPS] Unable to send event, there is no presistent state on that entity " + ToString(this.GetEntityID()));
      };
      return;
    };
    GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(persistentState.GetID(), persistentState.GetClassName(), evt);
  }

  public const func IsConnectedToSecuritySystem() -> Bool {
    return false;
  }

  public const func GetSecuritySystem() -> ref<SecuritySystemControllerPS> {
    return null;
  }

  public const func IsTargetTresspassingMyZone(target: ref<GameObject>) -> Bool {
    return false;
  }

  public final static func AddListener(obj: ref<GameObject>, listener: ref<GameObjectListener>) -> Void {
    let evt: ref<AddOrRemoveListenerForGOEvent> = new AddOrRemoveListenerForGOEvent();
    evt.listener = listener;
    evt.shouldAdd = true;
    obj.QueueEvent(evt);
  }

  public final static func RemoveListener(obj: ref<GameObject>, listener: ref<GameObjectListener>) -> Void {
    let evt: ref<AddOrRemoveListenerForGOEvent> = new AddOrRemoveListenerForGOEvent();
    evt.listener = listener;
    evt.shouldAdd = false;
    obj.QueueEvent(evt);
  }

  protected cb func OnAddOrRemoveListenerForGameObject(evt: ref<AddOrRemoveListenerForGOEvent>) -> Bool {
    if evt.shouldAdd {
      ArrayPush(this.m_prereqListeners, evt.listener);
    } else {
      ArrayRemove(this.m_prereqListeners, evt.listener);
    };
  }

  public final static func AddStatusEffectTriggerListener(target: ref<GameObject>, listener: ref<StatusEffectTriggerListener>) -> Void {
    let evt: ref<AddStatusEffectListenerEvent> = new AddStatusEffectListenerEvent();
    evt.listener = listener;
    target.QueueEvent(evt);
  }

  public final static func RemoveStatusEffectTriggerListener(target: ref<GameObject>, listener: ref<StatusEffectTriggerListener>) -> Void {
    let evt: ref<RemoveStatusEffectListenerEvent> = new RemoveStatusEffectListenerEvent();
    evt.listener = listener;
    target.QueueEvent(evt);
  }

  protected cb func OnAddStatusEffectTriggerListener(evt: ref<AddStatusEffectListenerEvent>) -> Bool {
    ArrayPush(this.m_statusEffectListeners, evt.listener);
  }

  protected cb func OnRemoveStatusEffectTriggerListener(evt: ref<RemoveStatusEffectListenerEvent>) -> Bool {
    ArrayRemove(this.m_statusEffectListeners, evt.listener);
    GameInstance.GetStatPoolsSystem(this.GetGame()).RequestUnregisteringListener(Cast(this.GetEntityID()), evt.listener.m_statPoolType, evt.listener);
  }

  public final native const func GetDisplayName() -> String;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"vision", n"gameVisionModeComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"scanning", n"gameScanningComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"workspotMapper", n"WorkspotMapperComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"StimBroadcaster", n"StimBroadcasterComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"SquadMember", n"SquadMemberBaseComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"StatusEffect", n"gameStatusEffectComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"sourceShootComponent", n"gameSourceShootComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"targetShootComponent", n"gameTargetShootComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_scanningComponent = EntityResolveComponentsInterface.GetComponent(ri, n"scanning") as ScanningComponent;
    this.m_visionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"vision") as VisionModeComponent;
    this.m_workspotMapper = EntityResolveComponentsInterface.GetComponent(ri, n"workspotMapper") as WorkspotMapperComponent;
    this.m_stimBroadcaster = EntityResolveComponentsInterface.GetComponent(ri, n"StimBroadcaster") as StimBroadcasterComponent;
    this.m_squadMemberComponent = EntityResolveComponentsInterface.GetComponent(ri, n"SquadMember") as SquadMemberBaseComponent;
    this.m_statusEffectComponent = EntityResolveComponentsInterface.GetComponent(ri, n"StatusEffect") as StatusEffectComponent;
    this.m_sourceShootComponent = EntityResolveComponentsInterface.GetComponent(ri, n"sourceShootComponent") as SourceShootComponent;
    this.m_targetShootComponent = EntityResolveComponentsInterface.GetComponent(ri, n"targetShootComponent") as TargetShootComponent;
  }

  protected cb func OnPostInitialize(evt: ref<entPostInitializeEvent>) -> Bool {
    if this.ShouldRegisterToHUD() {
      this.RegisterToHUDManager(true);
      this.RestoreRevealState();
      if this.IsTaggedinFocusMode() {
        GameObject.TagObject(this);
      };
    };
  }

  protected cb func OnPreUninitialize(evt: ref<entPreUninitializeEvent>) -> Bool {
    if this.ShouldRegisterToHUD() {
      this.RegisterToHUDManager(false);
    };
  }

  protected cb func OnGameAttached() -> Bool {
    let evt: ref<GameAttachedEvent> = new GameAttachedEvent();
    evt.isGameplayRelevant = this.IsGameplayRelevant();
    evt.displayName = this.GetDisplayName();
    evt.contentScale = this.GetContentScale();
    if this.ShouldSendGameAttachedEventToPS() {
      this.SendEventToDefaultPS(evt);
    };
  }

  protected cb func OnDetach() -> Bool {
    if this.m_hasVisibilityForcedInAnimSystem {
      this.ClearForcedVisibilityInAnimSystem();
    };
  }

  public final const func ShouldForceRegisterInHUDManager() -> Bool {
    return this.m_forceRegisterInHudManager;
  }

  public const func ShouldRegisterToHUD() -> Bool {
    if this.m_forceRegisterInHudManager || this.HasAnyClue() || this.IsQuest() || IsDefined(this.m_visionComponent) && this.m_visionComponent.HasStaticDefaultHighlight() {
      return true;
    };
    return false;
  }

  protected final func RequestHUDRefresh(opt updateData: ref<HUDActorUpdateData>) -> Void {
    let request: ref<RefreshActorRequest> = RefreshActorRequest.Construct(this.GetEntityID(), updateData);
    this.GetHudManager().QueueRequest(request);
  }

  protected final func RequestHUDRefresh(targetID: EntityID, opt updateData: ref<HUDActorUpdateData>) -> Void {
    let request: ref<RefreshActorRequest> = RefreshActorRequest.Construct(targetID, updateData);
    this.GetHudManager().QueueRequest(request);
  }

  public final const func CanScanThroughWalls() -> Bool {
    let statValue: Float;
    let player: ref<PlayerPuppet> = GetPlayer(this.GetGame());
    if IsDefined(player) {
      if player.HasAutoReveal() {
        return true;
      };
      statValue = GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(player.GetEntityID()), gamedataStatType.AutoReveal);
    };
    return statValue > 0.00;
  }

  public final const func IsScannerDataDirty() -> Bool {
    return this.m_isScannerDataDirty;
  }

  public final func SetScannerDirty(dirty: Bool) -> Void {
    this.m_isScannerDataDirty = dirty;
  }

  public const func CanRevealRemoteActionsWheel() -> Bool {
    return false;
  }

  public const func IsInitialized() -> Bool {
    return true;
  }

  public const func ShouldReactToTarget(targetID: EntityID) -> Bool {
    return false;
  }

  public const func GetSensesComponent() -> ref<SenseComponent> {
    return null;
  }

  public const func GetAttitudeAgent() -> ref<AttitudeAgent> {
    return null;
  }

  public const func GetScannerAttitudeTweak() -> TweakDBID {
    let recordID: TweakDBID;
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let attitude: EAIAttitude = this.GetAttitudeTowards(playerPuppet);
    switch attitude {
      case EAIAttitude.AIA_Friendly:
        recordID = t"scanning_devices.attitude_friendly";
        break;
      case EAIAttitude.AIA_Neutral:
        recordID = t"scanning_devices.attitude_neutral";
        break;
      case EAIAttitude.AIA_Hostile:
        recordID = t"scanning_devices.attitude_hostile";
    };
    return recordID;
  }

  public final static func GetAttitudeTowards(const first: ref<GameObject>, const second: ref<GameObject>) -> EAIAttitude {
    let fa: ref<AttitudeAgent>;
    let fb: ref<AttitudeAgent>;
    if first == null || second == null {
      return EAIAttitude.AIA_Neutral;
    };
    fa = first.GetAttitudeAgent();
    fb = second.GetAttitudeAgent();
    if fa != null && fb != null {
      return fa.GetAttitudeTowards(fb);
    };
    return EAIAttitude.AIA_Neutral;
  }

  public final const func GetAttitudeTowards(target: ref<GameObject>) -> EAIAttitude {
    let fb: ref<AttitudeAgent>;
    let fa: ref<AttitudeAgent> = this.GetAttitudeAgent();
    if IsDefined(target) {
      fb = target.GetAttitudeAgent();
    };
    if fa != null && fb != null {
      return fa.GetAttitudeTowards(fb);
    };
    return EAIAttitude.AIA_Neutral;
  }

  public final static func GetAttitudeBetween(first: ref<GameObject>, second: ref<GameObject>) -> EAIAttitude {
    return GameObject.GetAttitudeTowards(first, second);
  }

  public final static func IsFriendlyTowardsPlayer(obj: wref<GameObject>) -> Bool {
    if !IsDefined(obj) {
      return false;
    };
    if Equals(GameObject.GetAttitudeTowards(obj, GameInstance.GetPlayerSystem(obj.GetGame()).GetLocalPlayerMainGameObject()), EAIAttitude.AIA_Friendly) {
      return true;
    };
    if Equals(GameObject.GetAttitudeTowards(obj, GameInstance.GetPlayerSystem(obj.GetGame()).GetLocalPlayerControlledGameObject()), EAIAttitude.AIA_Friendly) {
      return true;
    };
    return false;
  }

  public final const func IsHostile() -> Bool {
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let attitude: EAIAttitude = this.GetAttitudeTowards(playerPuppet);
    if Equals(attitude, EAIAttitude.AIA_Hostile) {
      return true;
    };
    return false;
  }

  public final static func ChangeAttitudeToHostile(owner: wref<GameObject>, target: wref<GameObject>) -> Void {
    let attitudeOwner: ref<AttitudeAgent>;
    let attitudeTarget: ref<AttitudeAgent>;
    if !IsDefined(owner) || !IsDefined(target) {
      return;
    };
    attitudeOwner = owner.GetAttitudeAgent();
    attitudeTarget = target.GetAttitudeAgent();
    if !IsDefined(attitudeOwner) || !IsDefined(attitudeTarget) {
      return;
    };
    if NotEquals(attitudeOwner.GetAttitudeTowards(attitudeTarget), EAIAttitude.AIA_Hostile) {
      attitudeOwner.SetAttitudeTowards(attitudeTarget, EAIAttitude.AIA_Hostile);
    };
  }

  public final static func ChangeAttitudeToNeutral(owner: wref<GameObject>, target: wref<GameObject>) -> Void {
    let attitudeOwner: ref<AttitudeAgent>;
    let attitudeTarget: ref<AttitudeAgent>;
    if !IsDefined(owner) || !IsDefined(target) {
      return;
    };
    attitudeOwner = owner.GetAttitudeAgent();
    attitudeTarget = target.GetAttitudeAgent();
    if !IsDefined(attitudeOwner) || !IsDefined(attitudeTarget) {
      return;
    };
    if NotEquals(attitudeOwner.GetAttitudeTowards(attitudeTarget), EAIAttitude.AIA_Neutral) {
      attitudeOwner.SetAttitudeTowards(attitudeTarget, EAIAttitude.AIA_Neutral);
    };
  }

  public const func GetTargetTrackerComponent() -> ref<TargetTrackerComponent> {
    return null;
  }

  public final static func GetTDBID(object: wref<GameObject>) -> TweakDBID {
    let device: ref<Device>;
    let item: ref<ItemObject>;
    let puppet: ref<ScriptedPuppet> = object as ScriptedPuppet;
    if IsDefined(puppet) {
      return puppet.GetRecordID();
    };
    device = object as Device;
    if IsDefined(device) {
      return device.GetTweakDBRecord();
    };
    item = object as ItemObject;
    if IsDefined(item) {
      return ItemID.GetTDBID(item.GetItemID());
    };
    return TDBID.undefined();
  }

  public final static func GetActiveWeapon(object: wref<GameObject>) -> ref<WeaponObject> {
    let weapon: ref<WeaponObject>;
    if !IsDefined(object) || !object.IsAttached() {
      return null;
    };
    weapon = GameInstance.GetTransactionSystem(object.GetGame()).GetItemInSlot(object, t"AttachmentSlots.WeaponRight") as WeaponObject;
    if IsDefined(weapon) {
      return weapon;
    };
    weapon = GameInstance.GetTransactionSystem(object.GetGame()).GetItemInSlot(object, t"AttachmentSlots.WeaponLeft") as WeaponObject;
    if IsDefined(weapon) {
      return weapon;
    };
    return weapon;
  }

  public final static func StartCooldown(self: ref<GameObject>, cooldownName: CName, cooldownDuration: Float) -> Int32 {
    let cdRequest: RegisterNewCooldownRequest;
    let cs: ref<ICooldownSystem>;
    if cooldownDuration < 0.00 || !IsNameValid(cooldownName) {
      return -1;
    };
    if cooldownDuration == 0.00 {
      GameObject.RemoveCooldown(self, cooldownName);
      return -1;
    };
    cs = CSH.GetCooldownSystem(self);
    cdRequest.cooldownName = cooldownName;
    cdRequest.duration = cooldownDuration;
    cdRequest.owner = self;
    return cs.Register(cdRequest);
  }

  public final static func RemoveCooldown(self: ref<GameObject>, cooldownName: CName) -> Void {
    let cid: Int32;
    let cs: ref<ICooldownSystem>;
    if !IsNameValid(cooldownName) {
      return;
    };
    cs = CSH.GetCooldownSystem(self);
    cid = cs.GetCIDByOwnerAndName(self, cooldownName);
    if cs.DoesCooldownExist(cid) {
      cs.Remove(cid);
    };
  }

  public final static func IsCooldownActive(self: ref<GameObject>, cooldownName: CName, opt id: Int32) -> Bool {
    let cs: ref<ICooldownSystem> = CSH.GetCooldownSystem(self);
    if !IsDefined(cs) {
      return false;
    };
    if id > 0 {
      return cs.DoesCooldownExist(id);
    };
    id = cs.GetCIDByOwnerAndName(self, cooldownName);
    return cs.DoesCooldownExist(id);
  }

  public final static func GetTargetAngleInFloat(target: ref<GameObject>, owner: ref<GameObject>) -> Float {
    let forwardLocalToWorldAngle: Float = Vector4.Heading(owner.GetWorldForward());
    let localHitDirection: Vector4 = Vector4.RotByAngleXY(target.GetWorldForward(), forwardLocalToWorldAngle);
    let finalHitDirectionCalculationFloat: Float = Vector4.Heading(localHitDirection) + 180.00;
    return finalHitDirectionCalculationFloat;
  }

  public final static func GetTargetAngleInInt(target: ref<GameObject>, owner: ref<GameObject>) -> Int32 {
    let forwardLocalToWorldAngle: Float = Vector4.Heading(target.GetWorldForward());
    let localHitDirection: Vector4 = Vector4.RotByAngleXY(owner.GetWorldForward(), forwardLocalToWorldAngle);
    let finalHitDirectionCalculationFloat: Float = Vector4.Heading(localHitDirection) + 180.00;
    if finalHitDirectionCalculationFloat > 225.00 && finalHitDirectionCalculationFloat < 275.50 {
      return 1;
    };
    if finalHitDirectionCalculationFloat > 135.00 && finalHitDirectionCalculationFloat < 225.00 {
      return 2;
    };
    if finalHitDirectionCalculationFloat > 85.00 && finalHitDirectionCalculationFloat < 135.00 {
      return 3;
    };
    return 4;
  }

  public final static func GetAttackAngleInInt(hitEvent: ref<gameHitEvent>, opt hitSource: Int32) -> Int32 {
    if hitSource == 0 {
      return GameObject.GetLocalAngleForDirectionInInt(hitEvent.hitDirection, hitEvent.target);
    };
    return GameObject.GetTargetAngleInInt(hitEvent.attackData.GetSource(), hitEvent.target);
  }

  public final static func GetLocalAngleForDirectionInInt(direction: Vector4, owner: ref<GameObject>) -> Int32 {
    let forwardLocalToWorldAngle: Float = Vector4.Heading(owner.GetWorldForward());
    let localHitDirection: Vector4 = Vector4.RotByAngleXY(direction, forwardLocalToWorldAngle);
    let finalHitDirectionCalculationInt: Int32 = RoundMath((Vector4.Heading(localHitDirection) + 180.00) / 90.00);
    return finalHitDirectionCalculationInt;
  }

  public final static func GetAttackAngleInFloat(hitEvent: ref<gameHitEvent>) -> Float {
    let forwardLocalToWorldAngle: Float = Vector4.Heading(hitEvent.target.GetWorldForward());
    let localHitDirection: Vector4 = Vector4.RotByAngleXY(hitEvent.hitDirection, forwardLocalToWorldAngle);
    let finalHitDirectionCalculationfloat: Float = Vector4.Heading(localHitDirection) + 180.00;
    return finalHitDirectionCalculationfloat;
  }

  public final static func ApplyModifierGroup(self: ref<GameObject>, modifierGroupID: Uint64) -> Void {
    let objectID: StatsObjectID = Cast(self.GetEntityID());
    GameInstance.GetStatsSystem(self.GetGame()).ApplyModifierGroup(objectID, modifierGroupID);
  }

  public final static func RemoveModifierGroup(self: ref<GameObject>, modifierGroupID: Uint64) -> Void {
    let objectID: StatsObjectID = Cast(self.GetEntityID());
    GameInstance.GetStatsSystem(self.GetGame()).RemoveModifierGroup(objectID, modifierGroupID);
  }

  public final static func PlayVoiceOver(self: ref<GameObject>, voName: CName, debugInitialContext: CName, opt delay: Float, opt answeringEntityID: EntityID, opt canPlayInVehicle: Bool) -> DelayID {
    let delayID: DelayID;
    let evt: ref<SoundPlayVo> = new SoundPlayVo();
    if !IsDefined(self) {
      return delayID;
    };
    if VehicleComponent.IsMountedToVehicle(self.GetGame(), self) && !canPlayInVehicle {
      return delayID;
    };
    if IsServer() {
      return delayID;
    };
    if IsNameValid(voName) {
      evt.voContext = voName;
      if IsMultiplayer() {
        evt.ignoreFrustumCheck = true;
        evt.ignoreDistanceCheck = true;
      };
      evt.debugInitialContext = debugInitialContext;
      evt.answeringEntityId = answeringEntityID;
      if delay <= 0.00 {
        self.QueueEvent(evt);
      } else {
        delayID = GameInstance.GetDelaySystem(self.GetGame()).DelayEvent(self, evt, delay);
      };
    };
    return delayID;
  }

  public final static func PlaySound(self: ref<GameObject>, eventName: CName, opt emitterName: CName) -> Void {
    let objectID: EntityID = self.GetEntityID();
    if !EntityID.IsDefined(objectID) {
      GameInstance.GetAudioSystem(self.GetGame()).Play(eventName, objectID, emitterName);
    } else {
      GameObject.PlaySoundEvent(self, eventName);
    };
  }

  public final static func PlaySoundWithParams(self: ref<GameObject>, eventName: CName, opt emitterName: CName, opt flag: audioAudioEventFlags, opt type: audioEventActionType) -> Void {
    let objectID: EntityID = self.GetEntityID();
    if !EntityID.IsDefined(objectID) {
      GameInstance.GetAudioSystem(self.GetGame()).Play(eventName, objectID, emitterName);
    } else {
      GameObject.PlaySoundEventWithParams(self, eventName, flag, type);
    };
  }

  public final static func StopSound(self: ref<GameObject>, eventName: CName, opt emitterName: CName) -> Void {
    let objectID: EntityID = self.GetEntityID();
    if !EntityID.IsDefined(objectID) {
      GameInstance.GetAudioSystem(self.GetGame()).Stop(eventName, objectID, emitterName);
    } else {
      GameObject.StopSoundEvent(self, eventName);
    };
  }

  public final static func AudioSwitch(self: ref<GameObject>, switchName: CName, switchValue: CName, opt emitterName: CName) -> Void {
    let objectID: EntityID = self.GetEntityID();
    GameInstance.GetAudioSystem(self.GetGame()).Switch(switchName, switchValue, objectID, emitterName);
  }

  public final static func AudioParameter(self: ref<GameObject>, parameterName: CName, parameterValue: Float, opt emitterName: CName) -> Void {
    let objectID: EntityID = self.GetEntityID();
    GameInstance.GetAudioSystem(self.GetGame()).Parameter(parameterName, parameterValue, objectID, emitterName);
  }

  public final static func PlaySoundEvent(self: ref<GameObject>, eventName: CName) -> Void {
    let evt: ref<AudioEvent> = new AudioEvent();
    if !IsNameValid(eventName) {
      return;
    };
    evt.eventName = eventName;
    self.QueueEvent(evt);
  }

  public final static func PlaySoundEventWithParams(self: ref<GameObject>, eventName: CName, opt flag: audioAudioEventFlags, opt type: audioEventActionType) -> Void {
    let evt: ref<AudioEvent> = new AudioEvent();
    if !IsNameValid(eventName) {
      return;
    };
    evt.eventName = eventName;
    evt.eventFlags = flag;
    evt.eventType = type;
    self.QueueEvent(evt);
  }

  public final static func StopSoundEvent(self: ref<GameObject>, eventName: CName) -> Void {
    let evt: ref<SoundStopEvent> = new SoundStopEvent();
    if !IsNameValid(eventName) {
      return;
    };
    evt.soundName = eventName;
    self.QueueEvent(evt);
  }

  public final static func PlayMetadataEvent(self: ref<GameObject>, eventName: CName) -> Void {
    let evt: ref<AudioEvent> = new AudioEvent();
    evt.eventFlags = audioAudioEventFlags.Metadata;
    evt.eventName = eventName;
    self.QueueEvent(evt);
  }

  public final static func SetAudioSwitch(self: ref<GameObject>, switchName: CName, switchValue: CName) -> Void {
    let evt: ref<SoundSwitchEvent> = new SoundSwitchEvent();
    evt.switchName = switchName;
    evt.switchValue = switchValue;
    self.QueueEvent(evt);
  }

  public final static func SetAudioParameter(self: ref<GameObject>, paramName: CName, paramValue: Float) -> Void {
    let evt: ref<SoundParameterEvent> = new SoundParameterEvent();
    evt.parameterName = paramName;
    evt.parameterValue = paramValue;
    self.QueueEvent(evt);
  }

  public final native func QueueReplicatedEvent(evt: ref<Event>) -> Void;

  public final func OnEventReplicated(evt: ref<Event>) -> Void {
    this.QueueEvent(evt);
  }

  public final static func StartReplicatedEffectEvent(self: ref<GameObject>, effectName: CName, opt shouldPersist: Bool, opt breakAllOnDestroy: Bool) -> Void {
    let evt: ref<entSpawnEffectEvent> = new entSpawnEffectEvent();
    if IsNameValid(effectName) {
      evt.effectName = effectName;
      evt.persistOnDetach = shouldPersist;
      evt.breakAllOnDestroy = breakAllOnDestroy;
      self.QueueEvent(evt);
      self.QueueReplicatedEvent(evt);
    };
  }

  public final static func BreakReplicatedEffectLoopEvent(self: ref<GameObject>, effectName: CName) -> Void {
    let evt: ref<entBreakEffectLoopEvent> = new entBreakEffectLoopEvent();
    if IsNameValid(effectName) {
      evt.effectName = effectName;
      self.QueueEvent(evt);
      self.QueueReplicatedEvent(evt);
    };
  }

  public final static func StopReplicatedEffectEvent(self: ref<GameObject>, effectName: CName) -> Void {
    let evt: ref<entKillEffectEvent> = new entKillEffectEvent();
    evt.effectName = effectName;
    self.QueueEvent(evt);
    self.QueueReplicatedEvent(evt);
  }

  public final static func StopEffectEvent(self: ref<GameObject>, id: EntityID, effectName: CName) -> Void {
    let evt: ref<entKillEffectEvent> = new entKillEffectEvent();
    evt.effectName = effectName;
    self.QueueEventForEntityID(id, evt);
  }

  public final static func SetMeshAppearanceEvent(self: ref<GameObject>, appearance: CName) -> Void {
    let reactivateHighLightEvt: ref<ForceReactivateHighlightsEvent>;
    let evt: ref<entAppearanceEvent> = new entAppearanceEvent();
    evt.appearanceName = appearance;
    self.QueueEvent(evt);
    if self.IsHighlightedInFocusMode() {
      reactivateHighLightEvt = new ForceReactivateHighlightsEvent();
      self.QueueEvent(reactivateHighLightEvt);
    };
  }

  public final func PassUpdate(dt: Float) -> Void {
    this.Update(dt);
  }

  protected func Update(dt: Float) -> Void;

  protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    this.ApplyStatusEffectPackages(evt);
    this.StartStatusEffectVFX(evt);
    this.StartStatusEffectSFX(evt);
    this.HandleICEBreakerUpdate(evt);
  }

  private final func HandleICEBreakerUpdate(evt: ref<ApplyStatusEffectEvent>) -> Void {
    if evt.staticData.GetID() == t"MinigameAction.ICEBrokenMinigameMinor" || evt.staticData.GetID() == t"MinigameAction.ICEBrokenMinigameMedium" || evt.staticData.GetID() == t"MinigameAction.ICEBrokenMinigameMajor" || evt.staticData.GetID() == t"MinigameAction.ICEBrokenMinigamePlacide" {
      QuickhackModule.RequestRefreshQuickhackMenu(this.GetGame(), this.GetEntityID());
    };
  }

  protected func ApplyStatusEffectPackages(evt: ref<ApplyStatusEffectEvent>) -> Void {
    let i: Int32;
    let packages: array<wref<GameplayLogicPackage_Record>>;
    let stackCount: Uint32;
    evt.staticData.Packages(packages);
    stackCount = evt.stackCount;
    i = 0;
    while i < ArraySize(packages) {
      GameInstance.GetGameplayLogicPackageSystem(this.GetGame()).ApplyPackages(this, GameInstance.FindEntityByID(this.GetGame(), evt.instigatorEntityID) as GameObject, packages[i].GetID(), stackCount);
      i += 1;
    };
  }

  protected func StartStatusEffectVFX(evt: ref<ApplyStatusEffectEvent>) -> Void {
    let i: Int32;
    let vfxList: array<wref<StatusEffectFX_Record>>;
    evt.staticData.VFX(vfxList);
    i = 0;
    while i < ArraySize(vfxList) {
      if evt.isNewApplication || vfxList[i].ShouldReapply() {
        GameObjectEffectHelper.StartEffectEvent(this, vfxList[i].Name());
      };
      i += 1;
    };
  }

  protected func StartStatusEffectSFX(evt: ref<ApplyStatusEffectEvent>) -> Void {
    let i: Int32;
    let sfxList: array<wref<StatusEffectFX_Record>>;
    evt.staticData.SFX(sfxList);
    i = 0;
    while i < ArraySize(sfxList) {
      if evt.isNewApplication || sfxList[i].ShouldReapply() {
        GameObject.PlaySound(this, sfxList[i].Name());
      };
      i += 1;
    };
  }

  protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
    this.RemoveStatusEffectPackages(evt);
    this.StopStatusEffectVFX(evt);
    this.StopStatusEffectSFX(evt);
  }

  protected func RemoveStatusEffectPackages(evt: ref<RemoveStatusEffect>) -> Void {
    let i: Int32;
    let packages: array<wref<GameplayLogicPackage_Record>>;
    let stackCount: Uint32;
    evt.staticData.Packages(packages);
    stackCount = evt.stackCount;
    i = 0;
    while i < ArraySize(packages) {
      if packages[i].Stackable() || evt.isFinalRemoval {
        GameInstance.GetGameplayLogicPackageSystem(this.GetGame()).RemovePackages(this, packages[i].GetID(), stackCount);
      };
      i += 1;
    };
  }

  protected func StopStatusEffectVFX(evt: ref<RemoveStatusEffect>) -> Void {
    let i: Int32;
    let vfxList: array<wref<StatusEffectFX_Record>>;
    evt.staticData.VFX(vfxList);
    i = 0;
    while i < ArraySize(vfxList) {
      if evt.isFinalRemoval {
        GameObjectEffectHelper.BreakEffectLoopEvent(this, vfxList[i].Name());
      };
      i += 1;
    };
  }

  protected func StopStatusEffectSFX(evt: ref<RemoveStatusEffect>) -> Void {
    let i: Int32;
    let sfxList: array<wref<StatusEffectFX_Record>>;
    evt.staticData.SFX(sfxList);
    i = 0;
    while i < ArraySize(sfxList) {
      if evt.isFinalRemoval {
        GameObject.StopSound(this, sfxList[i].Name());
      };
      i += 1;
    };
  }

  protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
    let hitStim: ref<StimuliEvent>;
    this.SetScannerDirty(true);
    this.ProcessDamagePipeline(evt);
    hitStim = new StimuliEvent();
    hitStim.name = n"HitStim";
    this.QueueEvent(hitStim);
  }

  protected cb func OnVehicleHit(evt: ref<gameVehicleHitEvent>) -> Bool {
    let attackContext: AttackInitContext;
    attackContext.record = TweakDBInterface.GetAttackRecord(t"Attacks.VehicleCollision");
    attackContext.instigator = evt.attackData.GetInstigator();
    attackContext.source = evt.attackData.GetSource();
    let attack: ref<IAttack> = IAttack.Create(attackContext);
    evt.attackData.SetAttackDefinition(attack);
    evt.attackData.AddFlag(hitFlag.FriendlyFire, n"vehicle_collision");
    GameInstance.GetDamageSystem(this.GetGame()).StartPipeline(evt);
    if ScriptedPuppet.IsAlive(this) {
      GameObject.PlayVoiceOver(this, n"vo_any_damage_hit", n"Scripts:OnHit");
      TargetTrackingExtension.OnHit(this as ScriptedPuppet, evt);
    };
  }

  protected cb func OnHitProjection(evt: ref<gameProjectedHitEvent>) -> Bool {
    GameInstance.GetDamageSystem(this.GetGame()).StartProjectionPipeline(evt);
  }

  protected cb func OnAttitudeChanged(evt: ref<AttitudeChangedEvent>) -> Bool {
    this.SetScannerDirty(true);
  }

  protected func ProcessDamagePipeline(evt: ref<gameHitEvent>) -> Void {
    GameInstance.GetDamageSystem(this.GetGame()).StartPipeline(evt);
  }

  public func ReactToHitProcess(hitEvent: ref<gameHitEvent>) -> Void {
    let targetGodMode: gameGodModeType;
    if hitEvent.attackData.HasFlag(hitFlag.WasBlocked) || hitEvent.attackData.HasFlag(hitFlag.WasDeflected) {
      this.OnHitBlockedOrDeflected(hitEvent);
    };
    GetImmortality(hitEvent.target, targetGodMode);
    if hitEvent.target.IsPlayer() && (Equals(targetGodMode, gameGodModeType.Invulnerable) || hitEvent.attackData.HasFlag(hitFlag.DealNoDamage)) {
      return;
    };
    this.OnHitUI(hitEvent);
    if hitEvent.attackData.HasFlag(hitFlag.DisableNPCHitReaction) && !hitEvent.target.IsPlayer() {
      return;
    };
    this.OnHitAnimation(hitEvent);
    this.OnHitSounds(hitEvent);
    this.OnHitVFX(hitEvent);
  }

  protected func OnHitBlockedOrDeflected(hitEvent: ref<gameHitEvent>) -> Void;

  protected func OnHitAnimation(hitEvent: ref<gameHitEvent>) -> Void;

  protected func OnHitUI(hitEvent: ref<gameHitEvent>) -> Void {
    let dmgInfos: array<DamageInfo>;
    if IsClient() {
      return;
    };
    dmgInfos = GameInstance.GetDamageSystem(this.GetGame()).ConvertHitDataToDamageInfo(hitEvent);
    this.DisplayHitUI(dmgInfos);
  }

  public func DisplayHitUI(dmgInfos: array<DamageInfo>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(dmgInfos) {
      GameInstance.GetTargetingSystem(this.GetGame()).GetPuppetBlackboardUpdater().AddDamageInfo(dmgInfos[i]);
      i += 1;
    };
  }

  public func DisplayKillUI(killInfo: KillInfo) -> Void {
    GameInstance.GetTargetingSystem(this.GetGame()).GetPuppetBlackboardUpdater().AddKillInfo(killInfo);
  }

  protected func OnHitSounds(hitEvent: ref<gameHitEvent>) -> Void {
    if hitEvent.attackData.HasFlag(hitFlag.DisableSounds) {
      return;
    };
  }

  protected func OnHitVFX(hitEvent: ref<gameHitEvent>) -> Void;

  protected cb func OnDamageReceived(evt: ref<gameDamageReceivedEvent>) -> Bool {
    this.ProcessDamageReceived(evt);
  }

  protected final func ProcessDamageReceived(evt: ref<gameDamageReceivedEvent>) -> Void {
    let damageHistoryEvt: DamageHistoryEntry;
    let damageInflictedEvent: ref<DamageInflictedEvent>;
    let instigator: wref<GameObject> = evt.hitEvent.attackData.GetInstigator();
    if instigator.IsControlledByAnyPeer() {
      if GameInstance.GetStatPoolsSystem(evt.hitEvent.target.GetGame()).GetStatPoolValue(Cast(evt.hitEvent.target.GetEntityID()), gamedataStatPoolType.Health, false) <= 0.00 {
        ChatterHelper.TryPlayEnemyKilledChatter(instigator);
      } else {
        ChatterHelper.TryPlayEnemyDamagedChatter(instigator);
      };
    };
    if evt.totalDamageReceived > 0.00 {
      if ArraySize(this.m_receivedDamageHistory) > 0 {
        if this.m_receivedDamageHistory[ArraySize(this.m_receivedDamageHistory) - 1].frameReceived < GameInstance.GetFrameNumber(this.GetGame()) {
          ArrayClear(this.m_receivedDamageHistory);
        };
      };
      damageHistoryEvt.hitEvent = evt.hitEvent;
      damageHistoryEvt.frameReceived = GameInstance.GetFrameNumber(this.GetGame());
      damageHistoryEvt.timestamp = EngineTime.ToFloat(GameInstance.GetEngineTime(this.GetGame()));
      damageHistoryEvt.totalDamageReceived = evt.totalDamageReceived;
      damageHistoryEvt.source = evt.hitEvent.attackData.GetInstigator();
      damageHistoryEvt.target = evt.hitEvent.target;
      damageHistoryEvt.healthAtTheTime = GameInstance.GetStatPoolsSystem(this.GetGame()).GetStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.Health, false);
      ArrayPush(this.m_receivedDamageHistory, damageHistoryEvt);
    };
    CoopIrritationDelayCallback.TryCreate(instigator);
    if IsDefined(instigator) {
      damageInflictedEvent = new DamageInflictedEvent();
      instigator.QueueEvent(damageInflictedEvent);
    };
  }

  public func Record1DamageInHistory(source: ref<GameObject>) -> Void {
    let damageHistoryEvt: DamageHistoryEntry;
    if ArraySize(this.m_receivedDamageHistory) > 0 {
      if this.m_receivedDamageHistory[ArraySize(this.m_receivedDamageHistory) - 1].frameReceived < GameInstance.GetFrameNumber(this.GetGame()) {
        ArrayClear(this.m_receivedDamageHistory);
      };
    };
    damageHistoryEvt.frameReceived = GameInstance.GetFrameNumber(this.GetGame());
    damageHistoryEvt.timestamp = EngineTime.ToFloat(GameInstance.GetEngineTime(this.GetGame()));
    damageHistoryEvt.totalDamageReceived = 1.00;
    damageHistoryEvt.source = source;
    damageHistoryEvt.target = this;
    damageHistoryEvt.healthAtTheTime = 1.00;
    ArrayPush(this.m_receivedDamageHistory, damageHistoryEvt);
  }

  protected cb func OnRecord1DamageInHistoryEvent(evt: ref<Record1DamageInHistoryEvent>) -> Bool {
    this.Record1DamageInHistory(evt.source);
  }

  public final func FindAndRewardKiller(killType: gameKillType, opt instigator: wref<GameObject>) -> Void {
    let i: Int32;
    let isAnyDamageNonlethal: Bool;
    let p: Int32;
    let playerDamageData: array<PlayerTotalDamageAgainstHealth>;
    let randomInt: Int32;
    let reserveKillerPool: array<wref<GameObject>>;
    let validKillerPool: array<wref<GameObject>>;
    if ArraySize(this.m_receivedDamageHistory) > 0 {
      i = 0;
      while i < ArraySize(this.m_receivedDamageHistory) {
        if this.m_receivedDamageHistory[i].source != null {
          if !ArrayContains(reserveKillerPool, this.m_receivedDamageHistory[i].source) {
            ArrayPush(reserveKillerPool, this.m_receivedDamageHistory[i].source);
            ArrayResize(playerDamageData, ArraySize(reserveKillerPool));
            p = ArraySize(reserveKillerPool) - 1;
            playerDamageData[p].player = this.m_receivedDamageHistory[i].source;
            playerDamageData[p].totalDamage = this.m_receivedDamageHistory[i].totalDamageReceived;
            playerDamageData[p].targetHealth = this.m_receivedDamageHistory[i].healthAtTheTime;
          } else {
            p = ArrayFindFirst(reserveKillerPool, this.m_receivedDamageHistory[i].source);
            playerDamageData[p].totalDamage += this.m_receivedDamageHistory[i].totalDamageReceived;
            if playerDamageData[p].targetHealth > this.m_receivedDamageHistory[i].healthAtTheTime {
              playerDamageData[p].targetHealth = this.m_receivedDamageHistory[i].healthAtTheTime;
            };
          };
        };
        if IsDefined(this.m_receivedDamageHistory[i].hitEvent) {
          if this.m_receivedDamageHistory[i].hitEvent.attackData.HasFlag(hitFlag.Nonlethal) {
            isAnyDamageNonlethal = true;
          };
        };
        i += 1;
      };
      i = 0;
      while i < ArraySize(playerDamageData) {
        if playerDamageData[i].totalDamage >= playerDamageData[i].targetHealth {
          ArrayPush(validKillerPool, playerDamageData[i].player);
        };
        i += 1;
      };
      if ArraySize(validKillerPool) > 0 {
        randomInt = RandRange(0, ArraySize(validKillerPool));
        this.RewardKiller(validKillerPool[randomInt], killType, isAnyDamageNonlethal);
        this.CheckIfPreventionShouldReact(validKillerPool);
      } else {
        if ArraySize(reserveKillerPool) > 0 {
          randomInt = RandRange(0, ArraySize(reserveKillerPool));
          this.RewardKiller(reserveKillerPool[randomInt], killType, isAnyDamageNonlethal);
          this.CheckIfPreventionShouldReact(reserveKillerPool);
        };
      };
    } else {
      if IsDefined(instigator) {
        this.RewardKiller(instigator, killType, isAnyDamageNonlethal);
        ArrayPush(validKillerPool, instigator);
        this.CheckIfPreventionShouldReact(validKillerPool);
      };
    };
  }

  protected func RewardKiller(killer: wref<GameObject>, killType: gameKillType, isAnyDamageNonlethal: Bool) -> Void {
    let killRewardEvt: ref<KillRewardEvent>;
    if this.m_killRewardDisabled {
      return;
    };
    if this.m_willDieSoon && Equals(killType, gameKillType.Normal) {
      return;
    };
    killRewardEvt = new KillRewardEvent();
    killRewardEvt.victim = this;
    if this.m_forceDefeatReward {
      killRewardEvt.killType = gameKillType.Defeat;
    } else {
      if this.m_willDieSoon {
        killRewardEvt.killType = gameKillType.Normal;
      } else {
        killRewardEvt.killType = killType;
      };
    };
    killer.QueueEvent(killRewardEvt);
  }

  public final func ForceDefeatReward(value: Bool) -> Void {
    this.m_forceDefeatReward = value;
  }

  public final func DisableKillReward(value: Bool) -> Void {
    this.m_killRewardDisabled = value;
  }

  protected cb func OnChangeRewardSettingsEvent(evt: ref<ChangeRewardSettingsEvent>) -> Bool {
    this.ForceDefeatReward(evt.forceDefeatReward);
    this.DisableKillReward(evt.disableKillReward);
  }

  protected cb func OnWillDieSoonEventEvent(evt: ref<WillDieSoonEvent>) -> Bool {
    this.m_willDieSoon = true;
  }

  private final func CheckIfPreventionShouldReact(damageDealers: array<wref<GameObject>>) -> Void {
    let i: Int32;
    if PreventionSystem.ShouldPreventionSystemReactToKill(this as ScriptedPuppet) {
      i = 0;
      while i < ArraySize(damageDealers) {
        if damageDealers[i].IsPlayer() {
          PreventionSystem.CreateNewDamageRequest(this.GetGame(), this, 1.00);
          return;
        };
        i += 1;
      };
    };
  }

  public const func IsVehicle() -> Bool {
    return false;
  }

  public const func IsPuppet() -> Bool {
    return false;
  }

  public const func IsPlayer() -> Bool {
    return false;
  }

  public const func IsReplacer() -> Bool {
    return false;
  }

  public const func IsVRReplacer() -> Bool {
    return false;
  }

  public const func IsJohnnyReplacer() -> Bool {
    return false;
  }

  public const func IsNPC() -> Bool {
    return false;
  }

  public const func IsContainer() -> Bool {
    return false;
  }

  public const func IsShardContainer() -> Bool {
    return false;
  }

  public const func IsDevice() -> Bool {
    return false;
  }

  public const func IsSensor() -> Bool {
    return false;
  }

  public const func IsTurret() -> Bool {
    return false;
  }

  public const func IsActive() -> Bool {
    return false;
  }

  public const func IsPrevention() -> Bool {
    return false;
  }

  public const func IsDropPoint() -> Bool {
    return false;
  }

  public const func IsDrone() -> Bool {
    return false;
  }

  protected final const func IsItem() -> Bool {
    return (this as ItemObject) != null;
  }

  public const func IsDead() -> Bool {
    if GameInstance.GetStatPoolsSystem(this.GetGame()).GetStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.Health, false) <= 0.00 {
      return true;
    };
    return false;
  }

  public const func IsDeadNoStatPool() -> Bool {
    return this.IsDead();
  }

  public func UpdateAdditionalScanningData() -> Void {
    let stats: GameObjectScanStats;
    stats.scannerData.entityName = this.GetDisplayName();
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_Scanner);
    if IsDefined(bb) {
      bb.SetVariant(GetAllBlackboardDefs().UI_Scanner.scannerObjectStats, ToVariant(stats));
      bb.SignalVariant(GetAllBlackboardDefs().UI_Scanner.scannerObjectStats);
    };
  }

  protected cb func OnOutlineItemRequestEvent(evt: ref<OutlineItemRequestEvent>) -> Bool;

  protected cb func OnOutlineRequestEvent(evt: ref<OutlineRequestEvent>) -> Bool {
    if !this.m_e3HighlightHackStarted {
      this.m_e3HighlightHackStarted = true;
      this.StartUpdate();
    };
    if this.IsDead() {
      return false;
    };
    if Equals(evt.outlineRequest.GetRequestType(), EOutlineType.RED) {
      this.m_lastFrameRed = evt.outlineRequest;
    } else {
      if Equals(evt.outlineRequest.GetRequestType(), EOutlineType.GREEN) {
        this.m_lastFrameGreen = evt.outlineRequest;
      };
    };
  }

  private final func StartUpdate() -> Void {
    this.FireSingleE3Tick();
  }

  private final func FireSingleE3Tick() -> Void {
    let fakeUpdate: ref<FakeUpdateEvent> = new FakeUpdateEvent();
    this.QueueEvent(fakeUpdate);
  }

  protected cb func OnFakeUpdate(evt: ref<FakeUpdateEvent>) -> Bool {
    if this.m_e3HighlightHackStarted {
      this.QueueEvent(evt);
      this.EvaluateLastFrameRequest();
      this.ClearLastFrame();
    };
  }

  private final func EvaluateLastFrameRequest() -> Void {
    if !IsDefined(this.m_outlineRequestsManager) {
      this.m_outlineRequestsManager = new OutlineRequestManager();
      this.m_outlineRequestsManager.Initialize(this);
    };
    if this.IsDead() {
      return;
    };
    if this.m_lastFrameGreen.ShouldAdd() {
      this.m_outlineRequestsManager.PushRequest(this.m_lastFrameGreen);
    } else {
      if this.m_lastFrameRed.ShouldAdd() {
        this.m_outlineRequestsManager.PushRequest(this.m_lastFrameRed);
      } else {
        this.Suppress();
      };
    };
    this.SetUpProperOutline();
  }

  private final func ClearLastFrame() -> Void {
    this.m_lastFrameGreen = null;
    this.m_lastFrameRed = null;
  }

  private final func Suppress() -> Void {
    if this.IsDead() {
      return;
    };
    this.m_outlineRequestsManager.ClearAllRequests();
  }

  protected cb func OnSuppressOutlineEvent(evt: ref<SuppressOutlineEvent>) -> Bool {
    let newRequest: ref<OutlineRequest> = new OutlineRequest();
    if this.IsDead() {
      return false;
    };
    newRequest = OutlineRequest.CreateRequest(evt.requestToSuppress.GetRequester(), false, evt.requestToSuppress.GetData());
    this.m_outlineRequestsManager.PushRequest(newRequest);
    this.SetUpProperOutline();
  }

  private final func SetUpProperOutline() -> Void {
    let i: Int32;
    let opacityEvent: ref<HighlightOpacityEvent> = new HighlightOpacityEvent();
    let isGreen: Bool = this.m_outlineRequestsManager.HasOutlineOfType(EOutlineType.GREEN);
    if this.IsDead() {
      return;
    };
    if isGreen {
      i = 0;
      while i < ArraySize(this.m_prereqListeners) {
        this.m_prereqListeners[i].OnRedOutlineStateChanged(false);
        this.m_prereqListeners[i].OnGreenOutlineStateChanged(true);
        i += 1;
      };
      opacityEvent.opacity = 1.00;
      this.QueueEvent(opacityEvent);
    } else {
      if this.m_outlineRequestsManager.HasOutlineOfType(EOutlineType.RED) {
        i = 0;
        while i < ArraySize(this.m_prereqListeners) {
          this.m_prereqListeners[i].OnGreenOutlineStateChanged(false);
          this.m_prereqListeners[i].OnRedOutlineStateChanged(true);
          i += 1;
        };
        opacityEvent.opacity = 1.00;
        this.QueueEvent(opacityEvent);
      } else {
        if !this.m_outlineRequestsManager.HasAnyOutlineRequest() {
          i = 0;
          while i < ArraySize(this.m_prereqListeners) {
            this.m_prereqListeners[i].OnGreenOutlineStateChanged(false);
            this.m_prereqListeners[i].OnRedOutlineStateChanged(false);
            i += 1;
          };
          this.QueueEvent(opacityEvent);
        };
      };
    };
  }

  protected final func FadeOutOutlines() -> Void {
    let data: OutlineData;
    let fadeOutUpdate: ref<FadeOutOutlinesUpdate>;
    let i: Int32;
    let lastRequest: ref<OutlineRequest>;
    if !IsDefined(this.m_outlineRequestsManager) || !this.m_outlineRequestsManager.HasAnyOutlineRequest() || this.m_fadeOutStarted {
      return;
    };
    fadeOutUpdate = new FadeOutOutlinesUpdate();
    lastRequest = new OutlineRequest();
    data.outlineType = EOutlineType.RED;
    data.outlineStrength = 1.00;
    lastRequest = OutlineRequest.CreateRequest(n"lastRequest", true, data);
    this.m_fadeOutStarted = true;
    this.m_outlineRequestsManager.ClearAllRequests();
    this.m_outlineRequestsManager.PushRequest(lastRequest);
    this.m_outlineRequestsManager.BlockRequests();
    i = 0;
    while i < ArraySize(this.m_prereqListeners) {
      this.m_prereqListeners[i].OnGreenOutlineStateChanged(false);
      this.m_prereqListeners[i].OnRedOutlineStateChanged(true);
      i += 1;
    };
    GameInstance.GetDelaySystem(this.GetGame()).TickOnEvent(this, fadeOutUpdate, 5.50);
  }

  protected cb func OnFadeOutOutlinesUpdate(evt: ref<FadeOutOutlinesUpdate>) -> Bool {
    let i: Int32;
    let opacityEvent: ref<HighlightOpacityEvent>;
    this.m_e3HighlightHackStarted = false;
    let strongestOutline: Float = this.m_outlineRequestsManager.FindStrongestRequest();
    this.m_outlineFadeCounter += 1;
    this.m_accumulatedTimePasssed += this.CalculateRealTimePassed();
    if this.m_accumulatedTimePasssed >= 5.50 || Equals(evt.state, gameTickableEventState.LastTick) {
      this.m_outlineRequestsManager.ClearAllRequests();
      i = 0;
      while i < ArraySize(this.m_prereqListeners) {
        this.m_prereqListeners[i].OnGreenOutlineStateChanged(false);
        this.m_prereqListeners[i].OnRedOutlineStateChanged(false);
        this.m_prereqListeners[i].E3BlockHack();
        i += 1;
      };
      this.m_accumulatedTimePasssed = 0.00;
      this.m_e3HighlightHackStarted = false;
      opacityEvent = new HighlightOpacityEvent();
      opacityEvent.opacity = 0.00;
      this.QueueEvent(opacityEvent);
      return false;
    };
    opacityEvent = new HighlightOpacityEvent();
    opacityEvent.opacity = this.CalculateOpacity(strongestOutline);
    if opacityEvent.opacity < 0.20 {
      Log("success");
    };
    this.QueueEvent(opacityEvent);
  }

  private final func CalculateRealTimePassed() -> Float {
    let deltaTime: Float;
    let newTime: Float = EngineTime.ToFloat(GameInstance.GetEngineTime(this.GetGame()));
    if this.m_lastEngineTime != 0.00 {
      deltaTime = newTime - this.m_lastEngineTime;
    };
    this.m_lastEngineTime = newTime;
    return deltaTime;
  }

  protected cb func OnForceFadeOutlineEventForWeapon(evt: ref<ForceFadeOutlineEventForWeapon>) -> Bool {
    Log("GameObject \\ ForceFadeOutlineEventForWeapon " + EntityID.ToDebugString(this.GetEntityID()));
    this.FadeOutOutlines();
  }

  protected final func CalculateAmountOfTicks() -> Int32 {
    return FloorF(30.00 * 5.50);
  }

  protected final func CalculateOpacity(outlineStrength: Float) -> Float {
    let progress: Float = this.m_accumulatedTimePasssed / 5.50;
    let result: Float = (1.00 - progress) / outlineStrength;
    return result;
  }

  public final func ShouldEnableOutlineRed() -> Bool {
    return this.m_outlineRequestsManager.HasOutlineOfType(EOutlineType.RED);
  }

  public final func ShouldEnableOutlineGreen() -> Bool {
    return this.m_outlineRequestsManager.HasOutlineOfType(EOutlineType.GREEN);
  }

  protected cb func OnDebugOutlineEvent(evt: ref<DebugOutlineEvent>) -> Bool {
    let data: OutlineData;
    let outlineRequestEvent: ref<OutlineRequestEvent> = new OutlineRequestEvent();
    let outlineRequest: ref<OutlineRequest> = new OutlineRequest();
    data.outlineType = evt.type;
    data.outlineStrength = evt.opacity;
    outlineRequest = OutlineRequest.CreateRequest(n"debug", true, data);
    outlineRequestEvent.outlineRequest = outlineRequest;
    outlineRequestEvent.flag = false;
    this.QueueEvent(outlineRequestEvent);
  }

  protected cb func OnScanningModeChanged(evt: ref<ScanningModeEvent>) -> Bool {
    GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_Scanner).SetVariant(GetAllBlackboardDefs().UI_Scanner.ScannerMode, ToVariant(evt));
  }

  protected cb func OnScanningLookedAt(evt: ref<ScanningLookAtEvent>) -> Bool {
    if evt.state {
      this.PurgeScannerBlackboard();
      this.SetScannerDirty(true);
    };
  }

  protected cb func OnLookedAtEvent(evt: ref<LookedAtEvent>) -> Bool;

  protected cb func OnPulseEvent(evt: ref<gameVisionModeUpdateVisuals>) -> Bool {
    if this.IsPlayer() || this.IsItem() || this.GetNetworkSystem().IsPingLinksLimitReached() || this.GetNetworkSystem().HasActivePing(this.GetEntityID()) || this.m_e3ObjectRevealed {
      return false;
    };
    if evt.pulse {
    };
  }

  protected func PulseNetwork(revealNetworkAtEnd: Bool) -> Void {
    let duration: Float;
    let request: ref<StartPingingNetworkRequest>;
    this.m_e3ObjectRevealed = true;
    if GameInstance.GetQuestsSystem(this.GetGame()).GetFact(n"pingingNetworkDisabled") > 0 {
      return;
    };
    request = new StartPingingNetworkRequest();
    duration = this.GetNetworkSystem().GetSpacePingDuration();
    request.source = this;
    request.fxResource = this.GetFxResourceByKey(n"pingNetworkLink");
    request.duration = duration;
    request.pingType = EPingType.SPACE;
    request.fakeLinkType = ELinkType.FREE;
    request.revealNetworkAtEnd = revealNetworkAtEnd;
    this.GetNetworkSystem().QueueRequest(request);
  }

  public final const func GetTakeOverControlSystem() -> ref<TakeOverControlSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"TakeOverControlSystem") as TakeOverControlSystem;
  }

  public final const func GetTaggingSystem() -> ref<FocusModeTaggingSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"FocusModeTaggingSystem") as FocusModeTaggingSystem;
  }

  public final static func TagObject(obj: wref<GameObject>) -> Void {
    let request: ref<TagObjectRequest>;
    if !IsDefined(obj) || !obj.CanBeTagged() {
      return;
    };
    request = new TagObjectRequest();
    request.object = obj;
    obj.GetTaggingSystem().QueueRequest(request);
  }

  public final static func UntagObject(obj: wref<GameObject>) -> Void {
    let request: ref<UnTagObjectRequest>;
    if !IsDefined(obj) {
      return;
    };
    request = new UnTagObjectRequest();
    request.object = obj;
    obj.GetTaggingSystem().QueueRequest(request);
  }

  public const func CanBeTagged() -> Bool {
    return true;
  }

  protected cb func OnTagObjectEvent(evt: ref<TagObjectEvent>) -> Bool {
    if evt.isTagged {
      GameObject.TagObject(this);
    } else {
      GameObject.UntagObject(this);
    };
  }

  public const func GetDefaultHighlight() -> ref<FocusForcedHighlightData> {
    let highlight: ref<FocusForcedHighlightData>;
    let outline: EFocusOutlineType;
    if this.IsBraindanceBlocked() || this.IsPhotoModeBlocked() {
      return null;
    };
    outline = this.GetCurrentOutline();
    highlight = new FocusForcedHighlightData();
    highlight.sourceID = this.GetEntityID();
    highlight.sourceName = this.GetClassName();
    highlight.priority = EPriority.Low;
    highlight.outlineType = outline;
    if this.IsQuest() {
      highlight.highlightType = EFocusForcedHighlightType.QUEST;
      highlight.outlineType = EFocusOutlineType.QUEST;
    } else {
      if this.IsTaggedinFocusMode() {
        highlight.highlightType = EFocusForcedHighlightType.INTERACTION;
        highlight.outlineType = EFocusOutlineType.INTERACTION;
      } else {
        highlight = null;
      };
    };
    return highlight;
  }

  protected final func UpdateDefaultHighlight() -> Void {
    let updateHighlightEvt: ref<ForceUpdateDefaultHighlightEvent> = new ForceUpdateDefaultHighlightEvent();
    this.QueueEvent(updateHighlightEvt);
  }

  public const func GetCurrentOutline() -> EFocusOutlineType {
    return EFocusOutlineType.INVALID;
  }

  public final const func GetDefaultHighlightType() -> EFocusForcedHighlightType {
    let data: ref<FocusForcedHighlightData> = this.GetDefaultHighlight();
    if data != null {
      return data.highlightType;
    };
    return EFocusForcedHighlightType.INVALID;
  }

  public final const func HasHighlight(highlightType: EFocusForcedHighlightType, outlineType: EFocusOutlineType) -> Bool {
    if !IsDefined(this.m_visionComponent) {
      return false;
    };
    return this.m_visionComponent.HasHighlight(highlightType, outlineType);
  }

  public final const func HasOutlineOrFill(highlightType: EFocusForcedHighlightType, outlineType: EFocusOutlineType) -> Bool {
    if !IsDefined(this.m_visionComponent) {
      return false;
    };
    return this.m_visionComponent.HasOutlineOrFill(highlightType, outlineType);
  }

  public final const func HasHighlight(highlightType: EFocusForcedHighlightType, outlineType: EFocusOutlineType, sourceID: EntityID) -> Bool {
    if !IsDefined(this.m_visionComponent) {
      return false;
    };
    return this.m_visionComponent.HasHighlight(highlightType, outlineType, sourceID);
  }

  public final const func HasHighlight(highlightType: EFocusForcedHighlightType, outlineType: EFocusOutlineType, sourceID: EntityID, sourceName: CName) -> Bool {
    if !IsDefined(this.m_visionComponent) {
      return false;
    };
    return this.m_visionComponent.HasHighlight(highlightType, outlineType, sourceID, sourceName);
  }

  public final const func HasRevealRequest(data: gameVisionModeSystemRevealIdentifier) -> Bool {
    if !IsDefined(this.m_visionComponent) {
      return false;
    };
    return this.m_visionComponent.HasRevealRequest(data);
  }

  protected final func CancelForcedVisionAppearance(data: ref<FocusForcedHighlightData>) -> Void {
    let evt: ref<ForceVisionApperanceEvent> = new ForceVisionApperanceEvent();
    evt.forcedHighlight = data;
    evt.apply = false;
    this.QueueEvent(evt);
  }

  protected final func ForceVisionAppearance(data: ref<FocusForcedHighlightData>) -> Void {
    let evt: ref<ForceVisionApperanceEvent> = new ForceVisionApperanceEvent();
    evt.forcedHighlight = data;
    evt.apply = true;
    this.QueueEvent(evt);
  }

  public final static func ForceVisionAppearance(self: ref<GameObject>, data: ref<FocusForcedHighlightData>) -> Void {
    let evt: ref<ForceVisionApperanceEvent> = new ForceVisionApperanceEvent();
    evt.forcedHighlight = data;
    evt.apply = true;
    self.QueueEvent(evt);
  }

  public final static func SetFocusForcedHightlightData(outType: EFocusOutlineType, highType: EFocusForcedHighlightType, prio: EPriority, id: EntityID, className: CName) -> ref<FocusForcedHighlightData> {
    let newData: ref<FocusForcedHighlightData> = new FocusForcedHighlightData();
    newData.outlineType = outType;
    newData.highlightType = highType;
    newData.priority = prio;
    newData.sourceID = id;
    newData.sourceName = className;
    return newData;
  }

  protected final func SendReactivateHighlightEvent() -> Void {
    let evt: ref<ForceReactivateHighlightsEvent> = new ForceReactivateHighlightsEvent();
    this.QueueEvent(evt);
  }

  public const func GetObjectToForwardHighlight() -> array<wref<GameObject>> {
    let emptyArray: array<wref<GameObject>>;
    return emptyArray;
  }

  protected cb func OnHUDInstruction(evt: ref<HUDInstruction>) -> Bool {
    if Equals(evt.highlightInstructions.GetState(), InstanceState.ON) {
      this.m_isHighlightedInFocusMode = true;
    } else {
      if evt.highlightInstructions.WasProcessed() {
        this.m_isHighlightedInFocusMode = false;
      };
    };
  }

  protected final func TryOpenQuickhackMenu(shouldOpen: Bool) -> Void {
    if shouldOpen {
      shouldOpen = this.CanRevealRemoteActionsWheel();
    };
    this.SendQuickhackCommands(shouldOpen);
  }

  protected func SendQuickhackCommands(shouldOpen: Bool) -> Void;

  protected final func SendForceRevealObjectEvent(reveal: Bool, reason: CName, opt instigatorID: EntityID, opt lifetime: Float, opt delay: Float) -> Void {
    let evt: ref<RevealObjectEvent> = new RevealObjectEvent();
    evt.reveal = reveal;
    evt.reason.reason = reason;
    evt.reason.sourceEntityId = instigatorID;
    evt.lifetime = lifetime;
    if delay > 0.00 {
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, delay, true);
    } else {
      this.QueueEvent(evt);
    };
  }

  public final static func SendForceRevealObjectEvent(self: ref<GameObject>, reveal: Bool, reason: CName, opt instigatorID: EntityID, opt lifetime: Float, opt delay: Float) -> Void {
    self.SendForceRevealObjectEvent(reveal, reason, instigatorID, lifetime, delay);
  }

  private final func RestoreRevealState() -> Void {
    let evt: ref<RestoreRevealStateEvent>;
    if this.IsObjectRevealed() {
      evt = new RestoreRevealStateEvent();
      this.QueueEvent(evt);
    };
  }

  public const func IsHighlightedInFocusMode() -> Bool {
    return this.m_isHighlightedInFocusMode;
  }

  public final const func IsScanned() -> Bool {
    if this.m_scanningComponent != null {
      return this.m_scanningComponent.IsScanned();
    };
    return false;
  }

  public final const func GetBraindanceLayer() -> braindanceVisionMode {
    if IsDefined(this.m_scanningComponent) {
      return this.m_scanningComponent.GetBraindanceLayer();
    };
    return braindanceVisionMode.Default;
  }

  public final const func IsObjectRevealed() -> Bool {
    if this.m_visionComponent == null {
      return false;
    };
    return this.m_visionComponent.IsRevealed();
  }

  protected final func GetFastTravelSystem() -> ref<FastTravelSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"FastTravelSystem") as FastTravelSystem;
  }

  protected final const func GetNetworkSystem() -> ref<NetworkSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"NetworkSystem") as NetworkSystem;
  }

  public const func CanOverrideNetworkContext() -> Bool {
    return false;
  }

  public const func IsAccessPoint() -> Bool {
    return false;
  }

  protected func StartPingingNetwork() -> Void;

  protected func StopPingingNetwork() -> Void;

  public const func GetNetworkLinkSlotName(out transform: WorldTransform) -> CName {
    return n"";
  }

  public const func GetNetworkLinkSlotName() -> CName {
    return n"";
  }

  public const func GetRoleMappinSlotName() -> CName {
    return n"roleMappin";
  }

  public const func GetQuickHackIndicatorSlotName() -> CName {
    return n"uploadBar";
  }

  public const func GetPhoneCallIndicatorSlotName() -> CName {
    return n"phoneCall";
  }

  public const func IsNetworkLinkDynamic() -> Bool {
    return false;
  }

  public const func GetNetworkBeamEndpoint() -> Vector4 {
    let beamPos: Vector4 = this.GetWorldPosition();
    return beamPos;
  }

  public const func IsNetworkKnownToPlayer() -> Bool {
    return false;
  }

  public const func CanPlayerUseQuickHackVulnerability(data: TweakDBID) -> Bool {
    return false;
  }

  public const func IsConnectedToBackdoorDevice() -> Bool {
    return false;
  }

  public const func IsInIconForcedVisibilityRange() -> Bool {
    return false;
  }

  public func EvaluateMappinsVisualState() -> Void {
    let evt: ref<EvaluateMappinsVisualStateEvent> = new EvaluateMappinsVisualStateEvent();
    this.QueueEvent(evt);
  }

  public const func IsGameplayRelevant() -> Bool {
    let role: EGameplayRole = this.DeterminGameplayRole();
    return NotEquals(role, IntEnum(1l)) && NotEquals(role, EGameplayRole.UnAssigned);
  }

  public const func ShouldSendGameAttachedEventToPS() -> Bool {
    return true;
  }

  public const func GetContentScale() -> TweakDBID {
    let id: TweakDBID;
    return id;
  }

  public const func IsGameplayRoleValid(role: EGameplayRole) -> Bool {
    return true;
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    if IsDefined(this.m_scanningComponent) && this.m_scanningComponent.IsAnyClueEnabled() {
      return EGameplayRole.Clue;
    };
    return IntEnum(1l);
  }

  public const func DeterminGameplayRoleMappinVisuaState(data: SDeviceMappinData) -> EMappinVisualState {
    if this.HasAnyClue() && this.IsClueInspected() {
      return EMappinVisualState.Inactive;
    };
    return EMappinVisualState.Default;
  }

  public const func DeterminGameplayRoleMappinRange(data: SDeviceMappinData) -> Float {
    return 0.00;
  }

  protected cb func OnGameplayRoleChangeNotification(evt: ref<GameplayRoleChangeNotification>) -> Bool {
    if Equals(evt.newRole, IntEnum(1l)) && NotEquals(evt.oldRole, IntEnum(1l)) {
      this.RequestHUDRefresh();
      this.RegisterToHUDManagerByTask(false);
    } else {
      if NotEquals(evt.newRole, IntEnum(1l)) && (Equals(evt.oldRole, IntEnum(1l)) || Equals(evt.oldRole, EGameplayRole.UnAssigned)) {
        if this.ShouldRegisterToHUD() {
          this.RegisterToHUDManagerByTask(true);
        };
      };
    };
  }

  public const func IsHackingPlayer() -> Bool {
    return false;
  }

  public const func IsQuickHackAble() -> Bool {
    return false;
  }

  public const func IsQuickHacksExposed() -> Bool {
    return false;
  }

  public const func IsBreached() -> Bool {
    return false;
  }

  public const func IsBackdoor() -> Bool {
    return false;
  }

  public const func IsActiveBackdoor() -> Bool {
    return false;
  }

  public const func IsBodyDisposalPossible() -> Bool {
    return false;
  }

  public const func IsControllingDevices() -> Bool {
    return false;
  }

  public const func HasAnySlaveDevices() -> Bool {
    return false;
  }

  public const func IsFastTravelPoint() -> Bool {
    return false;
  }

  public const func IsExplosive() -> Bool {
    return false;
  }

  public const func HasImportantInteraction() -> Bool {
    return false;
  }

  public const func HasAnyDirectInteractionActive() -> Bool {
    return false;
  }

  public const func ShouldEnableRemoteLayer() -> Bool {
    return false;
  }

  public const func IsTechie() -> Bool {
    return false;
  }

  public const func IsSolo() -> Bool {
    return false;
  }

  public const func IsNetrunner() -> Bool {
    return false;
  }

  public final const func IsAnyPlaystyleValid() -> Bool {
    return this.IsTechie() || this.IsSolo() || this.IsNetrunner();
  }

  public const func IsHackingSkillCheckActive() -> Bool {
    return false;
  }

  public const func IsDemolitionSkillCheckActive() -> Bool {
    return false;
  }

  public const func IsEngineeringSkillCheckActive() -> Bool {
    return false;
  }

  public const func CanPassEngineeringSkillCheck() -> Bool {
    return false;
  }

  public const func CanPassDemolitionSkillCheck() -> Bool {
    return false;
  }

  public const func CanPassHackingSkillCheck() -> Bool {
    return false;
  }

  public const func HasDirectActionsActive() -> Bool {
    return false;
  }

  public const func HasActiveDistraction() -> Bool {
    return false;
  }

  public const func HasActiveQuickHackUpload() -> Bool {
    return false;
  }

  public const func IsInvestigating() -> Bool {
    return false;
  }

  public const func IsInvestigatingObject(targetID: ref<GameObject>) -> Bool {
    return false;
  }

  public final const func IsTaggedinFocusMode() -> Bool {
    return GameInstance.GetVisionModeSystem(this.GetGame()).GetScanningController().IsTagged(this);
  }

  public const func IsQuest() -> Bool {
    return this.m_markAsQuest;
  }

  protected cb func OnSetAsQuestImportantEvent(evt: ref<SetAsQuestImportantEvent>) -> Bool {
    this.ToggleQuestImportance(evt.IsImportant());
  }

  protected final func ToggleQuestImportance(isImportant: Bool) -> Void {
    if NotEquals(this.IsQuest(), isImportant) {
      this.MarkAsQuest(isImportant);
      this.RequestHUDRefresh();
    };
  }

  protected func MarkAsQuest(isQuest: Bool) -> Void {
    this.m_markAsQuest = isQuest;
  }

  public final const func IsGrouppedClue() -> Bool {
    return IsDefined(this.m_scanningComponent) && this.m_scanningComponent.IsActiveClueLinked();
  }

  public final const func HasAnyClue() -> Bool {
    return IsDefined(this.m_scanningComponent) && this.m_scanningComponent.HasAnyClue();
  }

  public final const func IsClueInspected() -> Bool {
    return IsDefined(this.m_scanningComponent) && this.m_scanningComponent.IsClueInspected();
  }

  public final const func GetLinkedClueData(clueIndex: Int32) -> LinkedFocusClueData {
    let linkedClueData: LinkedFocusClueData;
    if this.m_scanningComponent != null {
      this.m_scanningComponent.GetLinkedClueData(clueIndex, linkedClueData);
    };
    return linkedClueData;
  }

  public final const func GetAvailableClueIndex() -> Int32 {
    if this.m_scanningComponent != null {
      return this.m_scanningComponent.GetAvailableClueIndex();
    };
    return -1;
  }

  protected final func PurgeScannerBlackboard() -> Void {
    let scannerBlackboard: wref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_ScannerModules);
    if IsDefined(scannerBlackboard) {
      scannerBlackboard.ClearAllFields(false);
    };
  }

  protected cb func OnlinkedClueTagEvent(evt: ref<linkedClueTagEvent>) -> Bool {
    if evt.tag {
      GameObject.TagObject(this);
    } else {
      GameObject.UntagObject(this);
    };
  }

  public const func CompileScannerChunks() -> Bool {
    let displayName: String;
    let hasValidDisplayName: Bool;
    let nameChunk: ref<ScannerName>;
    let scannerBlackboard: wref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_ScannerModules);
    if IsDefined(scannerBlackboard) {
      displayName = this.GetDisplayName();
      hasValidDisplayName = IsStringValid(displayName);
      if !hasValidDisplayName {
        displayName = "";
      };
      if hasValidDisplayName || IsDefined(this.m_scanningComponent) && (this.m_scanningComponent.IsAnyClueEnabled() || this.m_scanningComponent.HasValidObjectDescription()) {
        nameChunk = new ScannerName();
        nameChunk.Set(displayName);
        scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerName, ToVariant(nameChunk), true);
      };
      scannerBlackboard.SetInt(GetAllBlackboardDefs().UI_ScannerModules.ObjectType, EnumInt(ScannerObjectType.GENERIC), true);
      return true;
    };
    return false;
  }

  protected func FillObjectDescription(out arr: array<ScanningTooltipElementDef>) -> Void {
    let customDescriptionsIDS: array<TweakDBID>;
    let gameplayDescriptionID: TweakDBID;
    let i: Int32;
    let objectData: ScanningTooltipElementDef;
    let objectDescription: ref<ObjectScanningDescription> = this.m_scanningComponent.GetObjectDescription();
    if objectDescription == null {
      return;
    };
    customDescriptionsIDS = objectDescription.GetCustomDesriptions();
    gameplayDescriptionID = objectDescription.GetGameplayDesription();
    if TDBID.IsValid(gameplayDescriptionID) {
      objectData.recordID = gameplayDescriptionID;
      ArrayPush(arr, objectData);
    };
    if ArraySize(customDescriptionsIDS) != 0 {
      i = 0;
      while i < ArraySize(customDescriptionsIDS) {
        objectData.recordID = customDescriptionsIDS[i];
        ArrayPush(arr, objectData);
        i += 1;
      };
    };
  }

  public func GetScannableObjects() -> array<ScanningTooltipElementDef> {
    let arr: array<ScanningTooltipElementDef>;
    let clueIndex: Int32;
    let conclusionData: ScanningTooltipElementDef;
    if this.m_scanningComponent != null {
      clueIndex = this.m_scanningComponent.GetAvailableClueIndex();
      if clueIndex >= 0 {
        arr = this.m_scanningComponent.GetScannableDataForSingleClueByIndex(clueIndex, conclusionData);
        this.ResolveFocusClueExtendedDescription(clueIndex);
        this.ResolveFocusClueConclusion(clueIndex, conclusionData);
      };
      if this.m_scanningComponent.IsObjectDescriptionEnabled() {
        this.FillObjectDescription(arr);
      };
      if this.IsScannerDataDirty() {
        this.CompileScannerChunks();
        this.SetScannerDirty(false);
      };
    };
    return arr;
  }

  public const func ShouldShowScanner() -> Bool {
    if !IsDefined(this.m_scanningComponent) {
      return false;
    };
    if this.GetHudManager().IsBraindanceActive() && !this.m_scanningComponent.IsBraindanceClue() {
      return false;
    };
    if this.m_scanningComponent.IsBraindanceBlocked() || this.m_scanningComponent.IsPhotoModeBlocked() {
      return false;
    };
    if !this.m_scanningComponent.HasValidObjectDescription() && (!this.m_scanningComponent.IsAnyClueEnabled() || this.IsScaningCluesBlocked()) {
      return false;
    };
    return true;
  }

  public const func IsScaningCluesBlocked() -> Bool {
    if IsDefined(this.m_scanningComponent) {
      return this.m_scanningComponent.IsScanningCluesBlocked();
    };
    return false;
  }

  public final const func IsBraindanceBlocked() -> Bool {
    if IsDefined(this.m_scanningComponent) {
      return this.m_scanningComponent.IsBraindanceBlocked();
    };
    return false;
  }

  public final const func IsPhotoModeBlocked() -> Bool {
    return GameInstance.GetPhotoModeSystem(this.GetGame()).IsPhotoModeActive();
  }

  private final func ResolveFocusClueExtendedDescription(clueIndex: Int32) -> Void {
    let clueRecords: array<ClueRecordData>;
    let i: Int32;
    if this.m_scanningComponent != null {
      clueRecords = this.m_scanningComponent.GetExtendedClueRecords(clueIndex);
      i = 0;
      while i < ArraySize(clueRecords) {
        if !clueRecords[i].wasInspected && clueRecords[i].percentage >= this.m_scanningComponent.GetScanningProgress() {
          this.ResolveFacts(clueRecords[i].facts);
          this.m_scanningComponent.SetClueExtendedDescriptionAsInspected(clueIndex, i);
        };
        i += 1;
      };
    };
  }

  private final func ResolveFocusClueConclusion(clueIndex: Int32, conclusionData: ScanningTooltipElementDef) -> Void {
    let clue: FocusClueDefinition;
    if this.m_scanningComponent != null {
      if clueIndex < 0 {
        return;
      };
      if !TDBID.IsValid(conclusionData.recordID) {
        return;
      };
      if !this.m_scanningComponent.WasConclusionShown(clueIndex) && conclusionData.timePct >= this.m_scanningComponent.GetScanningProgress() {
        clue = this.m_scanningComponent.GetClueByIndex(clueIndex);
        this.ResolveFacts(clue.facts);
        this.m_scanningComponent.SetConclusionAsShown(clueIndex);
      };
    };
  }

  protected final func ResolveFacts(facts: array<SFactOperationData>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(facts) {
      if IsNameValid(facts[i].factName) {
        if Equals(facts[i].operationType, EMathOperationType.Add) {
          AddFact(this.GetGame(), facts[i].factName, facts[i].factValue);
        } else {
          SetFactValue(this.GetGame(), facts[i].factName, facts[i].factValue);
        };
      };
      i += 1;
    };
  }

  public final const func GetFocusClueSystem() -> ref<FocusCluesSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"FocusCluesSystem") as FocusCluesSystem;
  }

  public final const func IsAnyClueEnabled() -> Bool {
    if IsDefined(this.m_scanningComponent) {
      return this.m_scanningComponent.IsAnyClueEnabled();
    };
    return false;
  }

  protected final const func IsCurrentTarget() -> Bool {
    let lookedAtObect: ref<GameObject> = GameInstance.GetTargetingSystem(this.GetGame()).GetLookAtObject(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet);
    if lookedAtObect == null {
      return false;
    };
    return lookedAtObect.GetEntityID() == this.GetEntityID();
  }

  protected final const func IsCurrentlyScanned() -> Bool {
    let blackBoard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_Scanner);
    let entityID: EntityID = blackBoard.GetEntityID(GetAllBlackboardDefs().UI_Scanner.ScannedObject);
    return this.GetEntityID() == entityID;
  }

  public const func GetFreeWorkspotRefForAIAction(aiAction: gamedataWorkspotActionType) -> NodeRef {
    let worskpotRef: NodeRef;
    if this.m_workspotMapper != null {
      worskpotRef = this.m_workspotMapper.GetFreeWorkspotRefForAIAction(aiAction);
    };
    return worskpotRef;
  }

  public const func GetFreeWorkspotDataForAIAction(aiAction: gamedataWorkspotActionType) -> ref<WorkspotEntryData> {
    let worskpotData: ref<WorkspotEntryData>;
    if this.m_workspotMapper != null {
      worskpotData = this.m_workspotMapper.GetFreeWorkspotDataForAIAction(aiAction);
    };
    return worskpotData;
  }

  public const func HasFreeWorkspotForInvestigation() -> Bool {
    let worskpotData: ref<WorkspotEntryData>;
    if this.m_workspotMapper != null {
      worskpotData = this.m_workspotMapper.GetFreeWorkspotDataForAIAction(gamedataWorkspotActionType.DeviceInvestigation);
    };
    return worskpotData != null;
  }

  public const func GetFreeWorkspotsCountForAIAction(aiAction: gamedataWorkspotActionType) -> Int32 {
    let numberOfWorkspots: Int32;
    if this.m_workspotMapper != null {
      numberOfWorkspots = this.m_workspotMapper.GetFreeWorkspotsCountForAIAction(aiAction);
    };
    return numberOfWorkspots;
  }

  public const func GetNumberOfWorkpotsForAIAction(aiAction: gamedataWorkspotActionType) -> Int32 {
    let numberOfWorkspots: Int32;
    if this.m_workspotMapper != null {
      numberOfWorkspots = this.m_workspotMapper.GetNumberOfWorkpotsForAIAction(aiAction);
    };
    return numberOfWorkspots;
  }

  public final const func GetTotalCountOfInvestigationSlots() -> Int32 {
    let count: Int32 = this.GetNumberOfWorkpotsForAIAction(gamedataWorkspotActionType.DeviceInvestigation);
    if count == 0 {
      count = 1;
    };
    return count;
  }

  public final const func GetStimBroadcasterComponent() -> ref<StimBroadcasterComponent> {
    return this.m_stimBroadcaster;
  }

  public final native const func GetUISlotComponent() -> ref<SlotComponent>;

  public final const func GetSquadMemberComponent() -> ref<SquadMemberBaseComponent> {
    return this.m_squadMemberComponent;
  }

  public final const func GetStatusEffectComponent() -> ref<StatusEffectComponent> {
    return this.m_statusEffectComponent;
  }

  public final const func GetSourceShootComponent() -> ref<SourceShootComponent> {
    return this.m_sourceShootComponent;
  }

  public final const func GetTargetShootComponent() -> ref<TargetShootComponent> {
    return this.m_targetShootComponent;
  }

  public final native func ReplicateAnimFeature(obj: ref<GameObject>, inputName: CName, value: ref<AnimFeature>) -> Void;

  public final func OnAnimFeatureReplicated(inputName: CName, value: ref<AnimFeature>) -> Void {
    AnimationControllerComponent.ApplyFeature(this, inputName, value);
  }

  public final native func ReplicateAnimEvent(obj: ref<GameObject>, eventName: CName) -> Void;

  public final func OnAnimEventReplicated(eventName: CName) -> Void {
    AnimationControllerComponent.PushEvent(this, eventName);
  }

  public final native func ReplicateInputFloat(obj: ref<GameObject>, inputName: CName, value: Float) -> Void;

  public final native func ReplicateInputBool(obj: ref<GameObject>, inputName: CName, value: Bool) -> Void;

  public final native func ReplicateInputInt(obj: ref<GameObject>, inputName: CName, value: Int32) -> Void;

  public final native func ReplicateInputVector(obj: ref<GameObject>, inputName: CName, value: Vector4) -> Void;

  public const func GetPlaystyleMappinLocalPos() -> Vector4 {
    let pos: Vector4;
    return pos;
  }

  public const func GetPlaystyleMappinSlotWorldPos() -> Vector4 {
    return this.GetWorldPosition();
  }

  public const func GetPlaystyleMappinSlotWorldTransform() -> WorldTransform {
    let transform: WorldTransform;
    WorldTransform.SetPosition(transform, this.GetWorldPosition());
    WorldTransform.SetOrientation(transform, this.GetWorldOrientation());
    return transform;
  }

  public const func GetFxResourceByKey(key: CName) -> FxResource {
    let resource: FxResource;
    return resource;
  }

  protected cb func OnDelayPrereqEvent(evt: ref<DelayPrereqEvent>) -> Bool {
    evt.m_state.UpdatePrereq();
  }

  protected cb func OnTriggerAttackEffectorWithDelay(evt: ref<TriggerAttackEffectorWithDelay>) -> Bool {
    if IsDefined(evt.attack) {
      evt.attack.StartAttack();
    };
  }

  protected cb func OnToggleOffMeshConnections(evt: ref<ToggleOffMeshConnections>) -> Bool {
    if evt.enable {
      this.EnableOffMeshConnections(evt.affectsPlayer, evt.affectsNPCs);
    } else {
      this.DisableOffMeshConnections(evt.affectsPlayer, evt.affectsNPCs);
    };
  }

  protected func EnableOffMeshConnections(player: Bool, npc: Bool) -> Void;

  protected func DisableOffMeshConnections(player: Bool, npc: Bool) -> Void;

  protected cb func OnPhysicalDestructionEvent(evt: ref<PhysicalDestructionEvent>) -> Bool {
    if IsDefined(this.m_stimBroadcaster) {
      this.m_stimBroadcaster.TriggerSingleBroadcast(this, gamedataStimType.SoundDistraction);
    };
  }

  public final const func GetHudManager() -> ref<HUDManager> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"HUDManager") as HUDManager;
  }

  protected final func TriggerMenuEvent(eventName: CName) -> Void {
    let currentEventName: CName;
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().MenuEventBlackboard);
    if IsDefined(blackboard) {
      currentEventName = blackboard.GetName(GetAllBlackboardDefs().MenuEventBlackboard.MenuEventToTrigger);
      if IsNameValid(currentEventName) {
        blackboard.SetName(GetAllBlackboardDefs().MenuEventBlackboard.MenuEventToTrigger, n"");
      };
      blackboard.SetName(GetAllBlackboardDefs().MenuEventBlackboard.MenuEventToTrigger, eventName);
    };
  }

  public const func GetAcousticQuerryStartPoint() -> Vector4 {
    return this.GetWorldPosition();
  }

  public const func CanBeInvestigated() -> Bool {
    return true;
  }

  public final static func IsVehicle(object: wref<GameObject>) -> Bool {
    return (object as VehicleObject) != null;
  }

  public final const func GetPreventionSystem() -> ref<PreventionSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"PreventionSystem") as PreventionSystem;
  }

  public const func GetLootQuality() -> gamedataQuality {
    return gamedataQuality.Invalid;
  }

  public const func GetIsIconic() -> Bool {
    return false;
  }

  public final const func GetAnimationSystemForcedVisibilityManager() -> ref<AnimationSystemForcedVisibilityManager> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"AnimationSystemForcedVisibilityManager") as AnimationSystemForcedVisibilityManager;
  }

  public final static func ToggleForcedVisibilityInAnimSystemEvent(owner: ref<GameObject>, sourceName: CName, isVisibe: Bool, opt transitionTime: Float) -> Void {
    let evt: ref<ToggleVisibilityInAnimSystemEvent>;
    if owner == null || !IsNameValid(sourceName) {
      return;
    };
    evt = new ToggleVisibilityInAnimSystemEvent();
    evt.isVisible = isVisibe;
    evt.sourceName = sourceName;
    evt.transitionTime = transitionTime;
    owner.QueueEvent(evt);
  }

  protected final func ToggleForcedVisibilityInAnimSystem(sourceName: CName, isVisibe: Bool, opt transitionTime: Float, opt entityID: EntityID, opt forcedVisibleOnlyInFrustum: Bool) -> Void {
    let request: ref<ToggleVisibilityInAnimSystemRequest>;
    if !IsNameValid(sourceName) {
      return;
    };
    request = new ToggleVisibilityInAnimSystemRequest();
    request.isVisible = isVisibe;
    request.sourceName = sourceName;
    request.transitionTime = transitionTime;
    request.forcedVisibleOnlyInFrustum = forcedVisibleOnlyInFrustum;
    if EntityID.IsDefined(entityID) {
      request.entityID = entityID;
    } else {
      request.entityID = this.GetEntityID();
    };
    this.m_hasVisibilityForcedInAnimSystem = isVisibe;
    this.GetAnimationSystemForcedVisibilityManager().QueueRequest(request);
  }

  protected final func ClearForcedVisibilityInAnimSystem() -> Void {
    let request: ref<ClearVisibilityInAnimSystemRequest> = new ClearVisibilityInAnimSystemRequest();
    request.entityID = this.GetEntityID();
    this.GetAnimationSystemForcedVisibilityManager().QueueRequest(request);
    this.m_hasVisibilityForcedInAnimSystem = false;
  }

  protected final func HasVisibilityForcedInAnimSystem() -> Bool {
    return this.m_hasVisibilityForcedInAnimSystem || this.GetAnimationSystemForcedVisibilityManager().HasVisibilityForced(this.GetEntityID());
  }

  protected cb func OnToggleVisibilityInAnimSystemEvent(evt: ref<ToggleVisibilityInAnimSystemEvent>) -> Bool {
    this.ToggleForcedVisibilityInAnimSystem(evt.sourceName, evt.isVisible, evt.transitionTime);
  }

  protected cb func OnSetGlitchOnUIEvent(evt: ref<SetGlitchOnUIEvent>) -> Bool {
    let glitchEvt: ref<AdvertGlitchEvent> = new AdvertGlitchEvent();
    glitchEvt.SetShouldGlitch(evt.intensity);
    this.QueueEvent(glitchEvt);
  }

  protected cb func OnCustomUIAnimationEvent(evt: ref<CustomUIAnimationEvent>) -> Bool {
    evt.ownerID = this.GetEntityID();
    GameInstance.GetUISystem(this.GetGame()).QueueEvent(evt);
  }

  protected cb func OnSmartGunLockEvent(evt: ref<SmartGunLockEvent>) -> Bool {
    if evt.lockedOnByPlayer {
      this.SendForceRevealObjectEvent(evt.locked, n"SmartGunLock");
    };
  }
}

public static func OperatorAdd(s: String, o: ref<GameObject>) -> String {
  return s + o.GetDisplayName();
}

public static func OperatorAdd(o: ref<GameObject>, s: String) -> String {
  return o.GetDisplayName() + s;
}
