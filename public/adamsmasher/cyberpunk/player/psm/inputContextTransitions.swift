
public abstract class InputContextTransitionDecisions extends DefaultTransition {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }

  protected const func ToGameplayContext(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.IsOnEnterConditionEnabled() || !this.EnterCondition(stateContext, scriptInterface);
  }

  protected const func ToBaseContext(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.IsOnEnterConditionEnabled() || !this.EnterCondition(stateContext, scriptInterface);
  }

  protected const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.IsOnEnterConditionEnabled() || !this.EnterCondition(stateContext, scriptInterface);
  }
}

public abstract class InputContextTransitionEvents extends DefaultTransition {

  public let m_gameplaySettings: wref<GameplaySettingsSystem>;

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_gameplaySettings = GameplaySettingsSystem.GetGameplaySettingsSystemInstance(scriptInterface.executionOwner);
  }

  protected final const func ShouldForceRefreshInputHints(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let shouldForceRefresh: StateResultBool = stateContext.GetTemporaryBoolParameter(n"forceRefreshInputHints");
    if shouldForceRefresh.valid && shouldForceRefresh.value {
      return true;
    };
    return false;
  }

  protected final const func ShowBodyCarryInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if scriptInterface.HasStatFlag(gamedataStatType.CanShootWhileCarryingBody) {
      this.ShowInputHint(scriptInterface, n"DropCarriedObject", n"BodyCarry", "LocKey#43673", inkInputHintHoldIndicationType.FromInputConfig, true);
    } else {
      this.ShowInputHint(scriptInterface, n"DropCarriedObject", n"BodyCarry", "LocKey#43673");
    };
    stateContext.SetPermanentBoolParameter(n"isBodyCarryInputHintDisplayed", true, true);
  }

  protected final const func RemoveBodyCarryInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveInputHintsBySource(scriptInterface, n"BodyCarry");
    stateContext.RemovePermanentBoolParameter(n"isBodyCarryInputHintDisplayed");
  }

  protected final const func ShowLadderInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ShowInputHint(scriptInterface, n"ToggleSprint", n"Ladder", "LocKey#36200");
    this.ShowInputHint(scriptInterface, n"Jump", n"Ladder", "LocKey#36201");
    this.ShowInputHint(scriptInterface, n"ToggleCrouch", n"Ladder", "LocKey#36204");
    stateContext.SetPermanentBoolParameter(n"isLadderInputHintDisplayed", true, true);
  }

  protected final const func RemoveLadderInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveInputHintsBySource(scriptInterface, n"Ladder");
    stateContext.RemovePermanentBoolParameter(n"isLadderInputHintDisplayed");
  }

  protected final const func ShowTerminalInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ShowInputHint(scriptInterface, n"Choice1", n"Terminal", "LocKey#49422");
    stateContext.SetPermanentBoolParameter(n"isTerminalInputHintDisplayed", true, true);
  }

  protected final const func RemoveTerminalInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveInputHintsBySource(scriptInterface, n"Terminal");
    stateContext.RemovePermanentBoolParameter(n"isTerminalInputHintDisplayed");
  }

  protected final const func ShowGenericExplorationInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if Equals(stateContext.GetStateMachineCurrentState(n"CombatGadget"), n"combatGadgetCharge") {
      this.ShowInputHint(scriptInterface, n"CancelChargingCG", n"Locomotion", "LocKey#49906");
    } else {
      if !this.IsEmptyHandsForced(stateContext, scriptInterface) {
        this.ShowInputHint(scriptInterface, n"SwitchItem", n"Locomotion", "LocKey#45381");
      };
    };
    stateContext.SetPermanentBoolParameter(n"isLocomotionInputHintDisplayed", true, true);
  }

  protected final func RemoveGenericExplorationInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveInputHintsBySource(scriptInterface, n"Locomotion");
    stateContext.RemovePermanentBoolParameter(n"isLocomotionInputHintDisplayed");
  }

  protected final const func ShowMeleeInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ShowInputHint(scriptInterface, n"MeleeAttack", n"Melee", "LocKey#40351");
    this.ShowInputHint(scriptInterface, n"MeleeBlock", n"Melee", "LocKey#36191");
    if scriptInterface.executionOwner.PlayerLastUsedKBM() {
      this.ShowInputHint(scriptInterface, n"MoveX", n"Melee", "LocKey#36192");
    } else {
      this.ShowInputHint(scriptInterface, n"Dodge", n"Melee", "LocKey#36192");
    };
    stateContext.SetPermanentBoolParameter(n"isMeleeInputHintDisplayed", true, true);
  }

  protected final func RemoveMeleeInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveInputHintsBySource(scriptInterface, n"Melee");
    stateContext.RemovePermanentBoolParameter(n"isMeleeInputHintDisplayed");
  }

  protected final const func ShowRangedInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if DefaultTransition.IsChargeRangedWeapon(scriptInterface) {
      this.ShowInputHint(scriptInterface, n"RangedAttack", n"Ranged", "LocKey#47919");
      stateContext.SetPermanentBoolParameter(n"isChargeHintDisplayed", true, true);
    };
    this.ShowInputHint(scriptInterface, n"Reload", n"Ranged", "LocKey#36198");
    this.ShowInputHint(scriptInterface, n"QuickMelee", n"Ranged", "LocKey#45380");
    stateContext.SetPermanentBoolParameter(n"isRangedInputHintDisplayed", true, true);
  }

  protected final func RemoveRangedInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveInputHintsBySource(scriptInterface, n"Ranged");
    stateContext.RemovePermanentBoolParameter(n"isRangedInputHintDisplayed");
    stateContext.RemovePermanentBoolParameter(n"isChargeHintDisplayed");
  }

  protected final const func ShowVehicleDriverInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ShowInputHint(scriptInterface, n"ToggleVehCamera", n"VehicleDriver", "LocKey#36194");
    this.ShowVehicleExitInputHint(stateContext, scriptInterface, true);
    stateContext.SetPermanentBoolParameter(n"isDriverInputHintDisplayed", true, true);
  }

  protected final const func ShowVehicleRadioInputHint(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ShowInputHint(scriptInterface, n"VehicleInsideWheel", n"UI_DPad", "LocKey#49365", inkInputHintHoldIndicationType.FromInputConfig, true);
    stateContext.SetPermanentBoolParameter(n"isVehicleRadioInputHintDisplayed", true, true);
  }

  protected final const func RemoveVehicleRadioInputHint(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveInputHintsBySource(scriptInterface, n"UI_DPad");
    stateContext.RemovePermanentBoolParameter(n"isVehicleRadioInputHintDisplayed");
  }

  protected final const func ShowVehicleRestrictedInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ShowInputHint(scriptInterface, n"ToggleVehCamera", n"VehicleDriver", "LocKey#36194", inkInputHintHoldIndicationType.FromInputConfig, true);
    this.ShowVehicleExitInputHint(stateContext, scriptInterface, true);
  }

  protected final const func RemoveVehicleRestrictedInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveInputHintsBySource(scriptInterface, n"VehicleDriver");
  }

  protected final const func ShowVehiclePassengerInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ShowVehicleExitInputHint(stateContext, scriptInterface);
    stateContext.SetPermanentBoolParameter(n"isPassengerInputHintDisplayed", true, true);
  }

  protected final const func RemoveVehiclePassengerInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveInputHint(scriptInterface, n"VehicleInsideWheel", n"UI_DPad");
    this.RemoveInputHintsBySource(scriptInterface, n"VehiclePassenger");
    stateContext.RemovePermanentBoolParameter(n"isPassengerInputHintDisplayed");
  }

  protected final const func RemoveVehicleDriverInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveInputHint(scriptInterface, n"VehicleInsideWheel", n"UI_DPad");
    this.RemoveInputHintsBySource(scriptInterface, n"VehicleDriver");
    stateContext.RemovePermanentBoolParameter(n"isDriverInputHintDisplayed");
  }

  protected final const func ShowVehicleDriverCombatInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ShowInputHint(scriptInterface, n"Reload", n"VehicleDriverCombat", "LocKey#36198");
    this.ShowInputHint(scriptInterface, n"WeaponWheel", n"VehicleDriverCombat", "LocKey#36199");
  }

  protected final const func RemoveVehicleDriverCombatInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveInputHintsBySource(scriptInterface, n"VehicleDriverCombat");
  }

  protected final const func ShowVehicleExitInputHint(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, opt driver: Bool) -> Void {
    let vehicle: wref<GameObject>;
    VehicleComponent.GetVehicle(scriptInterface.owner.GetGame(), scriptInterface.executionOwner, vehicle);
    if IsDefined(vehicle = vehicle as BikeObject) {
      this.ShowInputHint(scriptInterface, n"Exit", n"VehicleDriver", "LocKey#53066", inkInputHintHoldIndicationType.FromInputConfig, true);
    } else {
      if driver {
        this.ShowInputHint(scriptInterface, n"Exit", n"VehicleDriver", "LocKey#36196", inkInputHintHoldIndicationType.FromInputConfig, true);
      } else {
        this.ShowInputHint(scriptInterface, n"Exit", n"VehiclePassenger", "LocKey#36196", inkInputHintHoldIndicationType.FromInputConfig, true);
      };
    };
  }

  protected final const func ShowVehiclePassengerCombatInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ShowInputHint(scriptInterface, n"RangedAttack", n"VehiclePassengerCombat", "LocKey#36197");
    this.ShowInputHint(scriptInterface, n"Reload", n"VehiclePassengerCombat", "LocKey#36198");
    this.ShowInputHint(scriptInterface, n"WeaponWheel", n"VehiclePassengerCombat", "LocKey#36199");
    stateContext.SetPermanentBoolParameter(n"isPassengerCombatInputHintDisplayed", true, true);
  }

  protected final const func RemoveVehiclePassengerCombatInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveInputHintsBySource(scriptInterface, n"VehiclePassengerCombat");
    stateContext.RemovePermanentBoolParameter(n"isPassengerCombatInputHintDisplayed");
  }

  protected final const func ShowSwimmingInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ShowInputHint(scriptInterface, n"ToggleSprint", n"Swimming", "LocKey#40155");
    this.ShowInputHint(scriptInterface, n"Jump", n"Swimming", "LocKey#40158");
    this.ShowInputHint(scriptInterface, n"ToggleCrouch", n"Swimming", "LocKey#40157");
    stateContext.SetPermanentBoolParameter(n"isSwimmingInputHintDisplayed", true, true);
  }

  protected final const func RemoveSwimmingInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveInputHintsBySource(scriptInterface, n"Swimming");
    stateContext.RemovePermanentBoolParameter(n"isSwimmingInputHintDisplayed");
  }

  protected final func RemoveAllInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveGenericExplorationInputHints(stateContext, scriptInterface);
    this.RemoveRangedInputHints(stateContext, scriptInterface);
    this.RemoveMeleeInputHints(stateContext, scriptInterface);
    this.RemoveBodyCarryInputHints(stateContext, scriptInterface);
    this.RemoveLadderInputHints(stateContext, scriptInterface);
    this.RemoveSwimmingInputHints(stateContext, scriptInterface);
    this.RemoveVehicleDriverInputHints(stateContext, scriptInterface);
    this.RemoveVehicleDriverCombatInputHints(stateContext, scriptInterface);
    this.RemoveVehiclePassengerCombatInputHints(stateContext, scriptInterface);
    this.RemoveVehiclePassengerInputHints(stateContext, scriptInterface);
    this.RemoveVehicleRestrictedInputHints(stateContext, scriptInterface);
    this.RemoveVehicleRadioInputHint(stateContext, scriptInterface);
  }

  protected final func UpdateWeaponInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let rightHandWeapon: wref<WeaponObject> = DefaultTransition.GetActiveWeapon(scriptInterface);
    let isMeleeInputHintDisplayed: Bool = stateContext.GetBoolParameter(n"isMeleeInputHintDisplayed", true);
    let isRangedInputHintDisplayed: Bool = stateContext.GetBoolParameter(n"isRangedInputHintDisplayed", true);
    let isExaminingDevice: Bool = this.IsExaminingDevice(scriptInterface) || DefaultTransition.IsInteractingWithTerminal(scriptInterface);
    let isDeviceControlled: Bool = scriptInterface.executionOwner.GetTakeOverControlSystem().IsDeviceControlled();
    let isInExploration: Bool = this.IsInHighLevelState(stateContext, n"exploration");
    let inEquipState: Bool = this.IsRightHandInEquippedState(stateContext) || this.IsRightHandInEquippingState(stateContext) || this.IsInFirstEquip(stateContext);
    let isRangedWeaponEquipped: Bool = inEquipState && rightHandWeapon.IsRanged();
    let isMeleeWeaponEquipped: Bool = inEquipState && !isRangedWeaponEquipped && rightHandWeapon.IsMelee();
    if !isMeleeInputHintDisplayed && !isExaminingDevice && isInExploration && isMeleeWeaponEquipped {
      this.ShowMeleeInputHints(stateContext, scriptInterface);
    } else {
      if isMeleeInputHintDisplayed && (!isInExploration || !isMeleeWeaponEquipped || isExaminingDevice || isDeviceControlled || this.ShouldForceRefreshInputHints(stateContext, scriptInterface) || this.CheckForControllerChange(stateContext, scriptInterface)) {
        this.RemoveMeleeInputHints(stateContext, scriptInterface);
      } else {
        if !isRangedInputHintDisplayed && !isExaminingDevice && isInExploration && isRangedWeaponEquipped && !rightHandWeapon.IsHeavyWeapon() {
          this.ShowRangedInputHints(stateContext, scriptInterface);
        } else {
          if isRangedInputHintDisplayed && (!isInExploration || !isRangedWeaponEquipped || isExaminingDevice || isDeviceControlled || this.ShouldForceRefreshInputHints(stateContext, scriptInterface) || NotEquals(Equals(rightHandWeapon.GetCurrentTriggerMode().Type(), gamedataTriggerMode.Charge), stateContext.GetBoolParameter(n"isChargeHintDisplayed", true))) {
            this.RemoveRangedInputHints(stateContext, scriptInterface);
          };
        };
      };
    };
  }

  protected final func CheckForControllerChange(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isKeyboard: Bool = scriptInterface.executionOwner.PlayerLastUsedKBM();
    if stateContext.GetBoolParameter(n"usingKeyboardAndMouse", true) && !isKeyboard {
      stateContext.SetPermanentBoolParameter(n"usingKeyboardAndMouse", false, true);
      return true;
    };
    if !stateContext.GetBoolParameter(n"usingKeyboardAndMouse", true) && isKeyboard {
      stateContext.SetPermanentBoolParameter(n"usingKeyboardAndMouse", true, true);
      return true;
    };
    return false;
  }
}

