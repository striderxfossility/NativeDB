
public abstract class QuickSlotsTransition extends DefaultTransition {

  protected final func SetUIBlackboardBoolVariable(scriptInterface: ref<StateGameScriptInterface>, id: BlackboardID_Bool, value: Bool) -> Void {
    let blackboardSystem: ref<BlackboardSystem> = scriptInterface.GetBlackboardSystem();
    let blackboard: ref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    blackboard.SetBool(id, value);
  }

  protected final func SetUIBlackboardFloatVariable(scriptInterface: ref<StateGameScriptInterface>, id: BlackboardID_Float, value: Float) -> Void {
    let blackboardSystem: ref<BlackboardSystem> = scriptInterface.GetBlackboardSystem();
    let blackboard: ref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    blackboard.SetFloat(id, value);
  }

  protected final func SetUIBlackboardIntVariable(scriptInterface: ref<StateGameScriptInterface>, id: BlackboardID_Int, value: Int32) -> Void {
    let blackboardSystem: ref<BlackboardSystem> = scriptInterface.GetBlackboardSystem();
    let blackboard: ref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    blackboard.SetInt(id, value);
  }

  protected final func SetUIBlackboardVector4Variable(scriptInterface: ref<StateGameScriptInterface>, id: BlackboardID_Vector4, value: Vector4) -> Void {
    let blackboardSystem: ref<BlackboardSystem> = scriptInterface.GetBlackboardSystem();
    let blackboard: ref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    blackboard.SetVector4(id, value);
  }

  protected final func GetQuickSlotsManager(scriptInterface: ref<StateGameScriptInterface>) -> ref<QuickSlotsManager> {
    return (scriptInterface.owner as PlayerPuppet).GetQuickSlotsManager();
  }

  protected final const func CheckForAnyItemInEquipmentArea(const scriptInterface: ref<StateGameScriptInterface>, areaType: gamedataEquipmentArea) -> Bool {
    return EquipmentSystem.GetData(scriptInterface.executionOwner).GetNumberOfItemsInEquipmentArea(areaType) > 0;
  }

  protected final const func HasAnyVehiclesUnlocked(const scriptInterface: ref<StateGameScriptInterface>) -> Int32 {
    let playerVehicleList: array<PlayerVehicle>;
    let vehicleSystem: ref<VehicleSystem> = GameInstance.GetVehicleSystem(scriptInterface.GetGame());
    vehicleSystem.GetPlayerUnlockedVehicles(playerVehicleList);
    return ArraySize(playerVehicleList);
  }

  protected final const func DoesVehicleSupportRadio(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let vehObject: wref<VehicleObject>;
    VehicleComponent.GetVehicle(scriptInterface.GetGame(), scriptInterface.executionOwnerEntityID, vehObject);
    if vehObject != (vehObject as CarObject) && vehObject != (vehObject as BikeObject) {
      return false;
    };
    return true;
  }

  protected final const func CheckNoRadialMenusRestriction(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoRadialMenus");
  }

  protected final const func CheckVehicleSummonigRestriction(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"VehicleSummoning");
  }

  protected final const func IsPlayerInWheelBlockingWorkspot(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return stateContext.IsStateActive(n"Locomotion", n"workspot") && DefaultTransition.GetPlayerPuppet(scriptInterface).PlayerContainsWorkspotTag(n"BlockRadialWheels");
  }

  protected final const func IsVehicleDriverAllowedToSelectWeapons(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if stateContext.IsStateActive(n"Vehicle", n"drive") && !VehicleTransition.CanEnterDriverCombat() {
      return false;
    };
    return true;
  }

  protected final const func IsplayerInStateAllowedToSelectWeapons(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let ladderState: CName;
    if stateContext.IsStateMachineActive(n"LocomotionSwimming") {
      return false;
    };
    ladderState = stateContext.GetStateMachineCurrentState(n"Locomotion");
    if Equals(ladderState, n"ladder") || Equals(ladderState, n"ladderSprint") || Equals(ladderState, n"ladderSlide") {
      return false;
    };
    return true;
  }
}

