
public class HUDInstruction extends Event {

  public let scannerInstructions: ref<ScanInstance>;

  public let highlightInstructions: ref<HighlightInstance>;

  public let braindanceInstructions: ref<BraindanceInstance>;

  public let iconsInstruction: ref<IconsInstance>;

  public let quickhackInstruction: ref<QuickhackInstance>;

  public final static func Construct(self: ref<HUDInstruction>, id: EntityID) -> Void {
    if !EntityID.IsDefined(id) {
      return;
    };
    self.scannerInstructions = new ScanInstance();
    self.highlightInstructions = new HighlightInstance();
    self.iconsInstruction = new IconsInstance();
    self.braindanceInstructions = new BraindanceInstance();
    self.quickhackInstruction = new QuickhackInstance();
    ModuleInstance.Construct(self.scannerInstructions, id);
    ModuleInstance.Construct(self.highlightInstructions, id);
    ModuleInstance.Construct(self.iconsInstruction, id);
    ModuleInstance.Construct(self.braindanceInstructions, id);
    ModuleInstance.Construct(self.quickhackInstruction, id);
  }
}

public class HUDManager extends NativeHudManager {

  private let m_state: HUDState;

  @default(HUDManager, ActiveMode.SEMI)
  private let m_activeMode: ActiveMode;

  private let m_instructionsDelayID: DelayID;

  private let m_isBraindanceActive: Bool;

  private let m_modulesArray: array<ref<HUDModule>>;

  private let m_scanner: ref<ScannerModule>;

  private let m_braindanceModule: ref<BraindanceModule>;

  private let m_highlightsModule: ref<HighlightModule>;

  private let m_iconsModule: ref<IconsModule>;

  private let m_crosshair: ref<CrosshairModule>;

  private let m_aimAssist: ref<AimAssistModule>;

  private let m_quickhackModule: ref<QuickhackModule>;

  private let m_lastTarget: wref<HUDActor>;

  private let m_currentTarget: wref<HUDActor>;

  private let m_lookAtTarget: EntityID;

  private let m_scannerTarget: EntityID;

  private let m_nameplateTarget: EntityID;

  private let m_quickHackTarget: EntityID;

  private let m_lootedTarget: EntityID;

  private let m_scannningController: wref<ScanningController>;

  @default(HUDManager, false)
  private let m_uiScannerVisible: Bool;

  @default(HUDManager, false)
  private let m_uiQuickHackVisible: Bool;

  private let m_quickHackDescriptionVisible: Bool;

  private let m_targetingSystem: wref<TargetingSystem>;

  private let m_visionModeSystem: wref<VisionModeSystem>;

  private let m_isHackingMinigameActive: Bool;

  private let m_stickInputListener: ref<CallbackHandle>;

  private let m_quickHackPanelListener: ref<CallbackHandle>;

  private let m_carriedBodyListener: ref<CallbackHandle>;

  private let m_grappleListener: ref<CallbackHandle>;

  private let m_lookatRequest: AimRequest;

  private let m_isQHackUIInputLocked: Bool;

  private let m_playerAttachedCallbackID: Uint32;

  private let m_playerDetachedCallbackID: Uint32;

  private let m_playerTargetCallbackID: ref<CallbackHandle>;

  private let m_braindanceToggleCallbackID: ref<CallbackHandle>;

  private let m_nameplateCallbackID: ref<CallbackHandle>;

  private let m_visionModeChangedCallbackID: ref<CallbackHandle>;

  private let m_scannerTargetCallbackID: ref<CallbackHandle>;

  private let m_hackingMinigameCallbackID: ref<CallbackHandle>;

  private let m_uiScannerVisibleCallbackID: ref<CallbackHandle>;

  private let m_uiQuickHackVisibleCallbackID: ref<CallbackHandle>;

  private let m_lootDataCallbackID: ref<CallbackHandle>;

  private let m_pulseDelayID: DelayID;

  private let m_previousStickInput: Vector4;

  private func OnAttach() -> Void {
    this.InitializeHUD();
  }

  private func OnDetach() -> Void {
    this.UninitializeHUD();
  }

  private final func InitializeHUD() -> Void {
    this.m_scannningController = GameInstance.GetVisionModeSystem(this.GetGameInstance()).GetScanningController();
    this.m_targetingSystem = GameInstance.GetTargetingSystem(this.GetGameInstance());
    this.m_visionModeSystem = GameInstance.GetVisionModeSystem(this.GetGameInstance());
    this.m_playerAttachedCallbackID = GameInstance.GetPlayerSystem(this.GetGameInstance()).RegisterPlayerPuppetAttachedCallback(this, n"PlayerAttachedCallback");
    this.m_playerDetachedCallbackID = GameInstance.GetPlayerSystem(this.GetGameInstance()).RegisterPlayerPuppetDetachedCallback(this, n"PlayerDetachedCallback");
    this.RegisterPlayerTargetCallback();
    this.RegisterScannerTargetCallback();
    this.RegisterNameplateShownCallback();
    this.RegisterHackingMinigameCallback();
    this.RegisterBraindanceToggleCallback();
    this.RegisterUICallbacks();
    this.InitializeModules();
    this.m_state = HUDState.ACTIVATED;
  }

  private final func InitializeModules() -> Void {
    this.m_scanner = new ScannerModule();
    this.m_braindanceModule = new BraindanceModule();
    this.m_highlightsModule = new HighlightModule();
    this.m_iconsModule = new IconsModule();
    this.m_crosshair = new CrosshairModule();
    this.m_aimAssist = new AimAssistModule();
    this.m_quickhackModule = new QuickhackModule();
    this.m_scanner.InitializeModule(this, ModuleState.ON);
    this.m_highlightsModule.InitializeModule(this, ModuleState.ON);
    this.m_iconsModule.InitializeModule(this, ModuleState.ON);
    this.m_crosshair.InitializeModule(this, ModuleState.DISABLED);
    this.m_aimAssist.InitializeModule(this, ModuleState.DISABLED);
    this.m_braindanceModule.InitializeModule(this, ModuleState.ON);
    this.m_quickhackModule.InitializeModule(this, ModuleState.ON);
    ArrayPush(this.m_modulesArray, this.m_scanner);
    ArrayPush(this.m_modulesArray, this.m_braindanceModule);
    ArrayPush(this.m_modulesArray, this.m_highlightsModule);
    ArrayPush(this.m_modulesArray, this.m_iconsModule);
    ArrayPush(this.m_modulesArray, this.m_quickhackModule);
  }

  private final func UninitializeHUD() -> Void {
    GameInstance.GetPlayerSystem(this.GetGameInstance()).UnregisterPlayerPuppetAttachedCallback(this.m_playerAttachedCallbackID);
    GameInstance.GetPlayerSystem(this.GetGameInstance()).UnregisterPlayerPuppetDetachedCallback(this.m_playerDetachedCallbackID);
    this.UnregisterUICallbacks();
    this.m_playerAttachedCallbackID = 0u;
    this.m_playerDetachedCallbackID = 0u;
    this.m_scannningController = null;
  }

