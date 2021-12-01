
public abstract class ScenesFastForwardTransition extends DefaultTransition {

  protected final const func SetFastForwardAvailableBB(const scriptInterface: ref<StateGameScriptInterface>, newVal: Bool) -> Void;

  protected final const func SetFastForwardActiveBB(const scriptInterface: ref<StateGameScriptInterface>, newVal: Bool) -> Void;

  protected final const func GetDebugFFConditionParam(const stateContext: ref<StateContext>) -> Bool {
    let result: StateResultBool = stateContext.GetConditionBoolParameter(n"debugFF");
    return result.valid && result.value;
  }

  protected final func CleanupFastForward(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.HideFFButtonPrompt(scriptInterface);
    this.StopGlitchFx(scriptInterface);
    stateContext.RemovePermanentBoolParameter(n"FFRestriction");
    stateContext.RemovePermanentBoolParameter(n"FFCrouchLock");
    stateContext.RemovePermanentBoolParameter(n"FFhintActive");
    stateContext.RemovePermanentBoolParameter(n"FFHoldLock");
    stateContext.RemovePermanentBoolParameter(n"HoldInputFastForwardLock");
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.FastForward");
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.FastForwardCrouchLock");
  }

  protected final const func ActivateFastForward(const scriptInterface: ref<StateGameScriptInterface>, mode: scnFastForwardMode) -> Void {
    scriptInterface.GetSceneSystem().GetScriptInterface().FastForwardingActivate(mode);
  }

  protected final const func IsFastForwardModeActive(const scriptInterface: ref<StateGameScriptInterface>, mode: scnFastForwardMode) -> Bool {
    return scriptInterface.GetSceneSystem().GetScriptInterface().IsFastForwardingActive(mode);
  }

  protected final const func DeActivateFastForward(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.GetSceneSystem().GetScriptInterface().FastForwardingDeactivate();
  }

  protected final const func IsFastForwardAvailable(const scriptInterface: ref<StateGameScriptInterface>, mode: scnFastForwardMode) -> Bool {
    return scriptInterface.GetSceneSystem().GetScriptInterface().IsFastForwardingAllowed(mode);
  }

  protected final const func FastForwardInputValid(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustReleased(n"SceneFastForward");
  }

  protected final const func DebugFastForwardInputValid(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustReleased(n"FastForward");
  }

  protected final const func ProcessHoldInputFastForwardLock(stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if stateContext.GetBoolParameter(n"HoldInputFastForwardLock", true) {
      if scriptInterface.GetActionValue(n"ToggleCrouch") == 0.00 {
        stateContext.RemovePermanentBoolParameter(n"HoldInputFastForwardLock");
      };
    };
  }

  protected final const func StartGlitchFx(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let blackboard: ref<worldEffectBlackboard> = new worldEffectBlackboard();
    GameObjectEffectHelper.StartEffectEvent(scriptInterface.executionOwner, n"transition_glitch_loop", false, blackboard);
  }

  protected final const func StopGlitchFx(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    GameObjectEffectHelper.StopEffectEvent(scriptInterface.executionOwner, n"transition_glitch_loop");
  }

  protected final const func GetFFSceneThrehsoldFromBraindanceSystem(const scriptInterface: ref<StateGameScriptInterface>) -> Int32 {
    let bdSystem: ref<BraindanceSystem> = scriptInterface.GetScriptableSystem(n"BraindanceSystem") as BraindanceSystem;
    return bdSystem.GetDebugFFSceneThreshold();
  }

  protected final const func DisplayFFButtonPrompt(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let data: InputHintData;
    data.action = n"SceneFastForward";
    data.source = n"FastForward";
    data.localizedLabel = "LocKey#35482";
    data.holdIndicationType = this.GetFFButtonType(scriptInterface);
    let evt: ref<UpdateInputHintEvent> = new UpdateInputHintEvent();
    evt.data = data;
    evt.show = true;
    evt.targetHintContainer = n"GameplayInputHelper";
    scriptInterface.GetUISystem().QueueEvent(evt);
  }

  protected final const func GetFFButtonType(const scriptInterface: ref<StateGameScriptInterface>) -> inkInputHintHoldIndicationType {
    if this.IsFastForwardByLine(scriptInterface) {
      return inkInputHintHoldIndicationType.Press;
    };
    return inkInputHintHoldIndicationType.Hold;
  }

