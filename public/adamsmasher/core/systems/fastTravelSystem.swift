
public native class FastTravelPointData extends IScriptable {

  private native persistent let pointRecord: TweakDBID;

  private native persistent let markerRef: NodeRef;

  private native persistent let requesterID: EntityID;

  public let mappinID: NewMappinID;

  public final native func IsValid() -> Bool;

  public final const func GetPointDisplayName() -> String {
    return TweakDBInterface.GetFastTravelPointRecord(this.pointRecord).DisplayName();
  }

  public final const func GetPointDisplayDescription() -> String {
    return TweakDBInterface.GetFastTravelPointRecord(this.pointRecord).Description();
  }

  public final const func GetDistrictDisplayName() -> String {
    return TweakDBInterface.GetFastTravelPointRecord(this.pointRecord).District().LocalizedName();
  }

  public final const func ShouldShowMappinOnWorldMap() -> Bool {
    return TweakDBInterface.GetFastTravelPointRecord(this.pointRecord).ShowOnWorldMap();
  }

  public final const func ShouldShowMappinInWorld() -> Bool {
    return TweakDBInterface.GetFastTravelPointRecord(this.pointRecord).ShowInWorld();
  }

  public final const func GetPointRecord() -> TweakDBID {
    return this.pointRecord;
  }

  public final const func GetMarkerRef() -> NodeRef {
    return this.markerRef;
  }

  public final const func GetRequesterID() -> EntityID {
    return this.requesterID;
  }

  public final const func HasReqesterID() -> Bool {
    return EntityID.IsDefined(this.requesterID);
  }

  public final func SetRequesterID(id: EntityID) -> Void {
    this.requesterID = id;
  }
}

public class EnableFastTravelRequest extends ScriptableSystemRequest {

  public edit let isEnabled: Bool;

  @default(EnableFastTravelRequest, true)
  public edit let forceRefreshUI: Bool;

  @default(EnableFastTravelRequest, quest)
  public edit let reason: CName;

  public let linkedStatusEffectID: TweakDBID;

  public final func GetFriendlyDescription() -> String {
    return "Enable Fast Travel";
  }
}

public class RegisterFastTravelPointsRequest extends ScriptableSystemRequest {

  public inline edit let fastTravelNodes: array<ref<FastTravelPointData>>;

  @default(RegisterFastTravelPointsRequest, true)
  public edit let register: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Register Fast Travel Points";
  }
}

public class FastTravelSystem extends ScriptableSystem {

  private persistent let m_fastTravelNodes: array<ref<FastTravelPointData>>;

  @default(FastTravelSystem, false)
  private let m_isFastTravelEnabledOnMap: Bool;

  @default(FastTravelSystem, 149)
  private persistent const let m_fastTravelPointsTotal: Int32;

  @default(FastTravelSystem, -1)
  private persistent let m_lastUpdatedAchievementCount: Int32;

  private persistent let m_fastTravelLocks: array<FastTravelSystemLock>;

  private let m_loadingScreenCallbackID: ref<CallbackHandle>;

  private let m_requestAutoSafeAfterLoadingScreen: Bool;

  private let m_lockLisenerID: CName;

  private let m_unlockLisenerID: CName;

  private let m_removeAllLocksLisenerID: CName;

  private func OnAttach() -> Void {
    this.RegisterLoadingScreenCallback();
    if !IsFinal() {
      this.InitializeDebugButtons();
      this.ShowDebug();
    };
  }

  private func OnDetach() -> Void {
    this.UnregisterLoadingCallback();
    if !IsFinal() {
      this.UninitializeDebugButtons();
    };
  }

  private func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void {
    this.RestoreFastTravelMappins();
    this.EvaluateFastTravelLocksOnRestore();
    this.CheckForScottieAchievement();
  }