  private final func PlayerAttachedCallback(playerPuppet: ref<GameObject>) -> Void {
    this.RegisterVisionModeCallback(playerPuppet);
    this.RegisterToInput();
    this.m_quickHackPanelListener = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_QuickSlotsData).RegisterListenerBool(GetAllBlackboardDefs().UI_QuickSlotsData.quickhackPanelOpen, this, n"OnQuickHackPanelOpened");
    this.m_carriedBodyListener = this.GetPlayerSMBlackboard().RegisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.Carrying, this, n"OnBodyCarryStateChanged");
    this.m_grappleListener = this.GetPlayerSMBlackboard().RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown, this, n"OnGrappleStateChanged");
  }

  private final func PlayerDetachedCallback(playerPuppet: ref<GameObject>) -> Void {
    this.UnregisterVisionModeCallback(playerPuppet);
    this.UnregisterToInput();
    if IsDefined(this.m_quickHackPanelListener) {
      GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_QuickSlotsData).UnregisterListenerBool(GetAllBlackboardDefs().UI_QuickSlotsData.quickhackPanelOpen, this.m_quickHackPanelListener);
    };
    if IsDefined(this.m_carriedBodyListener) {
      this.GetPlayerSMBlackboard().UnregisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.Carrying, this.m_carriedBodyListener);
    };
    if IsDefined(this.m_grappleListener) {
      this.GetPlayerSMBlackboard().UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown, this.m_grappleListener);
    };
  }

  public final const func GetPlayerSMBlackboard() -> ref<IBlackboard> {
    let psmBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).GetLocalInstanced(this.GetPlayer().GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return psmBlackboard;
  }

  protected final func OnRegister(request: ref<HUDManagerRegistrationRequest>) -> Void {
    if this.IsRequestLegal(request) {
      this.ProcessRegistration(request);
    };
  }

  protected final func OnRefreshSingleActor(request: ref<RefreshActorRequest>) -> Void {
    let actor: ref<HUDActor>;
    let requestedModules: array<wref<HUDModule>>;
    let updateData: ref<HUDActorUpdateData>;
    if request.IsValid() {
      actor = this.GetActor(request.ownerID);
      if !IsDefined(actor) {
        return;
      };
      updateData = request.GetActorUpdateData();
      if IsDefined(updateData) {
        actor.UpdateActorData(updateData);
      };
      requestedModules = request.GetRequestedModules();
      if ArraySize(requestedModules) > 0 {
        this.RefreshHudForSingleActor(actor, requestedModules);
      } else {
        this.RefreshHudForSingleActor(actor);
      };
    };
  }

  private final func OnLockQHackInput(request: ref<LockQHackInput>) -> Void {
    this.m_isQHackUIInputLocked = request.isLocked;
  }

  public final const func IsQHackInputLocked() -> Bool {
    return this.m_isQHackUIInputLocked;
  }

  public final static func IsQHackInputLocked(context: GameInstance) -> Bool {
    let self: ref<HUDManager> = GameInstance.GetScriptableSystemsContainer(context).Get(n"HUDManager") as HUDManager;
    if IsDefined(self) {
      return self.IsQHackInputLocked();
    };
    return false;
  }

  public final static func LockQHackInput(context: GameInstance, isLocked: Bool) -> Void {
    let request: ref<LockQHackInput>;
    let self: ref<HUDManager> = GameInstance.GetScriptableSystemsContainer(context).Get(n"HUDManager") as HUDManager;
    if IsDefined(self) {
      request = new LockQHackInput();
      request.isLocked = isLocked;
      self.QueueRequest(request);
    };
  }

  private final func OnRevealQuickhackMenu(request: ref<RevealQuickhackMenu>) -> Void {
    if request.shouldOpenWheel {
      this.GetCurrentTarget().SetShouldRefreshQHack(true);
      this.RefreshHudForSingleActor(this.GetCurrentTarget());
    } else {
      this.CloseQHackMenu();
    };
  }

  private final const func CloseQHackMenu() -> Void {
    let evt: ref<QuickHackScreenOpen> = new QuickHackScreenOpen();
    evt.setToOpen = false;
    this.GetPlayer().QueueEvent(evt);
  }

  public final static func CanCurrentTargetRevealRemoteActionsWheel(context: GameInstance) -> Bool {
    let canOpen: Bool;
    let gameObject: ref<GameObject>;
    let self: ref<HUDManager> = GameInstance.GetScriptableSystemsContainer(context).Get(n"HUDManager") as HUDManager;
    if IsDefined(self) {
      gameObject = GameInstance.FindEntityByID(context, self.GetCurrentTargetID()) as GameObject;
      if IsDefined(gameObject) {
        canOpen = gameObject.CanRevealRemoteActionsWheel();
      };
      if canOpen {
        return true;
      };
      return false;
    };
    return false;
  }

  protected final func OnRevealActorNotification(request: ref<RevealStatusNotification>) -> Void {
    let actor: ref<HUDActor>;
    if this.IsRequestLegal(request) {
      actor = this.GetActor(request.ownerID);
      if IsDefined(actor) {
        actor.SetRevealed(request.isRevealed);
      };
    };
    if IsDefined(actor) {
      this.IterateModules(this.CreateJob(actor));
    };
  }

  protected final func OnTagActorNotification(request: ref<TagStatusNotification>) -> Void {
    let actor: ref<HUDActor>;
    if this.IsRequestLegal(request) {
      actor = this.GetActor(request.ownerID);
      if IsDefined(actor) {
        actor.SetTagged(request.isTagged);
      };
    };
    if IsDefined(actor) {
      this.IterateModules(this.CreateJob(actor));
    };
  }

  protected final func OnClueClueLockNotification(request: ref<ClueLockNotification>) -> Void {
    if this.IsRequestLegal(request) {
      this.IterateModules(this.CreateJobsForClueActors(this.GetAllActors()));
    };
  }

  protected final func OnClueActorNotification(request: ref<ClueStatusNotification>) -> Void {
    let actor: ref<HUDActor>;
    if this.IsRequestLegal(request) {
      actor = this.GetActor(request.ownerID);
      if IsDefined(actor) {
        actor.SetClue(request.isClue);
        actor.SetClueGroup(request.clueGroupID);
        this.IterateModules(this.CreateJob(actor));
      };
    };
  }

  protected cb func OnVisionModeChanged(value: Int32) -> Bool {
    let newActiveMode: ActiveMode;
    let visionType: gameVisionModeType;
    this.ResolveCurrentTarget();
    if NotEquals(this.GetHUDState(), HUDState.ACTIVATED) {
      return false;
    };
    visionType = IntEnum(value);
    if Equals(visionType, gameVisionModeType.Focus) {
      newActiveMode = ActiveMode.FOCUS;
    } else {
      newActiveMode = ActiveMode.SEMI;
    };
    if NotEquals(newActiveMode, this.m_activeMode) {
      this.m_activeMode = newActiveMode;
      this.GetCurrentTarget().SetShouldRefreshQHack(true);
      this.RefreshHUD();
    };
  }

  protected cb func OnPlayerTargetChanged(value: EntityID) -> Bool {
    let request: ref<PlayerTargetChangedRequest> = new PlayerTargetChangedRequest();
    request.playerTarget = value;
    this.QueueRequest(request);
  }

  protected cb func OnBraindanceToggle(value: Bool) -> Bool {
    if NotEquals(this.m_isBraindanceActive, value) {
      this.m_isBraindanceActive = value;
      this.RefreshHUD();
      if !value {
        this.OnVisionModeChanged(this.GetPlayerStateMachineBlackboard(this.GetPlayer()).GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vision));
      };
    };
  }

  protected final func OnPlayerTargetChangedRequest(evt: ref<PlayerTargetChangedRequest>) -> Void {
    this.ResolveLookAtTarget(evt.playerTarget);
    if Equals(this.m_activeMode, ActiveMode.FOCUS) && EntityID.IsDefined(this.m_scannerTarget) {
      return;
    };
    if !this.ResolveCurrentTarget() {
      return;
    };
    this.ReactToTargetChanged();
  }

  private final func ResolveLookAtTarget(newTarget: EntityID) -> Void {
    let lastTarget: EntityID;
    let lookAtStarted: ref<LookedAtEvent>;
    let lookAtStopped: ref<LookedAtEvent>;
    if newTarget != this.m_lookAtTarget {
      lastTarget = this.m_lookAtTarget;
      this.m_lookAtTarget = newTarget;
      lookAtStarted = new LookedAtEvent();
      lookAtStopped = new LookedAtEvent();
      lookAtStarted.isLookedAt = true;
      lookAtStopped.isLookedAt = false;
      if EntityID.IsDefined(this.m_lookAtTarget) {
        this.QueueEntityEvent(this.m_lookAtTarget, lookAtStarted);
      };
      if EntityID.IsDefined(lastTarget) {
        this.QueueEntityEvent(lastTarget, lookAtStopped);
      };
    };
  }

  protected final func RegisterToInput() -> Void {
    let player: ref<GameObject> = this.GetPlayer();
    player.RegisterInputListener(this, n"QH_MoveLeft");
    player.RegisterInputListener(this, n"QH_MoveRight");
    player.RegisterInputListener(this, n"Ping");
    player.RegisterInputListener(this, n"OpenQuickHackPanel");
    player.RegisterInputListener(this, n"DescriptionChange");
    this.m_stickInputListener = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_QuickSlotsData).RegisterListenerVector4(GetAllBlackboardDefs().UI_QuickSlotsData.leftStick, this, n"OnStickInputChanged");
  }

  protected final func UnregisterToInput() -> Void {
    this.GetPlayer().UnregisterInputListener(this);
    if IsDefined(this.m_stickInputListener) {
      GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_QuickSlotsData).UnregisterListenerVector4(GetAllBlackboardDefs().UI_QuickSlotsData.leftStick, this.m_stickInputListener);
    };
  }

  public final const func IsBraindanceActive() -> Bool {
    return this.m_isBraindanceActive;
  }

  protected cb func OnQuickHackPanelOpened(value: Bool) -> Bool {
    let invalidID: EntityID;
    if NotEquals(value, this.IsQuickHackPanelOpened()) {
      this.SetIsQuickHackPanelOpened(value);
      this.SendQuickHackPanelStateEvent(value);
    };
    if value {
      this.m_previousStickInput = Vector4.EmptyVector();
    } else {
      Vector4.Zero(this.m_lookatRequest.lookAtTarget);
      this.m_quickHackTarget = invalidID;
      this.ResolveCurrentTarget();
    };
    this.RefreshDebug();
  }

  protected cb func OnBodyCarryStateChanged(value: Bool) -> Bool {
    this.RefreshHUD();
  }

  protected cb func OnGrappleStateChanged(value: Int32) -> Bool {
    this.RefreshHUD();
  }

  protected cb func OnBreachingNetwork(value: String) -> Bool {
    if IsStringValid(value) {
      this.m_isHackingMinigameActive = true;
    } else {
      this.m_isHackingMinigameActive = false;
    };
  }

  public final const func IsHackingMinigameActive() -> Bool {
    return this.m_isHackingMinigameActive;
  }

  private final func SendQuickHackPanelStateEvent(isOpened: Bool) -> Void {
    let evt: ref<QuickHackPanelStateEvent>;
    let targetID: EntityID = this.m_currentTarget.GetEntityID();
    if EntityID.IsDefined(targetID) {
      evt = new QuickHackPanelStateEvent();
      evt.isOpened = isOpened;
      this.QueueEntityEvent(targetID, evt);
    };
  }

  public final static func IsQuickHackPanelOpen(context: GameInstance) -> Bool {
    let self: ref<HUDManager> = GameInstance.GetScriptableSystemsContainer(context).Get(n"HUDManager") as HUDManager;
    if IsDefined(self) {
      return self.IsQuickHackPanelOpened();
    };
    return false;
  }

  public final static func SetQHDescriptionVisibility(context: GameInstance, visible: Bool) -> Void {
    let request: ref<QuickHackSetDescriptionVisibilityRequest>;
    let self: ref<HUDManager> = GameInstance.GetScriptableSystemsContainer(context).Get(n"HUDManager") as HUDManager;
    if IsDefined(self) {
      request = new QuickHackSetDescriptionVisibilityRequest();
      request.visible = visible;
      self.QueueRequest(request);
    };
  }

  private final func OnQuickHackSetDescriptionVisibility(evt: ref<QuickHackSetDescriptionVisibilityRequest>) -> Void {
    this.SetQhuickHackDescriptionVisibility(evt.visible);
  }

  private final func SetQhuickHackDescriptionVisibility(value: Bool) -> Void {
    this.m_quickHackDescriptionVisible = value;
    GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_QuickSlotsData).SetBool(GetAllBlackboardDefs().UI_QuickSlotsData.quickHackDescritpionVisible, this.m_quickHackDescriptionVisible, true);
  }

  public final const func IsQHDescriptionVisible() -> Bool {
    return this.m_quickHackDescriptionVisible;
  }

  public final static func IsQuickHackDescriptionVisible(context: GameInstance) -> Bool {
    let self: ref<HUDManager> = GameInstance.GetScriptableSystemsContainer(context).Get(n"HUDManager") as HUDManager;
    if IsDefined(self) {
      return self.IsQHDescriptionVisible();
    };
    return false;
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    let actionName: CName;
    let isReleased: Bool;
    if this.IsHackingMinigameActive() {
      return false;
    };
    isReleased = Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_PRESSED);
    actionName = ListenerAction.GetName(action);
    if this.IsQuickHackPanelOpened() && !this.m_isQHackUIInputLocked {
      if isReleased && !GameObject.IsCooldownActive(this.GetPlayer(), n"Qhack_targetChange_lock") {
        switch actionName {
          case n"QH_MoveLeft":
            if isReleased {
              this.JumpToNextTarget(false);
            };
            GameObject.StartCooldown(this.GetPlayer(), n"Qhack_targetChange_lock", 0.00);
            break;
          case n"QH_MoveRight":
            if isReleased {
              this.JumpToNextTarget(true);
            };
            GameObject.StartCooldown(this.GetPlayer(), n"Qhack_targetChange_lock", 0.00);
            break;
          default:
        };
      };
    };
    if ListenerAction.IsButtonJustPressed(action) {
      switch actionName {
        case n"Ping":
          this.StartPulse();
          break;
        case n"DescriptionChange":
          if this.IsQuickHackPanelOpened() {
            this.SetQhuickHackDescriptionVisibility(!this.m_quickHackDescriptionVisible);
          };
          break;
        default:
      };
    };
  }

  protected cb func OnStickInputChanged(value: Vector4) -> Bool;

  protected final func JumpToNextTarget(right: Bool) -> Void {
    let inputVector: Vector4;
    if right {
      inputVector.X = 1.00;
    } else {
      inputVector.X = -1.00;
    };
    this.JumpToTarget(inputVector);
  }

  protected final func JumpToTarget(inputVector: Vector4, opt dotThreshold: Float) -> Void {
    let angleDistance: EulerAngles;
    let dot: Float;
    let gameObj: wref<GameObject>;
    let i: Int32;
    let normalizedDot: Float;
    let searchQuery: TargetSearchQuery;
    let selectedTarget: Int32;
    let smallestDot: Float;
    let targetParts: array<TS_TargetPartInfo>;
    let vecToNextObject: Vector4;
    if Vector4.IsZero(inputVector) {
      return;
    };
    if LiftDevice.IsPlayerInsideElevator(this.GetGameInstance()) {
      return;
    };
    selectedTarget = -1;
    smallestDot = 100000000.00;
    TargetSearchQuery.SetComponentFilter(searchQuery, TargetComponentFilterType.QuickHack);
    searchQuery.searchFilter = TSF_Quickhackable();
    searchQuery.maxDistance = SNameplateRangesData.GetMaxDisplayRange();
    GameInstance.GetTargetingSystem(this.GetGameInstance()).GetTargetParts(this.GetPlayer(), searchQuery, targetParts);
    i = 0;
    while i < ArraySize(targetParts) {
      gameObj = TS_TargetPartInfo.GetComponent(targetParts[i]).GetEntity() as GameObject;
      if !IsDefined(gameObj) || gameObj.GetEntityID() == this.m_currentTarget.GetEntityID() || !gameObj.CanRevealRemoteActionsWheel() {
      } else {
        angleDistance = TS_TargetPartInfo.GetPlayerAngleDistance(targetParts[i]);
        vecToNextObject.X = angleDistance.Yaw * -1.00;
        vecToNextObject.Y = angleDistance.Pitch * -1.00;
        dot = Vector4.Dot2D(inputVector, vecToNextObject);
        normalizedDot = Vector4.Dot2D(inputVector, Vector4.Normalize2D(vecToNextObject));
        if normalizedDot < dotThreshold {
        } else {
          if dot < smallestDot {
            smallestDot = dot;
            selectedTarget = i;
          };
        };
      };
      i += 1;
    };
    if selectedTarget >= 0 {
      angleDistance = TS_TargetPartInfo.GetPlayerAngleDistance(targetParts[selectedTarget]);
      vecToNextObject.X = angleDistance.Yaw * -1.00;
      vecToNextObject.Y = angleDistance.Pitch * -1.00;
      this.LookAtNewTarget(TS_TargetPartInfo.GetComponent(targetParts[selectedTarget]), vecToNextObject);
    };
  }

  private final func ClearQuickHackTargetData(targetID: EntityID) -> Void {
    let evt: ref<QHackWheelItemChangedEvent> = new QHackWheelItemChangedEvent();
    evt.currentEmpty = true;
    if EntityID.IsDefined(targetID) {
      GameInstance.GetPersistencySystem(this.GetGameInstance()).QueueEntityEvent(targetID, evt);
    };
  }

  private final func LookAtNearestCroshairTarget(opt targetEntityID: EntityID) -> Void {
    let angleDistance: EulerAngles;
    let component: wref<TargetingComponent>;
    let searchQuery: TargetSearchQuery;
    let vecToNextObject: Vector4;
    TargetSearchQuery.SetComponentFilter(searchQuery, TargetComponentFilterType.QuickHack);
    searchQuery.searchFilter = TSF_Quickhackable();
    searchQuery.maxDistance = SNameplateRangesData.GetMaxDisplayRange();
    if EntityID.IsDefined(targetEntityID) {
      searchQuery.queryTarget = targetEntityID;
      searchQuery.testedSet = TargetingSet.Complete;
    };
    component = GameInstance.GetTargetingSystem(this.GetGameInstance()).GetComponentClosestToCrosshair(this.GetPlayer(), angleDistance, searchQuery) as TargetingComponent;
    if IsDefined(component) {
      vecToNextObject.X = angleDistance.Yaw * -1.00;
      vecToNextObject.Y = angleDistance.Pitch * -1.00;
      this.LookAtNewTarget(component, vecToNextObject);
    };
  }

  private final func LookAtNewTarget(lookAtComponent: wref<TargetingComponent>, vecToNextObject: Vector4) -> Void {
    let aimRequest: AimRequest;
    GameInstance.GetTargetingSystem(this.GetGameInstance()).BreakAimSnap(this.GetPlayer());
    aimRequest = this.FillLookAtRequestData(lookAtComponent);
    if NotEquals(this.m_lookatRequest.lookAtTarget, aimRequest.lookAtTarget) {
      this.m_lookatRequest = aimRequest;
      this.m_quickHackTarget = lookAtComponent.GetEntity().GetEntityID();
      if this.ResolveCurrentTarget() {
        this.ReactToTargetChanged();
      };
      GameInstance.GetTargetingSystem(this.GetGameInstance()).LookAt(this.GetPlayer(), this.m_lookatRequest);
      this.RequestTimeDilation(n"quickHackChangeTarget", true);
    };
  }

  protected final func FillLookAtRequestData(lookAtComponent: wref<TargetingComponent>) -> AimRequest {
    let localAimRequest: AimRequest;
    let localToWorldMatrix: Matrix = lookAtComponent.GetLocalToWorld();
    localAimRequest.lookAtTarget = Matrix.GetTranslation(localToWorldMatrix);
    localAimRequest.duration = 0.10;
    localAimRequest.easeIn = false;
    localAimRequest.easeOut = false;
    localAimRequest.precision = 0.01;
    localAimRequest.adjustPitch = true;
    localAimRequest.adjustYaw = true;
    localAimRequest.checkRange = false;
    localAimRequest.endOnCameraInputApplied = true;
    localAimRequest.endOnTargetReached = false;
    localAimRequest.processAsInput = true;
    return localAimRequest;
  }

  protected cb func OnNameplateChanged(value: Variant) -> Bool {
    let request: ref<NemaplateChangedRequest> = new NemaplateChangedRequest();
    request.playerTarget = FromVariant(value);
    this.QueueRequest(request);
  }

  protected final func OnNemaplateChangedRequest(evt: ref<NemaplateChangedRequest>) -> Void {
    this.m_nameplateTarget = evt.playerTarget;
    if this.ResolveCurrentTarget() {
      this.ReactToTargetChanged();
    };
  }

  protected cb func OnScannerTargetChanged(value: EntityID) -> Bool {
    let request: ref<ScannerTargetChangedRequest> = new ScannerTargetChangedRequest();
    request.scannerTarget = value;
    this.QueueRequest(request);
  }

  private final func RequestTimeDilation(eventId: CName, val: Bool) -> Void {
    let psmEvent: ref<PSMPostponedParameterBool> = new PSMPostponedParameterBool();
    psmEvent.id = eventId;
    psmEvent.value = val;
    this.GetPlayer().QueueEvent(psmEvent);
  }

  protected final func OnScannerTargetChangedRequest(request: ref<ScannerTargetChangedRequest>) -> Void {
    this.m_scannerTarget = request.scannerTarget;
    if this.ResolveCurrentTarget() {
      this.ReactToTargetChanged();
    };
    this.RequestTimeDilation(n"quickHackChangeTarget", false);
  }

  protected final func OnResolveRadial(request: ref<ResolveQuickHackRadialRequest>) -> Void;

  public final const func IsRegistered(id: EntityID) -> Bool {
    return this.GetActor(id) != null;
  }

  private final func ProcessRegistration(request: ref<HUDManagerRegistrationRequest>) -> Void {
    if request.isRegistering {
      if IsDefined(this.GetActor(request.ownerID)) {
        this.HUDLog(EntityID.ToDebugString(request.ownerID) + " already exists. RegistryRequest rejected");
      } else {
        this.RegisterActor_Script(request);
      };
    } else {
      this.UnregisterActor_Script(request);
    };
  }

  private final func RegisterActor_Script(request: ref<HUDManagerRegistrationRequest>) -> Void {
    let freshActor: ref<HUDActor> = this.RegisterActor(request.ownerID);
    let type: HUDActorType = request.type;
    if Equals(type, HUDActorType.UNINITIALIZED) {
      this.HUDLog("REGISTRATION FAILED. UNKNOWN TYPE");
      return;
    };
    HUDActor.Construct(freshActor, request.ownerID, type, HUDActorStatus.REGISTERED, this.DetermineActorVisibilityState(request.ownerID));
    if Equals(this.m_state, HUDState.ACTIVATED) && IsDefined(freshActor) {
      this.IterateModules(this.CreateJob(freshActor));
    };
  }

  private final func UnregisterActor_Script(request: ref<HUDManagerRegistrationRequest>) -> Void {
    let i: Int32;
    let hudActor: ref<HUDActor> = this.GetActor(request.ownerID);
    this.SuppressActor(hudActor);
    if IsDefined(hudActor) {
      i = 0;
      while i < ArraySize(this.m_modulesArray) {
        this.m_modulesArray[i].UnregisterActor(hudActor);
        i += 1;
      };
      this.UnregisterActor(request.ownerID);
    };
  }

  private final func ResolveCurrentTarget() -> Bool {
    let actor: ref<HUDActor>;
    let potentialTarget: EntityID;
    if !IsFinal() {
      this.RefreshDebug();
    };
    if EntityID.IsDefined(this.m_scannerTarget) {
      potentialTarget = this.m_scannerTarget;
    } else {
      if EntityID.IsDefined(this.m_lookAtTarget) {
        potentialTarget = this.m_lookAtTarget;
      } else {
        if this.SetNewTarget(null) {
          return true;
        };
        return false;
      };
    };
    if EntityID.IsDefined(potentialTarget) {
      actor = this.GetActor(potentialTarget);
      if this.SetNewTarget(actor) {
        return true;
      };
    };
    return false;
  }

  private final func SetNewTarget(newTarget: ref<HUDActor>) -> Bool {
    if this.m_currentTarget == newTarget {
      return false;
    };
    this.m_lastTarget = this.m_currentTarget;
    this.m_currentTarget = newTarget;
    this.m_currentTarget.SetShouldRefreshQHack(true);
    return true;
  }

  private final func ReactToTargetChanged() -> Void {
    let actors: array<ref<HUDActor>>;
    if NotEquals(this.m_state, HUDState.ACTIVATED) {
      return;
    };
    if IsDefined(this.m_currentTarget) {
      ArrayPush(actors, this.m_currentTarget);
    };
    if this.m_lastTarget != this.m_currentTarget {
      ArrayPush(actors, this.m_lastTarget);
      if this.IsQuickHackPanelOpened() {
        this.ClearQuickHackTargetData(this.m_lastTarget.GetEntityID());
        this.RefreshHudForSingleActor(this.GetCurrentTarget());
      };
    };
    this.IterateModules(this.CreateJobs(actors));
    if !IsFinal() {
      this.RefreshDebug();
    };
  }

  private final func CanShowHintMessage() -> Bool {
    let attitudeCheck: Bool;
    let currentTargetObj: wref<GameObject>;
    if Equals(this.m_currentTarget.GetType(), HUDActorType.PUPPET) || Equals(this.m_currentTarget.GetType(), HUDActorType.DEVICE) || Equals(this.m_currentTarget.GetType(), HUDActorType.BODY_DISPOSAL_DEVICE) {
      currentTargetObj = GameInstance.FindEntityByID(this.GetGameInstance(), this.m_currentTarget.GetEntityID()) as GameObject;
      attitudeCheck = NotEquals(GameObject.GetAttitudeTowards(this.GetPlayer(), currentTargetObj), EAIAttitude.AIA_Friendly);
      return this.IsCyberdeckEquipped() && attitudeCheck;
    };
    if Equals(this.m_currentTarget.GetType(), HUDActorType.ITEM) || Equals(this.m_currentTarget.GetType(), HUDActorType.VEHICLE) {
      return false;
    };
    return this.IsCyberdeckEquipped();
  }

  public final const func IsCyberdeckEquipped() -> Bool {
    let player: ref<GameObject> = GetPlayer(this.GetGameInstance());
    return EquipmentSystem.IsCyberdeckEquipped(player);
  }

  private final func RefreshHUD() -> Void {
    let invalidDealy: DelayID;
    let jobs: array<HUDJob>;
    if NotEquals(this.m_state, HUDState.ACTIVATED) {
      return;
    };
    if this.m_instructionsDelayID != invalidDealy {
      GameInstance.GetDelaySystem(this.GetGameInstance()).CancelCallback(this.m_instructionsDelayID);
      GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_instructionsDelayID);
      this.m_instructionsDelayID = invalidDealy;
    };
    jobs = this.CreateJobs(this.GetAllActors());
    this.IterateModules(jobs);
  }

  private final func RefreshHudForSingleActor(actor: ref<HUDActor>, opt targetModules: array<wref<HUDModule>>) -> Void {
    let actors: array<ref<HUDActor>>;
    let i: Int32;
    let jobs: array<HUDJob>;
    if NotEquals(this.m_state, HUDState.ACTIVATED) || actor == null {
      return;
    };
    ArrayPush(actors, actor);
    jobs = this.CreateJobs(actors);
    if ArraySize(targetModules) > 0 {
      i = 0;
      while i < ArraySize(targetModules) {
        targetModules[i].Iterate(jobs);
        i += 1;
      };
    } else {
      i = 0;
      while i < ArraySize(this.m_modulesArray) {
        this.m_modulesArray[i].Iterate(jobs);
        i += 1;
      };
    };
    this.SendInstructions(jobs);
  }

  private final func CreateJob(actor: ref<HUDActor>) -> HUDJob {
    let job: HUDJob;
    job.actor = actor;
    job.instruction = new HUDInstruction();
    HUDInstruction.Construct(job.instruction, actor.GetEntityID());
    return job;
  }

  private final func CreateJobsForClueActors(actors: array<ref<HUDActor>>) -> array<HUDJob> {
    let jobs: array<HUDJob>;
    let i: Int32 = 0;
    while i < ArraySize(actors) {
      if IsDefined(actors[i]) && actors[i].IsClue() {
        ArrayPush(jobs, this.CreateJob(actors[i]));
      };
      i += 1;
    };
    return jobs;
  }

  private final func CreateJobsByActorType(actors: array<ref<HUDActor>>, type: HUDActorType) -> array<HUDJob> {
    let jobs: array<HUDJob>;
    let i: Int32 = 0;
    while i < ArraySize(actors) {
      if IsDefined(actors[i]) && Equals(actors[i].GetType(), type) {
        ArrayPush(jobs, this.CreateJob(actors[i]));
      };
      i += 1;
    };
    return jobs;
  }

  private final func CreateJobs(actors: array<ref<HUDActor>>) -> array<HUDJob> {
    let jobs: array<HUDJob>;
    let i: Int32 = 0;
    while i < ArraySize(actors) {
      if IsDefined(actors[i]) {
        ArrayPush(jobs, this.CreateJob(actors[i]));
      };
      i += 1;
    };
    return jobs;
  }

  private final func IterateModules(job: HUDJob) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_modulesArray) {
      this.m_modulesArray[i].Iterate(job);
      i += 1;
    };
    this.SendSingleInstruction(job.actor.GetEntityID(), job.instruction);
  }

  private final func IterateModules(jobs: array<HUDJob>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_modulesArray) {
      this.m_modulesArray[i].Iterate(jobs);
      i += 1;
    };
    this.SendInstructions(jobs);
  }

  private final func SendInstructions(jobs: array<HUDJob>) -> Void {
    let excessJobsPackage: array<HUDJob>;
    let totalInstructions: Int32;
    let i: Int32 = 0;
    while i < ArraySize(jobs) {
      if totalInstructions >= this.GetMaxInstructionsPerFrame() {
        ArrayPush(excessJobsPackage, jobs[i]);
      } else {
        this.SendSingleInstruction(jobs[i].actor.GetEntityID(), jobs[i].instruction);
      };
      totalInstructions += 1;
      i += 1;
    };
    if ArraySize(excessJobsPackage) > 0 {
      this.SendInstructionsByRequest(excessJobsPackage);
    };
  }

  private final func SuppressActor(actor: ref<HUDActor>) -> Void {
    let i: Int32;
    let suppressJobs: array<HUDJob>;
    if IsDefined(actor) {
      ArrayPush(suppressJobs, this.CreateJob(actor));
    };
    i = 0;
    while i < ArraySize(this.m_modulesArray) {
      this.m_modulesArray[i].Suppress(suppressJobs);
      i += 1;
    };
    this.SendInstructions(suppressJobs);
  }

  private final func SendSingleInstruction(entityID: EntityID, evt: ref<Event>) -> Void {
    if evt != null && EntityID.IsDefined(entityID) {
      this.QueueEntityEvent(entityID, evt);
    };
  }

  private final func PostponeModuleIteration(remainingJobs: array<HUDJob>) -> Void {
    let request: ref<IterateModulesRequest> = new IterateModulesRequest();
    request.remainingJobs = remainingJobs;
    GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(this.GetClassName(), request, 0.03, false);
  }

  private final func OnIterateModulesRequest(request: ref<IterateModulesRequest>) -> Void {
    this.IterateModules(request.remainingJobs);
  }

  private final func SendInstructionsByRequest(jobs: array<HUDJob>) -> Void {
    let request: ref<SendInstructionRequest> = new SendInstructionRequest();
    request.jobs = jobs;
    this.m_instructionsDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(this.GetClassName(), request, 0.03, false);
  }

  protected final func OnInstructionRequest(request: ref<SendInstructionRequest>) -> Void {
    let invalidID: DelayID;
    this.m_instructionsDelayID = invalidID;
    this.SendInstructions(request.jobs);
  }

  private final const func GetMaxInstructionsPerFrame() -> Int32 {
    return 50;
  }

  private final const func DetermineActorVisibilityState(id: EntityID) -> ActorVisibilityStatus {
    return ActorVisibilityStatus.OUTSIDE_CAMERA;
  }

  private final func ForceScannerModule(actor: wref<HUDActor>, shouldForce: Bool) -> Void {
    let mode: gameScanningMode;
    let scanningController: ref<ScanningController>;
    if NotEquals(this.m_state, HUDState.ACTIVATED) {
      return;
    };
    scanningController = this.m_visionModeSystem.GetScanningController();
    if !IsDefined(scanningController) {
      this.HUDLog("NO SCANNING CONTROLLER!");
      return;
    };
    if shouldForce {
      mode = gameScanningMode.Light;
      scanningController.EnterMode(this.GetPlayer(), mode);
      scanningController.SetIsScanned_Event(GameInstance.FindEntityByID(this.GetGameInstance(), actor.GetEntityID()) as GameObject, shouldForce);
      NetworkSystem.SendEvaluateVisionModeRequest(this.GetGameInstance(), gameVisionModeType.Focus);
    };
    if !shouldForce && !Equals(this.GetActiveMode(), ActiveMode.FOCUS) {
      mode = gameScanningMode.Inactive;
      scanningController.EnterMode(this.GetPlayer(), mode);
      NetworkSystem.SendEvaluateVisionModeRequest(this.GetGameInstance(), gameVisionModeType.Default);
    };
  }

  protected final func RegisterScannerTargetCallback() -> Void {
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_Scanner);
    if IsDefined(blackboard) && !IsDefined(this.m_scannerTargetCallbackID) {
      this.m_scannerTargetCallbackID = blackboard.RegisterListenerEntityID(GetAllBlackboardDefs().UI_Scanner.ScannedObject, this, n"OnScannerTargetChanged");
    };
  }

  protected final func RegisterPlayerTargetCallback() -> Void {
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_TargetingInfo);
    if IsDefined(blackboard) && !IsDefined(this.m_playerTargetCallbackID) {
      this.m_playerTargetCallbackID = blackboard.RegisterListenerEntityID(GetAllBlackboardDefs().UI_TargetingInfo.CurrentVisibleTarget, this, n"OnPlayerTargetChanged");
    };
  }

  protected final func RegisterBraindanceToggleCallback() -> Void {
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().Braindance);
    if IsDefined(blackboard) && !IsDefined(this.m_braindanceToggleCallbackID) {
      this.m_braindanceToggleCallbackID = blackboard.RegisterListenerBool(GetAllBlackboardDefs().Braindance.IsActive, this, n"OnBraindanceToggle");
    };
  }

  protected final func RegisterNameplateShownCallback() -> Void {
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_NameplateData);
    if IsDefined(blackboard) && !IsDefined(this.m_nameplateCallbackID) {
      this.m_nameplateCallbackID = blackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_NameplateData.EntityID, this, n"OnNameplateChanged");
    };
  }

  protected final func UnRegisterPlayerTargetCallback() -> Void {
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_TargetingInfo);
    if IsDefined(this.m_playerTargetCallbackID) {
      blackboard.UnregisterListenerEntityID(GetAllBlackboardDefs().UI_TargetingInfo.CurrentVisibleTarget, this.m_playerTargetCallbackID);
    };
  }

  private final func RegisterVisionModeCallback(player: ref<GameObject>) -> Void {
    let blackboard: ref<IBlackboard>;
    if player != null {
      blackboard = this.GetPlayerStateMachineBlackboard(player);
      if IsDefined(blackboard) && !IsDefined(this.m_visionModeChangedCallbackID) {
        this.m_visionModeChangedCallbackID = blackboard.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Vision, this, n"OnVisionModeChanged");
      };
    };
  }

  private final func UnregisterVisionModeCallback(player: ref<GameObject>) -> Void {
    let blackboard: ref<IBlackboard>;
    if player != null {
      blackboard = this.GetPlayerStateMachineBlackboard(player);
      if IsDefined(blackboard) {
        if IsDefined(this.m_visionModeChangedCallbackID) {
          blackboard.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Vision, this.m_visionModeChangedCallbackID);
        };
      };
      this.m_visionModeChangedCallbackID = null;
    };
  }

  private final func RegisterHackingMinigameCallback() -> Void {
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().NetworkBlackboard);
    if IsDefined(blackboard) && !IsDefined(this.m_hackingMinigameCallbackID) {
      this.m_hackingMinigameCallbackID = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().NetworkBlackboard).RegisterListenerString(GetAllBlackboardDefs().NetworkBlackboard.NetworkName, this, n"OnBreachingNetwork");
    };
  }

  private final func UnregisterHackingMinigameCallback(player: ref<GameObject>) -> Void {
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().NetworkBlackboard);
    if IsDefined(blackboard) && IsDefined(this.m_hackingMinigameCallbackID) {
      blackboard.UnregisterListenerString(GetAllBlackboardDefs().NetworkBlackboard.NetworkName, this.m_hackingMinigameCallbackID);
    };
    this.m_hackingMinigameCallbackID = null;
  }

  protected final func RegisterUICallbacks() -> Void {
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_Scanner);
    if IsDefined(blackboard) && !IsDefined(this.m_uiScannerVisibleCallbackID) {
      this.m_uiScannerVisibleCallbackID = blackboard.RegisterListenerBool(GetAllBlackboardDefs().UI_Scanner.UIVisible, this, n"OnScannerUIVisibleChanged");
    };
    blackboard = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    if IsDefined(blackboard) && !IsDefined(this.m_uiQuickHackVisibleCallbackID) {
      this.m_uiQuickHackVisibleCallbackID = blackboard.RegisterListenerBool(GetAllBlackboardDefs().UI_QuickSlotsData.quickhackPanelOpen, this, n"OnQuickHackUIVisibleChanged");
    };
    blackboard = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UIInteractions);
    if IsDefined(blackboard) && !IsDefined(this.m_lootDataCallbackID) {
      this.m_lootDataCallbackID = blackboard.RegisterListenerVariant(GetAllBlackboardDefs().UIInteractions.LootData, this, n"OnLootDataChanged");
    };
  }

  protected final func UnregisterUICallbacks() -> Void {
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_Scanner);
    if blackboard != null && IsDefined(this.m_uiScannerVisibleCallbackID) {
      blackboard.UnregisterListenerBool(GetAllBlackboardDefs().UI_Scanner.UIVisible, this.m_uiScannerVisibleCallbackID);
    };
    blackboard = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    if blackboard != null && IsDefined(this.m_uiQuickHackVisibleCallbackID) {
      blackboard.UnregisterListenerBool(GetAllBlackboardDefs().UI_QuickSlotsData.quickhackPanelOpen, this.m_uiQuickHackVisibleCallbackID);
    };
    blackboard = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UIInteractions);
    if blackboard != null && IsDefined(this.m_lootDataCallbackID) {
      blackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UIInteractions.LootData, this.m_lootDataCallbackID);
    };
  }

  protected cb func OnScannerUIVisibleChanged(visible: Bool) -> Bool {
    let uiSystem: ref<UISystem> = GameInstance.GetUISystem(this.GetGameInstance());
    if uiSystem == null || Equals(this.m_uiScannerVisible, visible) {
      return true;
    };
    this.m_uiScannerVisible = visible;
    if this.m_uiQuickHackVisible {
      return true;
    };
    if visible {
      uiSystem.PushGameContext(UIGameContext.Scanning);
    } else {
      uiSystem.PopGameContext(UIGameContext.Scanning);
    };
    this.RefreshDebug();
  }

  protected cb func OnQuickHackUIVisibleChanged(visible: Bool) -> Bool {
    let uiSystem: ref<UISystem> = GameInstance.GetUISystem(this.GetGameInstance());
    if uiSystem == null || Equals(this.m_uiQuickHackVisible, visible) {
      return true;
    };
    this.m_uiQuickHackVisible = visible;
    if visible {
      if this.m_uiScannerVisible {
        uiSystem.SwapGameContext(UIGameContext.Scanning, UIGameContext.QuickHack);
      } else {
        uiSystem.PushGameContext(UIGameContext.QuickHack);
      };
    } else {
      if this.m_uiScannerVisible {
        uiSystem.SwapGameContext(UIGameContext.QuickHack, UIGameContext.Scanning);
      } else {
        uiSystem.PopGameContext(UIGameContext.QuickHack);
      };
    };
  }

  protected cb func OnLootDataChanged(value: Variant) -> Bool {
    let invalidID: EntityID;
    let newActor: ref<HUDActor>;
    let newTarget: EntityID;
    let oldActor: ref<HUDActor>;
    let data: LootData = FromVariant(value);
    if data.isActive {
      newTarget = data.ownerId;
    } else {
      newTarget = invalidID;
    };
    if newTarget != this.m_lootedTarget {
      if EntityID.IsDefined(newTarget) {
        newActor = this.GetActor(newTarget);
      };
      if EntityID.IsDefined(this.m_lootedTarget) {
        oldActor = this.GetActor(this.m_lootedTarget);
      };
      this.m_lootedTarget = newTarget;
      if IsDefined(oldActor) {
        this.RefreshHudForSingleActor(oldActor);
      };
      if IsDefined(newActor) {
        this.RefreshHudForSingleActor(newActor);
      };
    };
  }

  public final const func GetHUDState() -> HUDState {
    return this.m_state;
  }

  public final const func GetActiveMode() -> ActiveMode {
    return this.m_activeMode;
  }

  public final static func GetActiveMode(context: GameInstance) -> ActiveMode {
    let self: ref<HUDManager> = GameInstance.GetScriptableSystemsContainer(context).Get(n"HUDManager") as HUDManager;
    if !IsDefined(self) {
      return ActiveMode.UNINITIALIZED;
    };
    return self.GetActiveMode();
  }

  public final const func GetLastTarget() -> ref<HUDActor> {
    return this.m_lastTarget;
  }

  public final const func GetUiScannerVisible() -> Bool {
    return this.m_uiScannerVisible;
  }

  public final const func GetIconsModule() -> ref<IconsModule> {
    return this.m_iconsModule.IsModuleOperational() ? this.m_iconsModule : null;
  }

  public final const func GetLockedClueID() -> EntityID {
    let id: EntityID;
    if IsDefined(this.m_scannningController) {
      id = this.m_scannningController.GetExclusiveFocusClueEntity();
    };
    return id;
  }

  public final const func GetLastTargetID() -> EntityID {
    let entityID: EntityID;
    if IsDefined(this.m_lastTarget) {
      entityID = this.m_lastTarget.GetEntityID();
    };
    return entityID;
  }

  public final const func GetQuickHackTargetID() -> EntityID {
    return this.m_quickHackTarget;
  }

  public final const func GetLootedTargetID() -> EntityID {
    return this.m_lootedTarget;
  }

  public final const func GetCurrentTarget() -> ref<HUDActor> {
    return this.m_currentTarget;
  }

  public final static func GetCurrentTarget(context: GameInstance) -> ref<HUDActor> {
    let self: ref<HUDManager> = GameInstance.GetScriptableSystemsContainer(context).Get(n"HUDManager") as HUDManager;
    if !IsDefined(self) {
      return null;
    };
    return self.GetCurrentTarget();
  }

  public final const func GetCurrentTargetObject() -> ref<GameObject> {
    return GameInstance.FindEntityByID(this.GetGameInstance(), this.GetCurrentTarget().GetEntityID()) as GameObject;
  }

  public final const func GetCurrentTargetID() -> EntityID {
    let entityID: EntityID;
    if IsDefined(this.m_currentTarget) {
      entityID = this.m_currentTarget.GetEntityID();
    };
    return entityID;
  }

  public final const func HasCurrentTarget() -> Bool {
    if IsDefined(this.m_currentTarget) {
      return true;
    };
    return false;
  }

  public final static func HasCurrentTarget(context: GameInstance) -> Bool {
    let self: ref<HUDManager> = GameInstance.GetScriptableSystemsContainer(context).Get(n"HUDManager") as HUDManager;
    if !IsDefined(self) {
      return false;
    };
    return self.HasCurrentTarget();
  }

  public final const func CanActivateRemoteActionWheel() -> Bool {
    let object: ref<GameObject>;
    if this.HasCurrentTarget() {
      object = GameInstance.FindEntityByID(this.GetGameInstance(), this.m_currentTarget.GetEntityID()) as GameObject;
      if IsDefined(object) {
        return object.ShouldShowScanner() && object.CanRevealRemoteActionsWheel();
      };
      return false;
    };
    return false;
  }

  public final const func GetPlayerStateMachineBlackboard(playerPuppet: wref<GameObject>) -> ref<IBlackboard> {
    let blackboard: ref<IBlackboard>;
    if playerPuppet != null {
      blackboard = GameInstance.GetBlackboardSystem(this.GetGameInstance()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    };
    return blackboard;
  }

  protected final const func IsRequestLegal(requestToValidate: ref<HUDManagerRequest>) -> Bool {
    if requestToValidate.IsValid() {
      return true;
    };
    return false;
  }

  public final const func QueueEntityEvent(entityID: EntityID, evt: ref<Event>) -> Void {
    if EntityID.IsDefined(entityID) && evt != null {
      GameInstance.GetPersistencySystem(this.GetGameInstance()).QueueEntityEvent(entityID, evt);
    };
  }

  public final const func GetPlayer() -> ref<GameObject> {
    return GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerControlledGameObject();
  }

  private final func HUDLog(message: String) -> Void;

  public final static func ShowScannerHint(game: GameInstance) -> Void {
    let blackboard: ref<IBlackboard>;
    if GameInstance.IsValid(game) {
      blackboard = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().HUD_Manager);
      blackboard.SetBool(GetAllBlackboardDefs().HUD_Manager.ShowHudHintMessege, true);
    };
  }

  public final static func HideScannerHint(game: GameInstance) -> Void {
    let blackboard: ref<IBlackboard>;
    if GameInstance.IsValid(game) {
      blackboard = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().HUD_Manager);
      blackboard.SetBool(GetAllBlackboardDefs().HUD_Manager.ShowHudHintMessege, false);
    };
  }

  public final static func SetScannerHintMessege(game: GameInstance, text: String) -> Void {
    let blackboard: ref<IBlackboard>;
    if GameInstance.IsValid(game) {
      blackboard = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().HUD_Manager);
      blackboard.SetString(GetAllBlackboardDefs().HUD_Manager.HudHintMessegeContent, text);
    };
  }

  private final func GetPulseDuration() -> Float {
    return TDB.GetFloat(t"scanning.pulse.duration");
  }

  public final const func IsPulseActive() -> Bool {
    let invalidDelay: DelayID;
    return this.m_pulseDelayID != invalidDelay;
  }

  public final const func CanPulse() -> Bool {
    let player: ref<GameObject> = this.GetPlayer();
    let statValue: Float = GameInstance.GetStatsSystem(this.GetGameInstance()).GetStatValue(Cast(player.GetEntityID()), gamedataStatType.HasCybereye);
    let canScan: Bool = !StatusEffectSystem.ObjectHasStatusEffect(player, t"GameplayRestriction.NoScanning");
    return statValue > 0.00 && canScan;
  }

  private final func StartPulse() -> Void {
    let request: ref<PulseFinishedRequest>;
    let shouldRefresh: Bool;
    if !this.CanPulse() {
      return;
    };
    if this.IsPulseActive() {
      GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_pulseDelayID);
      GameInstance.GetDelaySystem(this.GetGameInstance()).CancelCallback(this.m_pulseDelayID);
      shouldRefresh = false;
    } else {
      shouldRefresh = true;
    };
    request = new PulseFinishedRequest();
    this.m_pulseDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(this.GetClassName(), request, this.GetPulseDuration(), false);
    if shouldRefresh {
      this.RefreshHUD();
    };
  }

  private final func StopPulse() -> Void {
    let invalidDelay: DelayID;
    this.m_pulseDelayID = invalidDelay;
    this.RefreshHUD();
  }

  protected final func OnPingFinishedRequest(request: ref<PulseFinishedRequest>) -> Void {
    this.StopPulse();
  }

  protected final const func GetNetworkSystem() -> ref<NetworkSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"NetworkSystem") as NetworkSystem;
  }

  private final func RefreshDebug() -> Void {
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, "HUDManager");
    SDOSink.PushString(sink, "Current target", EntityID.ToDebugString(this.m_currentTarget.GetEntityID()));
    SDOSink.PushString(sink, "Last target", EntityID.ToDebugString(this.m_lastTarget.GetEntityID()));
    SDOSink.PushString(sink, "LookAt target", EntityID.ToDebugString(this.m_lookAtTarget));
    SDOSink.PushString(sink, "Scanner target", EntityID.ToDebugString(this.m_scannerTarget));
    SDOSink.PushString(sink, "Nameplate target", EntityID.ToDebugString(this.m_nameplateTarget));
    SDOSink.PushBool(sink, "Scanner opened", this.m_uiScannerVisible);
    SDOSink.PushBool(sink, "QHMenu opened", this.IsQuickHackPanelOpened());
  }
}