public abstract class QuickSlotsHoldDecisions extends QuickSlotsDecisions {

  public func ToQuickSlotsReady(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let hasCancelled: Bool = stateContext.GetBoolParameter(n"RadialWheelCloseRequest");
    if scriptInterface.GetActionValue(n"CameraAim") > 0.00 {
      this.SoftBlockAimingForTime(stateContext, scriptInterface, 0.10);
    };
    if hasCancelled || stateContext.IsStateActive(n"Vehicle", n"exitingCombat") {
      stateContext.SetTemporaryFloatParameter(n"rightStickAngle", -1.00, true);
    };
    return hasCancelled || this.IsPlayerInAnyMenu(scriptInterface);
  }

  public func ToQuickSlotsBusy(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.IsActionJustReleased(n"SelectWheelItem") {
      return true;
    };
    return false;
  }
}

public abstract class QuickSlotsHoldEvents extends QuickSlotsEvents {

  public let m_holdDirection: EDPadSlot;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetUIBlackboardBoolVariable(scriptInterface, GetAllBlackboardDefs().UI_QuickSlotsData.UIRadialContextRequest, true);
    stateContext.SetPermanentBoolParameter(n"UIRadialContextActive", true, true);
    this.NotifyQuickSlotsManagerButtonHoldStart(scriptInterface, this.m_holdDirection);
    stateContext.SetTemporaryFloatParameter(n"rightStickAngle", -1.00, true);
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let stickAngle: Float = this.GetStickAngle(stateContext.GetTemporaryFloatParameter(n"rightStickAngle"), scriptInterface);
    this.SetUIBlackboardFloatVariable(scriptInterface, GetAllBlackboardDefs().UI_QuickSlotsData.UIRadialContextRightStickAngle, stickAngle);
    stateContext.SetTemporaryFloatParameter(n"rightStickAngle", stickAngle, true);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;

  protected final func NotifyQuickSlotsManagerButtonHoldStart(scriptInterface: ref<StateGameScriptInterface>, dPadItemDirection: EDPadSlot) -> Void {
    let evt: ref<QuickSlotButtonHoldStartEvent> = new QuickSlotButtonHoldStartEvent();
    evt.dPadItemDirection = dPadItemDirection;
    scriptInterface.owner.QueueEvent(evt);
  }

