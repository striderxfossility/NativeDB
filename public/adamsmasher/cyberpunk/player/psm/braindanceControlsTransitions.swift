
public abstract class BraindanceControlsTransition extends DefaultTransition {

  protected final const func SetBraindaneVisionModeBB(const scriptInterface: ref<StateGameScriptInterface>, newMode: braindanceVisionMode) -> Void {
    let BraindanceBB: ref<IBlackboard> = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().Braindance);
    BraindanceBB.SetInt(GetAllBlackboardDefs().Braindance.activeBraindanceVisionMode, EnumInt(newMode), true);
  }

  protected final const func SetLastBraindanceVisionMode(const scriptInterface: ref<StateGameScriptInterface>, newMode: braindanceVisionMode) -> Void {
    let BraindanceBB: ref<IBlackboard> = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().Braindance);
    BraindanceBB.SetInt(GetAllBlackboardDefs().Braindance.lastBraindanceVisionMode, EnumInt(newMode), true);
  }

  protected final const func SetBraindanceVisionFact(const scriptInterface: ref<StateGameScriptInterface>, newMode: braindanceVisionMode) -> Void {
    scriptInterface.GetQuestsSystem().SetFact(n"braindanceVisionMode", EnumInt(newMode));
  }

  protected final const func SetCachedPlaySpeedPermVariable(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>) -> Void {
    stateContext.SetPermanentIntParameter(n"cachedPlaySpeed", EnumInt(this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlaySpeed()), true);
  }

  protected final const func SetPlaybackSpeedInBlackboard(const scriptInterface: ref<StateGameScriptInterface>, speed: scnPlaySpeed) -> Void {
    let BraindanceBB: ref<IBlackboard> = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().Braindance);
    BraindanceBB.SetVariant(GetAllBlackboardDefs().Braindance.PlaybackSpeed, ToVariant(speed), true);
  }

  protected final const func SetPlaybackDirectionInBlackboard(const scriptInterface: ref<StateGameScriptInterface>, direction: scnPlayDirection) -> Void {
    let BraindanceBB: ref<IBlackboard> = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().Braindance);
    BraindanceBB.SetVariant(GetAllBlackboardDefs().Braindance.PlaybackDirection, ToVariant(direction), true);
  }

  protected final const func IsCachedPlaySpeedSet(const stateContext: ref<StateContext>) -> Bool {
    let result: StateResultInt = stateContext.GetPermanentIntParameter(n"cachedPlaySpeed");
    return result.valid;
  }

  protected final const func GetCachedPlaySpeedPermVariable(const stateContext: ref<StateContext>) -> scnPlaySpeed {
    let result: StateResultInt = stateContext.GetPermanentIntParameter(n"cachedPlaySpeed");
    return IntEnum(result.value);
  }

  protected final const func CanBraindanceEnterLayer(const scriptInterface: ref<StateGameScriptInterface>, layer: braindanceVisionMode) -> Bool {
    switch layer {
      case braindanceVisionMode.Default:
        return true;
      case braindanceVisionMode.Audio:
        return scriptInterface.GetQuestsSystem().GetFact(n"braindaneAudioLayerAvailable") > 0;
      case braindanceVisionMode.Thermal:
        return scriptInterface.GetQuestsSystem().GetFact(n"braindaneThermalLayerAvailable") > 0;
      default:
        return false;
    };
  }

  protected final const func GetCurrentBraindanceVisionMode(const scriptInterface: ref<StateGameScriptInterface>) -> braindanceVisionMode {
    let BraindanceBB: ref<IBlackboard> = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().Braindance);
    let mode: Int32 = BraindanceBB.GetInt(GetAllBlackboardDefs().Braindance.activeBraindanceVisionMode);
    return IntEnum(mode);
  }

  protected final const func GetLastBraindanceVisionMode(const scriptInterface: ref<StateGameScriptInterface>) -> braindanceVisionMode {
    let BraindanceBB: ref<IBlackboard> = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().Braindance);
    let mode: Int32 = BraindanceBB.GetInt(GetAllBlackboardDefs().Braindance.lastBraindanceVisionMode);
    return IntEnum(mode);
  }

  protected final const func SetBraindanceVisionMode(const scriptInterface: ref<StateGameScriptInterface>, newMode: braindanceVisionMode) -> Void {
    this.SetBraindaneVisionModeBB(scriptInterface, newMode);
    this.SetBraindanceVisionFact(scriptInterface, newMode);
  }

  protected final const func SendAudioEvents(const scriptInterface: ref<StateGameScriptInterface>, BdStart: Bool) -> Void {
    let AudioSys: ref<AudioSystem> = scriptInterface.GetAudioSystem();
    let eventName: CName = BdStart ? n"g_sc_bd_rewind_forward" : n"g_sc_bd_rewind_forward_end";
    AudioSys.Play(eventName);
    eventName = BdStart ? n"g_sc_bd_rewind_backward" : n"g_sc_bd_rewind_backward_end";
    AudioSys.Play(eventName);
  }

  protected final const func CycleBraindanceVisionMode(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let cycleMode: Int32 = EnumInt(this.GetCurrentBraindanceVisionMode(scriptInterface));
    let i: Int32 = 0;
    while Cast(i) < EnumGetMax(n"braindanceVisionMode") {
      cycleMode -= 1;
      if cycleMode < 0 {
        cycleMode = Cast(EnumGetMax(n"braindanceVisionMode"));
      };
      if this.CanBraindanceEnterLayer(scriptInterface, IntEnum(cycleMode)) {
        this.SetBraindanceVisionMode(scriptInterface, IntEnum(cycleMode));
      } else {
        i += 1;
      };
    };
  }

  protected final const func TogglePausePlayForward(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>) -> Void {
    let playDirection: scnPlayDirection;
    let playSpeed: scnPlaySpeed;
    if Equals(this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlaySpeed(), scnPlaySpeed.Pause) {
      playSpeed = scnPlaySpeed.Normal;
      playDirection = scnPlayDirection.Forward;
      scriptInterface.GetAudioSystem().Play(n"g_sc_bd_rewind_play");
      this.GetSceneSystemInterface(scriptInterface).SetRewindableSectionPlayDirection(playDirection);
      this.GetSceneSystemInterface(scriptInterface).SetRewindableSectionPlaySpeed(playSpeed);
      this.SetPlaybackDirectionInBlackboard(scriptInterface, playDirection);
    } else {
      playSpeed = scnPlaySpeed.Pause;
      scriptInterface.GetAudioSystem().Play(n"g_sc_bd_rewind_pause");
      this.GetSceneSystemInterface(scriptInterface).SetRewindableSectionPlaySpeed(playSpeed);
    };
    this.SetPlaybackSpeedInBlackboard(scriptInterface, playSpeed);
  }

  protected final const func ForceBraindancePause(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>) -> Void {
    if NotEquals(this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlaySpeed(), scnPlaySpeed.Pause) {
      scriptInterface.GetAudioSystem().Play(n"g_sc_bd_rewind_pause_forced");
      this.GetSceneSystemInterface(scriptInterface).SetRewindableSectionPlaySpeed(scnPlaySpeed.Pause);
      this.SetPlaybackSpeedInBlackboard(scriptInterface, scnPlaySpeed.Pause);
    };
  }

  protected final const func CyclePlaySpeed(const scriptInterface: ref<StateGameScriptInterface>, direction: scnPlayDirection) -> Void {
    let multiplier: Int32;
    let newPlaySpeed: scnPlaySpeed;
    let currentPlayDirection: scnPlayDirection = this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlayDirection();
    let currentPlaySpeed: scnPlaySpeed = this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlaySpeed();
    let newPlayDirection: scnPlayDirection = currentPlayDirection;
    if Equals(currentPlaySpeed, scnPlaySpeed.Fast) && Equals(currentPlayDirection, direction) {
      return;
    };
    if Equals(currentPlaySpeed, scnPlaySpeed.Pause) && NotEquals(direction, currentPlayDirection) {
      newPlayDirection = IntEnum((EnumInt(currentPlayDirection) + 1) % 2);
      this.GetSceneSystemInterface(scriptInterface).SetRewindableSectionPlayDirection(newPlayDirection);
      this.SetPlaybackDirectionInBlackboard(scriptInterface, newPlayDirection);
    };
    if Equals(currentPlaySpeed, scnPlaySpeed.Slow) && NotEquals(direction, currentPlayDirection) {
      newPlayDirection = IntEnum((EnumInt(currentPlayDirection) + 1) % 2);
      this.GetSceneSystemInterface(scriptInterface).SetRewindableSectionPlayDirection(newPlayDirection);
      this.SetPlaybackDirectionInBlackboard(scriptInterface, newPlayDirection);
      return;
    };
    multiplier = Equals(direction, newPlayDirection) ? 1 : -1;
    newPlaySpeed = IntEnum(Clamp(EnumInt(currentPlaySpeed) + multiplier, 0, Cast(EnumGetMax(n"scnPlaySpeed"))));
    this.GetSceneSystemInterface(scriptInterface).SetRewindableSectionPlaySpeed(newPlaySpeed);
    this.SetPlaybackSpeedInBlackboard(scriptInterface, newPlaySpeed);
  }

  protected final const func SetPlaySpeedAndDirection(const scriptInterface: ref<StateGameScriptInterface>, direction: scnPlayDirection, speed: scnPlaySpeed) -> Void {
    this.GetSceneSystemInterface(scriptInterface).SetRewindableSectionPlayDirection(direction);
    this.GetSceneSystemInterface(scriptInterface).SetRewindableSectionPlaySpeed(speed);
    this.SetPlaybackDirectionInBlackboard(scriptInterface, direction);
    this.SetPlaybackSpeedInBlackboard(scriptInterface, speed);
  }

  protected final const func GetDistanceFromBraindanceTPPCameraToFPPCamera(const scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let distance: Float = 0.00;
    let player: ref<PlayerPuppet> = scriptInterface.executionOwner as PlayerPuppet;
    if player != null {
      distance = Vector4.Distance(player.GetWorldPosition(), WorldPosition.ToVector4(this.GetSceneSystemInterface(scriptInterface).GetSceneSystemCameraLastCameraPosition()));
    };
    return distance;
  }

  protected final const func CheckTargetThirdPersonPositionCollisions(const scriptInterface: ref<StateGameScriptInterface>, fppPosition: Vector4, fppOrientationEuler: EulerAngles, angle: Float, distance: Float, radius: Float, queryFilter: QueryFilter, out outPosition: Vector4) -> Float {
    let foundCollision: TraceResult;
    let targetOrientationEuler: EulerAngles;
    targetOrientationEuler.Pitch = 0.00;
    targetOrientationEuler.Yaw = fppOrientationEuler.Yaw + angle;
    targetOrientationEuler.Roll = 0.00;
    let targetOrientationQuat: Quaternion = EulerAngles.ToQuat(targetOrientationEuler);
    let targetPosition: Vector4 = fppPosition - Quaternion.GetForward(targetOrientationQuat) * distance;
    let raycastDirection: Vector4 = targetPosition - fppPosition;
    let collisionDistance: Float = distance;
    Vector4.Normalize(raycastDirection);
    outPosition = targetPosition;
    foundCollision = scriptInterface.RayCastWithCollisionFilter(fppPosition, targetPosition, queryFilter);
    if TraceResult.IsValid(foundCollision) {
      collisionDistance = Vector4.Length(fppPosition - Cast(foundCollision.position)) - radius;
      outPosition = Cast(foundCollision.position) - raycastDirection * radius;
    };
    return collisionDistance;
  }

  protected final const func OnBraindancePerspectiveChangedFromFirstPersonToThirdPerson(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let collisionRadius: Float;
    let distanceOffset: Float;
    let foundGround: TraceResult;
    let fppOrientationEuler: EulerAngles;
    let fppOrientationQuat: Quaternion;
    let fppPosition: Vector4;
    let groundRaycastBeginPoint: Vector4;
    let groundRaycastEndPoint: Vector4;
    let heightOffset: Float;
    let player: ref<PlayerPuppet>;
    let queryFilter: QueryFilter;
    let targetDirection: Vector4;
    let targetDist: Float;
    let targetDistBack: Float;
    let targetDistLeft: Float;
    let targetDistRight: Float;
    let targetOrientationEuler: EulerAngles;
    let targetOrientationQuat: Quaternion;
    let targetPosBack: Vector4;
    let targetPosLeft: Vector4;
    let targetPosRight: Vector4;
    let targetPosition: Vector4;
    QueryFilter.AddGroup(queryFilter, n"Static");
    QueryFilter.AddGroup(queryFilter, n"Terrain");
    QueryFilter.AddGroup(queryFilter, n"PlayerBlocker");
    player = scriptInterface.GetPlayerSystem().GetLocalPlayerControlledGameObject() as PlayerPuppet;
    player.GetFPPCameraComponent().ResetPitch();
    fppPosition = WorldPosition.ToVector4(this.GetSceneSystemInterface(scriptInterface).GetSceneSystemCameraLastCameraPosition());
    fppOrientationQuat = this.GetSceneSystemInterface(scriptInterface).GetSceneSystemCameraLastCameraOrientation();
    fppOrientationEuler = Quaternion.ToEulerAngles(fppOrientationQuat);
    heightOffset = this.GetStaticFloatParameterDefault("tppInitialHeightOffset", 1.00);
    distanceOffset = this.GetStaticFloatParameterDefault("tppInitialDistance", 1.00);
    collisionRadius = this.GetStaticFloatParameterDefault("tppCollisionRadius", 0.40);
    targetDistBack = this.CheckTargetThirdPersonPositionCollisions(scriptInterface, fppPosition, fppOrientationEuler, 0.00, distanceOffset, collisionRadius, queryFilter, targetPosBack);
    targetPosition = targetPosBack;
    targetDist = targetDistBack;
    if targetDist < distanceOffset {
      targetDistLeft = this.CheckTargetThirdPersonPositionCollisions(scriptInterface, fppPosition, fppOrientationEuler, -90.00, distanceOffset, collisionRadius, queryFilter, targetPosLeft);
      if targetDistLeft > 0.00 && targetDistLeft > targetDist {
        targetPosition = targetPosLeft;
        targetDist = targetDistLeft;
      };
      targetDistRight = this.CheckTargetThirdPersonPositionCollisions(scriptInterface, fppPosition, fppOrientationEuler, 90.00, distanceOffset, collisionRadius, queryFilter, targetPosRight);
      if targetDistRight > 0.00 && targetDistRight > targetDist {
        targetPosition = targetPosRight;
        targetDist = targetDistRight;
      };
    };
    targetDirection = fppPosition - targetPosition;
    targetDirection.Z = 0.00;
    Vector4.Normalize(targetDirection);
    targetOrientationQuat = Quaternion.BuildFromDirectionVector(targetDirection);
    targetOrientationEuler = Quaternion.ToEulerAngles(targetOrientationQuat);
    groundRaycastBeginPoint = targetPosition;
    groundRaycastBeginPoint.Z += collisionRadius;
    groundRaycastEndPoint = targetPosition;
    groundRaycastEndPoint.Z -= heightOffset + collisionRadius;
    foundGround = scriptInterface.RayCastWithCollisionFilter(groundRaycastBeginPoint, groundRaycastEndPoint, queryFilter);
    if TraceResult.IsValid(foundGround) {
      targetPosition = Cast(foundGround.position);
      targetPosition.Z += collisionRadius;
    } else {
      targetPosition.Z -= heightOffset;
    };
    GameInstance.GetTeleportationFacility(scriptInterface.executionOwner.GetGame()).Teleport(player, targetPosition, targetOrientationEuler);
  }

  protected final const func EnableBraindanceLocomoition(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let swapEvent: ref<PSMAddOnDemandStateMachine> = new PSMAddOnDemandStateMachine();
    let player: ref<PlayerPuppet> = DefaultTransition.GetPlayerPuppet(scriptInterface);
    swapEvent.stateMachineName = n"LocomotionBraindance";
    player.QueueEvent(swapEvent);
  }

  protected final const func ToggleCameraControlEnabled(const scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, out blendTime: Float) -> Void {
    let BraindanceBB: ref<IBlackboard>;
    let distance: Float;
    let message: SimpleScreenMessage;
    let uiBB: ref<IBlackboard>;
    let minBlendTime: Float = 0.50;
    let maxBlendTime: Float = 2.00;
    let distanceToBlendRatio: Float = 15.00;
    let newState: Bool = !this.GetSceneSystemInterface(scriptInterface).GetSceneSystemCameraControlEnabled();
    stateContext.SetPermanentBoolParameter(n"forceVM", !newState, true);
    BraindanceBB = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().Braindance);
    BraindanceBB.SetBool(GetAllBlackboardDefs().Braindance.IsFPP, newState, false);
    uiBB = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Notifications);
    uiBB.SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(message));
    if newState {
      distance = this.GetDistanceFromBraindanceTPPCameraToFPPCamera(scriptInterface);
      blendTime = MinF(minBlendTime + distance / distanceToBlendRatio, maxBlendTime);
      this.RemoveBraindanceRestriction(scriptInterface);
      this.ApplyNoMovementRestriction(scriptInterface);
      this.GetSceneSystemInterface(scriptInterface).SetSceneSystemCameraControlEnabled(newState, blendTime);
      this.SetLastBraindanceVisionMode(scriptInterface, this.GetCurrentBraindanceVisionMode(scriptInterface));
      this.SetBraindanceVisionMode(scriptInterface, braindanceVisionMode.Default);
      stateContext.SetPermanentBoolParameter(n"forceDisableVision", true, true);
      this.SetBraindanceUiGameContext(scriptInterface, UIGameContext.BraindancePlayback);
    } else {
      blendTime = minBlendTime;
      this.EnableBraindanceLocomoition(scriptInterface);
      this.RemoveNoMovementRestriction(scriptInterface);
      this.ApplyBraindanceRestriction(scriptInterface);
      this.OnBraindancePerspectiveChangedFromFirstPersonToThirdPerson(scriptInterface);
      this.GetSceneSystemInterface(scriptInterface).SetSceneSystemCameraControlEnabled(newState, minBlendTime);
      if NotEquals(this.GetLastBraindanceVisionMode(scriptInterface), braindanceVisionMode.Default) {
        this.SetBraindanceVisionMode(scriptInterface, this.GetLastBraindanceVisionMode(scriptInterface));
      };
      this.SetBraindanceUiGameContext(scriptInterface, UIGameContext.BraindanceEditor);
    };
  }

  protected final const func SetCameraControl(const scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, setState: Bool, out blendTime: Float) -> Void {
    let BraindanceBB: ref<IBlackboard>;
    let message: SimpleScreenMessage;
    let uiBB: ref<IBlackboard>;
    let minBlendTime: Float = 0.50;
    let currentState: Bool = this.GetSceneSystemInterface(scriptInterface).GetSceneSystemCameraControlEnabled();
    if Equals(setState, currentState) {
      return;
    };
    stateContext.SetPermanentBoolParameter(n"forceVM", !setState, true);
    BraindanceBB = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().Braindance);
    BraindanceBB.SetBool(GetAllBlackboardDefs().Braindance.IsFPP, setState, false);
    uiBB = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Notifications);
    uiBB.SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(message));
    if setState {
      blendTime = 0.00;
      this.RemoveBraindanceRestriction(scriptInterface);
      this.ApplyNoMovementRestriction(scriptInterface);
      this.GetSceneSystemInterface(scriptInterface).SetSceneSystemCameraControlEnabled(setState, blendTime);
      this.SetLastBraindanceVisionMode(scriptInterface, this.GetCurrentBraindanceVisionMode(scriptInterface));
      this.SetBraindanceVisionMode(scriptInterface, braindanceVisionMode.Default);
      stateContext.SetPermanentBoolParameter(n"forceDisableVision", true, true);
      this.SetBraindanceUiGameContext(scriptInterface, UIGameContext.BraindancePlayback);
    } else {
      blendTime = minBlendTime;
      this.EnableBraindanceLocomoition(scriptInterface);
      this.RemoveNoMovementRestriction(scriptInterface);
      this.ApplyBraindanceRestriction(scriptInterface);
      this.OnBraindancePerspectiveChangedFromFirstPersonToThirdPerson(scriptInterface);
      this.GetSceneSystemInterface(scriptInterface).SetSceneSystemCameraControlEnabled(setState, minBlendTime);
      if NotEquals(this.GetLastBraindanceVisionMode(scriptInterface), braindanceVisionMode.Default) {
        this.SetBraindanceVisionMode(scriptInterface, this.GetLastBraindanceVisionMode(scriptInterface));
      };
      this.SetBraindanceUiGameContext(scriptInterface, UIGameContext.BraindanceEditor);
    };
  }

  protected final const func SetBraindanceState(const scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, newState: Bool, out blendTime: Float) -> Void {
    let BraindanceBB: ref<IBlackboard>;
    let distance: Float;
    let message: SimpleScreenMessage;
    let uiBB: ref<IBlackboard>;
    let minBlendTime: Float = 0.50;
    let maxBlendTime: Float = 2.00;
    let distanceToBlendRatio: Float = 15.00;
    if Equals(!newState, this.GetSceneSystemInterface(scriptInterface).GetSceneSystemCameraControlEnabled()) {
      return;
    };
    stateContext.SetPermanentBoolParameter(n"forceVM", newState, true);
    BraindanceBB = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().Braindance);
    BraindanceBB.SetBool(GetAllBlackboardDefs().Braindance.IsFPP, !newState, false);
    uiBB = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Notifications);
    uiBB.SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(message));
    if !newState {
      distance = this.GetDistanceFromBraindanceTPPCameraToFPPCamera(scriptInterface);
      blendTime = MinF(minBlendTime + distance / distanceToBlendRatio, maxBlendTime);
      this.RemoveBraindanceRestriction(scriptInterface);
      this.ApplyNoMovementRestriction(scriptInterface);
      this.GetSceneSystemInterface(scriptInterface).SetSceneSystemCameraControlEnabled(!newState, blendTime);
      this.SetLastBraindanceVisionMode(scriptInterface, this.GetCurrentBraindanceVisionMode(scriptInterface));
      this.SetBraindanceVisionMode(scriptInterface, braindanceVisionMode.Default);
      stateContext.SetPermanentBoolParameter(n"forceDisableVision", true, true);
      this.SetBraindanceUiGameContext(scriptInterface, UIGameContext.BraindancePlayback);
    } else {
      blendTime = minBlendTime;
      this.EnableBraindanceLocomoition(scriptInterface);
      this.RemoveNoMovementRestriction(scriptInterface);
      this.ApplyBraindanceRestriction(scriptInterface);
      this.OnBraindancePerspectiveChangedFromFirstPersonToThirdPerson(scriptInterface);
      this.GetSceneSystemInterface(scriptInterface).SetSceneSystemCameraControlEnabled(!newState, minBlendTime);
      if NotEquals(this.GetLastBraindanceVisionMode(scriptInterface), braindanceVisionMode.Default) {
        this.SetBraindanceVisionMode(scriptInterface, this.GetLastBraindanceVisionMode(scriptInterface));
      };
      this.SetBraindanceUiGameContext(scriptInterface, UIGameContext.BraindanceEditor);
    };
  }

  protected final const func SetBraindanceUiGameContext(const scriptInterface: ref<StateGameScriptInterface>, uiContext: UIGameContext) -> Void {
    let uiSystem: ref<UISystem> = scriptInterface.GetUISystem();
    switch uiContext {
      case UIGameContext.BraindanceEditor:
        uiSystem.PushGameContext(UIGameContext.BraindanceEditor);
        break;
      case UIGameContext.BraindancePlayback:
        uiSystem.PopGameContext(UIGameContext.BraindanceEditor);
        break;
      default:
    };
  }

  protected final const func RemoveUiGameContext(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let uiSystem: ref<UISystem> = scriptInterface.GetUISystem();
    uiSystem.PopGameContext(UIGameContext.Scanning);
    uiSystem.PopGameContext(UIGameContext.BraindanceEditor);
    uiSystem.PopGameContext(UIGameContext.BraindancePlayback);
  }

  protected final const func GetBraindancePauseInput(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustPressed(n"Pause");
  }

  protected final const func GetPlayForwardInput(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustPressed(n"PlayForward");
  }

  protected final const func CheckPlayForwardInput(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.GetActionValue(n"PlayForward") > 0.00;
  }

  protected final const func GetPlayBackwardInput(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustPressed(n"PlayBackward");
  }

  protected final const func CheckPlayBackwardInput(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.GetActionValue(n"PlayBackward") > 0.00;
  }

  protected final const func GetRestartInput(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustHeld(n"Restart");
  }

  protected final const func GetSwitchLayerInput(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustPressed(n"SwitchLayer");
  }

  protected final const func GetBdCameraToggleInput(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustPressed(n"BdCameraToggle");
  }

  protected final const func IsPerspectiveTransitionOn(const BlockPerspectiveSwitchTimer: Float) -> Bool {
    return BlockPerspectiveSwitchTimer > 0.00;
  }

  protected final const func UpdatePerspectiveTransitionTimer(out BlockPerspectiveSwitchTimer: Float, timeDelta: Float) -> Void {
    if BlockPerspectiveSwitchTimer > 0.00 {
      BlockPerspectiveSwitchTimer -= timeDelta;
    };
  }

  protected final const func PrintDebugInfo(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    Log("Direction: " + ToString(this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlayDirection()));
    Log("------------------------------------------------------------------------------");
    Log("Speed: " + ToString(this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlaySpeed()));
    Log("------------------------------------------------------------------------------");
    Log("Vision: " + ToString(this.GetCurrentBraindanceVisionMode(scriptInterface)));
    Log("------------------------------------------------------------------------------");
  }

  protected final const func GetBraindanceInputMask(const scriptInterface: ref<StateGameScriptInterface>) -> SBraindanceInputMask {
    return this.GetBraindanceSystem(scriptInterface).GetInputMask();
  }

  protected final const func SendAudioEventForBraindance(enable: Bool, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let audioEvent: ref<AudioEvent> = new AudioEvent();
    audioEvent.eventName = enable ? n"enableFootsteps" : n"disableFootsteps";
    scriptInterface.executionOwner.QueueEvent(audioEvent);
  }

  protected final const func IsProgressAtBeggining(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionProgress() == 0.00;
  }

  protected final const func IsProgressAtEnd(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionProgress() == 1.00;
  }

  protected final const func GetChangeBraindanceStateRequest(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetBraindanceSystem(scriptInterface).GetRequstCameraToggle();
  }

  protected final const func GetPauseBraindanceRequest(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetBraindanceSystem(scriptInterface).GetPauseBraindanceRequest();
  }

  protected final const func GetRequestedEditorState(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetBraindanceSystem(scriptInterface).GetRequestEditorState();
  }

  protected final const func SendClearBraindanceStateRequest(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let request: ref<ClearBraindanceStateRequest> = new ClearBraindanceStateRequest();
    this.GetBraindanceSystem(scriptInterface).QueueRequest(request);
  }

  protected final const func SendClearBraindancePauseRequest(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let request: ref<ClearBraindancePauseRequest> = new ClearBraindancePauseRequest();
    this.GetBraindanceSystem(scriptInterface).QueueRequest(request);
  }

  protected final const func IsResetting(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetSceneSystemInterface(scriptInterface).IsRewindableSectionResetting();
  }

  protected final const func IsInEditorMode(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.GetSceneSystemInterface(scriptInterface).GetSceneSystemCameraControlEnabled();
  }

  protected final const func StartGlitchFx(const scriptInterface: ref<StateGameScriptInterface>, opt fxState: Bool) -> Void {
    let effectName: CName;
    if fxState {
      return;
    };
    effectName = !this.IsInEditorMode(scriptInterface) ? n"transition_glitch_loop_braindance" : n"transition_glitch_loop";
    GameObjectEffectHelper.StopEffectEvent(scriptInterface.executionOwner, effectName);
    effectName = this.IsInEditorMode(scriptInterface) ? n"transition_glitch_loop_braindance" : n"transition_glitch_loop";
    GameObjectEffectHelper.StartEffectEvent(scriptInterface.executionOwner, effectName);
  }

  protected final const func StopGlitchFx(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let effectName: CName = this.IsInEditorMode(scriptInterface) ? n"transition_glitch_loop_braindance" : n"transition_glitch_loop";
    GameObjectEffectHelper.StopEffectEvent(scriptInterface.executionOwner, effectName);
  }

  protected final const func SetEndRecordingNotificationState(newState: Bool, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let simpleScreenMessage: SimpleScreenMessage;
    simpleScreenMessage.isShown = newState;
    simpleScreenMessage.duration = 0.00;
    simpleScreenMessage.message = "LocKey#52608";
    simpleScreenMessage.isInstant = true;
    scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(simpleScreenMessage), true);
  }

  protected final const func ApplyBraindanceRestriction(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.Braindance");
  }

  protected final const func RemoveBraindanceRestriction(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.Braindance");
  }

  protected final const func ApplyNoMovementRestriction(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.NoMovement");
  }

  protected final const func RemoveNoMovementRestriction(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.NoMovement");
  }

  protected final const func ApplyNoHubRestrictionOnLocalPlayer(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    StatusEffectHelper.ApplyStatusEffect(scriptInterface.GetPlayerSystem().GetLocalPlayerMainGameObject(), t"GameplayRestriction.BlockAllHubMenu");
  }

  protected final const func RemoveNoHubRestrictionFromLocalPlayer(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.GetPlayerSystem().GetLocalPlayerMainGameObject(), t"GameplayRestriction.BlockAllHubMenu");
  }
}