  protected final func RegisterLoadingScreenCallback() -> Void {
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().FastTRavelSystem);
    if IsDefined(blackboard) && !IsDefined(this.m_loadingScreenCallbackID) {
      this.m_loadingScreenCallbackID = blackboard.RegisterListenerBool(GetAllBlackboardDefs().FastTRavelSystem.FastTravelLoadingScreenFinished, this, n"OnLoadingScreenFinished");
    };
  }

  protected final func UnregisterLoadingCallback() -> Void {
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().FastTRavelSystem);
    if blackboard != null && IsDefined(this.m_loadingScreenCallbackID) {
      blackboard.UnregisterListenerBool(GetAllBlackboardDefs().FastTRavelSystem.FastTravelLoadingScreenFinished, this.m_loadingScreenCallbackID);
    };
  }

  private final func AddFastTravelPoint(nodeData: ref<FastTravelPointData>) -> Void {
    let existingData: ref<FastTravelPointData>;
    if IsDefined(nodeData) && nodeData.IsValid() {
      existingData = this.GetFastTravelPoint(nodeData);
      if IsDefined(existingData) {
        if !existingData.HasReqesterID() && nodeData.HasReqesterID() {
          this.UnregisterMappin(existingData);
          existingData.SetRequesterID(nodeData.GetRequesterID());
          this.RegisterMappin(existingData);
        };
        if nodeData.GetRequesterID() == existingData.GetRequesterID() {
          nodeData.mappinID = existingData.mappinID;
        };
      } else {
        ArrayPush(this.m_fastTravelNodes, nodeData);
        this.RegisterMappin(nodeData);
        this.TutorialAddFastTravelFact();
        if nodeData.ShouldShowMappinOnWorldMap() {
          this.CheckForScottieAchievement();
        };
      };
      if !IsFinal() {
        this.ShowDebug();
      };
    };
  }

  protected cb func OnLoadingScreenFinished(value: Bool) -> Bool {
    if value {
      if this.m_requestAutoSafeAfterLoadingScreen {
        this.RequestAutoSaveWithDelay();
      };
      this.m_requestAutoSafeAfterLoadingScreen = false;
    };
  }

  private final func CheckForScottieAchievement() -> Void {
    let achievementProgressRequest: ref<SetAchievementProgressRequest>;
    let achievementRequest: ref<AddAchievementRequest>;
    let achievement: gamedataAchievement = gamedataAchievement.GetMeThereScottie;
    let dataTrackingSystem: ref<DataTrackingSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"DataTrackingSystem") as DataTrackingSystem;
    let pointsOnMap: Int32 = this.GetAmmountOfFastTravelPointsOnMap();
    if this.m_lastUpdatedAchievementCount <= 0 {
      this.m_lastUpdatedAchievementCount = 0;
    };
    if pointsOnMap % 2 == 0 && pointsOnMap != this.m_lastUpdatedAchievementCount {
      achievementProgressRequest = new SetAchievementProgressRequest();
      achievementProgressRequest.achievement = achievement;
      achievementProgressRequest.currentValue = pointsOnMap;
      achievementProgressRequest.maxValue = this.m_fastTravelPointsTotal;
      dataTrackingSystem.QueueRequest(achievementProgressRequest);
      this.m_lastUpdatedAchievementCount = pointsOnMap;
    };
    if pointsOnMap >= this.m_fastTravelPointsTotal {
      achievementRequest = new AddAchievementRequest();
      achievementRequest.achievement = achievement;
      dataTrackingSystem.QueueRequest(achievementRequest);
    };
  }

  private final func RemoveFastTravelPoint(nodeData: ref<FastTravelPointData>) -> Void {
    let i: Int32 = ArraySize(this.m_fastTravelNodes) - 1;
    while i >= 0 {
      if Equals(this.m_fastTravelNodes[i].GetMarkerRef(), nodeData.GetMarkerRef()) && this.m_fastTravelNodes[i].GetPointRecord() == nodeData.GetPointRecord() {
        this.UnregisterMappin(this.m_fastTravelNodes[i]);
        this.m_fastTravelNodes[i] = null;
        ArrayErase(this.m_fastTravelNodes, i);
      };
      i -= 1;
    };
    if !IsFinal() {
      this.ShowDebug();
    };
  }

  public final const func HasFastTravelPoint(nodeData: ref<FastTravelPointData>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_fastTravelNodes) {
      if Equals(this.m_fastTravelNodes[i].GetMarkerRef(), nodeData.GetMarkerRef()) && this.m_fastTravelNodes[i].GetPointRecord() == nodeData.GetPointRecord() {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func GetFastTravelPoint(nodeData: ref<FastTravelPointData>) -> ref<FastTravelPointData> {
    let i: Int32 = 0;
    while i < ArraySize(this.m_fastTravelNodes) {
      if Equals(this.m_fastTravelNodes[i].GetMarkerRef(), nodeData.GetMarkerRef()) && this.m_fastTravelNodes[i].GetPointRecord() == nodeData.GetPointRecord() {
        return this.m_fastTravelNodes[i];
      };
      i += 1;
    };
    return null;
  }

  public final const func IsFastTravelEnabledOnMap() -> Bool {
    return this.m_isFastTravelEnabledOnMap && ArraySize(this.m_fastTravelLocks) <= 0;
  }

  public final const func GetFastTravelPoints() -> array<ref<FastTravelPointData>> {
    let points: array<ref<FastTravelPointData>> = this.m_fastTravelNodes;
    return points;
  }

  public final const func GetAmmountOfFastTravelPointsOnMap() -> Int32 {
    let count: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_fastTravelNodes) {
      if this.m_fastTravelNodes[i].ShouldShowMappinOnWorldMap() {
        count += 1;
      };
      i += 1;
    };
    return count;
  }

  private final func PerformFastTravel(player: ref<GameObject>, nodeData: ref<FastTravelPointData>) -> Void {
    let blackBoard: ref<IBlackboard>;
    let playerPuppet: ref<PlayerPuppet>;
    if this.HasFastTravelPoint(nodeData) {
      PlayerGameplayRestrictions.RemoveAllGameplayRestrictions(player);
      GameInstance.GetTeleportationFacility(this.GetGameInstance()).TeleportToNode(player, nodeData.GetMarkerRef());
      blackBoard = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().FastTRavelSystem);
      blackBoard.SetVariant(GetAllBlackboardDefs().FastTRavelSystem.DestinationPoint, ToVariant(nodeData.GetPointRecord()));
      this.m_requestAutoSafeAfterLoadingScreen = true;
      playerPuppet = player as PlayerPuppet;
      if IsDefined(playerPuppet) {
        playerPuppet.GetFPPCameraComponent().ResetPitch();
      };
    };
  }

  private final func AddFastTravelLock(reason: CName, opt statusEffectID: TweakDBID) -> Void {
    let i: Int32;
    let newLock: FastTravelSystemLock;
    if IsNameValid(reason) {
      i = 0;
      while i < ArraySize(this.m_fastTravelLocks) {
        if Equals(this.m_fastTravelLocks[i].lockReason, reason) {
          return;
        };
        i += 1;
      };
      newLock.lockReason = reason;
      newLock.linkedStatusEffectID = statusEffectID;
      ArrayPush(this.m_fastTravelLocks, newLock);
      if !IsFinal() {
        this.ShowDebug();
      };
    };
  }

  private final func RemoveFastTravelLock(reason: CName) -> Void {
    let i: Int32;
    if IsNameValid(reason) {
      i = 0;
      while i < ArraySize(this.m_fastTravelLocks) {
        if Equals(this.m_fastTravelLocks[i].lockReason, reason) {
          ArrayErase(this.m_fastTravelLocks, i);
          if !IsFinal() {
            this.ShowDebug();
          };
          return;
        };
        i += 1;
      };
    };
  }

  private final func EvaluateFastTravelLocksOnRestore() -> Void {
    let i: Int32;
    let isCurrentlyEnabled: Bool;
    let player: wref<PlayerPuppet>;
    if ArraySize(this.m_fastTravelLocks) == 0 {
      return;
    };
    player = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    isCurrentlyEnabled = this.IsFastTravelEnabled();
    i = ArraySize(this.m_fastTravelLocks) - 1;
    while i >= 0 {
      if TDBID.IsValid(this.m_fastTravelLocks[i].linkedStatusEffectID) {
        if !StatusEffectSystem.ObjectHasStatusEffect(player, this.m_fastTravelLocks[i].linkedStatusEffectID) {
          ArrayErase(this.m_fastTravelLocks, i);
        };
      };
      i -= 1;
    };
    if NotEquals(isCurrentlyEnabled, this.IsFastTravelEnabled()) {
      this.RefreshFastTravelNodes();
    };
  }

  public final const func IsFastTravelEnabled() -> Bool {
    return ArraySize(this.m_fastTravelLocks) <= 0;
  }

  private final func RegisterFastTravelPoint(pointData: ref<FastTravelPointData>, requesterID: EntityID) -> Void {
    let evt: ref<FastTravelPointsUpdated>;
    let player: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(player, n"BlockFastTravel") {
      this.TutorialAddFastTravelFact();
      return;
    };
    pointData.SetRequesterID(requesterID);
    this.AddFastTravelPoint(pointData);
    if EntityID.IsDefined(requesterID) {
      evt = new FastTravelPointsUpdated();
      evt.updateTrackingAlternative = true;
      GameInstance.GetPersistencySystem(this.GetGameInstance()).QueueEntityEvent(requesterID, evt);
    };
  }

  private final func UnregisterFastTravelPoint(pointData: ref<FastTravelPointData>, requesterID: EntityID) -> Void {
    let evt: ref<FastTravelPointsUpdated>;
    this.RemoveFastTravelPoint(pointData);
    if EntityID.IsDefined(requesterID) {
      evt = new FastTravelPointsUpdated();
      GameInstance.GetPersistencySystem(this.GetGameInstance()).QueueEntityEvent(requesterID, evt);
    };
  }

  private final func RefreshFastTravelNodes() -> Void {
    let evt: ref<FastTravelPointsUpdated>;
    let requesterID: EntityID;
    let i: Int32 = 0;
    while i < ArraySize(this.m_fastTravelNodes) {
      requesterID = this.m_fastTravelNodes[i].GetRequesterID();
      if EntityID.IsDefined(requesterID) {
        evt = new FastTravelPointsUpdated();
        GameInstance.GetPersistencySystem(this.GetGameInstance()).QueueEntityEvent(requesterID, evt);
      };
      i += 1;
    };
  }

  private final func RegisterMappin(nodeData: ref<FastTravelPointData>) -> Void {
    let mappinData: MappinData;
    if !nodeData.ShouldShowMappinOnWorldMap() {
      return;
    };
    mappinData.mappinType = t"Mappins.FastTravelStaticMappin";
    mappinData.variant = gamedataMappinVariant.FastTravelVariant;
    mappinData.active = true;
    nodeData.mappinID = GameInstance.GetMappinSystem(this.GetGameInstance()).RegisterFastTravelMappin(mappinData, nodeData);
  }

  private final func UnregisterMappin(nodeData: ref<FastTravelPointData>) -> Void {
    let invalidID: NewMappinID;
    if !nodeData.ShouldShowMappinOnWorldMap() {
      return;
    };
    GameInstance.GetMappinSystem(this.GetGameInstance()).UnregisterMappin(nodeData.mappinID);
    nodeData.mappinID = invalidID;
  }

  private final func OnRegisterFastTravelPointsRequest(request: ref<RegisterFastTravelPointsRequest>) -> Void {
    let requesterID: EntityID;
    let i: Int32 = 0;
    while i < ArraySize(request.fastTravelNodes) {
      if request.register {
        this.RegisterFastTravelPoint(request.fastTravelNodes[i], requesterID);
      } else {
        this.UnregisterFastTravelPoint(request.fastTravelNodes[i], requesterID);
      };
      i += 1;
    };
  }

  private final func OnEnableFastTravelRequest(request: ref<EnableFastTravelRequest>) -> Void {
    let isCurrentlyEnabled: Bool = this.IsFastTravelEnabled();
    if request.isEnabled {
      this.RemoveFastTravelLock(request.reason);
    } else {
      this.AddFastTravelLock(request.reason, request.linkedStatusEffectID);
    };
    if request.forceRefreshUI {
      if NotEquals(isCurrentlyEnabled, this.IsFastTravelEnabled()) {
        this.RefreshFastTravelNodes();
      };
    };
  }

  private final func OnRemoveAllFastTravelLocksRequest(request: ref<RemoveAllFastTravelLocksRequest>) -> Void {
    let isCurrentlyEnabled: Bool = this.IsFastTravelEnabled();
    if ArraySize(this.m_fastTravelLocks) > 0 {
      ArrayClear(this.m_fastTravelLocks);
      if NotEquals(isCurrentlyEnabled, this.IsFastTravelEnabled()) {
        this.RefreshFastTravelNodes();
      };
      if !IsFinal() {
        this.ShowDebug();
      };
    };
  }

  private final func OnRegisterFastTravelPointRequest(request: ref<RegisterFastTravelPointRequest>) -> Void {
    this.RegisterFastTravelPoint(request.pointData, request.requesterID);
  }

  private final func OnUnregisterFastTravelPointRequest(request: ref<UnregisterFastTravelPointRequest>) -> Void {
    this.UnregisterFastTravelPoint(request.pointData, request.requesterID);
  }

  private final func OnPerformFastTravelRequest(request: ref<PerformFastTravelRequest>) -> Void {
    this.PerformFastTravel(request.player, request.pointData);
  }

  private final func OnToggleFastTravelAvailabilityOnMapRequest(evt: ref<ToggleFastTravelAvailabilityOnMapRequest>) -> Void {
    let blackBoard: ref<IBlackboard>;
    this.m_isFastTravelEnabledOnMap = evt.isEnabled;
    if evt.isEnabled {
      blackBoard = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().FastTRavelSystem);
      blackBoard.SetVariant(GetAllBlackboardDefs().FastTRavelSystem.StartingPoint, ToVariant(evt.pointRecord));
    };
  }

  private final func OnRequestAutoSave(request: ref<AutoSaveRequest>) -> Void {
    this.RequestAutoSave();
  }

  private final func RequestAutoSaveWithDelay() -> Void {
    let request: ref<AutoSaveRequest> = new AutoSaveRequest();
    GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(this.GetClassName(), request, 0.50, false);
  }

  private final func RequestAutoSave() -> Void {
    GameInstance.GetAutoSaveSystem(this.GetGameInstance()).RequestCheckpoint();
  }

  private final func RestoreFastTravelMappins() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_fastTravelNodes) {
      this.RegisterMappin(this.m_fastTravelNodes[i]);
      i += 1;
    };
  }

  private final func TutorialAddFastTravelFact() -> Void {
    let questSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetGameInstance());
    if questSystem.GetFact(n"fast_travel_tutorial") != 0 && questSystem.GetFact(n"fast_travel_tutorial_seen") == 0 {
      questSystem.SetFact(n"fast_travel_tutorial", 0);
    } else {
      if questSystem.GetFact(n"fast_travel_tutorial") == 0 && questSystem.GetFact(n"disable_tutorials") == 0 && questSystem.GetFact(n"q001_in_v_room") != 0 && this.IsFastTravelEnabled() {
        questSystem.SetFact(n"fast_travel_tutorial", 1);
      };
    };
  }

  public final static func AddFastTravelLock(reason: CName, game: GameInstance, opt statusEffectID: TweakDBID) -> Void {
    FastTravelSystem.ManageFastTravelLock(false, reason, game, statusEffectID);
  }

  public final static func RemoveFastTravelLock(reason: CName, game: GameInstance, opt statusEffectID: TweakDBID) -> Void {
    FastTravelSystem.ManageFastTravelLock(true, reason, game, statusEffectID);
  }

  public final static func RemoveAllFastTravelLocks(game: GameInstance) -> Void {
    let request: ref<RemoveAllFastTravelLocksRequest> = new RemoveAllFastTravelLocksRequest();
    let ftSystem: ref<FastTravelSystem> = GameInstance.GetScriptableSystemsContainer(game).Get(n"FastTravelSystem") as FastTravelSystem;
    ftSystem.QueueRequest(request);
  }

  public final static func ManageFastTravelLock(enable: Bool, reason: CName, game: GameInstance, opt statusEffectID: TweakDBID) -> Void {
    let request: ref<EnableFastTravelRequest> = new EnableFastTravelRequest();
    request.isEnabled = enable;
    request.reason = reason;
    request.linkedStatusEffectID = statusEffectID;
    let ftSystem: ref<FastTravelSystem> = GameInstance.GetScriptableSystemsContainer(game).Get(n"FastTravelSystem") as FastTravelSystem;
    ftSystem.QueueRequest(request);
  }

  protected final func OnFastTravelConsoleInstructionRequest(request: ref<FastTravelConsoleInstructionRequest>) -> Void {
    switch request.instruction {
      case EFastTravelSystemInstruction.Forward:
        this.execInstructionForward(request.magicFloat);
        break;
      case EFastTravelSystemInstruction.Previous:
        this.execInstructionPrevious();
        break;
      default:
    };
  }

  private final func execInstructionForward(magicFloat: Float) -> Void {
    let position: Vector4;
    let rotation: EulerAngles;
    let player: ref<GameObject> = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerControlledGameObject();
    if !IsDefined(player) {
      return;
    };
    position = player.GetWorldPosition() + WorldTransform.GetForward(player.GetWorldTransform()) * magicFloat;
    GameInstance.GetTeleportationFacility(this.GetGameInstance()).Teleport(player, position, rotation);
  }

  private final func execInstructionPrevious() -> Void;

  private final func UninitializeDebugButtons() -> Void {
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, "FastTravel");
    SDOSink.UnregisterListener_OnClicked(sink, this, this.m_lockLisenerID);
    SDOSink.UnregisterListener_OnClicked(sink, this, this.m_unlockLisenerID);
    SDOSink.UnregisterListener_OnClicked(sink, this, this.m_removeAllLocksLisenerID);
  }

  private final func InitializeDebugButtons() -> Void {
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, "FastTravel");
    SDOSink.PushString(sink, "Lock", "EXECUTE");
    SDOSink.PushString(sink, "Unlock", "EXECUTE");
    SDOSink.PushString(sink, "RemoveAllLocks", "EXECUTE");
    this.m_lockLisenerID = SDOSink.RegisterListener_OnClicked(sink, this, "Lock");
    this.m_unlockLisenerID = SDOSink.RegisterListener_OnClicked(sink, this, "Unlock");
    this.m_removeAllLocksLisenerID = SDOSink.RegisterListener_OnClicked(sink, this, "RemoveAllLocks");
  }

  private final func OnDebugButtonClicked(request: ref<SDOClickedRequest>) -> Void {
    if Equals(request.key, n"Lock") {
      FastTravelSystem.AddFastTravelLock(n"DEBUG", this.GetGameInstance());
    } else {
      if Equals(request.key, n"Unlock") {
        FastTravelSystem.RemoveFastTravelLock(n"DEBUG", this.GetGameInstance());
      } else {
        if Equals(request.key, n"RemoveAllLocks") {
          FastTravelSystem.RemoveAllFastTravelLocks(this.GetGameInstance());
        };
      };
    };
  }

  private final func ShowDebug() -> Void {
    let dataTermID: String;
    let i: Int32;
    let lockReason: String;
    let markerRef: String;
    let record: String;
    let statusEffect: String;
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, "FastTravel");
    SDOSink.PushInt32(sink, "TOTAL_POINTS_ON_MAP:", this.m_fastTravelPointsTotal);
    SDOSink.PushInt32(sink, "CURRENT_POINTS_ON_MAP:", this.GetAmmountOfFastTravelPointsOnMap());
    SDOSink.PushString(sink, "ALL_REGISTERED_POINTS:", ToString(ArraySize(this.m_fastTravelNodes)));
    SDOSink.PushString(sink, "ACTIVE_LOCKS:", ToString(ArraySize(this.m_fastTravelLocks)));
    if ArraySize(this.m_fastTravelNodes) <= 0 {
      SDOSink.SetRoot(sink, "FastTravel/ALL_REGISTERED_POINTS:/POINT0");
      SDOSink.PushString(sink, "", "NONE");
      SDOSink.PushString(sink, "record", "NONE");
      SDOSink.PushString(sink, "marker_ref", "NONE");
      SDOSink.PushString(sink, "data_term_id", "NONE");
      SDOSink.PushBool(sink, "show_on_world_map", false);
      SDOSink.PushBool(sink, "show_in_world", false);
    };
    i = 0;
    while i < ArraySize(this.m_fastTravelNodes) {
      markerRef = ToString(this.m_fastTravelNodes[i].GetMarkerRef());
      dataTermID = EntityID.ToDebugString(this.m_fastTravelNodes[i].GetRequesterID());
      record = TDBID.ToStringDEBUG(this.m_fastTravelNodes[i].GetPointRecord());
      SDOSink.SetRoot(sink, "FastTravel/ALL_REGISTERED_POINTS:/POINT" + ToString(i));
      SDOSink.PushString(sink, "", record);
      SDOSink.PushString(sink, "record", record);
      SDOSink.PushString(sink, "marker_ref", markerRef);
      SDOSink.PushString(sink, "data_term_id", dataTermID);
      SDOSink.PushBool(sink, "show_on_world_map", this.m_fastTravelNodes[i].ShouldShowMappinOnWorldMap());
      SDOSink.PushBool(sink, "show_in_world", this.m_fastTravelNodes[i].ShouldShowMappinInWorld());
      i += 1;
    };
    if ArraySize(this.m_fastTravelLocks) <= 0 {
      SDOSink.SetRoot(sink, "FastTravel/ACTIVE_LOCKS:/LOCK0");
      SDOSink.PushString(sink, "", "NONE");
      SDOSink.PushString(sink, "reason", "NONE");
      SDOSink.PushString(sink, "status_effect", "NONE");
    };
    i = 0;
    while i < ArraySize(this.m_fastTravelLocks) {
      lockReason = ToString(this.m_fastTravelLocks[i].lockReason);
      statusEffect = TDBID.ToStringDEBUG(this.m_fastTravelLocks[i].linkedStatusEffectID);
      SDOSink.SetRoot(sink, "FastTravel/ACTIVE_LOCKS:/LOCK" + ToString(i));
      SDOSink.PushString(sink, "", lockReason);
      SDOSink.PushString(sink, "reason", lockReason);
      SDOSink.PushString(sink, "status_effect", statusEffect);
      i += 1;
    };
  }
}

public static exec func FastTravel_f(gameInstance: GameInstance, magicFloat: String) -> Void {
  let request: ref<FastTravelConsoleInstructionRequest>;
  let system: ref<FastTravelSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"FastTravelSystem") as FastTravelSystem;
  if IsDefined(system) {
    request = new FastTravelConsoleInstructionRequest();
    request.instruction = EFastTravelSystemInstruction.Forward;
    request.magicFloat = StringToFloat(magicFloat);
    system.QueueRequest(request);
  };
}