  protected final func NotifyQuickSlotsManagerButtonHoldEnd(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, dPadItemDirection: EDPadSlot, tryExecuteCommand: Bool) -> Void {
    let stateFloat: StateResultFloat = stateContext.GetTemporaryFloatParameter(n"rightStickAngle");
    let evt: ref<QuickSlotButtonHoldEndEvent> = new QuickSlotButtonHoldEndEvent();
    evt.dPadItemDirection = dPadItemDirection;
    evt.rightStickAngle = stateFloat.value;
    evt.tryExecuteCommand = tryExecuteCommand;
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoRadialMenus") {
      stateContext.SetTemporaryFloatParameter(n"rightStickAngle", -1.00, true);
      this.SetUIBlackboardFloatVariable(scriptInterface, GetAllBlackboardDefs().UI_QuickSlotsData.UIRadialContextRightStickAngle, -1.00);
      evt.rightStickAngle = -1.00;
      evt.tryExecuteCommand = false;
    };
    scriptInterface.owner.QueueEvent(evt);
  }

  protected final func GetRightStickAngle(stateFloat: StateResultFloat, scriptInterface: ref<StateGameScriptInterface>) -> Float {
    if AbsF(scriptInterface.GetActionValue(n"UI_MoveX_Axis")) + AbsF(scriptInterface.GetActionValue(n"UI_MoveY_Axis")) < this.GetStaticFloatParameterDefault("deadZone", 0.40) {
      return stateFloat.value;
    };
    return Rad2Deg(AtanF(scriptInterface.GetActionValue(n"UI_MoveX_Axis"), scriptInterface.GetActionValue(n"UI_MoveY_Axis"))) + 180.00;
  }

  protected final func GetLeftStickAngle(stateFloat: StateResultFloat, scriptInterface: ref<StateGameScriptInterface>) -> Float {
    if AbsF(scriptInterface.GetActionValue(n"UI_LookX_Axis")) + AbsF(scriptInterface.GetActionValue(n"UI_LookY_Axis")) < this.GetStaticFloatParameterDefault("deadZone", 0.40) {
      return stateFloat.value;
    };
    return Rad2Deg(AtanF(scriptInterface.GetActionValue(n"UI_LookX_Axis"), scriptInterface.GetActionValue(n"UI_LookY_Axis"))) + 180.00;
  }

  protected final func GetStickAngle(stateFloat: StateResultFloat, scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let leftStickInDeadZone: Bool = AbsF(scriptInterface.GetActionValue(n"UI_LookX_Axis")) + AbsF(scriptInterface.GetActionValue(n"UI_LookY_Axis")) < this.GetStaticFloatParameterDefault("deadZone", 0.40);
    let rightStickInDeadZone: Bool = AbsF(scriptInterface.GetActionValue(n"UI_MoveX_Axis")) + AbsF(scriptInterface.GetActionValue(n"UI_MoveY_Axis")) < this.GetStaticFloatParameterDefault("deadZone", 0.40);
    if leftStickInDeadZone && rightStickInDeadZone {
      return stateFloat.value;
    };
    if !leftStickInDeadZone {
      return Rad2Deg(AtanF(scriptInterface.GetActionValue(n"UI_LookX_Axis"), scriptInterface.GetActionValue(n"UI_LookY_Axis"))) + 180.00;
    };
    if !rightStickInDeadZone {
      return Rad2Deg(AtanF(scriptInterface.GetActionValue(n"UI_MoveX_Axis"), scriptInterface.GetActionValue(n"UI_MoveY_Axis"))) + 180.00;
    };
    return -1.00;
  }
}

public abstract class QuickSlotsTapDecisions extends QuickSlotsDecisions {

  public const func ToQuickSlotsReady(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetInStateTime() > this.GetStaticFloatParameterDefault("durationTime", 2.00);
  }

  public const func ToQuickSlotsBusy(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetInStateTime() > this.GetStaticFloatParameterDefault("singleTapStayTime", 0.50);
  }
}

public abstract class QuickSlotsTapEvents extends QuickSlotsEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;

  protected final func CallActionRequest(scriptInterface: ref<StateGameScriptInterface>, actionType: QuickSlotActionType) -> Void {
    let evt: ref<CallAction> = new CallAction();
    evt.calledAction = actionType;
    scriptInterface.owner.QueueEvent(evt);
  }
}

public class QuickSlotsReadyDecisions extends QuickSlotsDecisions {

  public final const func ToQuickSlotsBusy(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetInStateTime() > this.GetStaticFloatParameterDefault("durationTime", 2.00);
  }
}

public class QuickSlotsReadyEvents extends QuickSlotsEvents {

  @default(QuickSlotsReadyEvents, true)
  public let shouldSendEvent: Bool;

