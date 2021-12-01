
public class PingCachedData extends IScriptable {

  public let m_sourceID: EntityID;

  public let m_pingType: EPingType;

  public let m_pingNetworkEffect: ref<EffectInstance>;

  public let m_timeout: Float;

  public let m_ammountOfIntervals: Int32;

  public let m_linksCount: Int32;

  @default(PingCachedData, 1)
  public let m_currentInterval: Int32;

  public let m_delayID: DelayID;

  @default(PingCachedData, ELinkType.FREE)
  public let m_linkType: ELinkType;

  public let m_revealNetwork: Bool;

  public let m_linkFXresource: FxResource;

  public let m_sourcePosition: Vector4;

  public let m_hasActiveVirtualNetwork: Bool;

  public let m_virtualNetworkShape: wref<VirtualNetwork_Record>;

  public final func Initialize(sourceID: EntityID, timeout: Float, ammountOfIntervals: Int32, pingType: EPingType, gameEffect: ref<EffectInstance>, revealNetworkAtEnd: Bool, fxResource: FxResource, position: Vector4, virtualNetworkShapeID: TweakDBID) -> Void {
    this.m_timeout = timeout;
    this.m_ammountOfIntervals = ammountOfIntervals;
    this.m_currentInterval = ammountOfIntervals;
    this.m_linksCount = 0;
    this.m_sourceID = sourceID;
    this.m_pingType = pingType;
    this.m_revealNetwork = revealNetworkAtEnd;
    this.m_linkFXresource = fxResource;
    this.m_sourcePosition = position;
    this.m_virtualNetworkShape = TweakDBInterface.GetVirtualNetworkRecord(virtualNetworkShapeID);
  }

  public final func Initialize(timeout: Float, ammountOfIntervals: Int32) -> Void {
    this.m_timeout = timeout;
    this.m_ammountOfIntervals = ammountOfIntervals;
    this.m_currentInterval = ammountOfIntervals;
    this.m_linksCount = 0;
  }

  public final func IncrementLinkCounter() -> Void {
    this.m_linksCount += 1;
  }

  public final func GetLifetimeValue() -> Float {
    let lifetime: Float = RandRangeF(this.GetCurrentMinValue(), this.GetCurrentMaxValue());
    this.UpdateCurrentInterval();
    return lifetime;
  }

  private final func UpdateCurrentInterval() -> Void {
    if this.m_currentInterval == 1 {
      this.m_currentInterval = this.m_ammountOfIntervals;
    } else {
      this.m_currentInterval -= 1;
    };
  }

  private final func GetCurrentMaxValue() -> Float {
    return this.m_timeout / Cast(this.m_ammountOfIntervals) * Cast(this.m_currentInterval);
  }

  private final func GetCurrentMinValue() -> Float {
    let value: Float = this.GetCurrentMaxValue() - this.m_timeout / Cast(this.m_ammountOfIntervals);
    if this.m_currentInterval == 1 {
      value = value + (this.m_timeout / Cast(this.m_ammountOfIntervals)) / Cast(this.m_ammountOfIntervals);
    };
    return value;
  }
}

public class NetworkSystem extends ScriptableSystem {

  private let m_networkLinks: array<SNetworkLinkData>;

  private let m_networkRevealTargets: array<EntityID>;

  private let m_sessionStarted: Bool;

  private let m_visionModeChangedCallback: ref<CallbackHandle>;

  private let m_focusModeToggleCallback: ref<CallbackHandle>;

  private let m_playerSpawnCallback: Uint32;

  private let m_currentPlayerTargetCallbackID: ref<CallbackHandle>;

  private let m_lastTargetSlaveID: EntityID;

  private let m_lastTargetMasterID: EntityID;

  private let m_unregisterLinksRequestDelay: DelayID;

  private let m_focusModeActive: Bool;

  private let m_lastBeamResource: FxResource;

  private let m_pingNetworkEffect: ref<EffectInstance>;

  private let m_pingCachedData: ref<PingCachedData>;

  private let m_lastPingSourceID: EntityID;

  private let m_activePings: array<ref<PingCachedData>>;

  private let m_pingedSquads: array<CName>;

  private let m_pingLinksCounter: Int32;

  private let m_networkPresetTBDID: TweakDBID;

  private let m_networkPresetRecord: wref<NetworkPingingParameteres_Record>;

  private let m_backdoors: array<PersistentID>;

  private let m_revealedBackdoorsCount: Int32;

  private let m_debugCashedPingFxResource: FxResource;

  private let m_debugQueryNumber: Int32;

  private let m_activateLinksDelayID: DelayID;

  private let m_deactivateLinksDelayID: DelayID;

  protected final func ActivateNetworkLinkByTask(linkIndex: Int32) -> Void {
    let taskData: ref<ActivateNetworkLinkTaskData> = new ActivateNetworkLinkTaskData();
    taskData.linkIndex = linkIndex;
    GameInstance.GetDelaySystem(this.GetGameInstance()).QueueTask(this, taskData, n"ActivateNetworkLinkTask", gameScriptTaskExecutionStage.Any);
  }

  protected final func ActivateNetworkLinkTask(data: ref<ScriptTaskData>) -> Void {
    let taskData: ref<ActivateNetworkLinkTaskData> = data as ActivateNetworkLinkTaskData;
    if IsDefined(taskData) {
      this.ActivateNetworkLinkByIndex(taskData.linkIndex);
    };
  }

  protected final func DeactivateNetworkLinkByTask(linkIndex: Int32, instant: Bool) -> Void {
    let taskData: ref<DeactivateNetworkLinkTaskData> = new DeactivateNetworkLinkTaskData();
    taskData.linkIndex = linkIndex;
    taskData.instant = instant;
    GameInstance.GetDelaySystem(this.GetGameInstance()).QueueTask(this, taskData, n"DeactivateNetworkLinkTask", gameScriptTaskExecutionStage.Any);
  }

  protected final func DeactivateNetworkLinkTask(data: ref<ScriptTaskData>) -> Void {
    let taskData: ref<DeactivateNetworkLinkTaskData> = data as DeactivateNetworkLinkTaskData;
    if IsDefined(taskData) {
      this.KillNetworkBeam(taskData.linkIndex, taskData.instant);
    };
  }

  private func OnAttach() -> Void {
    this.RegisterPlayerSpawnedCallback();
    this.RegisterFocusModeCallback();
    this.RegisterPlayerTargetCallback();
    this.m_networkPresetTBDID = t"Network.ActiveNetworkPresets";
    this.SetupPingPresetRecord();
  }

  private func OnDetach() -> Void {
    this.UnregisterFocusModeCallback();
    this.UnregisterPlayerTargetCallback();
    this.UnregisterPlayerSpawnedCallback();
  }

  protected final func GetPlayerStateMachineBlackboard(playerPuppet: wref<GameObject>) -> ref<IBlackboard> {
    let blackboard: ref<IBlackboard>;
    if playerPuppet != null {
      blackboard = GameInstance.GetBlackboardSystem(this.GetGameInstance()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    };
    return blackboard;
  }

  private final func OnPlayerSpawnedCallback(playerPuppet: ref<GameObject>) -> Void {
    if IsDefined(this.m_visionModeChangedCallback) {
      this.UnregisterVisionModeCallback();
    };
    this.RegisterVisionModeCallback(playerPuppet);
  }

  protected final func RegisterPlayerSpawnedCallback() -> Void {
    if this.m_playerSpawnCallback == 0u {
      this.m_playerSpawnCallback = GameInstance.GetPlayerSystem(this.GetGameInstance()).RegisterPlayerPuppetAttachedCallback(this, n"OnPlayerSpawnedCallback");
    };
  }

  protected final func RegisterVisionModeCallback(player: ref<GameObject>) -> Void {
    let blackboard: ref<IBlackboard>;
    if player != null {
      blackboard = this.GetPlayerStateMachineBlackboard(player);
      if IsDefined(blackboard) && !IsDefined(this.m_visionModeChangedCallback) {
        this.m_visionModeChangedCallback = blackboard.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Vision, this, n"OnVisionModeChanged");
      };
    };
  }