public class ControlsInactiveDecisions extends BraindanceControlsTransition {

  protected final const func ToControlsActive(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetSceneSystemInterface(scriptInterface).IsRewindableSectionActive();
  }
}

public class ControlsInactiveEvents extends BraindanceControlsTransition {

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let SectionTime: Float;
    let BraindanceBB: ref<IBlackboard> = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().Braindance);
    BraindanceBB.SetBool(GetAllBlackboardDefs().Braindance.IsActive, true, false);
    BraindanceBB.SetBool(GetAllBlackboardDefs().Braindance.EnableExit, false, true);
    stateContext.SetPermanentBoolParameter(n"lockVM", true, true);
    SectionTime = this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionDurationInSec();
    BraindanceBB.SetFloat(GetAllBlackboardDefs().Braindance.SectionTime, SectionTime, false);
    this.SendAudioEventForBraindance(false, scriptInterface);
    this.SetLastBraindanceVisionMode(scriptInterface, braindanceVisionMode.Default);
    this.SetBraindanceVisionMode(scriptInterface, braindanceVisionMode.Default);
    this.SetPlaybackSpeedInBlackboard(scriptInterface, scnPlaySpeed.Normal);
    this.SetPlaybackDirectionInBlackboard(scriptInterface, scnPlayDirection.Forward);
    this.ApplyNoMovementRestriction(scriptInterface);
    this.ApplyNoHubRestrictionOnLocalPlayer(scriptInterface);
    this.SendAudioEvents(scriptInterface, true);
  }

  protected final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.RemovePermanentBoolParameter(n"lockVM");
  }

  protected final func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let message: SimpleScreenMessage;
    let uiBB: ref<IBlackboard>;
    let BraindanceBB: ref<IBlackboard> = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().Braindance);
    BraindanceBB.SetBool(GetAllBlackboardDefs().Braindance.IsActive, false, true);
    uiBB = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Notifications);
    uiBB.SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(message));
    this.GetSceneSystemInterface(scriptInterface).SetSceneSystemCameraControlEnabled(true);
    stateContext.RemovePermanentBoolParameter(n"lockVM");
    stateContext.RemovePermanentBoolParameter(n"forceVM");
    stateContext.SetPermanentBoolParameter(n"forceDisableVision", true, true);
    this.SendAudioEventForBraindance(true, scriptInterface);
    this.RemoveBraindanceRestriction(scriptInterface);
    this.RemoveNoMovementRestriction(scriptInterface);
    this.RemoveNoHubRestrictionFromLocalPlayer(scriptInterface);
    this.RemoveUiGameContext(scriptInterface);
  }
}

