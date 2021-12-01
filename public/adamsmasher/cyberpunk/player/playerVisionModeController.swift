
public class PlayerVisionModeController extends IScriptable {

  private let m_gameplayActiveFlagsRefreshPolicy: PlayerVisionModeControllerRefreshPolicy;

  private let m_blackboardIds: PlayerVisionModeControllerBBIds;

  private let m_blackboardValuesIds: PlayerVisionModeControllerBBValuesIds;

  private let m_blackboardListenersFunctions: PlayerVisionModeControllerBlackboardListenersFunctions;

  private let m_blackboardListeners: PlayerVisionModeControllerBBListeners;

  private let m_gameplayActiveFlags: PlayerVisionModeControllerActiveFlags;

  private let m_inputActionsNames: PlayerVisionModeControllerInputActionsNames;

  private let m_inputListeners: PlayerVisionModeControllerInputListeners;

  private let m_inputActiveFlags: PlayerVisionModeControllerInputActiveFlags;

  private let m_otherVars: PlayerVisionModeControllerOtherVars;

  private let m_owner: wref<GameObject>;

  public final func OnEnablePhotoMode(enable: Bool) -> Void {
    this.m_gameplayActiveFlags.m_isPhotoMode = !enable;
  }

  public final func RegisterOwner(owner: ref<GameObject>) -> Void {
    if this.m_owner != null {
      LogError("PlayerVisionModeController.RegisterOwner is stomping on a previously registered owner.");
      this.UnregisterBlackboardListeners();
    };
    this.m_owner = owner;
    if owner != null {
      this.InitInputActionsNames();
      this.RegisterInputListeners();
      this.InitPlayerVisionModeControllerRefreshPolicy();
      this.InitBlackboardIds();
      this.InitBlackboardValuesIds();
      this.InitBlackboardFunctions();
      this.RegisterBlackboardListeners();
    };
  }

  public final func UnregisterOwner() -> Void {
    if this.m_owner == null {
      LogError("PlayerVisionModeController.UnregisterOwner has nothing to unregister.");
    } else {
      this.UnregisterInputListeners();
      this.UnregisterBlackboardListeners();
    };
    this.m_owner = null;
  }

  public final func OnInvalidateActiveState(evt: ref<PlayerVisionModeControllerInvalidateEvent>) -> Void {
    this.m_otherVars.m_active = evt.m_active;
    if evt.m_active {
      this.ActivateVisionMode();
    } else {
      this.DeactivateVisionMode();
    };
    this.ProcessFlagsRefreshPolicy();
  }

  private final func InitInputActionsNames() -> Void {
    this.m_inputActionsNames.m_buttonHold = n"VisionHold";
    this.m_inputActionsNames.m_buttonToggle = n"VisionToggle";
  }

  private final func RegisterInputListeners() -> Void {
    this.m_owner.RegisterInputListener(this, n"VisionHold");
    this.m_owner.RegisterInputListener(this, n"VisionToggle");
  }

  private final func InitPlayerVisionModeControllerRefreshPolicy() -> Void {
    this.m_gameplayActiveFlagsRefreshPolicy.m_kerenzikov = PlayerVisionModeControllerRefreshPolicyEnum.Persistent;
    this.m_gameplayActiveFlagsRefreshPolicy.m_restrictedScene = PlayerVisionModeControllerRefreshPolicyEnum.Persistent;
    this.m_gameplayActiveFlagsRefreshPolicy.m_dead = PlayerVisionModeControllerRefreshPolicyEnum.Persistent;
    this.m_gameplayActiveFlagsRefreshPolicy.m_takedown = PlayerVisionModeControllerRefreshPolicyEnum.Persistent;
    this.m_gameplayActiveFlagsRefreshPolicy.m_deviceTakeover = PlayerVisionModeControllerRefreshPolicyEnum.Eventful;
    this.m_gameplayActiveFlagsRefreshPolicy.m_braindanceFPP = PlayerVisionModeControllerRefreshPolicyEnum.Persistent;
    this.m_gameplayActiveFlagsRefreshPolicy.m_braindanceActive = PlayerVisionModeControllerRefreshPolicyEnum.Persistent;
    this.m_gameplayActiveFlagsRefreshPolicy.m_veryHardLanding = PlayerVisionModeControllerRefreshPolicyEnum.Persistent;
    this.m_gameplayActiveFlagsRefreshPolicy.m_noScanningRestriction = PlayerVisionModeControllerRefreshPolicyEnum.Persistent;
  }