  protected final func RegisterFocusModeCallback() -> Void {
    let blackBoard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_VisionMode);
    if IsDefined(blackBoard) && !IsDefined(this.m_focusModeToggleCallback) {
      this.m_focusModeToggleCallback = blackBoard.RegisterListenerBool(GetAllBlackboardDefs().UI_VisionMode.isEnabled, this, n"OnFocusModeToggle");
    };
  }

  protected final func RegisterPlayerTargetCallback() -> Void {
    let blackBoard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_Scanner);
    if IsDefined(blackBoard) && !IsDefined(this.m_currentPlayerTargetCallbackID) {
      this.m_currentPlayerTargetCallbackID = blackBoard.RegisterListenerEntityID(GetAllBlackboardDefs().UI_Scanner.ScannedObject, this, n"OnPlayerTargetChanged");
    };
  }

  protected final func UnregisterVisionModeCallback() -> Void {
    let blackBoard: ref<IBlackboard>;
    let playerControlledObject: ref<GameObject> = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject();
    if playerControlledObject != null {
      blackBoard = this.GetPlayerStateMachineBlackboard(playerControlledObject);
      if blackBoard != null && IsDefined(this.m_visionModeChangedCallback) {
        blackBoard.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Vision, this.m_visionModeChangedCallback);
      };
    };
  }

  protected final func UnregisterFocusModeCallback() -> Void {
    let blackBoard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_VisionMode);
    if blackBoard != null && IsDefined(this.m_focusModeToggleCallback) {
      blackBoard.UnregisterListenerBool(GetAllBlackboardDefs().UI_VisionMode.isEnabled, this.m_focusModeToggleCallback);
    };
  }

  protected final func UnregisterPlayerTargetCallback() -> Void {
    let blackBoard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_TargetingInfo);
    if blackBoard != null && IsDefined(this.m_currentPlayerTargetCallbackID) {
      blackBoard.UnregisterListenerEntityID(GetAllBlackboardDefs().UI_TargetingInfo.CurrentVisibleTarget, this.m_currentPlayerTargetCallbackID);
    };
  }

  protected final func UnregisterPlayerSpawnedCallback() -> Void {
    if Cast(this.m_playerSpawnCallback) {
      GameInstance.GetPlayerSystem(this.GetGameInstance()).UnregisterPlayerPuppetAttachedCallback(this.m_playerSpawnCallback);
    };
  }

  private final func AddNetworkLink(linkData: SNetworkLinkData) -> Void {
    if FxResource.IsValid(linkData.fxResource) {
      this.m_lastBeamResource = linkData.fxResource;
    };
    linkData.priority = this.DeterminNetworkLinkPriority(linkData);
    ArrayPush(this.m_networkLinks, linkData);
  }

  private final func DeterminNetworkLinkPriority(linkData: SNetworkLinkData) -> EPriority {
    switch linkData.linkType {
      case ELinkType.NETWORK:
        if linkData.isPing {
          return EPriority.Medium;
        };
        return EPriority.Absolute;
      case ELinkType.GRID:
        if linkData.isPing {
          return EPriority.Low;
        };
        return EPriority.VeryHigh;
      case ELinkType.FREE:
        if linkData.isPing {
          return EPriority.VeryLow;
        };
        return EPriority.High;
      default:
        return EPriority.VeryLow;
    };
  }

  private final func RemoveNetworkLinksByID(ID: EntityID) -> Void {
    let i: Int32 = ArraySize(this.m_networkLinks) - 1;
    while i >= 0 {
      if this.m_networkLinks[i].slaveID == ID || this.m_networkLinks[i].masterID == ID {
        this.KillNetworkBeam(i, false);
        ArrayErase(this.m_networkLinks, i);
      };
      i -= 1;
    };
  }

  private final func RemoveNetworkLinksBetweenTwoEntitities(firstID: EntityID, secondID: EntityID, onlyRemoveWeakLink: Bool) -> Void {
    let i: Int32 = ArraySize(this.m_networkLinks) - 1;
    while i >= 0 {
      if this.m_networkLinks[i].slaveID == firstID || this.m_networkLinks[i].masterID == secondID || this.m_networkLinks[i].slaveID == secondID || this.m_networkLinks[i].masterID == firstID {
        if !onlyRemoveWeakLink || this.m_networkLinks[i].weakLink {
          this.KillNetworkBeam(i, false);
          ArrayErase(this.m_networkLinks, i);
        };
      };
      i -= 1;
    };
  }

  private final func RemoveNetworkLinkByData(linkData: SNetworkLinkData) -> Void {
    let instant: Bool;
    let targets: array<EntityID>;
    let i: Int32 = ArraySize(this.m_networkLinks) - 1;
    while i >= 0 {
      if Equals(this.m_networkLinks[i].linkType, linkData.linkType) && this.m_networkLinks[i].slaveID == linkData.slaveID && this.m_networkLinks[i].masterID == linkData.masterID && Equals(this.m_networkLinks[i].slavePos, linkData.slavePos) && Equals(this.m_networkLinks[i].masterPos, linkData.masterPos) {
        if linkData.lifetime > 0.00 {
          if Equals(linkData.linkType, ELinkType.NETWORK) && linkData.isPing {
            ArrayPush(targets, linkData.masterID);
            ArrayPush(targets, linkData.slaveID);
          };
          instant = false;
        };
        this.RemoveNetworkLink(i, instant);
      };
      i -= 1;
    };
    this.RevealNetworkOnCachedTarget(targets);
  }

  private final func RemoveNetworkLinkByType(linkType: ELinkType) -> Void {
    let i: Int32 = ArraySize(this.m_networkLinks) - 1;
    while i >= 0 {
      if Equals(this.m_networkLinks[i].linkType, linkType) {
        this.RemoveNetworkLink(i, false);
      };
      i -= 1;
    };
  }

  private final func RemoveNetworkLinkByIdAndType(linkType: ELinkType, ID: EntityID) -> Void {
    let i: Int32 = ArraySize(this.m_networkLinks) - 1;
    while i >= 0 {
      if Equals(this.m_networkLinks[i].linkType, linkType) && (this.m_networkLinks[i].slaveID == ID || this.m_networkLinks[i].masterID == ID) {
        this.RemoveNetworkLink(i, false);
      };
      i -= 1;
    };
  }

  private final func RemoveNetworkLink(index: Int32, instant: Bool) -> Void {
    if index < 0 || index >= ArraySize(this.m_networkLinks) {
      return;
    };
    if this.m_networkLinks[index].lifetime > 0.00 {
      this.CancelNetworkLinkDelay(this.m_networkLinks[index]);
    };
    this.KillNetworkBeam(index, instant);
    ArrayErase(this.m_networkLinks, index);
  }

  private final func UnregisterNetworkLinkWithDelay(linkData: SNetworkLinkData) -> DelayID {
    let unregisterReq: ref<UnregisterNetworkLinkRequest> = new UnregisterNetworkLinkRequest();
    ArrayPush(unregisterReq.linksData, linkData);
    unregisterReq.linksData[0].delayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(this.GetClassName(), unregisterReq, linkData.lifetime, false);
    return unregisterReq.linksData[0].delayID;
  }

  private final func RegisterNetworkLinkWithDelay(linkData: SNetworkLinkData, delay: Float) -> Void {
    let registerReq: ref<RegisterNetworkLinkRequest> = new RegisterNetworkLinkRequest();
    ArrayPush(registerReq.linksData, linkData);
    GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(this.GetClassName(), registerReq, delay, false);
  }

  public final const func HasNetworkLink(linkData: SNetworkLinkData, out index: Int32) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_networkLinks) {
      if Equals(linkData.slavePos, this.m_networkLinks[i].slavePos) && Equals(linkData.masterPos, this.m_networkLinks[i].masterPos) && linkData.slaveID == this.m_networkLinks[i].slaveID && linkData.masterID == this.m_networkLinks[i].masterID && Equals(linkData.linkType, this.m_networkLinks[i].linkType) && Equals(linkData.isPing, this.m_networkLinks[i].isPing) {
        index = i;
        return true;
      };
      i += 1;
    };
    index = -1;
    return false;
  }

  public final const func HasNetworkLink(linkData: SNetworkLinkData) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_networkLinks) {
      if Equals(linkData.slavePos, this.m_networkLinks[i].slavePos) && Equals(linkData.masterPos, this.m_networkLinks[i].masterPos) && linkData.slaveID == this.m_networkLinks[i].slaveID && linkData.masterID == this.m_networkLinks[i].masterID && Equals(linkData.linkType, this.m_networkLinks[i].linkType) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func UpdateNetworkLinkData(linkData: SNetworkLinkData, indexToUpdate: Int32) -> Void {
    if !FxResource.IsValid(linkData.fxResource) {
      return;
    };
    if !this.CompareLinksData(linkData, this.m_networkLinks[indexToUpdate]) {
      this.CancelNetworkLinkDelay(this.m_networkLinks[indexToUpdate]);
      this.KillNetworkBeam(indexToUpdate, true);
      linkData.priority = this.DeterminNetworkLinkPriority(linkData);
      if linkData.lifetime > 0.00 {
        linkData.delayID = this.UnregisterNetworkLinkWithDelay(linkData);
      };
      this.m_networkLinks[indexToUpdate] = linkData;
    };
  }

  private final func CancelNetworkLinkDelay(linkData: SNetworkLinkData) -> Void {
    let invalidDealyID: DelayID;
    if linkData.lifetime > 0.00 && linkData.delayID != invalidDealyID {
      GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(linkData.delayID);
    };
  }

  private final const func CompareLinks(linkData1: SNetworkLinkData, linkData2: SNetworkLinkData) -> Bool {
    return linkData1.slaveID == linkData2.slaveID && linkData1.masterID == linkData2.masterID && Equals(linkData1.linkType, linkData2.linkType) && Equals(linkData1.fxResource, linkData2.fxResource) && Equals(linkData1.isDynamic, linkData2.isDynamic) && Equals(linkData1.drawLink, linkData2.drawLink) && Equals(linkData1.isPing, linkData2.isPing) && Equals(linkData1.revealSlave, linkData2.revealSlave) && Equals(linkData1.revealMaster, linkData2.revealMaster);
  }

  private final const func CompareLinksData(linkData1: SNetworkLinkData, linkData2: SNetworkLinkData) -> Bool {
    return Equals(linkData1.fxResource, linkData2.fxResource) && Equals(linkData1.isDynamic, linkData2.isDynamic) && Equals(linkData1.drawLink, linkData2.drawLink) && Equals(linkData1.isPing, linkData2.isPing) && Equals(linkData1.revealSlave, linkData2.revealSlave) && Equals(linkData1.revealMaster, linkData2.revealMaster);
  }

  public final const func HasNetworkLinkWithHigherPriority(linkData: SNetworkLinkData) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_networkLinks) {
      if Equals(linkData.slavePos, this.m_networkLinks[i].slavePos) && Equals(linkData.masterPos, this.m_networkLinks[i].masterPos) && linkData.slaveID == this.m_networkLinks[i].slaveID && linkData.masterID == this.m_networkLinks[i].masterID {
        if EnumInt(this.m_networkLinks[i].priority) > EnumInt(linkData.priority) {
          return true;
        };
      };
      i += 1;
    };
    return false;
  }

  public final const func HasNetworkLink(ID: EntityID) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_networkLinks) {
      if ID == this.m_networkLinks[i].slaveID || ID == this.m_networkLinks[i].masterID {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func HasNetworkLink(ID: EntityID, ignorePingLinks: Bool) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_networkLinks) {
      if ignorePingLinks && this.m_networkLinks[i].isPing {
      } else {
        if ID == this.m_networkLinks[i].slaveID || ID == this.m_networkLinks[i].masterID {
          return true;
        };
      };
      i += 1;
    };
    return false;
  }

  public final const func HasNetworkLink(masterID: EntityID, slaveID: EntityID, linkType: ELinkType) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_networkLinks) {
      if slaveID == this.m_networkLinks[i].slaveID && masterID == this.m_networkLinks[i].masterID && Equals(this.m_networkLinks[i].linkType, linkType) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func HasAnyActiveNetworkLink(ID: EntityID) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_networkLinks) {
      if ID == this.m_networkLinks[i].slaveID || ID == this.m_networkLinks[i].masterID {
        if this.m_networkLinks[i].isActive {
          return true;
        };
      };
      i += 1;
    };
    return false;
  }

  private final func GetNetworkBeam(linkData: SNetworkLinkData) -> ref<FxInstance> {
    let i: Int32 = 0;
    while i < ArraySize(this.m_networkLinks) {
      if Equals(linkData.slavePos, this.m_networkLinks[i].slavePos) && Equals(linkData.masterPos, this.m_networkLinks[i].masterPos) && linkData.slaveID == this.m_networkLinks[i].slaveID && linkData.masterID == this.m_networkLinks[i].masterID {
        if this.m_networkLinks[i].beam != null {
          return this.m_networkLinks[i].beam;
        };
      };
      i += 1;
    };
    return null;
  }

  private final func OnNewBackdoorDeviceRequest(request: ref<NewBackdoorDeviceRequest>) -> Void {
    if !ArrayContains(this.m_backdoors, request.device.GetID()) {
      ArrayPush(this.m_backdoors, request.device.GetID());
    };
  }

  private final func OnMarkBackdoorAsRevealedRequest(request: ref<MarkBackdoorAsRevealedRequest>) -> Void {
    if ArraySize(this.m_backdoors) > 0 && ArrayContains(this.m_backdoors, request.device.GetID()) {
      this.m_revealedBackdoorsCount += 1;
    };
  }

  private final func OnUnregisterAllNetworkLinksRequest(request: ref<UnregisterAllNetworkLinksRequest>) -> Void {
    this.ResolveNetworkSystemCleanupDelay();
    this.CleanNetwork();
  }

  private final func OnDeactivateAllNetworkLinksRequest(request: ref<DeactivateAllNetworkLinksRequest>) -> Void {
    this.KillAllNetworkBeams();
    ArrayClear(this.m_networkLinks);
  }

  private final func KillAllNetworkBeams() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_networkLinks) {
      this.KillNetworkBeam(i, false);
      i += 1;
    };
  }

  private final func ResolveNetworkSystemCleanupDelay() -> Void {
    let defaultDelay: DelayID;
    if this.m_unregisterLinksRequestDelay != defaultDelay {
      GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_unregisterLinksRequestDelay);
      GameInstance.GetDelaySystem(this.GetGameInstance()).CancelCallback(this.m_unregisterLinksRequestDelay);
      this.m_unregisterLinksRequestDelay = defaultDelay;
    };
  }

  private final func CleanNetwork() -> Void {
    let invalidID: EntityID;
    this.m_lastTargetMasterID = invalidID;
    this.m_lastTargetSlaveID = invalidID;
    this.m_sessionStarted = false;
    let i: Int32 = ArraySize(this.m_networkLinks) - 1;
    while i >= 0 {
      if this.m_networkLinks[i].permanent {
      } else {
        this.KillNetworkBeam(i, false);
        if !this.IsTagged(this.m_networkLinks[i].masterID) && !this.IsTagged(this.m_networkLinks[i].slaveID) {
          ArrayErase(this.m_networkLinks, i);
        };
      };
      i -= 1;
    };
  }

  private final func RemoveAllNetworkLinks() -> Void {
    this.KillAllNetworkBeams();
    ArrayClear(this.m_networkLinks);
  }

  private final func OnUnregisterNetworkLinksByIDRequest(request: ref<UnregisterNetworkLinksByIDRequest>) -> Void {
    this.RemoveNetworkLinksByID(request.ID);
  }

  private final func OnUnregisterNetworkLinksByIdAndTypeRequest(request: ref<UnregisterNetworkLinksByIdAndTypeRequest>) -> Void {
    this.RemoveNetworkLinkByIdAndType(request.type, request.ID);
  }

  private final func OnUnregisterNetworkLinkRequest(request: ref<UnregisterNetworkLinkRequest>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(request.linksData) {
      this.RemoveNetworkLinkByData(request.linksData[i]);
      i += 1;
    };
  }

  private final func OnUnregisterNetworkLinkBetweenTwoEntitiesRequest(request: ref<UnregisterNetworkLinkBetweenTwoEntitiesRequest>) -> Void {
    this.RemoveNetworkLinksBetweenTwoEntitities(request.firstID, request.secondID, request.onlyRemoveWeakLink);
  }

  private final func KillNetworkBeamsByID(ID: EntityID) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_networkLinks) {
      if this.m_networkLinks[i].slaveID == ID || this.m_networkLinks[i].masterID == ID {
        this.KillNetworkBeam(i, false);
      };
      i += 1;
    };
  }

  private final func KillNetworkBeamByIndex(index: Int32) -> Void {
    this.KillNetworkBeam(index, false);
  }

  private final func KillNetworkBeamsByID(slaveID: EntityID, masterID: EntityID) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_networkLinks) {
      if this.m_networkLinks[i].slaveID == slaveID && this.m_networkLinks[i].masterID == masterID {
        this.KillNetworkBeam(i, false);
      };
      i += 1;
    };
  }

  private final func KillNetworkBeamByData(linkData: SNetworkLinkData) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_networkLinks) {
      if Equals(this.m_networkLinks[i].linkType, linkData.linkType) && this.m_networkLinks[i].slaveID == linkData.slaveID && this.m_networkLinks[i].masterID == linkData.masterID {
        this.KillNetworkBeam(i, false);
        return;
      };
      i += 1;
    };
  }

  private final func KillNetworkBeam(index: Int32, instant: Bool) -> Void {
    if index < 0 || index >= ArraySize(this.m_networkLinks) {
      return;
    };
    if this.ShouldForceInstantBeamKill() {
      instant = true;
    };
    if this.m_networkLinks[index].beam != null {
      if instant {
        this.m_networkLinks[index].beam.Kill();
      } else {
        this.m_networkLinks[index].beam.BreakLoop();
      };
      this.m_networkLinks[index].beam = null;
      if this.m_networkLinks[index].isPing {
        this.DecreasePingLinbksCounter();
      };
    };
    this.ResolveConnectionHighlight(false, this.m_networkLinks[index]);
    this.m_networkLinks[index].isActive = false;
  }

  private final func OnRegisterNetworkLinkRequest(request: ref<RegisterNetworkLinkRequest>) -> Void {
    let excessLnks: array<SNetworkLinkData>;
    let requestToSend: ref<RegisterNetworkLinkRequest>;
    let totalIinks: Int32;
    let i: Int32 = 0;
    while i < ArraySize(request.linksData) {
      if totalIinks > NetworkSystem.GetMaxLinksRegisteredAtOnce() {
        ArrayPush(excessLnks, request.linksData[i]);
      } else {
        this.RegisterNetworkLink(request.linksData[i]);
      };
      totalIinks += 1;
      i += 1;
    };
    if ArraySize(excessLnks) > 0 {
      requestToSend = new RegisterNetworkLinkRequest();
      requestToSend.linksData = excessLnks;
      GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequestNextFrame(this.GetClassName(), requestToSend);
    } else {
      this.UpdateNetworkVisualisation();
    };
  }

  private final func RegisterNetworkLink(linkData: SNetworkLinkData) -> Void {
    let currentTarget: EntityID;
    let evaluateTargets: Bool;
    let indexToUpdate: Int32;
    if !this.HasNetworkLink(linkData, indexToUpdate) {
      if linkData.lifetime > 0.00 {
        linkData.delayID = this.UnregisterNetworkLinkWithDelay(linkData);
        if Equals(linkData.linkType, ELinkType.NETWORK) && linkData.isPing {
          this.ResolveNetworkRevealTarget(linkData);
        };
      };
      this.AddNetworkLink(linkData);
      if !linkData.isPing && NotEquals(linkData.linkType, ELinkType.FREE) {
        currentTarget = this.GetCurrentTargetID();
        if currentTarget == linkData.slaveID {
          this.m_lastTargetSlaveID = currentTarget;
          evaluateTargets = true;
        } else {
          if currentTarget == linkData.masterID {
            this.m_lastTargetMasterID = currentTarget;
            evaluateTargets = true;
          };
        };
        if evaluateTargets {
          this.EvaluatelastTargets(currentTarget);
        };
      };
    } else {
      if indexToUpdate >= 0 {
        this.UpdateNetworkLinkData(linkData, indexToUpdate);
      };
    };
  }

  private final func OnUpdateNetworkVisualisationRequest(request: ref<UpdateNetworkVisualisationRequest>) -> Void {
    this.UpdateNetworkVisualisation();
  }

  private final func UpdateNetworkVisualisation() -> Void {
    let i: Int32;
    let toActivate: array<Int32>;
    let toDeactivate: array<Int32>;
    let hasContext: Bool = this.IsCurrentTargetValid();
    if this.m_activateLinksDelayID != GetInvalidDelayID() {
      GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_activateLinksDelayID);
      this.m_activateLinksDelayID = GetInvalidDelayID();
    };
    if this.m_deactivateLinksDelayID != GetInvalidDelayID() {
      GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_deactivateLinksDelayID);
      this.m_deactivateLinksDelayID = GetInvalidDelayID();
    };
    i = 0;
    while i < ArraySize(this.m_networkLinks) {
      if this.HasNetworkLinkWithHigherPriority(this.m_networkLinks[i]) {
        ArrayPush(toDeactivate, i);
      } else {
        if this.m_networkLinks[i].isPing {
          ArrayPush(toActivate, i);
        } else {
          if this.m_networkLinks[i].isNetrunner && this.m_focusModeActive {
            ArrayPush(toActivate, i);
          } else {
            if this.m_networkLinks[i].isNetrunner && !this.m_focusModeActive {
              ArrayPush(toDeactivate, i);
            } else {
              if hasContext {
                if this.IsCurrentTarget(this.m_networkLinks[i].slaveID) {
                  ArrayPush(toActivate, i);
                } else {
                  if this.ShouldShowLinksOnMaster() && this.IsCurrentTarget(this.m_networkLinks[i].masterID) {
                    ArrayPush(toActivate, i);
                  } else {
                    if this.m_networkLinks[i].isActive {
                      ArrayPush(toDeactivate, i);
                    };
                  };
                };
              } else {
                if this.IsLastSlaveTarget(this.m_networkLinks[i].slaveID) || this.IsTagged(this.m_networkLinks[i].slaveID) {
                  ArrayPush(toActivate, i);
                } else {
                  if this.ShouldShowLinksOnMaster() && (this.IsLastMasterTarget(this.m_networkLinks[i].masterID) || this.IsTagged(this.m_networkLinks[i].masterID)) {
                    ArrayPush(toActivate, i);
                  } else {
                    if this.m_networkLinks[i].isActive {
                      ArrayPush(toDeactivate, i);
                    };
                  };
                };
              };
            };
          };
        };
      };
      i += 1;
    };
    this.DeactivateNetworkLinks(toDeactivate, hasContext);
    this.ActivateNetworkLinks(toActivate);
  }

  protected final func OnActivateNetworkLinksRequest(request: ref<ActivateLinksRequest>) -> Void {
    this.m_activateLinksDelayID = GetInvalidDelayID();
    this.ActivateNetworkLinks(request.linksIDs);
  }

  private final func ActivateNetworkLinks(toActivate: array<Int32>) -> Void {
    let excessLnks: array<Int32>;
    let request: ref<ActivateLinksRequest>;
    let totalIinks: Int32;
    let i: Int32 = 0;
    while i < ArraySize(toActivate) {
      if totalIinks > NetworkSystem.GetMaxLinksDrawnAtOnce() {
        ArrayPush(excessLnks, toActivate[i]);
      } else {
        this.ActivateNetworkLinkByTask(toActivate[i]);
      };
      totalIinks += 1;
      i += 1;
    };
    if ArraySize(excessLnks) > 0 {
      request = new ActivateLinksRequest();
      request.linksIDs = excessLnks;
      this.m_activateLinksDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(this.GetClassName(), request, 0.03, false);
    };
  }

  protected final func OnDeactivateLinksRequest(request: ref<DeactivateLinksRequest>) -> Void {
    this.m_deactivateLinksDelayID = GetInvalidDelayID();
    this.DeactivateNetworkLinks(request.linksIDs, request.instant);
  }

  private final func DeactivateNetworkLinks(toDeactivate: array<Int32>, hasContext: Bool) -> Void {
    let excessLnks: array<Int32>;
    let request: ref<DeactivateLinksRequest>;
    let totalIinks: Int32;
    let i: Int32 = 0;
    while i < ArraySize(toDeactivate) {
      if totalIinks > NetworkSystem.GetMaxLinksDeactivatedAtOnce() {
        ArrayPush(excessLnks, toDeactivate[i]);
      } else {
        this.DeactivateNetworkLinkByTask(toDeactivate[i], hasContext);
      };
      totalIinks += 1;
      i += 1;
    };
    if ArraySize(excessLnks) > 0 {
      request = new DeactivateLinksRequest();
      request.linksIDs = excessLnks;
      request.instant = hasContext;
      this.m_deactivateLinksDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(this.GetClassName(), request, 0.03, false);
    };
  }

  private final func DeterminNetworkLinkVisibility(linkIndex: Int32) -> Bool {
    if !this.m_networkLinks[linkIndex].drawLink {
      return false;
    };
    if this.IsCurrentTarget(this.m_networkLinks[linkIndex].masterID) {
      return false;
    };
    if this.IsLastMasterTarget(this.m_networkLinks[linkIndex].masterID) && !this.IsLastSlaveTarget(this.m_networkLinks[linkIndex].slaveID) {
      return false;
    };
    return true;
  }

  private final func ActivateNetworkLinkByIndex(linkIndex: Int32) -> Void {
    if linkIndex < 0 || linkIndex >= ArraySize(this.m_networkLinks) {
      return;
    };
    if this.m_networkLinks[linkIndex].drawLink && !this.DrawNetworkBeamByIndex(linkIndex) {
      return;
    };
    this.ResolveConnectionHighlight(true, this.m_networkLinks[linkIndex]);
    this.m_networkLinks[linkIndex].isActive = true;
  }

  private final func DrawNetworkBeamByIndex(linkIndex: Int32) -> Bool {
    let attachementType: entAttachmentTarget;
    let beamResource: FxResource;
    let isDynamic: Bool;
    let isMasterRoot: Bool;
    let master: ref<GameObject>;
    let masterTransform: WorldTransform;
    let rootEntityWorldTransform: WorldTransform;
    let rootEnttity: ref<GameObject>;
    let rootWorldPosition: WorldPosition;
    let slave: ref<GameObject>;
    let slaveTransform: WorldTransform;
    let targetWorldPosition: WorldPosition;
    let beam: ref<FxInstance> = this.GetNetworkBeam(this.m_networkLinks[linkIndex]);
    if beam == null {
      if !FxResource.IsValid(this.m_networkLinks[linkIndex].fxResource) {
        beamResource = this.m_lastBeamResource;
      } else {
        beamResource = this.m_networkLinks[linkIndex].fxResource;
      };
      if !FxResource.IsValid(beamResource) {
        return false;
      };
      if Vector4.IsZero(this.m_networkLinks[linkIndex].masterPos) && Vector4.IsZero(this.m_networkLinks[linkIndex].slavePos) {
        return false;
      };
      isDynamic = this.m_networkLinks[linkIndex].isDynamic;
      if isDynamic {
        if EntityID.IsDefined(this.m_networkLinks[linkIndex].slaveID) {
          slave = GameInstance.FindEntityByID(this.GetGameInstance(), this.m_networkLinks[linkIndex].slaveID) as GameObject;
        };
        if EntityID.IsDefined(this.m_networkLinks[linkIndex].masterID) {
          master = GameInstance.FindEntityByID(this.GetGameInstance(), this.m_networkLinks[linkIndex].masterID) as GameObject;
        };
        if slave == null && master == null {
          return false;
        };
        if slave != null && master != null {
          if this.IsCurrentTarget(this.m_networkLinks[linkIndex].masterID) {
            rootEnttity = master;
            isMasterRoot = true;
          } else {
            rootEnttity = slave;
          };
        } else {
          if slave != null {
            rootEnttity = slave;
          } else {
            rootEnttity = master;
            isMasterRoot = true;
          };
        };
        WorldPosition.SetVector4(rootWorldPosition, rootEnttity.GetNetworkBeamEndpoint());
      } else {
        if this.IsCurrentTarget(this.m_networkLinks[linkIndex].masterID) {
          WorldPosition.SetVector4(rootWorldPosition, this.m_networkLinks[linkIndex].masterPos);
          isMasterRoot = true;
        } else {
          WorldPosition.SetVector4(rootWorldPosition, this.m_networkLinks[linkIndex].slavePos);
        };
        if isMasterRoot {
          if Vector4.IsZero(this.m_networkLinks[linkIndex].slavePos) {
            return false;
          };
        } else {
          if Vector4.IsZero(this.m_networkLinks[linkIndex].masterPos) {
            return false;
          };
        };
      };
      WorldTransform.SetWorldPosition(rootEntityWorldTransform, rootWorldPosition);
      beam = GameInstance.GetFxSystem(this.GetGameInstance()).SpawnEffect(beamResource, rootEntityWorldTransform, true);
      if isDynamic {
        if IsDefined(slave) && IsNameValid(slave.GetNetworkLinkSlotName()) {
          if slave == rootEnttity {
            attachementType = entAttachmentTarget.Transform;
          } else {
            attachementType = entAttachmentTarget.TargetPosition;
          };
          beam.AttachToSlot(slave, attachementType, slave.GetNetworkLinkSlotName(slaveTransform));
        };
        if IsDefined(master) && IsNameValid(master.GetNetworkLinkSlotName()) {
          if master == rootEnttity {
            attachementType = entAttachmentTarget.Transform;
          } else {
            attachementType = entAttachmentTarget.TargetPosition;
          };
          beam.AttachToSlot(master, attachementType, master.GetNetworkLinkSlotName(masterTransform));
        };
        if slave == rootEnttity && master == null {
          WorldPosition.SetVector4(targetWorldPosition, this.m_networkLinks[linkIndex].masterPos);
          beam.UpdateTargetPosition(targetWorldPosition);
        } else {
          if master == rootEnttity && slave == null {
            WorldPosition.SetVector4(targetWorldPosition, this.m_networkLinks[linkIndex].slavePos);
            beam.UpdateTargetPosition(targetWorldPosition);
          };
        };
      } else {
        if isMasterRoot {
          WorldPosition.SetVector4(targetWorldPosition, this.m_networkLinks[linkIndex].slavePos);
          beam.UpdateTargetPosition(targetWorldPosition);
        } else {
          WorldPosition.SetVector4(targetWorldPosition, this.m_networkLinks[linkIndex].masterPos);
          beam.UpdateTargetPosition(targetWorldPosition);
        };
      };
      this.m_networkLinks[linkIndex].beam = beam;
      this.m_networkLinks[linkIndex].fxResource = beamResource;
      if this.m_networkLinks[linkIndex].isPing {
        this.IncreasePingLinbksCounter();
      };
      return true;
    };
    return false;
  }

  private final func ResolveConnectionHighlight(enable: Bool, linkData: SNetworkLinkData) -> Void {
    let slaveID: EntityID = linkData.slaveID;
    let masterID: EntityID = linkData.masterID;
    if enable && !linkData.isActive || !enable && linkData.isActive {
      if linkData.revealSlave && EntityID.IsDefined(slaveID) {
        this.SendConnectionHighlightEvent(enable, slaveID, masterID, linkData);
      };
      if linkData.revealMaster && EntityID.IsDefined(masterID) {
        this.SendConnectionHighlightEvent(enable, masterID, slaveID, linkData);
      };
    };
  }

  private final func SendConnectionHighlightEvent(enable: Bool, target: EntityID, source: EntityID, linkData: SNetworkLinkData) -> Void {
    let evt: ref<RevealDeviceRequest> = new RevealDeviceRequest();
    evt.shouldReveal = enable;
    evt.sourceID = source;
    evt.linkData = linkData;
    GameInstance.GetPersistencySystem(this.GetGameInstance()).QueueEntityEvent(target, evt);
  }

  public final static func SendEvaluateVisionModeRequest(instance: GameInstance, mode: gameVisionModeType) -> Void {
    let request: ref<EvaluateVisionModeRequest>;
    let networkSystem: ref<NetworkSystem> = GameInstance.GetScriptableSystemsContainer(instance).Get(n"NetworkSystem") as NetworkSystem;
    if IsDefined(networkSystem) {
      request = new EvaluateVisionModeRequest();
      request.mode = mode;
      networkSystem.QueueRequest(request);
    };
  }

  private final func OnEvaluateVisionModeRequest(request: ref<EvaluateVisionModeRequest>) -> Void {
    this.EvaluateVisionMode(request.mode);
  }

  protected cb func OnVisionModeChanged(value: Int32) -> Bool {
    this.EvaluateVisionMode(IntEnum(value));
  }

  private final func EvaluateVisionMode(visionType: gameVisionModeType) -> Void {
    let duration: Float;
    let unregisterLinkRequest: ref<UnregisterAllNetworkLinksRequest>;
    let updateNetworkRequest: ref<UpdateNetworkVisualisationRequest>;
    if Equals(visionType, gameVisionModeType.Default) {
      this.m_focusModeActive = false;
      if !this.m_sessionStarted {
        return;
      };
      unregisterLinkRequest = new UnregisterAllNetworkLinksRequest();
      duration = this.GetRevealLinksAfterLeavingFocusDuration();
      if Cast(duration) {
        this.m_unregisterLinksRequestDelay = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(this.GetClassName(), unregisterLinkRequest, duration, false);
      } else {
        this.ResolveNetworkSystemCleanupDelay();
        this.CleanNetwork();
      };
    } else {
      if Equals(visionType, gameVisionModeType.Focus) {
        this.m_focusModeActive = true;
        this.m_sessionStarted = true;
        this.ResolveNetworkSystemCleanupDelay();
        updateNetworkRequest = new UpdateNetworkVisualisationRequest();
        this.QueueRequest(updateNetworkRequest);
      };
    };
    this.UpdateNetworkVisualisation();
  }

  protected cb func OnFocusModeToggle(value: Bool) -> Bool {
    let unregisterLinkRequest: ref<UnregisterAllNetworkLinksRequest>;
    this.m_focusModeActive = value;
    if !value {
      unregisterLinkRequest = new UnregisterAllNetworkLinksRequest();
      this.QueueRequest(unregisterLinkRequest);
    };
  }

  protected cb func OnPlayerTargetChanged(value: EntityID) -> Bool {
    let updateNetworkRequest: ref<UpdateNetworkVisualisationRequest>;
    this.EvaluatelastTargets(value);
    if this.m_focusModeActive {
      updateNetworkRequest = new UpdateNetworkVisualisationRequest();
      this.QueueRequest(updateNetworkRequest);
    };
  }

  private final func EvaluatelastTargets(newTarget: EntityID) -> Bool {
    let emptyID: EntityID;
    let newTargetObject: wref<GameObject>;
    let newTargetSet: Bool;
    if !EntityID.IsDefined(newTarget) {
      return false;
    };
    newTargetObject = this.GetObjectFromID(newTarget);
    if newTargetObject != null && !newTargetObject.CanOverrideNetworkContext() {
      return false;
    };
    if EntityID.IsDefined(this.m_lastTargetSlaveID) && !EntityID.IsDefined(this.m_lastTargetMasterID) {
      if newTarget != this.m_lastTargetSlaveID {
        if Equals(this.GetNetworkRelation(newTarget, this.m_lastTargetSlaveID), ENetworkRelation.MASTER) {
          this.m_lastTargetMasterID = newTarget;
          newTargetSet = true;
        } else {
          if Equals(this.GetNetworkRelation(newTarget, this.m_lastTargetSlaveID), ENetworkRelation.SLAVE) {
            this.m_lastTargetMasterID = this.m_lastTargetSlaveID;
            this.m_lastTargetSlaveID = newTarget;
            newTargetSet = true;
          } else {
            this.m_lastTargetSlaveID = emptyID;
          };
        };
      };
    } else {
      if !EntityID.IsDefined(this.m_lastTargetSlaveID) && EntityID.IsDefined(this.m_lastTargetMasterID) {
        if newTarget != this.m_lastTargetMasterID {
          if Equals(this.GetNetworkRelation(newTarget, this.m_lastTargetMasterID), ENetworkRelation.SLAVE) {
            this.m_lastTargetSlaveID = newTarget;
            newTargetSet = true;
          } else {
            if Equals(this.GetNetworkRelation(newTarget, this.m_lastTargetMasterID), ENetworkRelation.MASTER) {
              this.m_lastTargetSlaveID = this.m_lastTargetMasterID;
              this.m_lastTargetMasterID = newTarget;
              newTargetSet = true;
            } else {
              this.m_lastTargetMasterID = emptyID;
            };
          };
        };
      } else {
        if EntityID.IsDefined(this.m_lastTargetSlaveID) && EntityID.IsDefined(this.m_lastTargetMasterID) {
          if newTarget != this.m_lastTargetMasterID {
            if Equals(this.GetNetworkRelation(newTarget, this.m_lastTargetMasterID), ENetworkRelation.SLAVE) {
              this.m_lastTargetSlaveID = newTarget;
              newTargetSet = true;
            } else {
              if Equals(this.GetNetworkRelation(newTarget, this.m_lastTargetMasterID), ENetworkRelation.MASTER) {
                this.m_lastTargetSlaveID = this.m_lastTargetMasterID;
                this.m_lastTargetMasterID = newTarget;
                newTargetSet = true;
              } else {
                this.m_lastTargetMasterID = emptyID;
              };
            };
          };
          if newTarget != this.m_lastTargetSlaveID {
            if Equals(this.GetNetworkRelation(newTarget, this.m_lastTargetSlaveID), ENetworkRelation.MASTER) {
              this.m_lastTargetMasterID = newTarget;
              newTargetSet = true;
            } else {
              if Equals(this.GetNetworkRelation(newTarget, this.m_lastTargetSlaveID), ENetworkRelation.SLAVE) {
                this.m_lastTargetMasterID = this.m_lastTargetSlaveID;
                this.m_lastTargetSlaveID = newTarget;
                newTargetSet = true;
              } else {
                this.m_lastTargetSlaveID = emptyID;
              };
            };
          };
        };
      };
    };
    if !EntityID.IsDefined(this.m_lastTargetSlaveID) && !EntityID.IsDefined(this.m_lastTargetMasterID) {
      if this.IsSlaveInNetwork(newTarget) {
        this.m_lastTargetSlaveID = newTarget;
        newTargetSet = true;
      };
      if this.IsMasterInNetwork(newTarget) {
        this.m_lastTargetMasterID = newTarget;
        newTargetSet = true;
      };
    };
    if newTargetSet {
      if this.AllowSimultanousPinging() {
        return newTargetSet;
      };
      this.RemoveAllActivePings();
    };
    return newTargetSet;
  }

  private final func GetNetworkRelation(sourceID: EntityID, targetID: EntityID) -> ENetworkRelation {
    let i: Int32 = 0;
    while i < ArraySize(this.m_networkLinks) {
      if this.m_networkLinks[i].slaveID == sourceID && this.m_networkLinks[i].masterID == targetID {
        return ENetworkRelation.SLAVE;
      };
      if this.m_networkLinks[i].masterID == sourceID && this.m_networkLinks[i].slaveID == targetID {
        return ENetworkRelation.MASTER;
      };
      i += 1;
    };
    return ENetworkRelation.NONE;
  }

  private final func EvaluateLastSlaveTarget(masterID: EntityID) -> Void {
    let currMasterID: EntityID;
    let currSlaveID: EntityID;
    let emptyID: EntityID;
    let i: Int32;
    if !EntityID.IsDefined(masterID) || masterID == emptyID {
      return;
    };
    if ArraySize(this.m_networkLinks) == 0 {
      return;
    };
    i = 0;
    while i < ArraySize(this.m_networkLinks) {
      currMasterID = this.m_networkLinks[i].masterID;
      currSlaveID = this.m_networkLinks[i].slaveID;
      if masterID == currMasterID && currSlaveID == this.m_lastTargetSlaveID {
        return;
      };
      i += 1;
    };
    this.m_lastTargetSlaveID = emptyID;
  }

  private final func EvaluateLastMasterTarget(slaveID: EntityID) -> Void {
    let currMasterID: EntityID;
    let currSlaveID: EntityID;
    let emptyID: EntityID;
    let i: Int32;
    if !EntityID.IsDefined(slaveID) || slaveID == emptyID {
      return;
    };
    if ArraySize(this.m_networkLinks) == 0 {
      return;
    };
    i = 0;
    while i < ArraySize(this.m_networkLinks) {
      currMasterID = this.m_networkLinks[i].masterID;
      currSlaveID = this.m_networkLinks[i].slaveID;
      if slaveID == currSlaveID && currMasterID == this.m_lastTargetMasterID {
        return;
      };
      i += 1;
    };
    this.m_lastTargetMasterID = emptyID;
  }

  private final func IsMaster(targetEntityID: EntityID) -> Bool {
    let masterID: EntityID;
    let i: Int32 = 0;
    while i < ArraySize(this.m_networkLinks) {
      masterID = this.m_networkLinks[i].masterID;
      if masterID == targetEntityID {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func IsLastSlaveTarget(entityID: EntityID) -> Bool {
    return entityID == this.m_lastTargetSlaveID;
  }

  private final func IsLastMasterTarget(entityID: EntityID) -> Bool {
    return entityID == this.m_lastTargetMasterID;
  }

  private final func IsCurrentTarget(entityID: EntityID) -> Bool {
    return entityID == this.GetCurrentTargetID();
  }

  private final func IsCurrentTargetValid() -> Bool {
    let currentTarget: wref<GameObject> = this.GetCurrentTarget();
    return currentTarget != null && currentTarget.CanOverrideNetworkContext();
  }

  private final func IsCurrentTargetValidInNetwork() -> Bool {
    let emptyID: EntityID;
    let currentTargetID: EntityID = this.GetCurrentTargetID();
    return EntityID.IsDefined(currentTargetID) && currentTargetID != emptyID && this.IsInNetwork(currentTargetID);
  }

  private final func IsInNetwork(id: EntityID) -> Bool {
    let masterEntityID: EntityID;
    let slaveEntityID: EntityID;
    let i: Int32 = 0;
    while i < ArraySize(this.m_networkLinks) {
      slaveEntityID = this.m_networkLinks[i].slaveID;
      masterEntityID = this.m_networkLinks[i].masterID;
      if slaveEntityID == id || masterEntityID == id {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func IsSlaveInNetwork(id: EntityID) -> Bool {
    let slaveEntityID: EntityID;
    let i: Int32 = 0;
    while i < ArraySize(this.m_networkLinks) {
      slaveEntityID = this.m_networkLinks[i].slaveID;
      if slaveEntityID == id {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func GetAllSlavesOfMaster(masterID: EntityID) -> array<EntityID> {
    let slaves: array<EntityID>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_networkLinks) {
      if this.m_networkLinks[i].masterID == masterID {
        if EntityID.IsDefined(this.m_networkLinks[i].slaveID) {
          ArrayPush(slaves, this.m_networkLinks[i].slaveID);
        };
      };
      i += 1;
    };
    return slaves;
  }

  private final func IsMasterInNetwork(id: EntityID) -> Bool {
    let masterEntityID: EntityID;
    let i: Int32 = 0;
    while i < ArraySize(this.m_networkLinks) {
      masterEntityID = this.m_networkLinks[i].masterID;
      if masterEntityID == id {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func GetAllMastersOfSlave(slaveID: EntityID) -> array<EntityID> {
    let masters: array<EntityID>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_networkLinks) {
      if this.m_networkLinks[i].slaveID == slaveID {
        if EntityID.IsDefined(this.m_networkLinks[i].masterID) {
          ArrayPush(masters, this.m_networkLinks[i].masterID);
        };
      };
      i += 1;
    };
    return masters;
  }

  private final func GetCurrentTargetID() -> EntityID {
    return this.GetHudManager().GetCurrentTargetID();
  }

  private final func GetCurrentTarget() -> wref<GameObject> {
    let target: wref<GameObject>;
    let entityID: EntityID = this.GetCurrentTargetID();
    if EntityID.IsDefined(entityID) {
      target = GameInstance.FindEntityByID(this.GetGameInstance(), entityID) as GameObject;
    };
    return target;
  }

  private final const func GetObjectFromID(entityID: EntityID) -> wref<GameObject> {
    let target: wref<GameObject>;
    if EntityID.IsDefined(entityID) {
      target = GameInstance.FindEntityByID(this.GetGameInstance(), entityID) as GameObject;
    };
    return target;
  }

  private final func IsTagged(id: EntityID) -> Bool {
    let target: wref<GameObject> = this.GetObjectFromID(id);
    if IsDefined(target) {
      return GameInstance.GetVisionModeSystem(this.GetGameInstance()).GetScanningController().IsTagged(target);
    };
    return false;
  }

  private final func OnRegisterPingLinkRequest(request: ref<RegisterPingNetworkLinkRequest>) -> Void {
    let linkData: SNetworkLinkData;
    let ping: ref<PingCachedData>;
    let i: Int32 = 0;
    while i < ArraySize(request.linksData) {
      if !this.IsFreeLinkLimitReached(request.linksData[i]) {
        if this.IsPingLinksLimitReached() {
          this.KillSingleOldestFreeLink();
        };
        linkData = request.linksData[i];
        ping = this.GetActivePing(linkData.masterID);
        if ping != null && linkData.lifetime <= 0.00 {
          linkData.lifetime = ping.GetLifetimeValue();
        };
        this.RegisterNetworkLink(linkData);
      };
      i += 1;
    };
    this.UpdateNetworkVisualisation();
  }

  private final func KillSingleOldestFreeLink() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_networkLinks) {
      if Equals(this.m_networkLinks[i].linkType, ELinkType.FREE) {
        this.KillNetworkBeam(i, false);
        return;
      };
      i += 1;
    };
  }

  private final func KillSingleOldestFreeLinkWitoutRevealPing() -> Void {
    let i: Int32;
    let ping: ref<PingCachedData> = this.GetLastActivePingWithRevealNetwork();
    if ping != null {
      i = 0;
      while i < ArraySize(this.m_networkLinks) {
        if Equals(this.m_networkLinks[i].linkType, ELinkType.FREE) && this.m_networkLinks[i].masterID != ping.m_sourceID {
          this.KillNetworkBeam(i, false);
          return;
        };
        i += 1;
      };
    } else {
      this.KillSingleOldestFreeLink();
    };
  }

  private final const func IsFreeLinkLimitReached(linkData: SNetworkLinkData) -> Bool {
    let i: Int32;
    let sourceLinkCount: Int32;
    let targetLinkCount: Int32;
    if !linkData.isActive || !EntityID.IsDefined(linkData.slaveID) || !EntityID.IsDefined(linkData.masterID) {
      return false;
    };
    i = 0;
    while i < ArraySize(this.m_networkLinks) {
      if this.m_networkLinks[i].slaveID == linkData.slaveID {
        if Equals(this.m_networkLinks[i].linkType, ELinkType.FREE) {
          targetLinkCount += 1;
        };
      };
      if this.m_networkLinks[i].masterID == linkData.masterID {
        if Equals(this.m_networkLinks[i].linkType, ELinkType.FREE) {
          sourceLinkCount += 1;
        };
      };
      if sourceLinkCount > NetworkSystem.GetMaximumNumberOfFreeLinksPerTarget() || targetLinkCount > NetworkSystem.GetMaximumNumberOfFreeLinksPerTarget() {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func OnStartPingingNetworkRequest(request: ref<StartPingingNetworkRequest>) -> Void {
    if this.IsActivePingsLimitReached() {
      return;
    };
    if Equals(request.pingType, EPingType.DIRECT) {
      if this.AllowSimultanousPinging() {
        this.RemoveActivePingBySourceAndType(request.source.GetEntityID(), EPingType.SPACE);
        if this.HasActivePing(request.source.GetEntityID()) {
          return;
        };
      } else {
        this.RemoveAllActivePings();
      };
    };
    if request.duration <= 0.00 {
      return;
    };
    if Equals(request.pingType, EPingType.SPACE) {
      if this.HasActivePing(request.source.GetEntityID()) {
        return;
      };
    };
    this.AddActivePing(request.source, request.pingType, request.duration, request.fakeLinkType, request.revealNetworkAtEnd, request.fxResource, request.virtualNetworkShapeID);
  }

  private final func OnStopingingNetworkRequest(request: ref<StopPingingNetworkRequest>) -> Void {
    let invalidID: DelayID;
    if request.pingData != null {
      request.pingData.m_delayID = invalidID;
      if Equals(request.pingData.m_pingType, EPingType.SPACE) && request.pingData.m_revealNetwork {
        this.SendRevealNetworkEvent(request.source.GetEntityID());
      };
      if Equals(request.pingData.m_pingType, EPingType.DIRECT) && request.pingData.m_revealNetwork {
        this.SendRevealNetworkGridRequest(request.source.GetEntityID());
      };
    };
    if !this.HasAnyActivePingWithRevealNetwork() {
      this.RemoveAllActiveFakePings();
    } else {
      if request.pingData.m_revealNetwork {
        this.RemoveActivePingBySource(request.source.GetEntityID());
      };
    };
  }

  private final func AddActivePing(source: ref<GameObject>, pingType: EPingType, duration: Float, linkType: ELinkType, revealNetworkAtEnd: Bool, fxResource: FxResource, virtualNetworkShapeID: TweakDBID) -> Void {
    let pingData: ref<PingCachedData>;
    let pingNetworkEffect: ref<EffectInstance>;
    let stopPingRequest: ref<StopPingingNetworkRequest>;
    if source == null {
      return;
    };
    if !this.HasActivePing(source.GetEntityID()) {
      pingData = new PingCachedData();
      pingNetworkEffect = GameInstance.GetGameEffectSystem(this.GetGameInstance()).CreateEffectStatic(n"pingNetworkEffect", n"ping_netwrok", source);
      EffectData.SetFloat(pingNetworkEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, this.GetPingRange());
      EffectData.SetFloat(pingNetworkEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.duration, duration);
      EffectData.SetVector(pingNetworkEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, source.GetWorldPosition());
      pingData.Initialize(source.GetEntityID(), duration, this.GetAmmountOfPingDurationIntervals(), pingType, pingNetworkEffect, revealNetworkAtEnd, fxResource, source.GetNetworkBeamEndpoint(), virtualNetworkShapeID);
      if duration > 0.00 {
        stopPingRequest = new StopPingingNetworkRequest();
        stopPingRequest.source = source;
        pingData.m_delayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(this.GetClassName(), stopPingRequest, duration + 0.10, false);
        stopPingRequest.pingData = pingData;
      };
      ArrayPush(this.m_activePings, pingData);
      this.m_lastPingSourceID = source.GetEntityID();
      if this.ShouldPulsRealObject() {
        pingNetworkEffect.Run();
      };
      if this.ShouldUsePulseOnPing() && pingData.m_revealNetwork {
        GameInstance.GetVisionModeSystem(this.GetGameInstance()).GetScanningController().PulseScan(GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject(), this.GetPulseRange(), source.GetWorldPosition());
      };
      this.CreateVirtualNetwork(pingData);
    };
  }

  private final func CreateVirtualNetwork(sourcePing: ref<PingCachedData>) -> Void {
    let currentPoint: Vector4;
    let drawingStarted: Bool;
    let i: Int32;
    let k: Int32;
    let lastPos: Vector4;
    let linkData: SNetworkLinkData;
    let localPing: ref<PingCachedData>;
    let networkRotation: Quaternion;
    let paths: array<wref<VirtualNetworkPath_Record>>;
    let playerPos: Vector4;
    let points: array<Vector3>;
    let registerDelay: Float;
    let scale: Float;
    let segmentMarker: Vector4;
    let sourceObject: wref<GameObject>;
    let sphereCentre: Vector4;
    let virtualNetworkRecord: wref<VirtualNetwork_Record>;
    if !this.IsVirtualNetworkWithinDistanceLimit(sourcePing) {
      return;
    };
    sourceObject = this.GetObjectFromID(sourcePing.m_sourceID);
    if sourceObject == null {
      return;
    };
    playerPos = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject().GetWorldPosition();
    sphereCentre = sourceObject.GetNetworkBeamEndpoint();
    if sourcePing.m_virtualNetworkShape != null {
      virtualNetworkRecord = sourcePing.m_virtualNetworkShape;
    } else {
      virtualNetworkRecord = this.GetVirtualNetworkRecord();
    };
    virtualNetworkRecord.Paths(paths);
    currentPoint = sphereCentre - playerPos;
    currentPoint.Z = 0.00;
    currentPoint = Vector4.Normalize(currentPoint);
    networkRotation = Quaternion.BuildFromDirectionVector(currentPoint, new Vector4(0.00, 0.00, 1.00, 0.00));
    linkData.masterID = sourcePing.m_sourceID;
    linkData.drawLink = true;
    linkData.linkType = ELinkType.FREE;
    linkData.isDynamic = false;
    linkData.revealMaster = false;
    linkData.revealSlave = false;
    linkData.fxResource = sourcePing.m_linkFXresource;
    linkData.isPing = true;
    linkData.permanent = true;
    sourcePing.m_hasActiveVirtualNetwork = true;
    localPing = new PingCachedData();
    localPing.m_timeout = sourcePing.m_timeout;
    localPing.m_ammountOfIntervals = this.GetMaxNumberOfSegmentsForVirtualNetwork(virtualNetworkRecord);
    segmentMarker = this.GetVirtualNetworkSegmentMarker(virtualNetworkRecord);
    i = 0;
    while i < ArraySize(paths) {
      points = paths[i].Points();
      drawingStarted = false;
      if ArraySize(points) < 2 {
      } else {
        localPing.m_currentInterval = ArraySize(points) - 1;
        scale = virtualNetworkRecord.Scale();
        k = 0;
        while k < ArraySize(points) {
          currentPoint = new Vector4(points[k].X, points[k].Y, points[k].Z, 0.00);
          if Equals(currentPoint, segmentMarker) {
            if drawingStarted {
              localPing.GetLifetimeValue();
            };
          } else {
            currentPoint *= scale;
            currentPoint = networkRotation * currentPoint;
            currentPoint += sphereCentre;
            if virtualNetworkRecord.OffsetMultiplier() > 1.00 {
              currentPoint *= virtualNetworkRecord.OffsetMultiplier();
            };
            if !drawingStarted {
              drawingStarted = true;
              lastPos = currentPoint;
            } else {
              linkData.slavePos = currentPoint;
              linkData.masterPos = lastPos;
              linkData.lifetime = localPing.GetLifetimeValue();
              if Equals(lastPos, sphereCentre) {
                linkData.isDynamic = sourceObject.IsNetworkLinkDynamic();
              };
              if this.GetSpacePingAppearModifier() > 0.00 {
                registerDelay = (0.00 + localPing.m_timeout - linkData.lifetime) / this.GetSpacePingAppearModifier();
                this.RegisterNetworkLinkWithDelay(linkData, registerDelay);
              } else {
                this.RegisterNetworkLink(linkData);
              };
              linkData.isDynamic = false;
              lastPos = linkData.slavePos;
            };
          };
          k += 1;
        };
      };
      i += 1;
    };
    if this.IsPingLinksLimitReached() {
      this.KillSingleOldestFreeLink();
    };
    this.UpdateNetworkVisualisation();
  }

  private final func IsVirtualNetworkWithinDistanceLimit(sourcePing: ref<PingCachedData>) -> Bool {
    let distance: Float;
    let minDistance: Float = this.GetVirtualNetworkRecord().MinDistanceToOther();
    let i: Int32 = 0;
    while i < ArraySize(this.m_activePings) {
      if sourcePing == this.m_activePings[i] || !this.m_activePings[i].m_hasActiveVirtualNetwork {
      } else {
        distance = Vector4.Distance(sourcePing.m_sourcePosition, this.m_activePings[i].m_sourcePosition);
        if distance < minDistance {
          return false;
        };
      };
      i += 1;
    };
    return true;
  }

  private final func CreateVirtualLinksForPing1(ping: ref<PingCachedData>) -> Void {
    let allVertices: array<Vector4>;
    let currentRadius: Float;
    let direction: Vector4;
    let i: Int32;
    let k: Int32;
    let lastPos: Vector4;
    let lastRadius: Float;
    let linkData: SNetworkLinkData;
    let radius: Float;
    let sphereCentre: Vector4;
    let zeroVec: Vector4;
    let sourceObject: wref<GameObject> = this.GetObjectFromID(ping.m_sourceID);
    if sourceObject == null {
      return;
    };
    sphereCentre = sourceObject.GetNetworkBeamEndpoint();
    linkData.masterID = ping.m_sourceID;
    linkData.drawLink = true;
    linkData.linkType = ELinkType.FREE;
    linkData.isDynamic = false;
    linkData.revealMaster = false;
    linkData.revealSlave = false;
    linkData.fxResource = ping.m_linkFXresource;
    linkData.isPing = true;
    linkData.permanent = true;
    radius = this.GetVirtualLinksSphereRadius() / Cast(this.GetVirtualLinkDepth());
    i = 0;
    while i < this.GetNumberOfVirtualLinksPerObject() {
      direction = this.GetRandomPointOnSphere(zeroVec, 1.00, i);
      k = 0;
      while k < this.GetVirtualLinkDepth() {
        currentRadius += radius * RandRangeF(0.90, 1.10);
        linkData.slavePos = this.GetRandomPoint(direction, currentRadius, this.GetVirtualLinkAngleTollerance());
        linkData.slavePos = linkData.slavePos + sphereCentre;
        if k == 0 {
          linkData.masterPos = sphereCentre;
          linkData.isDynamic = sourceObject.IsNetworkLinkDynamic();
        } else {
          linkData.masterPos = lastPos;
        };
        lastPos = linkData.slavePos;
        linkData.lifetime = ping.GetLifetimeValue();
        ArrayPush(allVertices, lastPos);
        if i > 0 {
          this.CreateForksForVirtualLink1(linkData, ping, sphereCentre, lastRadius, direction, allVertices);
        };
        this.RegisterNetworkLink(linkData);
        lastRadius = currentRadius;
        k += 1;
      };
      currentRadius = 0.00;
      lastRadius = 0.00;
      i += 1;
    };
    if this.IsPingLinksLimitReached() {
      this.KillSingleOldestFreeLinkWitoutRevealPing();
    };
    this.UpdateNetworkVisualisation();
  }

  private final func CreateVirtualLinksForPing(ping: ref<PingCachedData>) -> Void {
    let currentRadius: Float;
    let i: Int32;
    let k: Int32;
    let lastPos: Vector4;
    let linkData: SNetworkLinkData;
    let radius: Float;
    let sphereCentre: Vector4;
    let sourceObject: wref<GameObject> = this.GetObjectFromID(ping.m_sourceID);
    if sourceObject == null {
      return;
    };
    sphereCentre = sourceObject.GetNetworkBeamEndpoint();
    linkData.masterID = ping.m_sourceID;
    linkData.drawLink = true;
    linkData.linkType = ELinkType.FREE;
    linkData.isDynamic = sourceObject.IsNetworkLinkDynamic();
    linkData.revealMaster = false;
    linkData.revealSlave = false;
    linkData.fxResource = ping.m_linkFXresource;
    linkData.isPing = true;
    linkData.permanent = true;
    radius = this.GetVirtualLinksSphereRadius() / Cast(this.GetVirtualLinkDepth());
    i = 0;
    while i < this.GetNumberOfVirtualLinksPerObject() {
      k = 0;
      while k < this.GetVirtualLinkDepth() {
        currentRadius += radius * RandRangeF(0.90, 1.10);
        linkData.slavePos = this.GetRandomPointOnSphere(sphereCentre, currentRadius, i);
        if k == 0 {
          linkData.masterPos = sphereCentre;
        } else {
          linkData.masterPos = lastPos;
        };
        lastPos = linkData.slavePos;
        linkData.lifetime = ping.GetLifetimeValue();
        if this.IsPingLinksLimitReached() {
          this.KillSingleOldestFreeLinkWitoutRevealPing();
        };
        this.RegisterNetworkLink(linkData);
        k += 1;
      };
      currentRadius = 0.00;
      i += 1;
    };
    this.UpdateNetworkVisualisation();
  }

  private final func CreateForksForVirtualLink1(linkData: SNetworkLinkData, ping: ref<PingCachedData>, sphereCentre: Vector4, radius: Float, direction: Vector4, vertices: array<Vector4>) -> Void {
    let foundVertice: Vector4;
    let numberOfForks: Int32 = RandRange(0, this.GetMaxAmountOfVirtualLinkForks());
    let baseRadius: Float = this.GetVirtualLinksSphereRadius() / Cast(this.GetVirtualLinkDepth());
    let currentRadius: Float = radius;
    let linkDirection: Vector4 = Vector4.Normalize(linkData.slavePos - linkData.masterPos);
    let i: Int32 = 0;
    while i < numberOfForks {
      currentRadius += baseRadius * RandRangeF(0.90, 1.20);
      foundVertice = this.FindBestMatchingVertice(linkData.slavePos, linkDirection, Rad2Deg(this.GetVirtualLinkForkAngleTollerance()), this.GetVirtualLinksSphereRadius() * RandRangeF(1.00, 1.20), foundVertice, vertices);
      if Vector4.IsZero(foundVertice) {
      } else {
        linkData.slavePos = foundVertice;
      };
      this.RegisterNetworkLink(linkData);
      currentRadius = radius;
      i += 1;
    };
  }

  private final func CreateForksForVirtualLink1(linkData: SNetworkLinkData, ping: ref<PingCachedData>, sphereCentre: Vector4, radius: Float, direction: Vector4, connectionPoint: Vector4) -> Void {
    let baseRadius: Float;
    let forkToConnect: Int32;
    let i: Int32;
    let numberOfForks: Int32 = RandRange(0, this.GetMaxAmountOfVirtualLinkForks());
    if numberOfForks == 0 {
      numberOfForks = 1;
    };
    if numberOfForks > 0 {
      forkToConnect = RandRange(0, numberOfForks);
    };
    baseRadius = this.GetVirtualLinksSphereRadius() / Cast(this.GetVirtualLinkDepth());
    i = 0;
    while i < numberOfForks {
      if !Vector4.IsZero(connectionPoint) && forkToConnect == i {
        linkData.slavePos = connectionPoint;
      } else {
        radius = baseRadius * RandRangeF(0.80, 1.20);
        linkData.slavePos = sphereCentre + this.GetRandomPoint(direction, radius, this.GetVirtualLinkForkAngleTollerance());
      };
      this.RegisterNetworkLink(linkData);
      i += 1;
    };
  }

  private final func CreateForksForVirtualLink(linkData: SNetworkLinkData, ping: ref<PingCachedData>, sphereCentre: Vector4, radius: Float, slice: Int32) -> Void {
    let currentRadius: Float;
    let i: Int32;
    let numberOfForks: Int32 = RandRange(0, 4);
    let baseRadius: Float = this.GetVirtualLinksSphereRadius() / Cast(this.GetVirtualLinkDepth());
    currentRadius += radius + RandF() * baseRadius;
    i = 0;
    while i < numberOfForks {
      linkData.slavePos = this.GetRandomPointOnSphere(sphereCentre, currentRadius, slice);
      this.RegisterNetworkLink(linkData);
      i += 1;
    };
  }

  private final func RemoveActivePing(index: Int32) -> Void {
    let invalidID: DelayID;
    this.m_activePings[index].m_pingNetworkEffect.Terminate();
    if this.m_activePings[index].m_delayID != invalidID {
      GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_activePings[index].m_delayID);
    };
    this.m_activePings[index] = null;
    ArrayErase(this.m_activePings, index);
  }

  private final func RemoveActivePingBySource(sourceID: EntityID) -> Void {
    let isDirect: Bool;
    let linkType: ELinkType;
    let removeLinks: Bool;
    let i: Int32 = ArraySize(this.m_activePings) - 1;
    while i >= 0 {
      if this.m_activePings[i].m_sourceID == sourceID {
        isDirect = Equals(this.m_activePings[i].m_pingType, EPingType.DIRECT);
        linkType = this.m_activePings[i].m_linkType;
        this.RemoveActivePing(i);
        removeLinks = true;
      } else {
        i -= 1;
      };
    };
    if !this.HasAnyActivePing() {
      this.RemoveAllPingLinksByType(linkType);
    } else {
      if removeLinks {
        i = ArraySize(this.m_networkLinks) - 1;
        while i >= 0 {
          if isDirect {
            if this.m_networkLinks[i].isPing && Equals(this.m_networkLinks[i].linkType, linkType) && (this.m_networkLinks[i].masterID == sourceID || this.m_networkLinks[i].slaveID == sourceID) {
              this.KillNetworkBeam(i, true);
              ArrayErase(this.m_networkLinks, i);
            };
          } else {
            if this.m_networkLinks[i].masterID == sourceID && this.m_networkLinks[i].isPing && Equals(this.m_networkLinks[i].linkType, linkType) {
              this.KillNetworkBeam(i, true);
              ArrayErase(this.m_networkLinks, i);
            };
          };
          i -= 1;
        };
      };
    };
  }

  private final func RemoveAllActivePings() -> Void {
    let removeLinks: Bool = true;
    let i: Int32 = ArraySize(this.m_activePings) - 1;
    while i >= 0 {
      this.RemoveActivePing(i);
      i -= 1;
    };
    if removeLinks {
      this.RemoveAllPingLinks();
    };
  }

  private final func RemoveAllActiveFakePings() -> Void {
    let lastResource: FxResource;
    let resources: array<FxResource>;
    let i: Int32 = ArraySize(this.m_activePings) - 1;
    while i >= 0 {
      if !this.m_activePings[i].m_revealNetwork {
        if NotEquals(this.m_activePings[i].m_linkFXresource, lastResource) {
          ArrayPush(resources, this.m_activePings[i].m_linkFXresource);
          lastResource = this.m_activePings[i].m_linkFXresource;
        };
        this.RemoveActivePing(i);
      };
      i -= 1;
    };
    i = 0;
    while i < ArraySize(resources) {
      this.RemovePingLinksByFxResource(resources[i], true);
      i += 1;
    };
  }

  private final func RemoveAllPingLinks() -> Void {
    let i: Int32 = ArraySize(this.m_networkLinks) - 1;
    while i >= 0 {
      if this.m_networkLinks[i].isPing {
        this.KillNetworkBeam(i, false);
        ArrayErase(this.m_networkLinks, i);
      };
      i -= 1;
    };
  }

  private final func RemoveAllPingLinksByType(linkType: ELinkType) -> Void {
    let i: Int32 = ArraySize(this.m_networkLinks) - 1;
    while i >= 0 {
      if this.m_networkLinks[i].isPing && Equals(this.m_networkLinks[i].linkType, linkType) {
        this.KillNetworkBeam(i, false);
        ArrayErase(this.m_networkLinks, i);
      };
      i -= 1;
    };
  }

  private final func RemovePingLinksBySourceAndType(linkType: ELinkType, sourceID: EntityID) -> Void {
    let i: Int32 = ArraySize(this.m_networkLinks) - 1;
    while i >= 0 {
      if this.m_networkLinks[i].masterID == sourceID && this.m_networkLinks[i].isPing && Equals(this.m_networkLinks[i].linkType, linkType) {
        this.KillNetworkBeam(i, false);
        ArrayErase(this.m_networkLinks, i);
      };
      i -= 1;
    };
  }

  private final func RemovePingLinksBySource(sourceID: EntityID, intant: Bool) -> Void {
    let i: Int32 = ArraySize(this.m_networkLinks) - 1;
    while i >= 0 {
      if this.m_networkLinks[i].masterID == sourceID && this.m_networkLinks[i].isPing {
        this.KillNetworkBeam(i, intant);
        ArrayErase(this.m_networkLinks, i);
      };
      i -= 1;
    };
  }

  private final func RemovePingLinksBySourceAndFxResource(sourceID: EntityID, fxResource: FxResource, intant: Bool) -> Void {
    let i: Int32 = ArraySize(this.m_networkLinks) - 1;
    while i >= 0 {
      if (this.m_networkLinks[i].masterID == sourceID || this.m_networkLinks[i].slaveID == sourceID) && this.m_networkLinks[i].isPing && Equals(this.m_networkLinks[i].fxResource, fxResource) {
        this.KillNetworkBeam(i, intant);
        ArrayErase(this.m_networkLinks, i);
      };
      i -= 1;
    };
  }

  private final func RemovePingLinksByFxResource(fxResource: FxResource, intant: Bool) -> Void {
    let i: Int32 = ArraySize(this.m_networkLinks) - 1;
    while i >= 0 {
      if this.m_networkLinks[i].isPing && Equals(this.m_networkLinks[i].fxResource, fxResource) {
        this.KillNetworkBeam(i, intant);
        ArrayErase(this.m_networkLinks, i);
      };
      i -= 1;
    };
  }

  private final func RemoveActivePingBySourceAndType(sourceID: EntityID, pingType: EPingType) -> Void {
    let isDirect: Bool;
    let linkType: ELinkType;
    let removeLinks: Bool;
    let i: Int32 = ArraySize(this.m_activePings) - 1;
    while i >= 0 {
      if this.m_activePings[i].m_sourceID == sourceID && Equals(this.m_activePings[i].m_pingType, pingType) {
        isDirect = Equals(this.m_activePings[i].m_pingType, EPingType.DIRECT);
        linkType = this.m_activePings[i].m_linkType;
        this.RemoveActivePing(i);
        removeLinks = true;
      } else {
        i -= 1;
      };
    };
    if !this.HasAnyActivePing() {
      this.RemoveAllPingLinksByType(linkType);
    } else {
      if removeLinks {
        i = ArraySize(this.m_networkLinks) - 1;
        while i >= 0 {
          if isDirect {
            if this.m_networkLinks[i].isPing && Equals(this.m_networkLinks[i].linkType, linkType) && (this.m_networkLinks[i].masterID == sourceID || this.m_networkLinks[i].slaveID == sourceID) {
              this.KillNetworkBeam(i, false);
              ArrayErase(this.m_networkLinks, i);
            };
          } else {
            if this.m_networkLinks[i].masterID == sourceID && this.m_networkLinks[i].isPing && Equals(this.m_networkLinks[i].linkType, linkType) {
              this.KillNetworkBeam(i, false);
              ArrayErase(this.m_networkLinks, i);
            };
          };
          i -= 1;
        };
      };
    };
  }

  public final const func HasActivePing(sourceID: EntityID) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_activePings) {
      if this.m_activePings[i].m_sourceID == sourceID {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func GetActivePing(sourceID: EntityID) -> ref<PingCachedData> {
    let i: Int32 = 0;
    while i < ArraySize(this.m_activePings) {
      if this.m_activePings[i].m_sourceID == sourceID {
        return this.m_activePings[i];
      };
      i += 1;
    };
    return null;
  }

  public final const func GetInitialPingSourceID() -> EntityID {
    let entityID: EntityID;
    if this.m_activePings[0] != null {
      entityID = this.m_activePings[0].m_sourceID;
    };
    return entityID;
  }

  public final const func GetInitialPingSource() -> wref<GameObject> {
    let object: wref<GameObject>;
    if this.m_activePings[0] != null {
      object = this.GetObjectFromID(this.m_activePings[0].m_sourceID);
    };
    return object;
  }

  public final const func GetPingType(sourceID: EntityID) -> EPingType {
    let type: EPingType;
    let i: Int32 = 0;
    while i < ArraySize(this.m_activePings) {
      if this.m_activePings[i].m_sourceID == sourceID {
        type = this.m_activePings[i].m_pingType;
      };
      i += 1;
    };
    return type;
  }

  private final func HasAnyActivePing() -> Bool {
    return ArraySize(this.m_activePings) > 0;
  }

  public final const func HasAnyActivePingWithRevealNetwork() -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_activePings) {
      if this.m_activePings[i].m_revealNetwork {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func HasActivePingWithRevealNetwork(sourceID: EntityID) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_activePings) {
      if this.m_activePings[i].m_revealNetwork && this.m_activePings[i].m_sourceID == sourceID {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func GetLastActivePingWithRevealNetwork() -> ref<PingCachedData> {
    let ping: ref<PingCachedData>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_activePings) {
      if this.m_activePings[i].m_revealNetwork {
        ping = this.m_activePings[i];
      };
      i += 1;
    };
    return ping;
  }

  private final func IncreasePingLinbksCounter() -> Void {
    this.m_pingLinksCounter += 1;
  }

  private final func DecreasePingLinbksCounter() -> Void {
    this.m_pingLinksCounter -= 1;
  }

  public final const func IsPingLinksLimitReached() -> Bool {
    return this.m_pingLinksCounter >= this.GetMaxFreePingLinks();
  }

  private final const func IsActivePingsLimitReached() -> Bool {
    return ArraySize(this.m_activePings) > this.GetMaximumNumberOfActivePings();
  }

  private final func OnAddPingedSquadRequest(request: ref<AddPingedSquadRequest>) -> Void {
    this.AddPingedSquad(request.squadName);
  }

  private final func AddPingedSquad(squadName: CName) -> Void {
    if !ArrayContains(this.m_pingedSquads, squadName) {
      ArrayPush(this.m_pingedSquads, squadName);
    };
  }

  private final func OnRemovePingedSquadRequest(request: ref<RemovePingedSquadRequest>) -> Void {
    this.RemovePingedSquad(request.squadName);
  }

  private final func RemovePingedSquad(squadName: CName) -> Void {
    ArrayRemove(this.m_pingedSquads, squadName);
  }

  private final func OnClearPingedSquadRequest(request: ref<ClearPingedSquadRequest>) -> Void {
    this.ClearPingedSquads();
  }

  private final func ClearPingedSquads() -> Void {
    if ArraySize(this.m_pingedSquads) > 0 {
      ArrayClear(this.m_pingedSquads);
    };
  }

  public final const func IsSquadMarkedWithPing(squadName: CName) -> Bool {
    return ArrayContains(this.m_pingedSquads, squadName);
  }

  private final func HasDiffrentParentsThanTargets(sourceID: EntityID, targets: array<EntityID>) -> Bool {
    let i: Int32;
    let k: Int32;
    let sourceParents: array<ref<LazyDevice>>;
    let targetParents: array<ref<LazyDevice>>;
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetLazyParents(sourceID, sourceParents);
    if ArraySize(sourceParents) == 0 {
      return false;
    };
    i = 0;
    while i < ArraySize(targets) {
      GameInstance.GetDeviceSystem(this.GetGameInstance()).GetLazyParents(targets[i], targetParents);
      k = 0;
      while k < ArraySize(targetParents) {
        if !ArrayContains(sourceParents, targetParents[k]) {
          return true;
        };
        k += 1;
      };
      i += 1;
    };
    return false;
  }

  private final func HasDiffrentChildrenThanTargets(sourceID: EntityID, targets: array<EntityID>) -> Bool {
    let i: Int32;
    let k: Int32;
    let sourceChildren: array<ref<LazyDevice>>;
    let targetChildren: array<ref<LazyDevice>>;
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetLazyChildren(sourceID, sourceChildren);
    if ArraySize(sourceChildren) == 0 {
      return false;
    };
    i = 0;
    while i < ArraySize(targets) {
      GameInstance.GetDeviceSystem(this.GetGameInstance()).GetLazyChildren(targets[i], targetChildren);
      k = 0;
      while k < ArraySize(targetChildren) {
        if !ArrayContains(sourceChildren, targetChildren[k]) {
          return true;
        };
        k += 1;
      };
      i += 1;
    };
    return false;
  }

  private final func ResolveNetworkRevealTarget(linkData: SNetworkLinkData) -> Void {
    let ignoreNetworkReveal: Bool;
    let currentTargets: array<EntityID> = this.m_networkRevealTargets;
    let hasTargets: Bool = ArraySize(currentTargets) > 0;
    if this.HasActivePingWithRevealNetwork(linkData.slaveID) {
      if hasTargets {
        ignoreNetworkReveal = !this.HasDiffrentChildrenThanTargets(linkData.masterID, currentTargets) && !this.HasDiffrentParentsThanTargets(linkData.masterID, currentTargets);
      };
      if !ignoreNetworkReveal {
        this.AddNetworkRevealTarget(linkData.masterID);
        ignoreNetworkReveal = false;
      };
    };
    if this.HasActivePingWithRevealNetwork(linkData.masterID) {
      if hasTargets {
        ignoreNetworkReveal = !this.HasDiffrentChildrenThanTargets(linkData.slaveID, currentTargets) && !this.HasDiffrentParentsThanTargets(linkData.slaveID, currentTargets);
      };
      if !ignoreNetworkReveal {
        this.AddNetworkRevealTarget(linkData.slaveID);
        ignoreNetworkReveal = false;
      };
    };
  }

  private final func AddNetworkRevealTarget(target: EntityID) -> Void {
    if !ArrayContains(this.m_networkRevealTargets, target) {
      ArrayPush(this.m_networkRevealTargets, target);
    };
  }

  private final func RemoveNetworkRevealTarget(index: Int32) -> Void {
    if index >= 0 && index < ArraySize(this.m_networkRevealTargets) {
      ArrayErase(this.m_networkRevealTargets, index);
    };
  }

  private final func RevealNetworkOnCachedTarget(targets: array<EntityID>) -> Void {
    let i: Int32;
    let k: Int32;
    let pingData: ref<PingCachedData>;
    if ArraySize(targets) == 0 {
      return;
    };
    pingData = new PingCachedData();
    pingData.Initialize(this.GetSpacePingDuration(), ArraySize(targets) - 1);
    i = ArraySize(this.m_networkRevealTargets) - 1;
    while i >= 0 {
      k = 0;
      while k < ArraySize(targets) {
        if this.m_networkRevealTargets[i] == targets[k] {
          if EntityID.IsDefined(this.m_networkRevealTargets[i]) && !this.HasActivePing(targets[k]) {
            this.SendRevealNetworkEvent(this.m_networkRevealTargets[i], true);
          };
          ArrayErase(this.m_networkRevealTargets, i);
        };
        k += 1;
      };
      i -= 1;
    };
  }

  private final func RevealEntireNetworkOnTarget(target: EntityID) -> Void {
    let i: Int32;
    this.SendRevealNetworkEvent(target);
    i = 0;
    while i < ArraySize(this.m_networkLinks) {
      if this.m_networkLinks[i].slaveID == target {
        if EntityID.IsDefined(this.m_networkLinks[i].masterID) {
          this.SendRevealNetworkEvent(this.m_networkLinks[i].masterID);
        } else {
        };
      } else {
        if this.m_networkLinks[i].masterID == target {
          if EntityID.IsDefined(this.m_networkLinks[i].slaveID) {
            this.SendRevealNetworkEvent(this.m_networkLinks[i].slaveID);
          } else {
            i += 1;
          };
        } else {
        };
      };
      i += 1;
    };
  }

  private final func OnRevealNetworkRequestRequest(request: ref<RevealNetworkRequestRequest>) -> Void {
    this.SendRevealNetworkEvent(request.target, request.nextFrame, request.delay);
  }

  private final func SendRevealNetworkEvent(target: EntityID, opt nextFrame: Bool, opt delay: Float) -> Void {
    let request: ref<RevealNetworkRequestRequest>;
    let evt: ref<RevealNetworkGridOnPulse> = new RevealNetworkGridOnPulse();
    evt.duration = this.GetPingRevealDuration();
    evt.revealSlave = this.ShouldRevealSlaveOnPulse();
    evt.revealMaster = this.ShouldRevealMasterOnPulse();
    if delay > 0.00 || nextFrame {
      request = new RevealNetworkRequestRequest();
      request.target = target;
      request.delay = 0.00;
      request.nextFrame = false;
      if nextFrame {
        GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequestNextFrame(this.GetClassName(), request);
      } else {
        GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(this.GetClassName(), request, delay, false);
      };
    } else {
      GameInstance.GetPersistencySystem(this.GetGameInstance()).QueueEntityEvent(target, evt);
    };
  }

  private final func SendRevealNetworkGridRequest(target: EntityID) -> Void {
    let evt: ref<RevealNetworkGridNetworkRequest> = new RevealNetworkGridNetworkRequest();
    GameInstance.GetPersistencySystem(this.GetGameInstance()).QueueEntityEvent(target, evt);
  }

  private final func IsIdValid(id: EntityID) -> Bool {
    let emptyID: EntityID;
    return EntityID.IsDefined(id) && id != emptyID;
  }

  private final const func GetVirtualNetworkRecord() -> wref<VirtualNetwork_Record> {
    let record: ref<VirtualNetwork_Record> = this.GetPingPresetRecord().VirtualNetwork();
    return record;
  }

  private final const func GetVirtualNetworkSegmentMarker(virtualNetworkRecord: wref<VirtualNetwork_Record>) -> Vector4 {
    let segmentMarker: Vector3 = virtualNetworkRecord.SegmentMarker();
    return new Vector4(segmentMarker.X, segmentMarker.Y, segmentMarker.Z, 0.00);
  }

  private final func GetMaxNumberOfSegmentsForVirtualNetwork(virtualNetworkRecord: wref<VirtualNetwork_Record>) -> Int32 {
    let currentSegments: Int32;
    let i: Int32;
    let paths: array<wref<VirtualNetworkPath_Record>>;
    let points: array<Vector3>;
    let segments: Int32;
    virtualNetworkRecord.Paths(paths);
    i = 0;
    while i < ArraySize(paths) {
      points = paths[i].Points();
      currentSegments = ArraySize(points) - 1;
      if i == 0 {
        segments = currentSegments;
      } else {
        if currentSegments > segments {
          segments = currentSegments;
        };
      };
      i += 1;
    };
    return segments;
  }

  private final const func GetPingRange() -> Float {
    return this.GetPingPresetRecord().PingRange();
  }

  public final const func GetSpacePingDuration() -> Float {
    return this.GetPingPresetRecord().SpacePingDuration();
  }

  public final const func GetSpacePingAppearModifier() -> Float {
    return this.GetPingPresetRecord().SpacePingAppearModifier();
  }

  public final const func GetNetworkReavealDuration() -> Float {
    return this.GetPingPresetRecord().NetworkRevealDuration();
  }

  public final const func ShouldNetworkElementsPersistAfterFocus() -> Bool {
    return this.GetPingPresetRecord().ShouldNetworkElementsPersistAfterFocus();
  }

  private final const func ShouldForceInstantBeamKill() -> Bool {
    return this.GetPingPresetRecord().ForceInstantBeamKill();
  }

  public final const func GetRevealMasterAfterLeavingFocusDuration() -> Float {
    let duration: Float;
    let player: ref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
    if IsDefined(player) {
      duration = player.GetPingDuration();
    };
    if duration <= 0.00 {
      duration = this.GetPingPresetRecord().RevealMasterAfterLeavingFocusDuration();
    };
    return duration;
  }

  public final const func GetRevealLinksAfterLeavingFocusDuration() -> Float {
    return this.GetPingPresetRecord().RevealLinksAfterLeavingFocusDuration();
  }

  private final const func GetPingRevealDuration() -> Float {
    return this.GetPingPresetRecord().NetworkRevealDuration();
  }

  private final const func GetAmmountOfPingDurationIntervals() -> Int32 {
    return this.GetPingPresetRecord().AmmountOfIntervals();
  }

  private final const func GetMaxFreePingLinks() -> Int32 {
    return this.GetPingPresetRecord().MaxFreePingLinks();
  }

  private final static func GetMaxLinksDrawnInTotal() -> Int32 {
    return 23;
  }

  private final static func GetMaxLinksDrawnAtOnce() -> Int32 {
    return 10;
  }

  private final static func GetMaxLinksDeactivatedAtOnce() -> Int32 {
    return 10;
  }

  private final static func GetMaxLinksRegisteredAtOnce() -> Int32 {
    return 10;
  }

  private final static func GetMaximumNumberOfFreeLinksPerTarget() -> Int32 {
    return 20;
  }

  private final const func GetMaximumNumberOfActivePings() -> Int32 {
    return 10;
  }

  private final const func GetNumberOfVirtualLinksPerObject() -> Int32 {
    return 10;
  }

  private final const func GetVirtualLinkDepth() -> Int32 {
    return 6;
  }

  private final const func GetVirtualLinkAngleTollerance() -> Float {
    return Deg2Rad(45.00);
  }

  private final const func GetVirtualLinkForkAngleTollerance() -> Float {
    return Deg2Rad(45.00);
  }

  private final const func GetMaxAmountOfVirtualLinkForks() -> Int32 {
    return 2;
  }

  private final const func GetVirtualLinksSphereRadius() -> Float {
    return 25.00;
  }

  private final const func ShouldRevealMasterOnPulse() -> Bool {
    return this.GetPingPresetRecord().RevealMaster();
  }

  private final const func ShouldRevealSlaveOnPulse() -> Bool {
    return this.GetPingPresetRecord().RevealSlave();
  }

  public final const func SuppressPingIfBackdoorsFound() -> Bool {
    return this.GetPingPresetRecord().SuppressPingIfBackdoorsFound();
  }

  public final const func AllowSimultanousPinging() -> Bool {
    return this.GetPingPresetRecord().AllowSimultanousPinging();
  }

  public final const func ShouldRevealNetworkAfterPulse() -> Bool {
    return this.GetPingPresetRecord().ShouldRevealNetworkAfterPulse();
  }

  public final const func ShouldUsePulseOnPing() -> Bool {
    return this.GetPingPresetRecord().UsePulse();
  }

  public final const func GetPulseRange() -> Float {
    return this.GetPingPresetRecord().PulseRange();
  }

  public final const func ShouldPulsRealObject() -> Bool {
    return this.GetPingPresetRecord().PulseRealObjects();
  }

  public final const func ShouldShowLinksOnMaster() -> Bool {
    return this.GetPingPresetRecord().ReavealNetworkOnMaster();
  }

  public final const func QuickHacksExposedByDefault() -> Bool {
    return this.GetPingPresetRecord().QuickHacksExposedByDefaul();
  }

  public final static func QuickHacksExposedByDefault(game: GameInstance) -> Bool {
    let networkSystem: ref<NetworkSystem>;
    if GameInstance.IsValid(game) {
      networkSystem = GameInstance.GetScriptableSystemsContainer(game).Get(n"NetworkSystem") as NetworkSystem;
      return networkSystem.QuickHacksExposedByDefault();
    };
    return false;
  }

  public final const func ShouldShowOnlyTargetQuickHacks() -> Bool {
    return this.GetPingPresetRecord().ShowOnlyTargetQuickHacks();
  }

  public final static func ShouldShowOnlyTargetQuickHacks(game: GameInstance) -> Bool {
    let networkSystem: ref<NetworkSystem>;
    if GameInstance.IsValid(game) {
      networkSystem = GameInstance.GetScriptableSystemsContainer(game).Get(n"NetworkSystem") as NetworkSystem;
      return networkSystem.ShouldShowOnlyTargetQuickHacks();
    };
    return false;
  }

  private final const func GetPingPresetRecord() -> wref<NetworkPingingParameteres_Record> {
    return this.m_networkPresetRecord;
  }

  private final func SetupPingPresetRecord() -> Void {
    if TDBID.IsValid(this.m_networkPresetTBDID) {
      this.m_networkPresetRecord = TweakDBInterface.GetNetworkPresetBinderParametersRecord(this.m_networkPresetTBDID).PingPresetID();
    };
  }

  public final const func GetLastPingSourceID() -> EntityID {
    return this.m_lastPingSourceID;
  }

  private final func FindBestMatchingVertice(point: Vector4, direction: Vector4, angle: Float, radius: Float, excludeVertice: Vector4, vertices: array<Vector4>) -> Vector4 {
    let currentAngle: Float;
    let distance: Float;
    let foundVertice: Vector4;
    let foundVerticeDirection: Vector4;
    let bestAngle: Float = angle;
    let i: Int32 = 0;
    while i < ArraySize(vertices) {
      if Equals(vertices[i], excludeVertice) {
      } else {
        distance = Vector4.Distance(point, vertices[i]);
        if distance > radius {
        } else {
          foundVerticeDirection = Vector4.Normalize(vertices[i] - point);
          currentAngle = Vector4.GetAngleBetween(direction, foundVerticeDirection);
          if currentAngle > angle {
          } else {
            if currentAngle < bestAngle {
              bestAngle = currentAngle;
              foundVertice = vertices[i];
            };
          };
        };
      };
      i += 1;
    };
    return foundVertice;
  }

  private final func GetRandomPoint(direction: Vector4, radius: Float, angle: Float) -> Vector4 {
    let halfAngle: Float;
    let orientation: EulerAngles;
    let quat: Quaternion;
    let minAngle: Float = Deg2Rad(20.00);
    let point: Vector4 = direction;
    if angle > 0.00 {
      halfAngle = angle * 0.50;
      orientation.Pitch = RandRangeF(-halfAngle, halfAngle);
      orientation.Yaw = RandRangeF(-halfAngle, halfAngle);
      orientation.Pitch = SgnF(orientation.Pitch) * minAngle + orientation.Pitch;
      orientation.Yaw = SgnF(orientation.Yaw) * minAngle + orientation.Yaw;
      Quaternion.SetYRot(quat, orientation.Pitch);
      point = quat * point;
      Quaternion.SetZRot(quat, orientation.Yaw);
      point = quat * point;
      point = Vector4.Normalize(point);
    };
    point = point * radius;
    return point;
  }

  private final func GetRandomPointOnSphere(sphereCentre: Vector4, radius: Float, slice: Int32) -> Vector4 {
    let angleIncrementPhi: Float;
    let angleIncrementTheta: Float;
    let maxAnglePhi: Float;
    let maxAngleTheta: Float;
    let minAnglePhi: Float;
    let minAngleTheta: Float;
    let phi: Float;
    let point: Vector4;
    let theta: Float;
    if this.GetNumberOfVirtualLinksPerObject() > 0 {
      angleIncrementPhi = (2.00 * Pi()) / Cast(this.GetNumberOfVirtualLinksPerObject());
      angleIncrementTheta = HalfPi() / Cast(this.GetNumberOfVirtualLinksPerObject());
      minAngleTheta = Cast(slice) * angleIncrementTheta;
      maxAngleTheta = Cast(slice + 1) * angleIncrementTheta;
      minAnglePhi = Cast(slice) * angleIncrementPhi;
      maxAnglePhi = Cast(slice + 1) * angleIncrementPhi;
      theta = RandRangeF(minAngleTheta, maxAngleTheta);
      phi = RandRangeF(minAnglePhi, maxAnglePhi);
      point.X = sphereCentre.X + radius * SinF(phi) * CosF(theta);
      point.Y = sphereCentre.Y + radius * SinF(phi) * SinF(theta);
      point.Z = sphereCentre.Z + radius * CosF(theta);
    };
    return point;
  }

  private final func GetRandomPointOnSphere(sphereCentre: Vector4, radius: Float) -> Vector4 {
    let point: Vector4;
    let u: Float = RandF();
    let v: Float = RandF();
    let theta: Float = 2.00 * Pi() * u;
    let phi: Float = AcosF(2.00 * v - 1.00);
    point.X = sphereCentre.X + radius * SinF(phi) * CosF(theta);
    point.Y = sphereCentre.Y + radius * SinF(phi) * SinF(theta);
    point.Z = sphereCentre.Z + radius * CosF(phi);
    return point;
  }

  private final func GetRandomPointOnSphereQuadrant0() -> Vector4 {
    let point: Vector4;
    let u: Float = RandF();
    let v: Float = RandF();
    let theta: Float = Pi() * u * 0.50;
    let cosPhi: Float = SqrtF(1.00 - v);
    let sinPhi: Float = SqrtF(1.00 - cosPhi * cosPhi);
    point.X = sinPhi * CosF(theta);
    point.Y = sinPhi * SinF(theta);
    point.Z = cosPhi;
    return point;
  }

  private final func GetRandomPointOnSphereInFacingQuadrant(sphereCenter: Vector4, radius: Float, facePoint: Vector4) -> Vector4 {
    let point: Vector4 = this.GetRandomPointOnSphereQuadrant0();
    if facePoint.X < sphereCenter.X {
      point.X = -point.X;
    };
    if facePoint.Y < sphereCenter.Y {
      point.Y = -point.Y;
    };
    if facePoint.Z < sphereCenter.Z {
      point.Z = -point.Z;
    };
    point.X = sphereCenter.X + point.X * radius;
    point.Y = sphereCenter.Y + point.Y * radius;
    point.Z = sphereCenter.Z + point.Z * radius;
    return point;
  }

  public final const func GetHudManager() -> ref<HUDManager> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"HUDManager") as HUDManager;
  }
}