  public let timePressed: Float;

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetUIBlackboardBoolVariable(scriptInterface, GetAllBlackboardDefs().UI_QuickSlotsData.UIRadialContextRequest, false);
    stateContext.SetPermanentBoolParameter(n"UIRadialContextActive", false, true);
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let dpadAction: ref<DPADActionPerformed>;
    let value: Float;
    if scriptInterface.IsActionJustHeld(n"CallVehicle") {
      dpadAction = new DPADActionPerformed();
      dpadAction.action = EHotkey.DPAD_RIGHT;
      dpadAction.successful = true;
      dpadAction.state = EUIActionState.COMPLETED;
      scriptInterface.GetUISystem().QueueEvent(dpadAction);
      this.shouldSendEvent = true;
      return;
    };
    value = scriptInterface.GetActionValue(n"CallVehicle");
    if value > 0.00 {
      this.timePressed += timeDelta;
      if this.timePressed > 0.10 && this.shouldSendEvent {
        dpadAction = new DPADActionPerformed();
        dpadAction.action = EHotkey.DPAD_RIGHT;
        dpadAction.successful = true;
        dpadAction.state = EUIActionState.STARTED;
        scriptInterface.GetUISystem().QueueEvent(dpadAction);
        this.shouldSendEvent = false;
      };
      return;
    };
    if this.timePressed > 0.00 && value == 0.00 {
      this.timePressed = 0.00;
      dpadAction = new DPADActionPerformed();
      dpadAction.action = EHotkey.DPAD_RIGHT;
      dpadAction.successful = false;
      dpadAction.state = EUIActionState.ABORTED;
      scriptInterface.GetUISystem().QueueEvent(dpadAction);
    };
    this.shouldSendEvent = true;
  }
}

public class OnlyVehicleDecisions extends QuickSlotsReadyDecisions {

  private let m_executionOwner: wref<GameObject>;

  private let m_statusEffectListener: ref<DefaultTransitionStatusEffectListener>;

  private let m_hasStatusEffect: Bool;

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_statusEffectListener = new DefaultTransitionStatusEffectListener();
    this.m_statusEffectListener.m_transitionOwner = this;
    scriptInterface.GetStatusEffectSystem().RegisterListener(scriptInterface.owner.GetEntityID(), this.m_statusEffectListener);
    this.m_executionOwner = scriptInterface.executionOwner;
    this.UpdateHasStatusEffect();
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_statusEffectListener = null;
  }

  public func OnStatusEffectApplied(statusEffect: wref<StatusEffect_Record>) -> Void {
    if !this.m_hasStatusEffect {
      if statusEffect.GameplayTagsContains(n"VehicleSummoning") {
        this.m_hasStatusEffect = true;
        this.EnableOnEnterCondition(true);
      };
    };
  }

  public func OnStatusEffectRemoved(statusEffect: wref<StatusEffect_Record>) -> Void {
    if this.m_hasStatusEffect {
      if statusEffect.GameplayTagsContains(n"VehicleSummoning") {
        this.UpdateHasStatusEffect();
      };
    };
  }

  protected final func UpdateHasStatusEffect() -> Void {
    this.m_hasStatusEffect = StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_executionOwner, n"VehicleSummoning");
    this.EnableOnEnterCondition(this.m_hasStatusEffect);
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }

  public final const func ToQuickSlotsReady(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"VehicleSummoning") {
      return true;
    };
    return false;
  }
}

public class QuickSlotsBusyDecisions extends QuickSlotsDecisions {

  public final const func ToQuickSlotsReady(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetInStateTime() > this.GetStaticFloatParameterDefault("busyDuration", 2.00);
  }
}

public class QuickSlotsBusyEvents extends QuickSlotsEvents {

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;
}

public class QuickSlotsDisabledDecisions extends QuickSlotsDecisions {

  private let m_executionOwner: wref<GameObject>;

  private let m_statusEffectListener: ref<DefaultTransitionStatusEffectListener>;

  private let m_hasStatusEffect: Bool;