public class ControlsActiveDecisions extends BraindanceControlsTransition {

  protected final const func ToControlsInactive(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.GetSceneSystemInterface(scriptInterface).IsRewindableSectionActive();
  }
}

public class ControlsActiveEvents extends BraindanceControlsTransition {

  public let BraindanceBB: wref<IBlackboard>;

  public let BlockPerspectiveSwitchTimer: Float;

  public let fxActive: Bool;

  public let rewindFxActive: Bool;

  public let holdDuration: Float;

  public let cachedState: scnPlaySpeed;

  public let cacheSet: Bool;

  public let forwardInput: Bool;

  public let backwardInput: Bool;

  public let forwardInputLocked: Bool;

  public let backwardInputLocked: Bool;

  public let activeDirection: scnPlayDirection;

  public let rewindRunning: Bool;

  public let contextsSetup: Bool;

  public let pauseLock: Bool;

  public let endRecordingMessageSet: Bool;

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let currentState: Bool = this.GetSceneSystemInterface(scriptInterface).GetSceneSystemCameraControlEnabled();
    this.BraindanceBB = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().Braindance);
    this.BraindanceBB.SetBool(GetAllBlackboardDefs().Braindance.IsFPP, currentState, true);
    this.SetPlaybackSpeedInBlackboard(scriptInterface, this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlaySpeed());
    this.SetPlaybackDirectionInBlackboard(scriptInterface, this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlayDirection());
    this.ApplyNoMovementRestriction(scriptInterface);
    this.SendAudioEvents(scriptInterface, true);
    this.fxActive = false;
    this.rewindFxActive = false;
    this.BlockPerspectiveSwitchTimer = -1.00;
    this.holdDuration = 0.00;
    this.forwardInput = false;
    this.backwardInput = false;
    this.contextsSetup = false;
    this.pauseLock = false;
    this.endRecordingMessageSet = false;
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let inputMask: SBraindanceInputMask = this.GetBraindanceInputMask(scriptInterface);
    if !this.contextsSetup {
      scriptInterface.GetUISystem().PushGameContext(UIGameContext.BraindancePlayback);
      this.contextsSetup = true;
    };
    if !IsDefined(this.BraindanceBB) {
      this.BraindanceBB = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().Braindance);
    };
    this.UpdatePerspectiveTransitionTimer(this.BlockPerspectiveSwitchTimer, timeDelta);
    if this.IsResetting(scriptInterface) {
      return;
    };
    this.forwardInput = this.CheckPlayForwardInput(scriptInterface);
    this.backwardInput = this.CheckPlayBackwardInput(scriptInterface);
    if this.forwardInput || this.backwardInput {
      if !this.cacheSet {
        this.cachedState = Equals(this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlaySpeed(), scnPlaySpeed.Pause) ? scnPlaySpeed.Pause : scnPlaySpeed.Normal;
        this.cacheSet = true;
      };
      if Equals(this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlayDirection(), scnPlayDirection.Forward) && !this.forwardInput {
        this.backwardInputLocked = false;
      };
      if Equals(this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlayDirection(), scnPlayDirection.Backward) && !this.backwardInput {
        this.forwardInputLocked = false;
      };
      if this.forwardInput && inputMask.playForwardAction && !this.forwardInputLocked {
        this.forwardInputLocked = true;
        this.activeDirection = scnPlayDirection.Forward;
        this.holdDuration = 0.00;
        scriptInterface.GetAudioSystem().Play(n"g_sc_bd_rewind_resume");
      };
      if this.backwardInput && inputMask.playBackwardAction && !this.backwardInputLocked {
        this.backwardInputLocked = true;
        this.activeDirection = scnPlayDirection.Backward;
        this.holdDuration = 0.00;
        scriptInterface.GetAudioSystem().Play(n"g_sc_bd_rewind_resume");
      };
      if Equals(this.activeDirection, scnPlayDirection.Forward) && inputMask.playForwardAction && this.forwardInput && !this.IsProgressAtEnd(scriptInterface) && !this.pauseLock {
        this.holdDuration += timeDelta;
        if Equals(this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlaySpeed(), scnPlaySpeed.Pause) {
          this.SetPlaySpeedAndDirection(scriptInterface, scnPlayDirection.Forward, scnPlaySpeed.Normal);
          this.holdDuration = 0.00;
        } else {
          if Equals(this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlaySpeed(), scnPlaySpeed.Normal) && Equals(this.cachedState, scnPlaySpeed.Normal) {
            this.SetPlaySpeedAndDirection(scriptInterface, scnPlayDirection.Forward, scnPlaySpeed.Fast);
            this.holdDuration = 0.00;
          } else {
            if Equals(this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlaySpeed(), scnPlaySpeed.Normal) && this.holdDuration > 2.00 {
              this.SetPlaySpeedAndDirection(scriptInterface, scnPlayDirection.Forward, scnPlaySpeed.Fast);
              this.holdDuration = 0.00;
            } else {
              if Equals(this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlaySpeed(), scnPlaySpeed.Fast) && this.holdDuration > 2.00 {
                this.SetPlaySpeedAndDirection(scriptInterface, scnPlayDirection.Forward, scnPlaySpeed.VeryFast);
                this.holdDuration = 0.00;
              } else {
                if Equals(this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlayDirection(), scnPlayDirection.Backward) {
                  this.SetPlaySpeedAndDirection(scriptInterface, scnPlayDirection.Forward, scnPlaySpeed.Normal);
                  this.holdDuration = 0.00;
                  this.StopGlitchFx(scriptInterface);
                  this.rewindFxActive = false;
                };
              };
            };
          };
        };
      } else {
        if Equals(this.activeDirection, scnPlayDirection.Backward) && inputMask.playBackwardAction && this.backwardInput && !this.IsProgressAtBeggining(scriptInterface) && !this.pauseLock {
          this.holdDuration += timeDelta;
          if Equals(this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlaySpeed(), scnPlaySpeed.Pause) {
            this.SetPlaySpeedAndDirection(scriptInterface, scnPlayDirection.Backward, scnPlaySpeed.Normal);
            this.holdDuration = 0.00;
          } else {
            if Equals(this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlaySpeed(), scnPlaySpeed.Normal) && this.holdDuration < 2.00 {
              this.SetPlaySpeedAndDirection(scriptInterface, scnPlayDirection.Backward, scnPlaySpeed.Normal);
            } else {
              if Equals(this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlaySpeed(), scnPlaySpeed.Normal) && this.holdDuration > 2.00 {
                this.SetPlaySpeedAndDirection(scriptInterface, scnPlayDirection.Backward, scnPlaySpeed.Fast);
                this.holdDuration = 0.00;
              } else {
                if Equals(this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlaySpeed(), scnPlaySpeed.Fast) && this.holdDuration > 2.00 {
                  this.SetPlaySpeedAndDirection(scriptInterface, scnPlayDirection.Backward, scnPlaySpeed.VeryFast);
                  this.holdDuration = 0.00;
                } else {
                  if Equals(this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlayDirection(), scnPlayDirection.Forward) {
                    this.SetPlaySpeedAndDirection(scriptInterface, scnPlayDirection.Forward, scnPlaySpeed.Normal);
                    this.holdDuration = 0.00;
                  };
                };
              };
            };
          };
        };
      };
      this.forwardInputLocked = this.forwardInput;
      this.backwardInputLocked = this.backwardInput;
      this.ProcessGlitchFX(scriptInterface);
    } else {
      if this.cacheSet {
        if inputMask.playForwardAction || inputMask.playBackwardAction {
          this.SetPlaySpeedAndDirection(scriptInterface, scnPlayDirection.Forward, this.cachedState);
        };
        this.holdDuration = 0.00;
        this.cacheSet = false;
        this.forwardInputLocked = false;
        this.backwardInputLocked = false;
        if this.rewindFxActive {
          this.StopGlitchFx(scriptInterface);
          this.rewindFxActive = false;
        };
      };
    };
    if this.GetBraindancePauseInput(scriptInterface) && inputMask.pauseAction {
      this.TogglePausePlayForward(scriptInterface, stateContext);
      this.pauseLock = Equals(this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlaySpeed(), scnPlaySpeed.Pause);
      if this.rewindFxActive {
        this.StopGlitchFx(scriptInterface);
        this.rewindFxActive = false;
      };
    };
    if this.pauseLock {
      this.pauseLock = Equals(this.activeDirection, scnPlayDirection.Forward) ? this.forwardInput : this.backwardInput;
    };
    if this.GetSwitchLayerInput(scriptInterface) && !this.GetSceneSystemInterface(scriptInterface).GetSceneSystemCameraControlEnabled() && inputMask.switchLayerAction {
      this.CycleBraindanceVisionMode(scriptInterface);
    };
    if this.GetChangeBraindanceStateRequest(scriptInterface) && !this.IsPerspectiveTransitionOn(this.BlockPerspectiveSwitchTimer) {
      this.SetBraindanceState(scriptInterface, stateContext, this.GetRequestedEditorState(scriptInterface), this.BlockPerspectiveSwitchTimer);
      this.SendClearBraindanceStateRequest(scriptInterface);
    };
    if this.GetPauseBraindanceRequest(scriptInterface) {
      this.ForceBraindancePause(scriptInterface, stateContext);
      this.cachedState = scnPlaySpeed.Pause;
      this.SendClearBraindancePauseRequest(scriptInterface);
      this.StopGlitchFx(scriptInterface);
      this.rewindFxActive = false;
      this.forwardInputLocked = false;
      this.backwardInputLocked = false;
    };
    if this.GetBdCameraToggleInput(scriptInterface) && !this.IsPerspectiveTransitionOn(this.BlockPerspectiveSwitchTimer) && inputMask.cameraToggleAction {
      this.ToggleCameraControlEnabled(scriptInterface, stateContext, this.BlockPerspectiveSwitchTimer);
      this.StopGlitchFx(scriptInterface);
      this.rewindFxActive = false;
    };
    if this.GetRestartInput(scriptInterface) && inputMask.restartAction {
      scriptInterface.GetAudioSystem().Play(n"g_sc_bd_rewind_restart");
      this.GetSceneSystemInterface(scriptInterface).ResetRewindableSection(100.00, scnPlayDirection.Forward, scnPlaySpeed.Normal);
      this.StartGlitchFx(scriptInterface);
      this.fxActive = true;
      GameInstance.GetTelemetrySystem(scriptInterface.executionOwner.GetGame()).LogBraindanceReset();
    };
    if this.fxActive && !this.IsResetting(scriptInterface) {
      this.StopGlitchFx(scriptInterface);
      this.fxActive = false;
    };
    if this.IsProgressAtBeggining(scriptInterface) || this.IsProgressAtEnd(scriptInterface) {
      this.StopGlitchFx(scriptInterface);
      this.rewindFxActive = false;
    };
    if !this.endRecordingMessageSet && this.IsProgressAtEnd(scriptInterface) {
      this.SetEndRecordingNotificationState(true, scriptInterface);
      this.endRecordingMessageSet = true;
    } else {
      if this.endRecordingMessageSet && !this.IsProgressAtEnd(scriptInterface) {
        this.SetEndRecordingNotificationState(false, scriptInterface);
        this.endRecordingMessageSet = false;
      };
    };
    this.BraindanceBB.SetFloat(GetAllBlackboardDefs().Braindance.Progress, this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionProgress(), true);
  }

  protected final func ProcessGlitchFX(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let speed: scnPlaySpeed = this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlaySpeed();
    let direction: scnPlayDirection = this.GetSceneSystemInterface(scriptInterface).GetRewindableSectionPlayDirection();
    if this.rewindFxActive || Equals(speed, scnPlaySpeed.Pause) {
      return;
    };
    if Equals(direction, scnPlayDirection.Backward) || Equals(direction, scnPlayDirection.Forward) && NotEquals(speed, scnPlaySpeed.Normal) {
      this.StartGlitchFx(scriptInterface, this.rewindFxActive);
      this.rewindFxActive = true;
    };
  }

  protected final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.RemovePermanentBoolParameter(n"lockVM");
    stateContext.RemovePermanentBoolParameter(n"forceVM");
    this.StopGlitchFx(scriptInterface);
    this.SendAudioEvents(scriptInterface, false);
  }

  protected final func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if !IsDefined(this.BraindanceBB) {
      this.BraindanceBB = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().Braindance);
    };
    this.BraindanceBB.SetBool(GetAllBlackboardDefs().Braindance.IsActive, false, true);
    this.GetSceneSystemInterface(scriptInterface).SetSceneSystemCameraControlEnabled(true);
    stateContext.RemovePermanentBoolParameter(n"lockVM");
    stateContext.RemovePermanentBoolParameter(n"forceVM");
    stateContext.SetPermanentBoolParameter(n"forceDisableVision", true, true);
    this.SendAudioEventForBraindance(true, scriptInterface);
    this.StopGlitchFx(scriptInterface);
    this.RemoveBraindanceRestriction(scriptInterface);
    this.RemoveNoMovementRestriction(scriptInterface);
    this.RemoveNoHubRestrictionFromLocalPlayer(scriptInterface);
    this.RemoveUiGameContext(scriptInterface);
    this.SendAudioEvents(scriptInterface, false);
  }
}