  protected final const func HideFFButtonPrompt(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let data: InputHintData;
    data.action = n"SceneFastForward";
    data.source = n"FastForward";
    let evt: ref<UpdateInputHintEvent> = new UpdateInputHintEvent();
    evt.data = data;
    evt.show = false;
    evt.targetHintContainer = n"GameplayInputHelper";
    scriptInterface.GetUISystem().QueueEvent(evt);
  }

  protected final const func IsLookingAtDialogueEntity(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let npc: ref<ScriptedPuppet>;
    let hudManager: ref<HUDManager> = scriptInterface.GetScriptableSystem(n"HUDManager") as HUDManager;
    if IsDefined(hudManager) {
      npc = GameInstance.FindEntityByID(scriptInterface.GetGame(), hudManager.GetCurrentTargetID()) as ScriptedPuppet;
      if IsDefined(npc) && npc != scriptInterface.executionOwner {
        return scriptInterface.GetSceneSystem().GetScriptInterface().IsEntityInDialogue(hudManager.GetCurrentTargetID()) || scriptInterface.GetSceneSystem().GetScriptInterface().IsEntityInDialogue(scriptInterface.executionOwnerEntityID);
      };
    };
    return false;
  }

  protected final const func IsBlockedByPhoneCallRestriction(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsFastForwardByLine(scriptInterface) {
      return StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"PhoneCall");
    };
    return false;
  }

  protected final const func PhoneBBStateBlockingFF(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let lastPhoneCallInformation: PhoneCallInformation;
    let blackboardDef: ref<UI_ComDeviceDef> = GetAllBlackboardDefs().UI_ComDevice;
    let blackboard: ref<IBlackboard> = scriptInterface.GetBlackboardSystem().Get(blackboardDef);
    let infoVariant: Variant = blackboard.GetVariant(GetAllBlackboardDefs().UI_ComDevice.PhoneCallInformation);
    if VariantIsValid(infoVariant) {
      lastPhoneCallInformation = FromVariant(infoVariant);
      return Equals(lastPhoneCallInformation.callPhase, questPhoneCallPhase.StartCall) && this.GetSceneTier(scriptInterface) < 2;
    };
    return false;
  }
}

public class FastForwardUnavailableDecisions extends ScenesFastForwardTransition {

  protected final const func ToFastForwardAvailable(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !scriptInterface.IsPlayerInBraindance() && !this.IsPlayerInCombat(scriptInterface) && this.GetSceneTier(scriptInterface) < 5 && !scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicle) && !scriptInterface.IsEntityInCombat() && scriptInterface.IsOnGround() && !this.IsBlockedByPhoneCallRestriction(scriptInterface) && !scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsPlayerInsideElevator) && (this.IsFastForwardAvailable(scriptInterface, scnFastForwardMode.Default) || this.IsFastForwardAvailable(scriptInterface, scnFastForwardMode.GameplayReview));
  }
}

public class FastForwardUnavailableEvents extends ScenesFastForwardTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.DeActivateFastForward(scriptInterface);
    this.CleanupFastForward(stateContext, scriptInterface);
  }
}

public class FastForwardAvailableDecisions extends ScenesFastForwardTransition {

  protected final const func ToFastForwardUnavailable(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsPlayerInBraindance() || this.IsPlayerInCombat(scriptInterface) || this.GetSceneTier(scriptInterface) > 4 || scriptInterface.IsEntityInCombat() || scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicle) || !scriptInterface.IsOnGround() || this.IsBlockedByPhoneCallRestriction(scriptInterface) || scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsPlayerInsideElevator);
  }

  protected final const func ToFastForwardActive(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetSceneTier(scriptInterface) < 3 {
      if this.IsFastForwardByLine(scriptInterface) {
        if this.IsFastForwardAvailable(scriptInterface, scnFastForwardMode.Default) && this.FastForwardInputValid(scriptInterface) && !stateContext.GetBoolParameter(n"FFRestriction", true) && !stateContext.GetBoolParameter(n"HoldInputFastForwardLock", true) {
          return true;
        };
      } else {
        if this.IsFastForwardAvailable(scriptInterface, scnFastForwardMode.Default) && stateContext.GetBoolParameter(n"TriggerFF", true) {
          return true;
        };
      };
    } else {
      if this.GetSceneTier(scriptInterface) == 4 || this.GetSceneTier(scriptInterface) == 3 {
        if this.IsFastForwardByLine(scriptInterface) {
          if this.IsFastForwardAvailable(scriptInterface, scnFastForwardMode.Default) && this.FastForwardInputValid(scriptInterface) && !stateContext.GetBoolParameter(n"FFRestriction", true) {
            return true;
          };
        } else {
          if this.IsFastForwardAvailable(scriptInterface, scnFastForwardMode.Default) && stateContext.GetBoolParameter(n"TriggerFF", true) {
            return true;
          };
        };
      };
    };
    return false;
  }
}