  private final func InitBlackboardIds() -> Void {
    this.m_blackboardIds.m_kerenzikov = GetAllBlackboardDefs().PlayerStateMachine;
    this.m_blackboardIds.m_restrictedScene = GetAllBlackboardDefs().PlayerStateMachine;
    this.m_blackboardIds.m_dead = GetAllBlackboardDefs().PlayerStateMachine;
    this.m_blackboardIds.m_takedown = GetAllBlackboardDefs().PlayerStateMachine;
    this.m_blackboardIds.m_deviceTakeover = GetAllBlackboardDefs().DeviceTakeControl;
    this.m_blackboardIds.m_braindanceFPP = GetAllBlackboardDefs().Braindance;
    this.m_blackboardIds.m_braindanceActive = GetAllBlackboardDefs().Braindance;
    this.m_blackboardIds.m_veryHardLanding = GetAllBlackboardDefs().PlayerStateMachine;
  }

  private final func InitBlackboardValuesIds() -> Void {
    this.m_blackboardValuesIds.m_kerenzikov = GetAllBlackboardDefs().PlayerStateMachine.Locomotion;
    this.m_blackboardValuesIds.m_restrictedScene = GetAllBlackboardDefs().PlayerStateMachine.HighLevel;
    this.m_blackboardValuesIds.m_dead = GetAllBlackboardDefs().PlayerStateMachine.Vitals;
    this.m_blackboardValuesIds.m_takedown = GetAllBlackboardDefs().PlayerStateMachine.Takedown;
    this.m_blackboardValuesIds.m_deviceTakeover = GetAllBlackboardDefs().DeviceTakeControl.ActiveDevice;
    this.m_blackboardValuesIds.m_braindanceFPP = GetAllBlackboardDefs().Braindance.IsFPP;
    this.m_blackboardValuesIds.m_braindanceActive = GetAllBlackboardDefs().Braindance.IsActive;
    this.m_blackboardValuesIds.m_veryHardLanding = GetAllBlackboardDefs().PlayerStateMachine.Landing;
  }

  private final func InitBlackboardFunctions() -> Void {
    this.m_blackboardListenersFunctions.m_kerenzikov = n"OnKerenzikovChanged";
    this.m_blackboardListenersFunctions.m_restrictedScene = n"OnRestrictedSceneChanged";
    this.m_blackboardListenersFunctions.m_dead = n"OnDeadChanged";
    this.m_blackboardListenersFunctions.m_takedown = n"OnTakedownChanged";
    this.m_blackboardListenersFunctions.m_deviceTakeover = n"OnDeviceTakeoverChanged";
    this.m_blackboardListenersFunctions.m_braindanceFPP = n"OnBraindanceFPPChanged";
    this.m_blackboardListenersFunctions.m_braindanceActive = n"OnBraindanceActiveChanged";
    this.m_blackboardListenersFunctions.m_veryHardLanding = n"OnVeryHardLandingChanged";
  }