public class InitialStateDecisions extends InputContextTransitionDecisions {

  protected final const func ToUiContext(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let expectedRecordID: TweakDBID;
    let recordID: TweakDBID;
    let player: wref<PlayerPuppet> = scriptInterface.executionOwner as PlayerPuppet;
    if IsDefined(player) {
      expectedRecordID = t"Character.Player_Puppet_Menu";
      recordID = player.GetRecordID();
      if recordID == expectedRecordID {
        return true;
      };
    };
    return false;
  }
}

public class DeviceControlContextDecisions extends InputContextTransitionDecisions {

  private let m_callbackID: ref<CallbackHandle>;

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions>;
    if IsDefined(scriptInterface.localBlackboard) {
      allBlackboardDef = GetAllBlackboardDefs();
      this.m_callbackID = scriptInterface.localBlackboard.RegisterListenerBool(allBlackboardDef.PlayerStateMachine.IsControllingDevice, this, n"OnControllingDeviceChange");
      this.EnableOnEnterCondition(scriptInterface.localBlackboard.GetBool(allBlackboardDef.PlayerStateMachine.IsControllingDevice));
    };
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_callbackID = null;
  }

  protected cb func OnControllingDeviceChange(value: Bool) -> Bool {
    this.EnableOnEnterCondition(value);
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }
}