public class FastForwardAvailableEvents extends ScenesFastForwardTransition {

  public let forceCloseFX: Bool;

  public let delay: Float;

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.IsFastForwardModeActive(scriptInterface, scnFastForwardMode.GameplayReview) || this.IsFastForwardModeActive(scriptInterface, scnFastForwardMode.Default) {
      this.DeActivateFastForward(scriptInterface);
    };
    this.HideFFButtonPrompt(scriptInterface);
    stateContext.RemovePermanentBoolParameter(n"FFhintActive");
    this.forceCloseFX = false;
    this.delay = 0.00;
  }

  public func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if !this.forceCloseFX && this.GetInStateTime() > 0.30 && !this.IsTimeDilationActive(stateContext, scriptInterface, n"") {
      this.StopGlitchFx(scriptInterface);
      this.forceCloseFX = true;
    };
    if stateContext.GetBoolParameter(n"FFRestriction", true) && !this.IsTimeDilationActive(stateContext, scriptInterface, n"") {
      this.delay += 0.10;
      if this.delay > 0.10 {
        stateContext.SetPermanentBoolParameter(n"FFCrouchLock", true, true);
        stateContext.RemovePermanentBoolParameter(n"FFRestriction");
        StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.FastForward");
        if this.IsFastForwardByLine(scriptInterface) {
          StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.FastForwardCrouchLock");
        };
        this.delay = 0.00;
      };
    } else {
      if stateContext.GetBoolParameter(n"FFRestriction", true) && this.IsTimeDilationActive(stateContext, scriptInterface, n"") {
        timeDelta = 0.00;
      } else {
        if stateContext.GetBoolParameter(n"FFCrouchLock", true) && !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.FastForwardCrouchLock") {
          stateContext.RemovePermanentBoolParameter(n"FFCrouchLock");
        };
      };
    };
    if !this.IsFastForwardByLine(scriptInterface) {
      if scriptInterface.IsActionJustHeld(n"SceneFastForward") && !stateContext.GetBoolParameter(n"TriggerFF", true) {
        stateContext.SetPermanentBoolParameter(n"TriggerFF", true, true);
        stateContext.SetPermanentBoolParameter(n"FFHoldLock", true, true);
      } else {
        if stateContext.GetBoolParameter(n"TriggerFF", true) && scriptInterface.GetActionValue(n"SceneFastForward") == 0.00 {
          stateContext.RemovePermanentBoolParameter(n"TriggerFF");
          stateContext.RemovePermanentBoolParameter(n"FFHoldLock");
        };
      };
    };
    if this.GetSceneTier(scriptInterface) < 3 {
      if this.IsFastForwardAvailable(scriptInterface, scnFastForwardMode.Default) && !this.IsFastForwardModeActive(scriptInterface, scnFastForwardMode.GameplayReview) && !stateContext.GetBoolParameter(n"FFhintActive", true) {
        stateContext.SetPermanentBoolParameter(n"FFhintActive", true, true);
        this.DisplayFFButtonPrompt(scriptInterface);
      } else {
        if (!this.IsFastForwardAvailable(scriptInterface, scnFastForwardMode.Default) || this.IsFastForwardModeActive(scriptInterface, scnFastForwardMode.GameplayReview)) && stateContext.GetBoolParameter(n"FFhintActive", true) {
          this.HideFFButtonPrompt(scriptInterface);
          stateContext.RemovePermanentBoolParameter(n"FFhintActive");
        };
      };
    } else {
      if this.GetSceneTier(scriptInterface) == 4 || this.GetSceneTier(scriptInterface) == 3 {
        if this.IsFastForwardAvailable(scriptInterface, scnFastForwardMode.Default) && !this.IsFastForwardModeActive(scriptInterface, scnFastForwardMode.GameplayReview) && !stateContext.GetBoolParameter(n"FFhintActive", true) {
          stateContext.SetPermanentBoolParameter(n"FFhintActive", true, true);
          this.DisplayFFButtonPrompt(scriptInterface);
        } else {
          if (!this.IsFastForwardAvailable(scriptInterface, scnFastForwardMode.Default) || this.IsFastForwardModeActive(scriptInterface, scnFastForwardMode.GameplayReview)) && stateContext.GetBoolParameter(n"FFhintActive", true) {
            this.HideFFButtonPrompt(scriptInterface);
            stateContext.RemovePermanentBoolParameter(n"FFhintActive");
          };
        };
      } else {
        if (this.GetSceneTier(scriptInterface) == 1 || !this.IsFastForwardAvailable(scriptInterface, scnFastForwardMode.Default)) && stateContext.GetBoolParameter(n"FFhintActive", true) {
          this.HideFFButtonPrompt(scriptInterface);
          stateContext.RemovePermanentBoolParameter(n"FFhintActive");
        };
      };
    };
    if this.IsFastForwardByLine(scriptInterface) {
      this.ProcessHoldInputFastForwardLock(stateContext, scriptInterface);
    };
  }
}