  private final func RegisterBlackboardListeners() -> Void {
    let blackboardSystem: ref<BlackboardSystem>;
    if this.m_owner != null {
      blackboardSystem = GameInstance.GetBlackboardSystem(this.m_owner.GetGame());
    };
    if blackboardSystem != null {
      this.m_blackboardListeners.m_kerenzikov = blackboardSystem.GetLocalInstanced(this.m_owner.GetEntityID(), this.m_blackboardIds.m_kerenzikov).RegisterListenerInt(this.m_blackboardValuesIds.m_kerenzikov, this, this.m_blackboardListenersFunctions.m_kerenzikov);
      this.m_blackboardListeners.m_restrictedScene = blackboardSystem.GetLocalInstanced(this.m_owner.GetEntityID(), this.m_blackboardIds.m_restrictedScene).RegisterListenerInt(this.m_blackboardValuesIds.m_restrictedScene, this, this.m_blackboardListenersFunctions.m_restrictedScene);
      this.m_blackboardListeners.m_dead = blackboardSystem.GetLocalInstanced(this.m_owner.GetEntityID(), this.m_blackboardIds.m_dead).RegisterListenerInt(this.m_blackboardValuesIds.m_dead, this, this.m_blackboardListenersFunctions.m_dead);
      this.m_blackboardListeners.m_takedown = blackboardSystem.GetLocalInstanced(this.m_owner.GetEntityID(), this.m_blackboardIds.m_takedown).RegisterListenerInt(this.m_blackboardValuesIds.m_takedown, this, this.m_blackboardListenersFunctions.m_takedown);
      this.m_blackboardListeners.m_deviceTakeover = blackboardSystem.Get(this.m_blackboardIds.m_deviceTakeover).RegisterListenerEntityID(this.m_blackboardValuesIds.m_deviceTakeover, this, this.m_blackboardListenersFunctions.m_deviceTakeover);
      this.m_blackboardListeners.m_braindanceFPP = blackboardSystem.Get(this.m_blackboardIds.m_braindanceFPP).RegisterListenerBool(this.m_blackboardValuesIds.m_braindanceFPP, this, this.m_blackboardListenersFunctions.m_braindanceFPP);
      this.m_blackboardListeners.m_braindanceActive = blackboardSystem.Get(this.m_blackboardIds.m_braindanceActive).RegisterListenerBool(this.m_blackboardValuesIds.m_braindanceActive, this, this.m_blackboardListenersFunctions.m_braindanceActive);
      this.m_blackboardListeners.m_veryHardLanding = blackboardSystem.GetLocalInstanced(this.m_owner.GetEntityID(), this.m_blackboardIds.m_veryHardLanding).RegisterListenerInt(this.m_blackboardValuesIds.m_veryHardLanding, this, this.m_blackboardListenersFunctions.m_veryHardLanding);
    } else {
      LogError("PlayerVisionModeController.RegisterBlackboardListeners cannot register blackboard listeners.");
    };
  }

  private final func UnregisterInputListeners() -> Void {
    this.m_owner.UnregisterInputListener(this);
  }