public class DeviceControlContextEvents extends InputContextTransitionEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveAllInputHints(stateContext, scriptInterface);
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;
}

public class BraindanceContextDecisions extends InputContextTransitionDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsPlayerInBraindance(scriptInterface) {
      return true;
    };
    return false;
  }
}

public class DeadContextDecisions extends InputContextTransitionDecisions {

  private let m_callbackID: ref<CallbackHandle>;

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions>;
    if IsDefined(scriptInterface.localBlackboard) {
      allBlackboardDef = GetAllBlackboardDefs();
      this.m_callbackID = scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Vitals, this, n"OnVitalsChanged");
      this.OnVitalsChanged(scriptInterface.localBlackboard.GetInt(allBlackboardDef.PlayerStateMachine.Vitals));
    };
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_callbackID = null;
  }

  protected cb func OnVitalsChanged(value: Int32) -> Bool {
    this.EnableOnEnterCondition(value == EnumInt(gamePSMVitals.Dead));
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }
}

public class BaseContextEvents extends InputContextTransitionEvents {

  public let m_slicingFrame: Int32;

  protected final func UpdateHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, sliced: Bool) -> Void {
    if this.m_slicingFrame == 0 || !sliced {
      this.UpdateGenericExplorationInputHints(stateContext, scriptInterface);
    };
    if this.m_slicingFrame == 1 || !sliced {
      this.UpdateWeaponInputHints(stateContext, scriptInterface);
    };
    if this.m_slicingFrame == 2 || !sliced {
      this.UpdateLadderInputHints(stateContext, scriptInterface);
    };
    if this.m_slicingFrame == 3 || !sliced {
      this.UpdateSwimmingInputHints(stateContext, scriptInterface);
    };
    if this.m_slicingFrame == 4 || !sliced {
      this.UpdateBodyCarryInputHints(stateContext, scriptInterface);
    };
    if sliced {
      this.m_slicingFrame += 1;
      this.m_slicingFrame = this.m_slicingFrame % 6;
    };
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.m_gameplaySettings.GetIsInputHintEnabled() {
      this.UpdateHints(stateContext, scriptInterface, true);
    };
  }

  protected final func UpdateGenericExplorationInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let isValidState: Bool = this.IsStateValidForExploration(stateContext, scriptInterface);
    if isValidState && !stateContext.GetBoolParameter(n"isLocomotionInputHintDisplayed", true) {
      this.ShowGenericExplorationInputHints(stateContext, scriptInterface);
    } else {
      if (!isValidState || this.ShouldForceRefreshInputHints(stateContext, scriptInterface)) && stateContext.GetBoolParameter(n"isLocomotionInputHintDisplayed", true) {
        this.RemoveGenericExplorationInputHints(stateContext, scriptInterface);
      };
    };
  }

  protected final func UpdateBodyCarryInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let isInBodyCarry: Bool = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.BodyCarrying) == EnumInt(gamePSMBodyCarrying.Carry);
    if isInBodyCarry && !stateContext.GetBoolParameter(n"isBodyCarryInputHintDisplayed", true) {
      this.ShowBodyCarryInputHints(stateContext, scriptInterface);
    } else {
      if !isInBodyCarry && stateContext.GetBoolParameter(n"isBodyCarryInputHintDisplayed", true) {
        this.RemoveBodyCarryInputHints(stateContext, scriptInterface);
      };
    };
  }

  protected final func UpdateTerminalInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let isInteractingWithTerminal: Bool = DefaultTransition.IsInteractingWithTerminal(scriptInterface);
    if isInteractingWithTerminal && !stateContext.GetBoolParameter(n"isTerminalInputHintDisplayed", true) {
      this.ShowTerminalInputHints(stateContext, scriptInterface);
    } else {
      if !isInteractingWithTerminal && stateContext.GetBoolParameter(n"isTerminalInputHintDisplayed", true) {
        this.RemoveTerminalInputHints(stateContext, scriptInterface);
      };
    };
  }

  protected final func UpdateLadderInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let locomotionStateName: CName = this.GetLocomotionState(stateContext);
    if Equals(locomotionStateName, n"ladder") || Equals(locomotionStateName, n"ladderSprint") || Equals(locomotionStateName, n"ladderSlide") {
      if !stateContext.GetBoolParameter(n"isLadderInputHintDisplayed", true) {
        this.ShowLadderInputHints(stateContext, scriptInterface);
      };
    } else {
      if stateContext.GetBoolParameter(n"isLadderInputHintDisplayed", true) {
        this.RemoveLadderInputHints(stateContext, scriptInterface);
      };
    };
  }

  protected final func UpdateSwimmingInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let isSwimming: Bool = stateContext.IsStateMachineActive(n"LocomotionSwimming");
    if isSwimming && !stateContext.GetBoolParameter(n"isSwimmingInputHintDisplayed", true) {
      this.ShowSwimmingInputHints(stateContext, scriptInterface);
    } else {
      if !isSwimming && stateContext.GetBoolParameter(n"isSwimmingInputHintDisplayed", true) {
        this.RemoveSwimmingInputHints(stateContext, scriptInterface);
      };
    };
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.m_gameplaySettings.GetIsInputHintEnabled() {
      this.UpdateHints(stateContext, scriptInterface, false);
    };
  }

  private final func IsStateValidForExploration(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let locomotionState: CName;
    if NotEquals(stateContext.GetStateMachineCurrentState(n"HighLevel"), n"exploration") {
      return false;
    };
    locomotionState = stateContext.GetStateMachineCurrentState(n"Locomotion");
    if Equals(locomotionState, n"ladder") || Equals(locomotionState, n"ladderSprint") || Equals(locomotionState, n"ladderSlide") {
      return false;
    };
    if Equals(locomotionState, n"climb") {
      return false;
    };
    if scriptInterface.IsPlayerInBraindance() {
      return false;
    };
    if stateContext.IsStateMachineActive(n"CarriedObject") {
      return false;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle) != EnumInt(gamePSMVehicle.Default) {
      return false;
    };
    if DefaultTransition.HasRightWeaponEquipped(scriptInterface) {
      return false;
    };
    if scriptInterface.GetWorkspotSystem().IsActorInWorkspot(scriptInterface.executionOwner) {
      return false;
    };
    if Equals(locomotionState, n"veryHardLand") || scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsPlayerInsideMovingElevator) || StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoMovement") || StatusEffectSystem.ObjectHasStatusEffectOfType(scriptInterface.executionOwner, gamedataStatusEffectType.Stunned) || StatusEffectSystem.ObjectHasStatusEffectOfType(scriptInterface.executionOwner, gamedataStatusEffectType.Knockdown) {
      return false;
    };
    if scriptInterface.executionOwner.GetTakeOverControlSystem().IsDeviceControlled() {
      return false;
    };
    if this.IsExaminingDevice(scriptInterface) || DefaultTransition.IsInteractingWithTerminal(scriptInterface) {
      return false;
    };
    return true;
  }
}