public class FastForwardActiveDecisions extends ScenesFastForwardTransition {

  protected final const func ToFastForwardAvailable(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.IsFastForwardModeActive(scriptInterface, scnFastForwardMode.Default) && this.GetInStateTime() > 0.10;
  }

  protected final const func ToFastForwardUnavailable(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsPlayerInBraindance() || this.IsPlayerInCombat(scriptInterface) || scriptInterface.IsEntityInCombat() || scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicle) || !scriptInterface.IsOnGround() || this.IsBlockedByPhoneCallRestriction(scriptInterface) || scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsPlayerInsideElevator);
  }
}

public class FastForwardActiveEvents extends ScenesFastForwardTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.RemovePermanentBoolParameter(n"FFhintActive");
    stateContext.RemovePermanentBoolParameter(n"HoldInputFastForwardLock");
    stateContext.SetPermanentBoolParameter(n"FFRestriction", true, true);
    StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.FastForward");
    if this.GetDebugFFConditionParam(stateContext) {
      this.ActivateFastForward(scriptInterface, scnFastForwardMode.GameplayReview);
    } else {
      this.ActivateFastForward(scriptInterface, scnFastForwardMode.Default);
    };
    this.HideFFButtonPrompt(scriptInterface);
    this.StartGlitchFx(scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.GetDebugFFConditionParam(stateContext) {
      stateContext.RemoveConditionBoolParameter(n"debugFF");
    };
  }
}

public class FastForwardSelfRemovalDecisions extends ScenesFastForwardTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.IsFastForwardModeActive(scriptInterface, scnFastForwardMode.GameplayReview) && !this.IsFastForwardModeActive(scriptInterface, scnFastForwardMode.Default) && !this.IsFastForwardAvailable(scriptInterface, scnFastForwardMode.Default) && !this.IsFastForwardAvailable(scriptInterface, scnFastForwardMode.GameplayReview);
  }
}

public class FastForwardSelfRemovalEvents extends ScenesFastForwardTransition {

  public final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let psmIdent: StateMachineIdentifier;
    let psmRemove: ref<PSMRemoveOnDemandStateMachine> = new PSMRemoveOnDemandStateMachine();
    this.CleanupFastForward(stateContext, scriptInterface);
    psmIdent.definitionName = n"ScenesFastForward";
    psmIdent.referenceName = n"";
    psmRemove.stateMachineIdentifier = psmIdent;
    scriptInterface.executionOwner.QueueEvent(psmRemove);
  }
}

public static exec func SetDebugSceneTierThreshold2(gameInstance: GameInstance) -> Void {
  let request: ref<SetDebugSceneThrehsold> = new SetDebugSceneThrehsold();
  request.newThreshold = 2;
  let bdSystem: ref<BraindanceSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"BraindanceSystem") as BraindanceSystem;
  bdSystem.QueueRequest(request);
}

public static exec func SetDebugSceneTierThreshold1(gameInstance: GameInstance) -> Void {
  let request: ref<SetDebugSceneThrehsold> = new SetDebugSceneThrehsold();
  request.newThreshold = 1;
  let bdSystem: ref<BraindanceSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"BraindanceSystem") as BraindanceSystem;
  bdSystem.QueueRequest(request);
}

public static exec func SetDebugSceneTierThreshold3(gameInstance: GameInstance) -> Void {
  let request: ref<SetDebugSceneThrehsold> = new SetDebugSceneThrehsold();
  request.newThreshold = 3;
  let bdSystem: ref<BraindanceSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"BraindanceSystem") as BraindanceSystem;
  bdSystem.QueueRequest(request);
}