  protected final const func ShouldDisableRadialForReplacer(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let playerStatsBB: ref<IBlackboard> = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_PlayerStats);
    return playerStatsBB.GetBool(GetAllBlackboardDefs().UI_PlayerStats.isReplacer) && !scriptInterface.executionOwner.IsVRReplacer();
  }

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_statusEffectListener = new DefaultTransitionStatusEffectListener();
    this.m_statusEffectListener.m_transitionOwner = this;
    scriptInterface.GetStatusEffectSystem().RegisterListener(scriptInterface.owner.GetEntityID(), this.m_statusEffectListener);
    this.m_executionOwner = scriptInterface.executionOwner;
    this.UpdateHasStatusEffect();
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_statusEffectListener = null;
  }

  public func OnStatusEffectApplied(statusEffect: wref<StatusEffect_Record>) -> Void {
    if !this.m_hasStatusEffect {
      if statusEffect.GameplayTagsContains(n"VehicleSummoning") {
        this.m_hasStatusEffect = true;
        this.EnableOnEnterCondition(false);
      };
    };
  }

  public func OnStatusEffectRemoved(statusEffect: wref<StatusEffect_Record>) -> Void {
    if this.m_hasStatusEffect {
      if statusEffect.GameplayTagsContains(n"VehicleSummoning") {
        this.UpdateHasStatusEffect();
      };
    };
  }

  protected final func UpdateHasStatusEffect() -> Void {
    this.m_hasStatusEffect = StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_executionOwner, n"VehicleSummoning");
    this.EnableOnEnterCondition(!this.m_hasStatusEffect);
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.SceneTier) >= this.GetStaticIntParameterDefault("minBlockedSceneTier", 2) || scriptInterface.IsPlayerInBraindance() || this.ShouldDisableRadialForReplacer(scriptInterface) || scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vitals) == EnumInt(gamePSMVitals.Dead) || this.IsPlayerInWheelBlockingWorkspot(stateContext, scriptInterface) || StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"FastForward");
  }

  public final const func ToQuickSlotsReady(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"VehicleSummoning") {
      return true;
    };
    return scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.SceneTier) < this.GetStaticIntParameterDefault("minBlockedSceneTier", 2) && !scriptInterface.IsPlayerInBraindance() && !this.ShouldDisableRadialForReplacer(scriptInterface) && scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vitals) != EnumInt(gamePSMVitals.Dead) && !this.IsPlayerInWheelBlockingWorkspot(stateContext, scriptInterface) && !StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"FastForward");
  }

  public final const func ToCycleObjective(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustReleased(n"CycleObjectives");
  }
}

public class QuickSlotsDisabledEvents extends QuickSlotsEvents {

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetUIBlackboardBoolVariable(scriptInterface, GetAllBlackboardDefs().UI_QuickSlotsData.UIRadialContextRequest, false);
    stateContext.SetPermanentBoolParameter(n"UIRadialContextActive", false, true);
    this.ForceDisableRadialWheel(scriptInterface);
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let dpadAction: ref<DPADActionPerformed>;
    if scriptInterface.IsActionJustReleased(n"CallVehicle") {
      dpadAction = new DPADActionPerformed();
      dpadAction.action = EHotkey.DPAD_RIGHT;
      scriptInterface.GetUISystem().QueueEvent(dpadAction);
    };
  }
}

public class CycleObjectiveDecisions extends QuickSlotsTapDecisions {

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.RegisterInputListener(this, n"CycleObjectives");
    this.EnableOnEnterCondition(false);
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.UnregisterInputListener(this);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if ListenerAction.IsButtonJustReleased(action) {
      this.EnableOnEnterCondition(true);
    };
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    this.EnableOnEnterCondition(false);
    return scriptInterface.GetActionPrevStateTime(n"CycleObjectives") < this.GetStaticFloatParameterDefault("timeToWheel", 0.40);
  }
}

public class CycleObjectiveEvents extends QuickSlotsTapEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    GameInstance.GetJournalManager(scriptInterface.GetGame()).TrackPrevNextEntry(true);
  }
}

public class WeaponWheelDecisions extends QuickSlotsHoldDecisions {

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.RegisterInputListener(this, n"WeaponWheel");
    this.EnableOnEnterCondition(scriptInterface.IsActionJustHeld(n"WeaponWheel"));
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.UnregisterInputListener(this);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if ListenerAction.IsButtonJustPressed(action) {
      this.EnableOnEnterCondition(true);
    };
    if ListenerAction.IsButtonJustReleased(action) {
      this.EnableOnEnterCondition(false);
    };
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustHeld(n"WeaponWheel") && !StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoRadialMenus") && !StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoWeaponWheel") && !this.IsPlayingAsReplacer(scriptInterface) && !stateContext.IsStateMachineActive(n"CombatGadget") && !stateContext.IsStateMachineActive(n"Consumable") && NotEquals(stateContext.GetStateMachineCurrentState(n"Vehicle"), n"entering") && NotEquals(stateContext.GetStateMachineCurrentState(n"Vehicle"), n"switchSeats") && !this.IsVehicleBlockingCombat(scriptInterface) && this.IsVehicleDriverAllowedToSelectWeapons(stateContext, scriptInterface) && this.IsplayerInStateAllowedToSelectWeapons(stateContext, scriptInterface);
  }
}