public class AimingContextDecisions extends InputContextTransitionDecisions {

  private let m_leftHandChargeCallbackID: ref<CallbackHandle>;

  private let m_upperBodyCallbackID: ref<CallbackHandle>;

  private let m_meleeCallbackID: ref<CallbackHandle>;

  private let m_leftHandCharge: Bool;

  private let m_isAiming: Bool;

  private let m_meleeBlockActive: Bool;

  protected final func UpdateNeedsToBeChecked() -> Void {
    this.EnableOnEnterCondition(this.m_leftHandCharge || this.m_isAiming || this.m_meleeBlockActive);
  }

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions>;
    if IsDefined(scriptInterface.localBlackboard) {
      allBlackboardDef = GetAllBlackboardDefs();
      this.m_leftHandChargeCallbackID = scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.LeftHandCyberware, this, n"OnLeftHandCyberwareChanged");
      this.m_upperBodyCallbackID = scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.UpperBody, this, n"OnUpperBodyChanged");
      this.m_meleeCallbackID = scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Melee, this, n"OnMeleeChanged");
      this.UpdateLeftHandCyberware(scriptInterface.localBlackboard.GetInt(allBlackboardDef.PlayerStateMachine.LeftHandCyberware));
      this.UpdateUpperBodyState(scriptInterface.localBlackboard.GetInt(allBlackboardDef.PlayerStateMachine.UpperBody));
      this.UpdateMeleeState(scriptInterface.localBlackboard.GetInt(allBlackboardDef.PlayerStateMachine.Melee));
      this.UpdateNeedsToBeChecked();
    };
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_leftHandChargeCallbackID = null;
    this.m_upperBodyCallbackID = null;
    this.m_meleeCallbackID = null;
  }

  protected final func UpdateLeftHandCyberware(value: Int32) -> Void {
    this.m_leftHandCharge = value == EnumInt(gamePSMLeftHandCyberware.Charge);
  }

  protected cb func OnLeftHandCyberwareChanged(value: Int32) -> Bool {
    this.UpdateLeftHandCyberware(value);
    this.UpdateNeedsToBeChecked();
  }

  protected final func UpdateUpperBodyState(value: Int32) -> Void {
    this.m_isAiming = value == EnumInt(gamePSMUpperBodyStates.Aim);
  }

  protected cb func OnUpperBodyChanged(value: Int32) -> Bool {
    this.UpdateUpperBodyState(value);
    this.UpdateNeedsToBeChecked();
  }

  protected final func UpdateMeleeState(value: Int32) -> Void {
    this.m_meleeBlockActive = value == EnumInt(gamePSMMelee.Block);
  }

  protected cb func OnMeleeChanged(value: Int32) -> Bool {
    this.UpdateMeleeState(value);
    this.UpdateNeedsToBeChecked();
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }
}

