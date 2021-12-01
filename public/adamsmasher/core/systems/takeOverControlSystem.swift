
public class TakeOverControlSystem extends ScriptableSystem {

  private let m_controlledObject: wref<GameObject>;

  private let m_isInputRegistered: Bool;

  private let m_isInputLockedFromQuest: Bool;

  private let m_isChainForcedFromQuest: Bool;

  private let m_isActionButtonLocked: Bool;

  private let m_isDeviceChainCreationLocked: Bool;

  private let m_chainLockSources: array<CName>;

  private let m_TCDUpdateDelayID: DelayID;

  @default(TakeOverControlSystem, 0.1f)
  private let m_TCSupdateRate: Float;

  private let m_lastInputSimTime: Float;

  public final const func GetControlledObject() -> ref<GameObject> {
    return this.m_controlledObject;
  }

  public final const func IsInputLockedFromQuest() -> Bool {
    return this.m_isInputLockedFromQuest;
  }

  public final const func IsDeviceControlled() -> Bool {
    if IsDefined(this.GetControlledObject()) {
      return true;
    };
    return false;
  }

  private func IsSavingLocked() -> Bool {
    return this.IsDeviceControlled();
  }

  private final func CleanupControlledObject() -> Void {
    let cameraControlEvt: ref<DeviceEndPlayerCameraControlEvent> = new DeviceEndPlayerCameraControlEvent();
    this.m_controlledObject.QueueEvent(cameraControlEvt);
    this.m_controlledObject = null;
    this.CleanupActiveEntityInChainBlackboard();
  }

  private final func OnEnableFastTravelRequest(request: ref<LockTakeControlAction>) -> Void {
    this.m_isActionButtonLocked = request.isLocked;
  }