public class VehicleWheelDecisions extends QuickSlotsHoldDecisions {

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.RegisterInputListener(this, n"CallVehicle");
    this.EnableOnEnterCondition(scriptInterface.IsActionJustHeld(n"CallVehicle"));
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.UnregisterInputListener(this);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if ListenerAction.IsButtonJustPressed(action) {
      this.EnableOnEnterCondition(true);
    };
    if ListenerAction.IsButtonJustReleased(action) {
      this.EnableOnEnterCondition(false);
    };
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustHeld(n"CallVehicle") && !VehicleSystem.IsSummoningVehiclesRestricted(scriptInterface.GetGame());
  }

  public func ToQuickSlotsReady(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if VehicleSystem.IsSummoningVehiclesRestricted(scriptInterface.GetGame()) {
      return true;
    };
    return this.ToQuickSlotsReady(stateContext, scriptInterface);
  }
}

public class VehicleInsideWheelDecisions extends QuickSlotsHoldDecisions {

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.RegisterInputListener(this, n"VehicleInsideWheel");
    this.EnableOnEnterCondition(scriptInterface.IsActionJustHeld(n"VehicleInsideWheel"));
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.UnregisterInputListener(this);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if ListenerAction.IsButtonJustPressed(action) {
      this.EnableOnEnterCondition(true);
    };
    if ListenerAction.IsButtonJustReleased(action) {
      this.EnableOnEnterCondition(false);
    };
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustHeld(n"VehicleInsideWheel") && !StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"VehicleBlockRadioInput") && this.DoesVehicleSupportRadio(scriptInterface) && scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle) > EnumInt(gamePSMVehicle.Default);
  }

  protected func ToQuickSlotsReady(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.ToQuickSlotsReady(stateContext, scriptInterface);
  }
}

public class VehicleWheelEvents extends QuickSlotsHoldEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_holdDirection = EDPadSlot.VehicleWheel;
    this.OnEnter(stateContext, scriptInterface);
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
  }

  protected final func OnExitToQuickSlotsBusy(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.NotifyQuickSlotsManagerButtonHoldEnd(stateContext, scriptInterface, this.m_holdDirection, true);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.NotifyQuickSlotsManagerButtonHoldEnd(stateContext, scriptInterface, this.m_holdDirection, false);
  }
}

public class VehicleInsideWheelEvents extends QuickSlotsHoldEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_holdDirection = EDPadSlot.VehicleInsideWheel;
    this.OnEnter(stateContext, scriptInterface);
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
  }

  protected final func OnExitToQuickSlotsBusy(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.NotifyQuickSlotsManagerButtonHoldEnd(stateContext, scriptInterface, this.m_holdDirection, true);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.NotifyQuickSlotsManagerButtonHoldEnd(stateContext, scriptInterface, this.m_holdDirection, false);
  }
}

public class WeaponWheelEvents extends QuickSlotsHoldEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_holdDirection = EDPadSlot.WeaponsWheel;
    this.OnEnter(stateContext, scriptInterface);
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
  }

  protected final func OnExitToQuickSlotsBusy(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.NotifyQuickSlotsManagerButtonHoldEnd(stateContext, scriptInterface, this.m_holdDirection, true);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.NotifyQuickSlotsManagerButtonHoldEnd(stateContext, scriptInterface, this.m_holdDirection, false);
  }
}