public class AimingContextEvents extends InputContextTransitionEvents {

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.m_gameplaySettings.GetIsInputHintEnabled() {
      this.UpdateWeaponInputHints(stateContext, scriptInterface);
    };
  }
}

public class VisionContextDecisions extends InputContextTransitionDecisions {

  private let m_vehicleCallbackID: ref<CallbackHandle>;

  private let m_focusCallbackID: ref<CallbackHandle>;

  private let m_vehicleTransition: Bool;

  private let m_isFocusing: Bool;

  private let m_visionHoldPressed: Bool;

  protected final func UpdateNeedsToBeChecked() -> Void {
    if this.m_vehicleTransition {
      this.EnableOnEnterCondition(false);
    };
    this.EnableOnEnterCondition(this.m_visionHoldPressed || this.m_isFocusing);
  }

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions>;
    if IsDefined(scriptInterface.localBlackboard) {
      allBlackboardDef = GetAllBlackboardDefs();
      this.m_vehicleCallbackID = scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Vehicle, this, n"OnVehicleStateChanged");
      this.m_focusCallbackID = scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Vision, this, n"OnVisionChanged");
      this.UpdateVehicleStateValue(scriptInterface.localBlackboard.GetInt(allBlackboardDef.PlayerStateMachine.Vehicle));
      this.UpdateVisionValue(scriptInterface.localBlackboard.GetInt(allBlackboardDef.PlayerStateMachine.Vision));
    };
    scriptInterface.executionOwner.RegisterInputListener(this, n"VisionHold");
    this.UpdateVisionAction(scriptInterface.GetActionValue(n"VisionHold"));
    this.UpdateNeedsToBeChecked();
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_vehicleCallbackID = null;
    this.m_focusCallbackID = null;
    scriptInterface.executionOwner.UnregisterInputListener(this);
  }

  protected final func UpdateVisionAction(value: Float) -> Void {
    this.m_visionHoldPressed = value > 0.00;
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if Equals(ListenerAction.GetName(action), n"VisionHold") {
      this.UpdateVisionAction(ListenerAction.GetValue(action));
      this.UpdateNeedsToBeChecked();
    };
  }

  protected final func UpdateVehicleStateValue(value: Int32) -> Void {
    this.m_vehicleTransition = value == EnumInt(gamePSMVehicle.Transition);
  }

  protected cb func OnVehicleStateChanged(value: Int32) -> Bool {
    this.UpdateVehicleStateValue(value);
    this.UpdateNeedsToBeChecked();
  }

  protected final func UpdateVisionValue(value: Int32) -> Void {
    this.m_isFocusing = value == EnumInt(gamePSMVision.Focus);
  }

  protected cb func OnVisionChanged(value: Int32) -> Bool {
    this.UpdateVisionValue(value);
    this.UpdateNeedsToBeChecked();
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.m_isFocusing {
      return true;
    };
    if this.m_visionHoldPressed && !stateContext.GetBoolParameter(n"lockHoldInput", true) {
      return true;
    };
    return false;
  }
}

