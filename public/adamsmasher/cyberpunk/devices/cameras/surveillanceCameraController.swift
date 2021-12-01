
public class SurveillanceCameraController extends SensorDeviceController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class SurveillanceCameraControllerPS extends SensorDeviceControllerPS {

  private persistent let m_cameraProperties: CameraSetup;

  private persistent let m_cameraQuestProperties: CameraQuestProperties;

  private persistent let m_cameraState: ESurveillanceCameraStatus;

  @default(SurveillanceCameraControllerPS, false)
  private persistent let m_shouldStream: Bool;

  private let m_isDetecting: Bool;

  private persistent let m_feedReceivers: array<EntityID>;

  private persistent let m_mostRecentRequester: EntityID;

  private let m_virtualComponentName: CName;

  private persistent let m_isFeedReplacedWithBink: Bool;

  private let m_binkVideoPath: ResRef;

  private persistent let m_shouldRevealEnemies: Bool;

  private inline let m_cameraSkillChecks: ref<EngDemoContainer>;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "Gameplay-Devices-DisplayNames-SurveillanceCamera";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func LogicReady() -> Void {
    this.LogicReady();
    this.InitializeSkillChecks(this.m_cameraSkillChecks);
  }

  public final func PushResaveData(data: SurveillanceCameraResaveData) -> Void;

  public final const func GetCameraState() -> ESurveillanceCameraStatus {
    return this.m_cameraState;
  }

  protected func DetermineGameplayViability(context: GetActionsContext, hasActiveActions: Bool) -> Bool {
    return SurveillanceCameraViabilityInterpreter.Evaluate(this, hasActiveActions);
  }

  public final func ForceRevealEnemies(reveal: Bool) -> Void {
    this.m_shouldRevealEnemies = reveal;
  }

  public final const func ShouldRevealEnemies() -> Bool {
    return this.m_shouldRevealEnemies;
  }

  public final func GetQuestFactOnDetection() -> CName {
    return this.m_cameraQuestProperties.m_questFactOnDetection;
  }

  public const func GetDeviceStatusAction() -> ref<BaseDeviceStatus> {
    return this.ActionSurveillanceCameraStatus();
  }