  private final func UnregisterBlackboardListeners() -> Void {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.m_owner.GetGame());
    blackboardSystem.Get(this.m_blackboardIds.m_kerenzikov).UnregisterListenerInt(this.m_blackboardValuesIds.m_kerenzikov, this.m_blackboardListeners.m_kerenzikov);
    blackboardSystem.Get(this.m_blackboardIds.m_restrictedScene).UnregisterListenerInt(this.m_blackboardValuesIds.m_restrictedScene, this.m_blackboardListeners.m_restrictedScene);
    blackboardSystem.Get(this.m_blackboardIds.m_dead).UnregisterListenerInt(this.m_blackboardValuesIds.m_dead, this.m_blackboardListeners.m_dead);
    blackboardSystem.Get(this.m_blackboardIds.m_takedown).UnregisterListenerInt(this.m_blackboardValuesIds.m_takedown, this.m_blackboardListeners.m_takedown);
    blackboardSystem.Get(this.m_blackboardIds.m_deviceTakeover).UnregisterListenerEntityID(this.m_blackboardValuesIds.m_deviceTakeover, this.m_blackboardListeners.m_deviceTakeover);
    blackboardSystem.Get(this.m_blackboardIds.m_braindanceFPP).UnregisterListenerBool(this.m_blackboardValuesIds.m_braindanceFPP, this.m_blackboardListeners.m_braindanceFPP);
    blackboardSystem.Get(this.m_blackboardIds.m_braindanceActive).UnregisterListenerBool(this.m_blackboardValuesIds.m_braindanceActive, this.m_blackboardListeners.m_braindanceActive);
    blackboardSystem.Get(this.m_blackboardIds.m_veryHardLanding).UnregisterListenerInt(this.m_blackboardValuesIds.m_veryHardLanding, this.m_blackboardListeners.m_veryHardLanding);
  }

  private final func VerifyActivation() -> Void {
    let active: Bool;
    let inputActive: Bool = this.m_inputActiveFlags.m_buttonHold || this.m_inputActiveFlags.m_buttonToggle;
    let forced: Bool = this.m_gameplayActiveFlags.m_braindanceActive && !this.m_gameplayActiveFlags.m_braindanceFPP;
    this.m_gameplayActiveFlags.m_hasNotCybereye = !RPGManager.HasStatFlag(this.m_owner, gamedataStatType.HasCybereye);
    this.m_gameplayActiveFlags.m_isPhotoMode = GameInstance.GetPhotoModeSystem(this.m_owner.GetGame()).IsPhotoModeActive();
    if !forced && (!inputActive || this.m_gameplayActiveFlags.m_kerenzikov || this.m_gameplayActiveFlags.m_restrictedScene || this.m_gameplayActiveFlags.m_dead || this.m_gameplayActiveFlags.m_takedown || this.m_gameplayActiveFlags.m_deviceTakeover || this.m_gameplayActiveFlags.m_braindanceActive || this.m_gameplayActiveFlags.m_veryHardLanding || this.m_gameplayActiveFlags.m_noScanningRestriction || this.m_gameplayActiveFlags.m_hasNotCybereye || this.m_gameplayActiveFlags.m_isPhotoMode) {
      active = false;
    } else {
      active = true;
    };
    this.InvalidateActivationState(active);
  }

  private final func ActivateVisionMode() -> Void {
    GameInstance.GetVisionModeSystem(this.m_owner.GetGame()).GetScanningController().EnterMode(this.m_owner, gameScanningMode.Heavy);
    if !this.m_owner.GetHudManager().IsQuickHackPanelOpened() {
      GameInstance.GetTargetingSystem(this.m_owner.GetGame()).LookAt(this.m_owner, this.GetVisionAimSnapParams());
    };
    this.SendPSMBoolParameter(n"InterruptSprint", true, gamestateMachineParameterAspect.Temporary);
    this.SendPSMBoolParameter(n"SprintToggled", false, gamestateMachineParameterAspect.Conditional);
    this.ApplyFocusModeLocomotionRestriction();
    GameInstance.GetVisionModeSystem(this.m_owner.GetGame()).EnterMode(this.m_owner, gameVisionModeType.Focus);
    this.SetBlackboardIntVariable(GetAllBlackboardDefs().PlayerStateMachine, GetAllBlackboardDefs().PlayerStateMachine.Vision, EnumInt(gamePSMVision.Focus));
    this.SetFocusModeAnimFeature(true);
    this.SetupLockToggleInput();
    this.SetupLockHoldInput();
    GameInstance.GetAudioSystem(this.m_owner.GetGame()).NotifyGameTone(n"Scanning");
    this.m_otherVars.m_enabledByToggle = this.m_inputActiveFlags.m_buttonToggle;
  }

  private final func DeactivateVisionMode() -> Void {
    GameInstance.GetVisionModeSystem(this.m_owner.GetGame()).EnterMode(this.m_owner, gameVisionModeType.Default);
    GameInstance.GetVisionModeSystem(this.m_owner.GetGame()).GetScanningController().EnterMode(this.m_owner, gameScanningMode.Inactive);
    this.SetBlackboardIntVariable(GetAllBlackboardDefs().PlayerStateMachine, GetAllBlackboardDefs().PlayerStateMachine.Vision, EnumInt(gamePSMVision.Default));
    this.SendPSMBoolParameter(n"VisionToggled", false, gamestateMachineParameterAspect.Temporary);
    this.SendPSMBoolParameter(n"ReevaluateAiming", true, gamestateMachineParameterAspect.Temporary);
    this.SetFocusModeAnimFeature(false);
    this.SetupLockToggleInput();
    GameInstance.GetAudioSystem(this.m_owner.GetGame()).NotifyGameTone(n"NotScanning");
    GameInstance.GetTargetingSystem(this.m_owner.GetGame()).BreakAimSnap(this.m_owner);
    this.RemoveFocusModeLocomotionRestriction();
    this.m_otherVars.m_enabledByToggle = false;
    this.m_otherVars.m_toggledDuringHold = false;
  }

  private final func ProcessFlagsRefreshPolicy() -> Void {
    if Equals(this.m_gameplayActiveFlagsRefreshPolicy.m_kerenzikov, PlayerVisionModeControllerRefreshPolicyEnum.Eventful) {
      this.m_gameplayActiveFlags.m_kerenzikov = false;
    };
    if Equals(this.m_gameplayActiveFlagsRefreshPolicy.m_restrictedScene, PlayerVisionModeControllerRefreshPolicyEnum.Eventful) {
      this.m_gameplayActiveFlags.m_restrictedScene = false;
    };
    if Equals(this.m_gameplayActiveFlagsRefreshPolicy.m_dead, PlayerVisionModeControllerRefreshPolicyEnum.Eventful) {
      this.m_gameplayActiveFlags.m_dead = false;
    };
    if Equals(this.m_gameplayActiveFlagsRefreshPolicy.m_takedown, PlayerVisionModeControllerRefreshPolicyEnum.Eventful) {
      this.m_gameplayActiveFlags.m_takedown = false;
    };
    if Equals(this.m_gameplayActiveFlagsRefreshPolicy.m_deviceTakeover, PlayerVisionModeControllerRefreshPolicyEnum.Eventful) {
      this.m_gameplayActiveFlags.m_deviceTakeover = false;
    };
    if Equals(this.m_gameplayActiveFlagsRefreshPolicy.m_braindanceFPP, PlayerVisionModeControllerRefreshPolicyEnum.Eventful) {
      this.m_gameplayActiveFlags.m_braindanceFPP = false;
    };
    if Equals(this.m_gameplayActiveFlagsRefreshPolicy.m_braindanceActive, PlayerVisionModeControllerRefreshPolicyEnum.Eventful) {
      this.m_gameplayActiveFlags.m_braindanceActive = false;
    };
    if Equals(this.m_gameplayActiveFlagsRefreshPolicy.m_veryHardLanding, PlayerVisionModeControllerRefreshPolicyEnum.Eventful) {
      this.m_gameplayActiveFlags.m_veryHardLanding = false;
    };
    if Equals(this.m_gameplayActiveFlagsRefreshPolicy.m_noScanningRestriction, PlayerVisionModeControllerRefreshPolicyEnum.Eventful) {
      this.m_gameplayActiveFlags.m_noScanningRestriction = false;
    };
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if Equals(ListenerAction.GetName(action), this.m_inputActionsNames.m_buttonToggle) {
      if ListenerAction.GetValue(action) > 0.00 {
        if this.m_otherVars.m_enabledByToggle {
          this.m_inputActiveFlags.m_buttonToggle = !this.m_inputActiveFlags.m_buttonToggle;
        } else {
          this.m_inputActiveFlags.m_buttonToggle = !this.m_inputActiveFlags.m_buttonToggle;
        };
        if this.m_inputActiveFlags.m_buttonToggle && this.m_inputActiveFlags.m_buttonHold {
          this.m_otherVars.m_toggledDuringHold = true;
        };
      };
      this.VerifyActivation();
    } else {
      if Equals(ListenerAction.GetName(action), this.m_inputActionsNames.m_buttonHold) {
        if ListenerAction.GetValue(action) > 0.00 {
          this.m_inputActiveFlags.m_buttonHold = true;
          this.m_otherVars.m_toggledDuringHold = false;
        } else {
          this.m_inputActiveFlags.m_buttonHold = false;
          if !this.m_otherVars.m_toggledDuringHold {
            this.m_inputActiveFlags.m_buttonToggle = false;
          };
        };
        this.VerifyActivation();
      };
    };
  }

  protected cb func OnKerenzikovChanged(value: Int32) -> Bool {
    if value == EnumInt(gamePSMLocomotionStates.Kereznikov) {
      this.m_gameplayActiveFlags.m_kerenzikov = true;
    } else {
      this.m_gameplayActiveFlags.m_kerenzikov = false;
    };
    this.VerifyActivation();
  }

  protected cb func OnRestrictedSceneChanged(value: Int32) -> Bool {
    if value >= EnumInt(gamePSMHighLevel.SceneTier4) && value <= EnumInt(gamePSMHighLevel.SceneTier5) {
      this.m_gameplayActiveFlags.m_restrictedScene = true;
    } else {
      this.m_gameplayActiveFlags.m_restrictedScene = false;
    };
    this.VerifyActivation();
  }

  protected cb func OnDeadChanged(value: Int32) -> Bool {
    if value == EnumInt(gamePSMVitals.Dead) {
      this.m_gameplayActiveFlags.m_dead = true;
    } else {
      this.m_gameplayActiveFlags.m_dead = false;
    };
    this.VerifyActivation();
  }

  protected cb func OnTakedownChanged(value: Int32) -> Bool {
    if value == EnumInt(gamePSMTakedown.Takedown) {
      this.m_gameplayActiveFlags.m_takedown = true;
    } else {
      this.m_gameplayActiveFlags.m_takedown = false;
    };
    this.VerifyActivation();
  }

  protected cb func OnDeviceTakeoverChanged(value: EntityID) -> Bool {
    let empty: EntityID;
    if value != empty {
      this.m_gameplayActiveFlags.m_deviceTakeover = true;
    } else {
      this.m_gameplayActiveFlags.m_deviceTakeover = false;
    };
    this.VerifyActivation();
  }

  protected cb func OnBraindanceFPPChanged(value: Bool) -> Bool {
    this.m_gameplayActiveFlags.m_braindanceFPP = value;
    this.VerifyActivation();
  }

  protected cb func OnBraindanceActiveChanged(value: Bool) -> Bool {
    this.m_gameplayActiveFlags.m_braindanceActive = value;
    this.VerifyActivation();
  }

  protected cb func OnVeryHardLandingChanged(value: Int32) -> Bool {
    if value == EnumInt(gamePSMLandingState.VeryHardLand) {
      this.m_gameplayActiveFlags.m_veryHardLanding = true;
    } else {
      this.m_gameplayActiveFlags.m_veryHardLanding = false;
    };
    this.VerifyActivation();
  }

  public final func UpdateNoScanningRestriction() -> Void {
    let hasNoScanningRestriction: Bool = StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_owner, n"NoScanning");
    if NotEquals(hasNoScanningRestriction, this.m_gameplayActiveFlags.m_noScanningRestriction) {
      this.m_gameplayActiveFlags.m_noScanningRestriction = hasNoScanningRestriction;
      this.VerifyActivation();
    };
  }

  private final func InvalidateActivationState(active: Bool) -> Void {
    let invalidateEvent: ref<PlayerVisionModeControllerInvalidateEvent> = new PlayerVisionModeControllerInvalidateEvent();
    invalidateEvent.m_active = active;
    this.m_owner.QueueEvent(invalidateEvent);
  }

  private final func ApplyFocusModeLocomotionRestriction() -> Void {
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"GameplayRestriction.FocusModeLocomotion");
  }

  private final func SetBlackboardIntVariable(definition: ref<BlackboardDefinition>, id: BlackboardID_Int, value: Int32) -> Void {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.m_owner.GetGame());
    let blackboard: ref<IBlackboard> = blackboardSystem.GetLocalInstanced(this.m_owner.GetEntityID(), definition);
    if IsDefined(blackboard) {
      blackboard.SetInt(id, value);
    };
  }

  private final func SetFocusModeAnimFeature(newState: Bool) -> Void {
    let animFeature: ref<AnimFeature_FocusMode> = new AnimFeature_FocusMode();
    animFeature.isFocusModeActive = newState;
    AnimationControllerComponent.ApplyFeature(this.m_owner, n"FocusMode", animFeature);
  }

  protected final const func SetupLockToggleInput() -> Void {
    this.SendPSMBoolParameter(n"lockToggleInput", this.m_inputActiveFlags.m_buttonToggle, gamestateMachineParameterAspect.Permanent);
  }

  protected final const func SetupLockHoldInput() -> Void {
    this.SendPSMBoolParameter(n"lockHoldInput", this.m_inputActiveFlags.m_buttonHold, gamestateMachineParameterAspect.Permanent);
  }

  protected final const func SendPSMBoolParameter(id: CName, value: Bool, aspect: gamestateMachineParameterAspect) -> Void {
    let psmEvent: ref<PSMPostponedParameterBool> = new PSMPostponedParameterBool();
    psmEvent.id = id;
    psmEvent.value = value;
    psmEvent.aspect = aspect;
    this.m_owner.QueueEvent(psmEvent);
  }

  private final func GetVisionAimSnapParams() -> AimRequest {
    let aimSnapParams: AimRequest;
    aimSnapParams.duration = 0.25;
    aimSnapParams.adjustPitch = true;
    aimSnapParams.adjustYaw = true;
    aimSnapParams.endOnAimingStopped = true;
    aimSnapParams.endOnCameraInputApplied = true;
    aimSnapParams.precision = 0.10;
    aimSnapParams.easeIn = true;
    aimSnapParams.easeOut = true;
    aimSnapParams.checkRange = true;
    aimSnapParams.processAsInput = true;
    aimSnapParams.bodyPartsTracking = true;
    aimSnapParams.bptMaxDot = 0.50;
    aimSnapParams.bptMaxSwitches = -1.00;
    aimSnapParams.bptMinInputMag = 0.50;
    aimSnapParams.bptMinResetInputMag = 0.10;
    return aimSnapParams;
  }

  private final func RemoveFocusModeLocomotionRestriction() -> Void {
    StatusEffectHelper.RemoveStatusEffect(this.m_owner, t"GameplayRestriction.FocusModeLocomotion");
  }

  private final func UpdateAimAssist() -> Void {
    let hasMeleeEquipped: Bool;
    let inLefthandCW: Bool;
    let inMeleeAssistState: Bool;
    let inSprint: Bool;
    let leftHandCWState: Int32;
    let meleeState: Int32;
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.m_owner.GetGame());
    let blackboard: ref<IBlackboard> = blackboardSystem.GetLocalInstanced(this.m_owner.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    let playerPuppet: ref<PlayerPuppet> = this.m_owner as PlayerPuppet;
    if !IsDefined(playerPuppet) {
      return;
    };
    if blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vision) == EnumInt(gamePSMVision.Focus) {
      playerPuppet.ApplyAimAssistSettings("Settings_Scanning");
      return;
    };
    if this.m_owner.GetTakeOverControlSystem().IsDeviceControlled() {
      playerPuppet.ApplyAimAssistSettings("Settings_Default");
      return;
    };
    leftHandCWState = blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware);
    if leftHandCWState == EnumInt(gamePSMLeftHandCyberware.Charge) {
      playerPuppet.ApplyAimAssistSettings("Settings_LeftHandCyberwareCharge");
      return;
    };
    inLefthandCW = leftHandCWState != EnumInt(gamePSMLeftHandCyberware.Unequip) && leftHandCWState != EnumInt(gamePSMLeftHandCyberware.StartUnequip);
    if inLefthandCW {
      playerPuppet.ApplyAimAssistSettings("Settings_LeftHandCyberware");
      return;
    };
    hasMeleeEquipped = this.HasMeleeWeaponEquipped();
    inSprint = blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Locomotion) == EnumInt(gamePSMLocomotionStates.Sprint);
    if !inSprint && hasMeleeEquipped {
      meleeState = blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon);
      inMeleeAssistState = meleeState == EnumInt(gamePSMMeleeWeapon.Block) || meleeState == EnumInt(gamePSMMeleeWeapon.Deflect) || meleeState == EnumInt(gamePSMMeleeWeapon.DeflectAttack);
      playerPuppet.ApplyAimAssistSettings(inMeleeAssistState ? "Settings_MeleeCombat" : "Settings_MeleeCombatIdle");
      return;
    };
    if blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim) {
      playerPuppet.ApplyAimAssistSettings(RPGManager.HasStatFlag(this.m_owner, gamedataStatType.CanWeaponSnapToLimbs) ? "Settings_AimingLimbCyber" : "Settings_Aiming");
      return;
    };
    if blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Weapon) == EnumInt(gamePSMRangedWeaponStates.QuickMelee) {
      playerPuppet.ApplyAimAssistSettings("Settings_QuickMelee");
      return;
    };
    if blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle) == EnumInt(gamePSMVehicle.Combat) {
      playerPuppet.ApplyAimAssistSettings("Settings_VehicleCombat");
      return;
    };
    if inSprint {
      playerPuppet.ApplyAimAssistSettings("Settings_Sprinting");
      return;
    };
    playerPuppet.ApplyAimAssistSettings(RPGManager.HasStatFlag(this.m_owner, gamedataStatType.CanWeaponSnapToLimbs) ? "Settings_LimbCyber" : "Settings_Default");
  }

  private final func HasMeleeWeaponEquipped() -> Bool {
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
    let weapon: ref<WeaponObject> = transactionSystem.GetItemInSlot(this.m_owner, t"AttachmentSlots.WeaponRight") as WeaponObject;
    if IsDefined(weapon) {
      if transactionSystem.HasTag(this.m_owner, WeaponObject.GetMeleeWeaponTag(), weapon.GetItemID()) {
        return true;
      };
    };
    return false;
  }
}