public class UiContextDecisions extends InputContextTransitionDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let psmResult: StateResultBool = stateContext.GetTemporaryBoolParameter(n"OnUIContextActive");
    return psmResult.value;
  }

  protected const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let psmResult: StateResultBool = stateContext.GetTemporaryBoolParameter(n"OnUIContextInactive");
    return psmResult.value;
  }
}

public class UiRadialContextDecisions extends InputContextTransitionDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let psmResult: StateResultBool = stateContext.GetPermanentBoolParameter(n"UIRadialContextActive");
    return psmResult.value;
  }

  protected const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let psmResult: StateResultBool = stateContext.GetPermanentBoolParameter(n"UIRadialContextActive");
    return !psmResult.value;
  }
}

public class UiRadialContextEvents extends InputContextTransitionEvents {

  public let m_mouse: Vector4;

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let leftStick: Vector4;
    leftStick.X = scriptInterface.GetActionValue(n"UI_LookX_Axis");
    leftStick.Y = scriptInterface.GetActionValue(n"UI_LookY_Axis");
    if Vector4.Length(leftStick) <= 0.40 {
      leftStick = Vector4.EmptyVector();
      this.m_mouse.X += scriptInterface.GetActionValue(n"mouse_x") * timeDelta * 100.00;
      this.m_mouse.Y += scriptInterface.GetActionValue(n"mouse_y") * timeDelta * 100.00;
      this.m_mouse.X = ClampF(this.m_mouse.X, -1.00, 1.00);
      this.m_mouse.Y = ClampF(this.m_mouse.Y, -1.00, 1.00);
      if Vector4.Length(this.m_mouse) <= 0.40 {
        leftStick = Vector4.EmptyVector();
      } else {
        leftStick = Vector4.Normalize(this.m_mouse);
      };
    };
    this.SetUIBlackboardVector4Variable(scriptInterface, GetAllBlackboardDefs().UI_QuickSlotsData.leftStick, leftStick);
  }

  protected final func SetUIBlackboardVector4Variable(scriptInterface: ref<StateGameScriptInterface>, id: BlackboardID_Vector4, value: Vector4) -> Void {
    let blackboardSystem: ref<BlackboardSystem> = scriptInterface.GetBlackboardSystem();
    let blackboard: ref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    blackboard.SetVector4(id, value);
  }
}

public class UiQuickHackPanelContextDecisions extends InputContextTransitionDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsQuickHackPanelOpened(scriptInterface) {
      return true;
    };
    return false;
  }
}

public class UiQuickHackPanelContextEvents extends InputContextTransitionEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveAllInputHints(stateContext, scriptInterface);
  }
}

public class UiVendorContextDecisions extends InputContextTransitionDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let psmResult: StateResultBool = stateContext.GetTemporaryBoolParameter(n"OnUIVendorContextActive");
    return psmResult.value;
  }

  protected const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let vendorInactive: StateResultBool = stateContext.GetTemporaryBoolParameter(n"OnUIVendorContextInactive");
    return vendorInactive.value;
  }
}

public class UiPhoneContextDecisions extends InputContextTransitionDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let psmResult: StateResultBool = stateContext.GetTemporaryBoolParameter(n"OnUIContactListContextActive");
    return psmResult.value;
  }

  protected const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let psmResult: StateResultBool = stateContext.GetTemporaryBoolParameter(n"OnUIContactListContextInactive");
    return psmResult.value;
  }
}

public class LadderEnterContextDecisions extends InputContextTransitionDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return stateContext.GetBoolParameter(n"setLadderEnterInputContext", true);
  }
}

public class VehicleBlockInputContextEvents extends InputContextTransitionEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveAllInputHints(stateContext, scriptInterface);
  }
}

public class VehicleBlockInputContextDecisions extends InputContextTransitionDecisions {

  private let m_callbackID: ref<CallbackHandle>;

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions>;
    if IsDefined(scriptInterface.localBlackboard) {
      allBlackboardDef = GetAllBlackboardDefs();
      this.m_callbackID = scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Vehicle, this, n"OnVehicleStateChanged");
      this.OnVehicleStateChanged(scriptInterface.localBlackboard.GetInt(allBlackboardDef.PlayerStateMachine.Vehicle));
    };
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_callbackID = null;
  }

  protected cb func OnVehicleStateChanged(value: Int32) -> Bool {
    this.EnableOnEnterCondition(value == EnumInt(gamePSMVehicle.Transition));
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }
}

public class VehicleGameplayContextDecisions extends InputContextTransitionDecisions {