  private final const func ActionSurveillanceCameraStatus() -> ref<SurveillanceCameraStatus> {
    let action: ref<SurveillanceCameraStatus> = new SurveillanceCameraStatus();
    action.clearanceLevel = DefaultActionsParametersHolder.GetStatusClearance();
    action.SetUp(this);
    action.SetProperties(this);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  private final func ActionToggleStreamFeed(shouldStream: Bool) -> ref<ToggleStreamFeed> {
    let action: ref<ToggleStreamFeed> = new ToggleStreamFeed();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleStreamFeedClearance();
    action.SetUp(this);
    action.SetProperties(shouldStream);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  private func ActionCameraTagSeenEnemies() -> ref<CameraTagSeenEnemies> {
    let action: ref<CameraTagSeenEnemies> = new CameraTagSeenEnemies();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  private final func ActionQuestForceReplaceStreamWithVideo() -> ref<QuestForceReplaceStreamWithVideo> {
    let action: ref<QuestForceReplaceStreamWithVideo> = new QuestForceReplaceStreamWithVideo();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties(n"binkPathNotProvied");
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  private final func ActionQuestForceStopReplacingStream() -> ref<QuestForceStopReplacingStream> {
    let action: ref<QuestForceStopReplacingStream> = new QuestForceStopReplacingStream();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    if !this.GetActions(actions, context) {
      return false;
    };
    if SurveillanceCameraStatus.IsDefaultConditionMet(this, context) {
      ArrayPush(actions, this.ActionSurveillanceCameraStatus());
    };
    if TogglePower.IsDefaultConditionMet(this, context) && Equals(context.requestType, gamedeviceRequestType.External) {
      ArrayPush(actions, this.ActionTogglePower());
    };
    if ToggleON.IsDefaultConditionMet(this, context) && NotEquals(context.requestType, gamedeviceRequestType.Direct) && NotEquals(context.requestType, gamedeviceRequestType.Remote) {
      ArrayPush(actions, this.ActionToggleON());
    };
    if ToggleTakeOverControl.IsDefaultConditionMet(this, context) && Equals(context.requestType, gamedeviceRequestType.External) {
      ArrayPush(actions, this.ActionToggleTakeOverControl());
    };
    if ToggleStreamFeed.IsDefaultConditionMet(this, context) {
      ArrayPush(actions, this.ActionToggleStreamFeed(this.IsRequesterOnTheList(context.requestorID)));
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction>;
    if Equals(this.GetDurabilityState(), EDeviceDurabilityState.NOMINAL) {
      this.GetQuickHackActions(actions, context);
      currentAction = this.ActionToggleTakeOverControl();
      currentAction.SetObjectActionID(t"DeviceAction.TakeControlCameraClassHack");
      currentAction.SetInactiveWithReason(this.m_canPlayerTakeOverControl && Equals(this.GetDurabilityState(), EDeviceDurabilityState.NOMINAL), "LocKey#7004");
      currentAction.SetInactiveWithReason(!PlayerPuppet.IsSwimming(GetPlayer(this.GetGameInstance())), "LocKey#7003");
      currentAction.SetInactiveWithReason(PlayerPuppet.GetSceneTier(GetPlayer(this.GetGameInstance())) <= EnumInt(gamePSMHighLevel.SceneTier1), "LocKey#7003");
      ArrayPush(actions, currentAction);
      currentAction = this.ActionForceIgnoreTargets();
      currentAction.SetObjectActionID(t"DeviceAction.OverrideAttitudeClassHack");
      currentAction.SetInactiveWithReason(this.IsON(), "LocKey#7005");
      currentAction.SetInactiveWithReason(this.GetBehaviourCanDetectIntruders(), "LocKey#7007");
      currentAction.SetInactiveWithReason(this.IsAttitudeFromContextHostile(), "LocKey#7008");
      ArrayPush(actions, currentAction);
      currentAction = this.ActionQuickHackToggleON();
      currentAction.SetObjectActionID(t"DeviceAction.ToggleStateClassHack");
      ArrayPush(actions, currentAction);
    };
    this.FinalizeGetQuickHackActions(actions, context);
  }

  protected func GetMinigameActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let action: ref<ScriptableDeviceAction> = this.ActionProgramSetDeviceOff();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.AddDeviceName(this.m_deviceName);
    ArrayPush(actions, action);
    action = this.ActionProgramSetDeviceAttitude();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.AddDeviceName(this.m_deviceName);
    ArrayPush(actions, action);
  }

  protected func GetQuestActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(actions, context);
    ArrayPush(actions, this.ActionQuestForceReplaceStreamWithVideo());
    ArrayPush(actions, this.ActionQuestForceStopReplacingStream());
    ArrayPush(actions, this.ActionQuestForceTakeControlOverCamera());
    ArrayPush(actions, this.ActionQuestForceTakeControlOverCameraWithChain());
    ArrayPush(actions, this.ActionQuestForceStopTakeControlOverCamera());
    ArrayPush(actions, this.ActionQuestFollowTarget());
    ArrayPush(actions, this.ActionQuestStopFollowingTarget());
    ArrayPush(actions, this.ActionQuestLookAtTarget());
    ArrayPush(actions, this.ActionQuestStopLookAtTarget());
    ArrayPush(actions, this.ActionQuestSetDetectionToTrue());
    ArrayPush(actions, this.ActionQuestSetDetectionToFalse());
    ArrayPush(actions, this.ActionQuestForceAttitude());
    ArrayPush(actions, this.ActionQuestSpotTargetReference());
    ArrayPush(actions, this.ActionQuestForceScanEffect());
    ArrayPush(actions, this.ActionQuestForceScanEffectStop());
  }

  public final func OnToggleStreamFeed(evt: ref<ToggleStreamFeed>) -> EntityNotificationType {
    if NotEquals(this.m_deviceState, EDeviceStatus.ON) || !this.m_cameraProperties.m_canStreamVideo {
      this.m_shouldStream = false;
      return this.SendActionFailedEvent(evt, evt.GetRequesterID());
    };
    this.m_mostRecentRequester = evt.GetRequesterID();
    this.HandleFeedReceiversArray(!FromVariant(evt.prop.first), evt.vRoomFake);
    if ArraySize(this.m_feedReceivers) > 0 {
      this.m_shouldStream = true;
      if EnumInt(this.m_cameraState) < 2 {
        this.m_cameraState = ESurveillanceCameraStatus.STREAMING;
      };
    } else {
      this.m_shouldStream = false;
      if EnumInt(this.m_cameraState) < 2 {
        this.m_cameraState = ESurveillanceCameraStatus.WORKING;
      };
    };
    evt.prop.first = ToVariant(this.m_shouldStream);
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnToggleON(evt: ref<ToggleON>) -> EntityNotificationType {
    this.OnToggleON(evt);
    if !this.IsON() {
      this.m_shouldStream = false;
    } else {
      if EnumInt(this.m_cameraState) < 2 {
        this.m_cameraState = ESurveillanceCameraStatus.WORKING;
      };
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnQuestForceReplaceStreamWithVideo(evt: ref<QuestForceReplaceStreamWithVideo>) -> EntityNotificationType {
    let cachedStatus: ref<SurveillanceCameraStatus> = this.GetDeviceStatusAction() as SurveillanceCameraStatus;
    this.m_isFeedReplacedWithBink = true;
    if IsNameValid(FromVariant(evt.prop.first)) {
      this.m_binkVideoPath = ResRef.FromHash(FromVariant(evt.prop.first));
    };
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnQuestForceStopReplacingStream(evt: ref<QuestForceStopReplacingStream>) -> EntityNotificationType {
    this.m_isFeedReplacedWithBink = false;
    let binkEvent: ref<BinkVideoEvent> = new BinkVideoEvent();
    binkEvent.shouldPlay = false;
    let i: Int32 = 0;
    while i < ArraySize(this.m_feedReceivers) {
      this.GetPersistencySystem().QueueEntityEvent(this.m_feedReceivers[i], binkEvent);
      i += 1;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnCameraTagSeenEnemies(evt: ref<CameraTagSeenEnemies>) -> EntityNotificationType {
    this.m_canTagEnemies = true;
    this.SetIsIdleForced(true);
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnSetDeviceAttitude(evt: ref<SetDeviceAttitude>) -> EntityNotificationType {
    this.ExecutePSAction(this.ActionCameraTagSeenEnemies());
    this.OnSetDeviceAttitude(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func HandleFeedReceiversArray(shouldAdd: Bool, hasHack: Bool) -> Void {
    let binkEvent: ref<BinkVideoEvent>;
    let feedEvent: ref<FeedEvent>;
    let hackEvent: ref<VRoomFeed>;
    let toSendEvent: ref<Event>;
    if hasHack {
      hackEvent = new VRoomFeed();
      hackEvent.On = shouldAdd;
      toSendEvent = hackEvent;
    } else {
      feedEvent = new FeedEvent();
      feedEvent.On = shouldAdd;
      feedEvent.virtualComponentName = this.m_virtualComponentName;
      toSendEvent = feedEvent;
    };
    if shouldAdd {
      ArrayPush(this.m_feedReceivers, this.m_mostRecentRequester);
    } else {
      ArrayRemove(this.m_feedReceivers, this.m_mostRecentRequester);
    };
    this.GetPersistencySystem().QueueEntityEvent(this.m_mostRecentRequester, toSendEvent);
    if this.m_isFeedReplacedWithBink {
      binkEvent = new BinkVideoEvent();
      binkEvent.path = this.m_binkVideoPath;
      binkEvent.shouldPlay = shouldAdd;
      this.GetPersistencySystem().QueueEntityEvent(this.m_mostRecentRequester, binkEvent);
    };
  }

  private final func IsRequesterOnTheList(requester: EntityID) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_feedReceivers) {
      if this.m_feedReceivers[i] == requester {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func GetMostRecentRequester() -> EntityID {
    return this.m_mostRecentRequester;
  }

  public final const func GetFeedReceiversArray() -> array<EntityID> {
    return this.m_feedReceivers;
  }

  public final const func ShouldStream() -> Bool {
    return this.m_shouldStream;
  }

  public final const func GetfollowedTargetID() -> EntityID {
    return this.m_cameraQuestProperties.m_followedTargetID;
  }

  public final const quest func IsStreaming() -> Bool {
    if Equals(this.m_deviceState, EDeviceStatus.ON) {
      if Equals(this.m_cameraState, ESurveillanceCameraStatus.STREAMING) {
        return true;
      };
    };
    return false;
  }

  public final const quest func IsDetecting() -> Bool {
    return this.m_isDetecting;
  }

  public const func IsDetectingDebug() -> Bool {
    return this.m_isDetecting;
  }

  public const func GetVirtualSystemType() -> EVirtualSystem {
    return EVirtualSystem.SurveillanceSystem;
  }

  public func GetWidgetTypeName() -> CName {
    return n"GenericDeviceWidget";
  }

  public func GetDeviceIconPath() -> String {
    return "base/gameplay/gui/brushes/devices/icon_camera.widgetbrush";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.CameraDeviceBackground";
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.CameraDeviceIcon";
  }

  public func GetDeviceWidget(context: GetActionsContext) -> SDeviceWidgetPackage {
    let widgetData: SDeviceWidgetPackage = this.GetDeviceWidget(context);
    if Equals(this.m_cameraState, ESurveillanceCameraStatus.THREAT) {
      widgetData.widgetState = EWidgetState.LOCKED;
    };
    return widgetData;
  }

  public final func ClearFeedReceivers() -> Void {
    let feedEvent: ref<FeedEvent> = new FeedEvent();
    feedEvent.On = false;
    let i: Int32 = 0;
    while i < ArraySize(this.m_feedReceivers) {
      GameInstance.GetPersistencySystem(this.GetGameInstance()).QueueEntityEvent(this.m_feedReceivers[i], feedEvent);
      i += 1;
    };
    ArrayClear(this.m_feedReceivers);
  }

  public final func CanStreamVideo() -> Bool {
    return this.m_cameraProperties.m_canStreamVideo;
  }

  public final func ThreatDetected(isDetected: Bool) -> Void {
    if NotEquals(this.m_isDetecting, isDetected) {
      this.RefreshPS();
    };
    this.m_isDetecting = isDetected;
    if isDetected {
      this.m_cameraState = ESurveillanceCameraStatus.THREAT;
    } else {
      if this.m_shouldStream {
        this.m_cameraState = ESurveillanceCameraStatus.STREAMING;
      } else {
        if this.IsON() {
          this.m_cameraState = ESurveillanceCameraStatus.WORKING;
        };
      };
    };
  }

  protected func OnTCSTakeOverControlDeactivate(evt: ref<TCSTakeOverControlDeactivate>) -> EntityNotificationType {
    let returnType: EntityNotificationType = this.OnTCSTakeOverControlDeactivate(evt);
    if this.m_wasStateCached {
      if Equals(this.m_cachedDeviceState, EDeviceStatus.OFF) {
        this.ExecutePSAction(this.ActionSetDeviceOFF());
      };
    };
    return returnType;
  }

  public final func GetFakeToggleStreamAction(startStream: Bool, whoIsReceiving: EntityID) -> ref<ToggleStreamFeed> {
    let toggleStreamAction: ref<ToggleStreamFeed> = this.ActionToggleStreamFeed(!startStream);
    toggleStreamAction.vRoomFake = true;
    toggleStreamAction.RegisterAsRequester(whoIsReceiving);
    return toggleStreamAction;
  }

  protected func LogActionDetails(action: ref<ScriptableDeviceAction>, cachedStatus: ref<BaseDeviceStatus>, opt context: String, opt status: String, opt overrideStatus: Bool) -> Void {
    if this.IsLogInExclusiveMode() && !this.m_debugDevice {
      return;
    };
    overrideStatus = true;
    status = this.ActionSurveillanceCameraStatus().GetCurrentDisplayString();
    this.LogActionDetails(action, cachedStatus, context, status, overrideStatus);
  }

  protected func ActionEngineering(context: GetActionsContext) -> ref<ActionEngineering> {
    let action: ref<ActionEngineering> = this.ActionEngineering(context);
    let displayName: String = "Off";
    action.ResetCaption();
    action.CreateInteraction(context.processInitiatorObject, displayName);
    return action;
  }

  public func OnActionEngineering(evt: ref<ActionEngineering>) -> EntityNotificationType {
    if !evt.WasPassed() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.OnActionEngineering(evt);
    if evt.IsCompleted() {
      this.Override(evt);
      RPGManager.GiveReward(evt.GetExecutor().GetGame(), t"RPGActionRewards.ExtractPartsSecurityTurret");
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func Override(action: ref<ScriptableDeviceAction>) -> Void {
    let actionToSend: ref<ScriptableDeviceAction>;
    this.ExecutePSAction(this.ActionSetDeviceOFF());
    this.SetBlockSecurityWakeUp(true);
    this.GetPersistencySystem().QueuePSDeviceEvent(actionToSend);
  }
}