  private final func OnLockDeviceChainCreationRequest(request: ref<LockDeviceChainCreation>) -> Void {
    this.m_isDeviceChainCreationLocked = request.isLocked;
    if request.isLocked {
      ArrayPush(this.m_chainLockSources, request.source);
    } else {
      ArrayRemove(this.m_chainLockSources, request.source);
    };
    GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().DeviceTakeControl).SetBool(GetAllBlackboardDefs().DeviceTakeControl.ChainLocked, this.m_isDeviceChainCreationLocked);
  }

  public final const func IskDeviceChainCreationLocked() -> Bool {
    return this.m_isDeviceChainCreationLocked;
  }

  private final func LockInputFromQuestRequest(isLocked: Bool) -> Void {
    this.m_isInputLockedFromQuest = isLocked;
  }

  private final func ForceChainFromQuestRequest(isChainForced: Bool) -> Void {
    this.m_isChainForcedFromQuest = isChainForced;
  }

  public final static func RequestTakeControl(context: ref<GameObject>, originalevent: ref<ToggleTakeOverControl>) -> Void {
    let psmBlackboard: ref<IBlackboard>;
    let takeOverRequest: ref<RequestTakeControl>;
    let tier: Int32;
    let takeOverControlSystem: ref<TakeOverControlSystem> = GameInstance.GetScriptableSystemsContainer(context.GetGame()).Get(n"TakeOverControlSystem") as TakeOverControlSystem;
    if !IsDefined(takeOverControlSystem) {
      return;
    };
    if originalevent.IsQuickHack() {
      psmBlackboard = GameInstance.GetBlackboardSystem(context.GetGame()).GetLocalInstanced(GameInstance.GetPlayerSystem(context.GetGame()).GetLocalPlayerControlledGameObject().GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
      if IsDefined(psmBlackboard) {
        tier = psmBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel);
        if tier > EnumInt(gamePSMHighLevel.SceneTier1) && tier <= EnumInt(gamePSMHighLevel.SceneTier5) {
          return;
        };
      };
    };
    takeOverRequest = new RequestTakeControl();
    takeOverRequest.requestSource = context.GetEntityID();
    takeOverRequest.originalEvent = originalevent;
    takeOverControlSystem.QueueRequest(takeOverRequest);
  }

  private final func OnRequestTakeControl(request: ref<RequestTakeControl>) -> Void {
    this.RegisterAsCurrentObject(request.requestSource);
    this.SendTSCActivateEventToEntity(request.originalEvent.IsQuickHack());
    if this.m_isChainForcedFromQuest {
      this.TryFillControlBlackboardByForce(request);
      this.m_isChainForcedFromQuest = false;
    } else {
      this.TryFillControlBlackboard(request);
    };
    this.EnablePlayerTPPRepresenation(true);
    this.HideAdvanceInteractionInputHints();
  }

  private final func OnRemoveFromChainRequest(request: ref<RemoveFromChainRequest>) -> Void {
    let chain: array<SWidgetPackage>;
    let i: Int32;
    let psID: PersistentID;
    if this.GetControlledObject().GetEntityID() == request.requestSource {
      this.ToggleToNextControlledDevice();
    };
    chain = this.GetChain();
    i = 0;
    while i < ArraySize(chain) {
      psID = CreatePersistentID(request.requestSource, n"controller");
      if Equals(chain[i].ownerID, psID) {
        ArrayErase(chain, i);
      } else {
        i += 1;
      };
    };
    GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().DeviceTakeControl).SetVariant(GetAllBlackboardDefs().DeviceTakeControl.DevicesChain, ToVariant(chain));
  }

  public final static func ReleaseControlOnHit(player: wref<PlayerPuppet>) -> Bool {
    let controlledObject: wref<GameObject>;
    let takeOverControlSystem: ref<TakeOverControlSystem>;
    if !IsDefined(player) {
      return false;
    };
    takeOverControlSystem = GameInstance.GetScriptableSystemsContainer(player.GetGame()).Get(n"TakeOverControlSystem") as TakeOverControlSystem;
    if !IsDefined(takeOverControlSystem) {
      return false;
    };
    controlledObject = takeOverControlSystem.GetControlledObject();
    if !IsDefined(controlledObject) {
      return false;
    };
    if VehicleComponent.IsMountedToVehicle(player.GetGame(), player) {
      return false;
    };
    if IsDefined(controlledObject as SensorDevice) {
      takeOverControlSystem.QueueRequest(new RequestReleaseControl());
      return true;
    };
    return false;
  }

  public final static func ReleaseControl(game: GameInstance) -> Bool {
    let takeOverControlSystem: ref<TakeOverControlSystem>;
    if !GameInstance.IsValid(game) {
      return false;
    };
    takeOverControlSystem = GameInstance.GetScriptableSystemsContainer(game).Get(n"TakeOverControlSystem") as TakeOverControlSystem;
    if !IsDefined(takeOverControlSystem) {
      return false;
    };
    if !takeOverControlSystem.IsDeviceControlled() {
      return false;
    };
    takeOverControlSystem.QueueRequest(new RequestReleaseControl());
    return true;
  }

  private final func OnRequestReleaseControl(request: ref<RequestReleaseControl>) -> Void {
    this.ToggleToMainPlayerObject();
  }

  private final func OnRequestQuestTakeControlInputLock(request: ref<RequestQuestTakeControlInputLock>) -> Void {
    this.LockInputFromQuestRequest(request.isLocked);
    this.ForceChainFromQuestRequest(request.isChainForced);
  }

  private final func ReleaseCurrentObject() -> Void {
    let ReleaseEvt: ref<TCSTakeOverControlDeactivate> = new TCSTakeOverControlDeactivate();
    GameInstance.GetPersistencySystem(this.GetGameInstance()).QueuePSEvent(CreatePersistentID(this.GetControlledObject().GetEntityID(), n"controller"), (this.GetControlledObject() as Device).GetDevicePS().GetClassName(), ReleaseEvt);
    this.CleanupControlledObject();
  }

  private final func RegisterAsCurrentObject(entityID: EntityID) -> Void {
    this.RegisterObjectHandle(entityID);
    this.RegisterSystemOnInput(true);
    this.PSMSetIsPlayerControllDevice(true);
    GameObjectEffectHelper.StartEffectEvent(this.GetControlledObject(), n"camera_transition_effect_start");
  }

  private final func RegisterBBActiveObjectAsCurrentObject() -> Void {
    let chainBlackBoard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().DeviceTakeControl);
    chainBlackBoard.SetEntityID(GetAllBlackboardDefs().DeviceTakeControl.ActiveDevice, this.GetControlledObject().GetEntityID(), true);
  }

  private final func RegisterObjectHandle(EntID: EntityID) -> Void {
    let player: ref<PlayerPuppet>;
    if IsDefined(this.GetControlledObject()) {
      if this.GetControlledObject().GetEntityID() == EntID {
        return;
      };
      this.ReleaseCurrentObject();
    };
    player = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    this.m_controlledObject = GameInstance.FindEntityByID(this.GetGameInstance(), EntID) as GameObject;
    this.GetCameraDataFromControlledObject(this.GetControlledObject(), player);
    this.RegisterBBActiveObjectAsCurrentObject();
  }

  private final func SendTSCActivateEventToEntity(isQuickhack: Bool) -> Void {
    let evtOwner: ref<TCSTakeOverControlActivate> = new TCSTakeOverControlActivate();
    evtOwner.IsQuickhack = isQuickhack;
    GameInstance.GetPersistencySystem(this.GetGameInstance()).QueuePSEvent(CreatePersistentID(this.GetControlledObject().GetEntityID(), n"controller"), (this.GetControlledObject() as Device).GetDevicePS().GetClassName(), evtOwner);
  }

  private final func GetCameraDataFromControlledObject(ent: ref<GameObject>, player: ref<GameObject>) -> Void {
    let cameraRotationData: CameraRotationData;
    let cameraControlEvt: ref<DeviceStartPlayerCameraControlEvent> = new DeviceStartPlayerCameraControlEvent();
    let sensorControlledObject: ref<SensorDevice> = ent as SensorDevice;
    if IsDefined(sensorControlledObject) {
      cameraControlEvt.playerController = player;
      if sensorControlledObject.GetDevicePS().IsON() {
        sensorControlledObject.SyncRotationWithAnimGraph();
      } else {
        sensorControlledObject.ResetRotation();
      };
      cameraRotationData = sensorControlledObject.GetRotationData();
      cameraControlEvt.minYaw = cameraRotationData.m_minYaw;
      cameraControlEvt.maxYaw = cameraRotationData.m_maxYaw;
      cameraControlEvt.minPitch = cameraRotationData.m_minPitch;
      cameraControlEvt.maxPitch = cameraRotationData.m_maxPitch;
      cameraControlEvt.initialRotation.X = cameraRotationData.m_yaw;
      cameraControlEvt.initialRotation.Y = cameraRotationData.m_pitch;
      sensorControlledObject.QueueEvent(cameraControlEvt);
    };
  }

  private final func GetChain() -> array<SWidgetPackage> {
    let chainBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().DeviceTakeControl);
    let chain: array<SWidgetPackage> = FromVariant(chainBlackboard.GetVariant(GetAllBlackboardDefs().DeviceTakeControl.DevicesChain));
    return chain;
  }

  private final func TryFillControlBlackboard(evt: ref<RequestTakeControl>) -> Void {
    if !(this.GetControlledObject() as Device).GetDevicePS().CanBeInDeviceChain() {
      this.CleanupChainBlackboard();
      return;
    };
    this.TryFillControlBlackboardByForce(evt);
    this.ShowChainControls(true);
  }

  private final func TryFillControlBlackboardByForce(evt: ref<RequestTakeControl>) -> Void {
    let allMasters: array<ref<DeviceComponentPS>>;
    let i: Int32;
    let masterEvt: ref<FillTakeOverChainBBoardEvent>;
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetParents(evt.requestSource, allMasters);
    masterEvt = new FillTakeOverChainBBoardEvent();
    masterEvt.requesterID = Cast(evt.originalEvent.GetRequesterID());
    i = 0;
    while i < ArraySize(allMasters) {
      GameInstance.GetPersistencySystem(this.GetGameInstance()).QueuePSEvent(allMasters[i].GetID(), allMasters[i].GetClassName(), masterEvt);
      i += 1;
    };
    this.ShowChainControls(true);
  }

  private final func RegisterSystemOnInput(register: Bool) -> Void {
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    if IsDefined(player) {
      if register && !this.m_isInputRegistered {
        StatusEffectHelper.ApplyStatusEffect(player, t"GameplayRestriction.NoCameraControl");
        player.RegisterInputListener(this, n"CameraX");
        player.RegisterInputListener(this, n"CameraY");
        player.RegisterInputListener(this, n"CameraMouseX");
        player.RegisterInputListener(this, n"CameraMouseY");
        player.RegisterInputListener(this, n"DeviceAttack");
        player.RegisterInputListener(this, n"StopDeviceControl");
        player.RegisterInputListener(this, n"SwitchDevicePrevious");
        player.RegisterInputListener(this, n"SwitchDeviceNext");
        player.RegisterInputListener(this, n"OpenPauseMenu");
        this.m_isInputRegistered = true;
        this.CreateTCSUpdate();
      } else {
        if !register && this.m_isInputRegistered {
          StatusEffectHelper.RemoveStatusEffect(player, t"GameplayRestriction.NoCameraControl");
          player.UnregisterInputListener(this);
          this.m_isInputRegistered = false;
          this.BreakTCSUpdate();
        };
      };
    };
  }

  private final func ShowChainControls(show: Bool) -> Void {
    if show {
      GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_HudButtonHelp).SetString(GetAllBlackboardDefs().UI_HudButtonHelp.button1_Text, "Press to next");
      GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_HudButtonHelp).SetName(GetAllBlackboardDefs().UI_HudButtonHelp.button1_Icon, n"dpad_right");
      GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_HudButtonHelp).SetString(GetAllBlackboardDefs().UI_HudButtonHelp.button2_Text, "Press to previous");
      GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_HudButtonHelp).SetName(GetAllBlackboardDefs().UI_HudButtonHelp.button2_Icon, n"dpad_left");
    } else {
      GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_HudButtonHelp).SetString(GetAllBlackboardDefs().UI_HudButtonHelp.button1_Text, "");
      GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_HudButtonHelp).SetName(GetAllBlackboardDefs().UI_HudButtonHelp.button1_Icon, n"");
      GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_HudButtonHelp).SetString(GetAllBlackboardDefs().UI_HudButtonHelp.button2_Text, "");
      GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_HudButtonHelp).SetName(GetAllBlackboardDefs().UI_HudButtonHelp.button2_Icon, n"");
    };
  }

  private final func PSMSetIsPlayerControllDevice(controllsDevice: Bool) -> Void {
    let playerStateMachineBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).GetLocalInstanced(GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerControlledGameObject().GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsControllingDevice, controllsDevice);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, controllsDevice);
    if controllsDevice {
      playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsUIZoomDevice, false);
      playerStateMachineBlackboard.FireCallbacks();
    } else {
      playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsControllingDevice, false);
      playerStateMachineBlackboard.FireCallbacks();
    };
  }

  private final func ToggleToNextControlledDevice() -> Void {
    let isStructValid: Bool;
    let package: SWidgetPackage = this.GetPackageFromChainNextToMe(true, isStructValid);
    if !isStructValid {
      return;
    };
    this.ToggleToOtherDeviceFromChain(package);
  }

  private final func ToggleToPreviousControlledDevice() -> Void {
    let isStructValid: Bool;
    let package: SWidgetPackage = this.GetPackageFromChainNextToMe(false, isStructValid);
    if !isStructValid {
      return;
    };
    this.ToggleToOtherDeviceFromChain(package);
  }

  private final func ToggleToOtherDeviceFromChain(otherPackage: SWidgetPackage) -> Void {
    this.RegisterAsCurrentObject(PersistentID.ExtractEntityID(otherPackage.ownerID));
    this.SendTSCActivateEventToEntity(false);
  }

  private final func ToggleToMainPlayerObject() -> Void {
    GameObjectEffectHelper.StartEffectEvent(this.GetControlledObject(), n"camera_transition_effect_stop");
    this.ReleaseCurrentObject();
    this.RegisterSystemOnInput(false);
    this.PSMSetIsPlayerControllDevice(false);
    this.CleanupChainBlackboard();
    this.EnablePlayerTPPRepresenation(false);
  }

  private final func GetPackageFromChainNextToMe(higher: Bool, out isValid: Bool) -> SWidgetPackage {
    let choosenPackage: SWidgetPackage;
    let myIndex: Int32;
    let nextIndex: Int32;
    let overJumpsDone: Int32;
    let chainBlackBoard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().DeviceTakeControl);
    let deviceChain: array<SWidgetPackage> = FromVariant(chainBlackBoard.GetVariant(GetAllBlackboardDefs().DeviceTakeControl.DevicesChain));
    if ArraySize(deviceChain) < 2 {
      isValid = false;
    } else {
      isValid = true;
    };
    myIndex = this.GetCurrentActiveDeviceChainBlackboardIndex(deviceChain);
    Equals(higher, true) ? nextIndex = myIndex + 1 : nextIndex = myIndex - 1;
    while nextIndex != myIndex && overJumpsDone < ArraySize(deviceChain) {
      if nextIndex == ArraySize(deviceChain) {
        choosenPackage = deviceChain[0];
      } else {
        if nextIndex < 0 {
          choosenPackage = deviceChain[ArraySize(deviceChain) - 1];
        } else {
          choosenPackage = deviceChain[nextIndex];
        };
      };
      if IsDefined(GameInstance.FindEntityByID(this.GetGameInstance(), PersistentID.ExtractEntityID(choosenPackage.ownerID))) {
        return choosenPackage;
      };
      Equals(higher, true) ? nextIndex = nextIndex + 1 : nextIndex = nextIndex - 1;
      overJumpsDone += 1;
    };
    return deviceChain[myIndex];
  }

  private final func GetCurrentActiveDeviceChainBlackboardIndex(deviceChain: array<SWidgetPackage>) -> Int32 {
    let i: Int32;
    let myPersistenID: PersistentID;
    if !EntityID.IsDefined(this.GetControlledObject().GetEntityID()) {
      return -1;
    };
    myPersistenID = CreatePersistentID(this.GetControlledObject().GetEntityID(), n"controller");
    i = 0;
    while i < ArraySize(deviceChain) {
      if Equals(deviceChain[i].ownerID, myPersistenID) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final const func EnablePlayerTPPRepresenation(enable: Bool) -> Void {
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    if IsDefined(player) {
      if enable {
        player.QueueEvent(new ActivateTPPRepresentationEvent());
        GameInstance.GetAudioSystem(this.GetGameInstance()).SetBDCameraListenerOverride(true);
        GameObjectEffectHelper.StartEffectEvent(player, n"camera_mask");
      } else {
        player.QueueEvent(new DeactivateTPPRepresentationEvent());
        GameInstance.GetAudioSystem(this.GetGameInstance()).SetBDCameraListenerOverride(false);
        GameObjectEffectHelper.StopEffectEvent(player, n"camera_mask");
      };
    };
  }

  private final func CleanupChainBlackboard() -> Void {
    let emptyPSArray: array<SWidgetPackage>;
    GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().DeviceTakeControl).SetVariant(GetAllBlackboardDefs().DeviceTakeControl.DevicesChain, ToVariant(emptyPSArray));
    this.ShowChainControls(false);
  }

  private final func CleanupActiveEntityInChainBlackboard() -> Void {
    let emptyEntityID: EntityID = new EntityID();
    GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().DeviceTakeControl).SetEntityID(GetAllBlackboardDefs().DeviceTakeControl.ActiveDevice, emptyEntityID, true);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    let XAxisEvt: ref<TCSInputXAxisEvent>;
    let YAxisEvt: ref<TCSInputYAxisEvent>;
    let currentInput: Float;
    let devceAttackEvt: ref<TCSInputDeviceAttack>;
    let psmBlackboard: ref<IBlackboard>;
    let zoomLevel: Float;
    let inputModifier: Float = 1.00;
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    if IsDefined(player) {
      psmBlackboard = player.GetPlayerStateMachineBlackboard();
      zoomLevel = psmBlackboard.GetFloat(GetAllBlackboardDefs().PlayerStateMachine.ZoomLevel);
    };
    if Equals(ListenerAction.GetName(action), n"CameraMouseX") || Equals(ListenerAction.GetName(action), n"CameraX") {
      currentInput = -ListenerAction.GetValue(action);
      if currentInput != 0.00 {
        if Equals(ListenerAction.GetName(action), n"CameraMouseX") {
          inputModifier = 0.10;
        } else {
          inputModifier = 3.50;
        };
        XAxisEvt = new TCSInputXAxisEvent();
        XAxisEvt.value += (currentInput * inputModifier) / zoomLevel;
        XAxisEvt.value = ClampF(XAxisEvt.value, -180.00, 180.00);
        GameInstance.GetPersistencySystem(this.GetGameInstance()).QueueEntityEvent(this.GetControlledObject().GetEntityID(), XAxisEvt);
        this.m_lastInputSimTime = EngineTime.ToFloat(GameInstance.GetTimeSystem(this.GetGameInstance()).GetSimTime());
      };
    };
    if Equals(ListenerAction.GetName(action), n"CameraMouseY") || Equals(ListenerAction.GetName(action), n"CameraY") {
      currentInput = ListenerAction.GetValue(action);
      if currentInput != 0.00 {
        if Equals(ListenerAction.GetName(action), n"CameraMouseY") {
          inputModifier = 0.10;
        } else {
          inputModifier = 3.50;
        };
        YAxisEvt = new TCSInputYAxisEvent();
        YAxisEvt.value = (currentInput * inputModifier) / zoomLevel;
        YAxisEvt.value = ClampF(YAxisEvt.value, -180.00, 180.00);
        GameInstance.GetPersistencySystem(this.GetGameInstance()).QueueEntityEvent(this.GetControlledObject().GetEntityID(), YAxisEvt);
        this.m_lastInputSimTime = EngineTime.ToFloat(GameInstance.GetTimeSystem(this.GetGameInstance()).GetSimTime());
      };
    };
    if !this.m_isActionButtonLocked && Equals(ListenerAction.GetName(action), n"DeviceAttack") {
      devceAttackEvt = new TCSInputDeviceAttack();
      if ListenerAction.IsButtonJustPressed(action) {
        devceAttackEvt.value = true;
      };
      if ListenerAction.IsButtonJustReleased(action) {
        devceAttackEvt.value = false;
      };
      GameInstance.GetPersistencySystem(this.GetGameInstance()).QueueEntityEvent(this.GetControlledObject().GetEntityID(), devceAttackEvt);
    };
    if Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_PRESSED) {
      if Equals(ListenerAction.GetName(action), n"StopDeviceControl") || Equals(ListenerAction.GetName(action), n"OpenPauseMenu") {
        if !this.m_isInputLockedFromQuest {
          ListenerActionConsumer.DontSendReleaseEvent(consumer);
          this.ToggleToMainPlayerObject();
          this.PSMSetIsPlayerControllDevice(false);
        };
      };
    };
    if !this.IskDeviceChainCreationLocked() {
      if Equals(ListenerAction.GetName(action), n"SwitchDevicePrevious") {
        if ListenerAction.IsButtonJustPressed(action) {
          this.ToggleToPreviousControlledDevice();
        };
      };
      if Equals(ListenerAction.GetName(action), n"SwitchDeviceNext") {
        if ListenerAction.IsButtonJustPressed(action) {
          this.ToggleToNextControlledDevice();
        };
      };
    };
  }

  public final static func CreateInputHint(context: GameInstance, isVisible: Bool) -> Void {
    let data: InputHintData;
    let takeOverControlSystem: ref<TakeOverControlSystem> = GameInstance.GetScriptableSystemsContainer(context).Get(n"TakeOverControlSystem") as TakeOverControlSystem;
    if !takeOverControlSystem.IsInputLockedFromQuest() {
      data.action = n"StopDeviceControl";
      data.source = n"TakeOverControlSystem";
      data.localizedLabel = "LocKey#52037";
      SendInputHintData(context, isVisible, data);
    };
    data.action = n"ZoomIn";
    data.source = n"TakeOverControlSystem";
    data.localizedLabel = "LocKey#52038";
    SendInputHintData(context, isVisible, data);
    data.action = n"ZoomOut";
    data.source = n"TakeOverControlSystem";
    data.localizedLabel = "LocKey#52039";
    SendInputHintData(context, isVisible, data);
    if EquipmentSystem.IsCyberdeckEquipped(GameInstance.GetPlayerSystem(context).GetLocalPlayerControlledGameObject()) {
      data.action = n"VisionHold";
      data.source = n"TakeOverControlSystem";
      data.localizedLabel = "LocKey#52040";
      SendInputHintData(context, isVisible, data);
    };
  }

  private func HideAdvanceInteractionInputHints() -> Void {
    let evt: ref<DeleteInputHintBySourceEvent> = new DeleteInputHintBySourceEvent();
    evt.source = n"AdvanceInteractionMode";
    evt.targetHintContainer = n"GameplayInputHelper";
    GameInstance.GetUISystem(this.GetGameInstance()).QueueEvent(evt);
  }

  private final func CreateTCSUpdate() -> Void {
    let updateEvt: ref<TCSUpdate>;
    if this.m_TCDUpdateDelayID == GetInvalidDelayID() {
      updateEvt = new TCSUpdate();
      this.m_TCDUpdateDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"TakeOverControlSystem", updateEvt, this.m_TCSupdateRate);
    };
  }

  private final func BreakTCSUpdate() -> Void {
    if this.m_TCDUpdateDelayID != GetInvalidDelayID() {
      GameInstance.GetDelaySystem(this.GetGameInstance()).CancelCallback(this.m_TCDUpdateDelayID);
      GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_TCDUpdateDelayID);
    };
  }

  private final func OnTCSUpdate(request: ref<TCSUpdate>) -> Void {
    let XYAxisEvt: ref<TCSInputXYAxisEvent> = new TCSInputXYAxisEvent();
    XYAxisEvt.isAnyInput = EngineTime.ToFloat(GameInstance.GetTimeSystem(this.GetGameInstance()).GetSimTime()) - this.m_lastInputSimTime < 0.20;
    GameInstance.GetPersistencySystem(this.GetGameInstance()).QueueEntityEvent(this.GetControlledObject().GetEntityID(), XYAxisEvt);
    this.m_TCDUpdateDelayID = GetInvalidDelayID();
    this.CreateTCSUpdate();
    if !IsFinal() {
      this.RefreshDebug(XYAxisEvt.isAnyInput);
    };
  }

  private final func RefreshDebug(lastXYValue: Bool) -> Void {
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, "TCS");
    SDOSink.PushFloat(sink, "Last input simTime", this.m_lastInputSimTime);
    SDOSink.PushFloat(sink, "Last update simTime", EngineTime.ToFloat(GameInstance.GetTimeSystem(this.GetGameInstance()).GetSimTime()));
    SDOSink.PushBool(sink, "Last XY event value", lastXYValue);
  }
}

public class LockTakeControlAction extends ScriptableSystemRequest {

  public edit let isLocked: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Is action button locked when player controlls device (e.g. turret shoot)";
  }
}

public class LockDeviceChainCreation extends ScriptableSystemRequest {

  public edit let isLocked: Bool;

  public edit let source: CName;

  public final func GetFriendlyDescription() -> String {
    return "Is device chain locked? e.g. camera connected to network of 4 cameras will not create possibility to jump between cameras";
  }
}