  private let m_callbackID: ref<CallbackHandle>;

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions>;
    if IsDefined(scriptInterface.localBlackboard) {
      allBlackboardDef = GetAllBlackboardDefs();
      this.m_callbackID = scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Vehicle, this, n"OnVehicleStateChanged");
      this.OnVehicleStateChanged(scriptInterface.localBlackboard.GetInt(allBlackboardDef.PlayerStateMachine.Vehicle));
    };
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_callbackID = null;
  }

  protected cb func OnVehicleStateChanged(value: Int32) -> Bool {
    this.EnableOnEnterCondition(value != EnumInt(gamePSMVehicle.Default));
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }
}

public class VehiclePassengerContextEvents extends InputContextTransitionEvents {

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.UpdatePassengerInputHints(stateContext, scriptInterface);
  }

  protected final func UpdatePassengerInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let currentState: Int32;
    if this.m_gameplaySettings.GetIsInputHintEnabled() {
      currentState = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle);
      if this.ShouldForceRefreshInputHints(stateContext, scriptInterface) && stateContext.GetBoolParameter(n"isPassengerInputHintDisplayed", true) {
        this.RemoveVehiclePassengerInputHints(stateContext, scriptInterface);
        return;
      };
      if stateContext.GetBoolParameter(n"doNotDisplayPassengerInputHint", true) || StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.VehicleCombatNoInterruptions") {
        if stateContext.GetBoolParameter(n"isPassengerInputHintDisplayed", true) {
          this.RemoveVehiclePassengerInputHints(stateContext, scriptInterface);
        };
        return;
      };
      if currentState != EnumInt(gamePSMVehicle.Scene) && !stateContext.GetBoolParameter(n"isPassengerInputHintDisplayed", true) && !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.VehicleCombatNoInterruptions") {
        this.ShowVehiclePassengerInputHints(stateContext, scriptInterface);
      } else {
        if currentState == EnumInt(gamePSMVehicle.Scene) && stateContext.GetBoolParameter(n"isPassengerInputHintDisplayed", true) {
          this.RemoveVehiclePassengerInputHints(stateContext, scriptInterface);
        };
      };
    };
  }

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let vehicle: wref<GameObject>;
    VehicleComponent.GetVehicle(scriptInterface.owner.GetGame(), scriptInterface.executionOwner, vehicle);
    if IsDefined(vehicle = vehicle as AVObject) {
      stateContext.SetPermanentBoolParameter(n"doNotDisplayPassengerInputHint", true, true);
    };
    this.ShowVehiclePassengerInputHints(stateContext, scriptInterface);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveVehiclePassengerInputHints(stateContext, scriptInterface);
    this.RemoveVehicleRadioInputHint(stateContext, scriptInterface);
    stateContext.RemovePermanentBoolParameter(n"doNotDisplayPassengerInputHint");
  }
}

public class VehiclePassengerContextDecisions extends VehicleGameplayContextDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }

  protected const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let currentState: Int32 = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle);
    if currentState == EnumInt(gamePSMVehicle.Default) {
      return true;
    };
    if currentState != EnumInt(gamePSMVehicle.Scene) && currentState != EnumInt(gamePSMVehicle.Passenger) {
      return true;
    };
    return false;
  }
}

public class VehicleNoDriveContextEvents extends InputContextTransitionEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveVehicleDriverInputHints(stateContext, scriptInterface);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ShowVehicleDriverInputHints(stateContext, scriptInterface);
  }
}

public class VehicleNoDriveContextDecisions extends InputContextTransitionDecisions {

  private let m_callbackID: ref<CallbackHandle>;

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions>;
    if IsDefined(scriptInterface.localBlackboard) {
      allBlackboardDef = GetAllBlackboardDefs();
      this.m_callbackID = scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Vehicle, this, n"OnVehicleStateChanged");
      this.OnVehicleStateChanged(scriptInterface.localBlackboard.GetInt(allBlackboardDef.PlayerStateMachine.Vehicle));
    };
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_callbackID = null;
  }

  protected cb func OnVehicleStateChanged(value: Int32) -> Bool {
    this.EnableOnEnterCondition(value == EnumInt(gamePSMVehicle.Driving));
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoDriving") {
      return true;
    };
    return false;
  }
}

public class VehicleQuestRestrictedContextDecisions extends InputContextTransitionDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"VehicleOnlyForward") {
      return true;
    };
    return false;
  }
}

public class VehicleQuestRestrictedContextEvents extends VehicleNoDriveContextEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ShowVehicleRestrictedInputHints(stateContext, scriptInterface);
    stateContext.SetPermanentBoolParameter(n"inVehicleRestrictState", true, true);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveVehicleRestrictedInputHints(stateContext, scriptInterface);
    stateContext.RemovePermanentBoolParameter(n"inVehicleRestrictState");
  }
}

public class VehicleTankDriverContextDecisions extends InputContextTransitionDecisions {

  private let m_callbackID: ref<CallbackHandle>;

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions>;
    if IsDefined(scriptInterface.localBlackboard) {
      allBlackboardDef = GetAllBlackboardDefs();
      this.m_callbackID = scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Vehicle, this, n"OnVehicleStateChanged");
      this.OnVehicleStateChanged(scriptInterface.localBlackboard.GetInt(allBlackboardDef.PlayerStateMachine.Vehicle));
    };
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_callbackID = null;
  }

  protected cb func OnVehicleStateChanged(value: Int32) -> Bool {
    this.EnableOnEnterCondition(value == EnumInt(gamePSMVehicle.Driving));
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let vehicle: wref<GameObject>;
    if !VehicleComponent.GetVehicle(scriptInterface.owner.GetGame(), scriptInterface.executionOwner, vehicle) {
      return false;
    };
    if (vehicle as TankObject) == null {
      return false;
    };
    return true;
  }
}

public class VehicleDriverContextEvents extends InputContextTransitionEvents {

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.UpdateVehicleDriverInputHints(stateContext, scriptInterface);
  }

  protected final func UpdateVehicleDriverInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.m_gameplaySettings.GetIsInputHintEnabled() {
      if this.ShouldForceRefreshInputHints(stateContext, scriptInterface) {
        this.RemoveVehicleDriverInputHints(stateContext, scriptInterface);
        this.UpdateRadioInputHint(stateContext, scriptInterface);
        return;
      };
      if !stateContext.GetBoolParameter(n"isDriverInputHintDisplayed", true) {
        this.ShowVehicleDriverInputHints(stateContext, scriptInterface);
        this.UpdateRadioInputHint(stateContext, scriptInterface);
      };
    };
  }

  protected final func UpdateRadioInputHint(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let isRadioBlocked: Bool = StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"VehicleBlockRadioInput");
    if !stateContext.GetBoolParameter(n"isVehicleRadioInputHintDisplayed", true) {
      if !isRadioBlocked {
        this.ShowVehicleRadioInputHint(stateContext, scriptInterface);
      };
    } else {
      this.RemoveVehicleRadioInputHint(stateContext, scriptInterface);
    };
  }

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ShowVehicleDriverInputHints(stateContext, scriptInterface);
    this.UpdateRadioInputHint(stateContext, scriptInterface);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveVehicleDriverInputHints(stateContext, scriptInterface);
    this.RemoveVehicleRadioInputHint(stateContext, scriptInterface);
  }
}

public class VehicleDriverContextDecisions extends InputContextTransitionDecisions {

  private let m_callbackID: ref<CallbackHandle>;

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions>;
    if IsDefined(scriptInterface.localBlackboard) {
      allBlackboardDef = GetAllBlackboardDefs();
      this.m_callbackID = scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Vehicle, this, n"OnVehicleStateChanged");
      this.OnVehicleStateChanged(scriptInterface.localBlackboard.GetInt(allBlackboardDef.PlayerStateMachine.Vehicle));
    };
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_callbackID = null;
  }

  protected cb func OnVehicleStateChanged(value: Int32) -> Bool {
    this.EnableOnEnterCondition(value == EnumInt(gamePSMVehicle.Driving));
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"VehicleOnlyForward") {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoDriving") {
      return false;
    };
    return true;
  }
}

public class VehicleDriverCombatContextEvents extends InputContextTransitionEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ShowVehicleDriverCombatInputHints(stateContext, scriptInterface);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveVehicleDriverCombatInputHints(stateContext, scriptInterface);
  }
}

public class VehicleDriverCombatContextDecisions extends InputContextTransitionDecisions {

  private let m_callbackID: ref<CallbackHandle>;

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions>;
    if IsDefined(scriptInterface.localBlackboard) {
      allBlackboardDef = GetAllBlackboardDefs();
      this.m_callbackID = scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Vehicle, this, n"OnVehicleStateChanged");
      this.OnVehicleStateChanged(scriptInterface.localBlackboard.GetInt(allBlackboardDef.PlayerStateMachine.Vehicle));
    };
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_callbackID = null;
  }

  protected cb func OnVehicleStateChanged(value: Int32) -> Bool {
    this.EnableOnEnterCondition(value == EnumInt(gamePSMVehicle.DriverCombat));
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"VehicleOnlyForward") {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoDriving") {
      return false;
    };
    return true;
  }
}

public class VehicleNoDriveCombatContextDecisions extends InputContextTransitionDecisions {

  private let m_callbackID: ref<CallbackHandle>;

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions>;
    if IsDefined(scriptInterface.localBlackboard) {
      allBlackboardDef = GetAllBlackboardDefs();
      this.m_callbackID = scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Vehicle, this, n"OnVehicleStateChanged");
      this.OnVehicleStateChanged(scriptInterface.localBlackboard.GetInt(allBlackboardDef.PlayerStateMachine.Vehicle));
    };
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_callbackID = null;
  }

  protected cb func OnVehicleStateChanged(value: Int32) -> Bool {
    this.EnableOnEnterCondition(value == EnumInt(gamePSMVehicle.DriverCombat));
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoDriving") {
      return true;
    };
    return false;
  }
}

public class VehicleCombatContextEvents extends InputContextTransitionEvents {

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.UpdateVehicleCombatInputHints(stateContext, scriptInterface);
  }

  protected final func UpdateVehicleCombatInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.m_gameplaySettings.GetIsInputHintEnabled() {
      if this.ShouldForceRefreshInputHints(stateContext, scriptInterface) {
        this.RemoveVehiclePassengerCombatInputHints(stateContext, scriptInterface);
      };
      if !stateContext.GetBoolParameter(n"isPassengerCombatInputHintDisplayed", true) {
        this.ShowVehiclePassengerCombatInputHints(stateContext, scriptInterface);
      };
    };
  }

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ShowVehiclePassengerCombatInputHints(stateContext, scriptInterface);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveVehiclePassengerCombatInputHints(stateContext, scriptInterface);
  }
}

public class VehicleCombatContextDecisions extends InputContextTransitionDecisions {

  private let m_callbackID: ref<CallbackHandle>;

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions>;
    if IsDefined(scriptInterface.localBlackboard) {
      allBlackboardDef = GetAllBlackboardDefs();
      this.m_callbackID = scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Vehicle, this, n"OnVehicleStateChanged");
      this.OnVehicleStateChanged(scriptInterface.localBlackboard.GetInt(allBlackboardDef.PlayerStateMachine.Vehicle));
    };
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_callbackID = null;
  }

  protected cb func OnVehicleStateChanged(value: Int32) -> Bool {
    this.EnableOnEnterCondition(value == EnumInt(gamePSMVehicle.Combat));
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }
}
