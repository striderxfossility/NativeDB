
public native class PanzerHUDGameController extends inkHUDGameController {

  private let m_vehicle: wref<VehicleObject>;

  private let m_vehiclePS: ref<VehicleComponentPS>;

  private edit let m_Date: inkTextRef;

  private edit let m_Timer: inkTextRef;

  private edit let healthStatus: inkTextRef;

  private edit let healthBar: inkWidgetRef;

  private let m_rightStickX: Float;

  private let m_rightStickY: Float;

  private edit let m_LeanAngleValue: inkCanvasRef;

  private edit let m_CoriRotation: inkCanvasRef;

  private edit let m_CompassRotation: inkCanvasRef;

  private edit let m_Cori_S: inkCanvasRef;

  private edit let m_Cori_M: inkCanvasRef;

  private edit let m_trimmerArrow: inkImageRef;

  private edit let m_SpeedValue: inkTextRef;

  private edit let m_RPMValue: inkTextRef;

  private let m_scanBlackboard: wref<IBlackboard>;

  private let m_psmBlackboard: wref<IBlackboard>;

  private let m_PSM_BBID: ref<CallbackHandle>;

  private let m_root: wref<inkCompoundWidget>;

  private let m_currentZoom: Float;

  private let currentTime: GameTime;

  private let m_vehicleBlackboard: wref<IBlackboard>;

  private let m_activeVehicleUIBlackboard: wref<IBlackboard>;

  private let m_vehicleBBStateConectionId: ref<CallbackHandle>;

  private let m_speedBBConnectionId: ref<CallbackHandle>;

  private let m_gearBBConnectionId: ref<CallbackHandle>;

  private let m_tppBBConnectionId: ref<CallbackHandle>;

  private let m_rpmValueBBConnectionId: ref<CallbackHandle>;

  private let m_leanAngleBBConnectionId: ref<CallbackHandle>;

  private let m_playerStateBBConnectionId: ref<CallbackHandle>;

  private let m_isTargetingFriendlyConnectionId: ref<CallbackHandle>;

  private let m_bbPlayerStats: wref<IBlackboard>;

  private let m_bbPlayerEventId: ref<CallbackHandle>;

  private let m_currentHealth: Int32;

  private let m_previousHealth: Int32;

  private let m_maximumHealth: Int32;

  private let m_quickhacksMemoryPercent: Float;

  private let m_playerObject: wref<GameObject>;

  private let m_weaponBlackboard: wref<IBlackboard>;

  private let m_weaponParamsListenerId: ref<CallbackHandle>;

  private let m_targetIndicators: array<TargetIndicatorEntry>;

  private edit let m_targetHolder: inkCompoundRef;

  @default(PanzerHUDGameController, Marker)
  private edit let m_targetWidgetLibraryName: CName;

  @default(PanzerHUDGameController, 10)
  private edit let m_targetWidgetPoolSize: Int32;

  protected cb func OnInitialize() -> Bool {
    let ownerObject: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    let playerPuppet: wref<GameObject> = this.GetOwnerEntity() as PlayerPuppet;
    let bbSys: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(playerPuppet.GetGame());
    this.m_psmBlackboard = this.GetPSMBlackboard(playerPuppet);
    this.m_playerObject = playerPuppet;
    let playerControlledObject: ref<GameObject> = this.GetPlayerControlledObject();
    playerControlledObject.RegisterInputListener(this, n"right_stick_x");
    playerControlledObject.RegisterInputListener(this, n"right_stick_y");
    this.m_scanBlackboard = bbSys.Get(GetAllBlackboardDefs().UI_Scanner);
    this.m_root = this.GetRootWidget() as inkCompoundWidget;
    this.m_root.SetVisible(false);
    this.m_vehicle = GetMountedVehicle(playerPuppet);
    this.m_vehiclePS = this.m_vehicle.GetVehiclePS();
    this.m_vehicleBlackboard = this.m_vehicle.GetBlackboard();
    this.m_activeVehicleUIBlackboard = bbSys.Get(GetAllBlackboardDefs().UI_ActiveVehicleData);
    this.m_bbPlayerStats = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_PlayerBioMonitor);
    this.m_bbPlayerEventId = this.m_bbPlayerStats.RegisterListenerVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.PlayerStatsInfo, this, n"OnStatsChanged");
    if IsDefined(this.m_psmBlackboard) {
      this.m_PSM_BBID = this.m_psmBlackboard.RegisterDelayedListenerFloat(GetAllBlackboardDefs().PlayerStateMachine.ZoomLevel, this, n"OnZoomChange");
      this.m_playerStateBBConnectionId = this.m_psmBlackboard.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle, this, n"OnPlayerVehicleStateChange", true);
    };
    if IsDefined(this.m_vehicleBlackboard) {
      this.m_vehicleBBStateConectionId = this.m_vehicleBlackboard.RegisterListenerInt(GetAllBlackboardDefs().Vehicle.VehicleState, this, n"OnVehicleStateChanged");
      this.m_speedBBConnectionId = this.m_vehicleBlackboard.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this, n"OnSpeedValueChanged");
      this.m_gearBBConnectionId = this.m_vehicleBlackboard.RegisterListenerInt(GetAllBlackboardDefs().Vehicle.GearValue, this, n"OnGearValueChanged");
      this.m_rpmValueBBConnectionId = this.m_vehicleBlackboard.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMValue, this, n"OnRpmValueChanged");
      this.m_leanAngleBBConnectionId = this.m_vehicleBlackboard.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.BikeTilt, this, n"OnLeanAngleChanged");
      this.m_isTargetingFriendlyConnectionId = this.m_vehicleBlackboard.RegisterListenerBool(GetAllBlackboardDefs().Vehicle.IsTargetingFriendly, this, n"OnIsTargetingFriendly");
    };
    this.currentTime = GameInstance.GetTimeSystem(ownerObject.GetGame()).GetGameTime();
    inkTextRef.SetText(this.m_Timer, ToString(GameTime.Hours(this.currentTime)) + ":" + ToString(GameTime.Minutes(this.currentTime)) + ":" + ToString(GameTime.Seconds(this.currentTime)));
    inkTextRef.SetText(this.m_Date, "05-13-2077");
    this.SpawnTargetIndicators();
    this.m_weaponBlackboard = bbSys.Get(GetAllBlackboardDefs().UI_ActiveWeaponData);
    if IsDefined(this.m_weaponBlackboard) {
      this.m_weaponParamsListenerId = this.m_weaponBlackboard.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_ActiveWeaponData.SmartGunParams, this, n"OnSmartGunParams");
    };
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_vehicleBlackboard) {
      this.m_vehicleBlackboard.UnregisterListenerInt(GetAllBlackboardDefs().Vehicle.VehicleState, this.m_vehicleBBStateConectionId);
      this.m_vehicleBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this.m_speedBBConnectionId);
      this.m_vehicleBlackboard.UnregisterListenerInt(GetAllBlackboardDefs().Vehicle.GearValue, this.m_gearBBConnectionId);
      this.m_vehicleBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMValue, this.m_rpmValueBBConnectionId);
      this.m_vehicleBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.BikeTilt, this.m_leanAngleBBConnectionId);
      this.m_vehicleBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().Vehicle.IsTargetingFriendly, this.m_isTargetingFriendlyConnectionId);
      this.m_activeVehicleUIBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UI_ActiveVehicleData.VehPlayerStateData, this.m_playerStateBBConnectionId);
    };
    if IsDefined(this.m_bbPlayerStats) {
      this.m_bbPlayerStats.UnregisterListenerVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.PlayerStatsInfo, this.m_bbPlayerEventId);
    };
    if IsDefined(this.m_weaponBlackboard) {
      this.m_weaponBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ActiveWeaponData.SmartGunParams, this.m_weaponParamsListenerId);
    };
    if IsDefined(this.m_psmBlackboard) {
      this.m_psmBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().PlayerStateMachine.ZoomLevel, this.m_PSM_BBID);
    };
    this.GetPlayerControlledObject().UnregisterInputListener(this, n"right_stick_x");
    this.GetPlayerControlledObject().UnregisterInputListener(this, n"right_stick_y");
  }

  protected cb func OnVehicleStateChanged(state: Int32) -> Bool {
    let vehicleState: vehicleEState = IntEnum(state);
    if this.m_vehiclePS.GetIsUiQuestModified() {
      return false;
    };
    if Equals(vehicleState, vehicleEState.On) {
      this.EvaluateUIState();
    };
    if Equals(vehicleState, vehicleEState.Default) {
      this.TurnOff();
    };
    if Equals(vehicleState, vehicleEState.Disabled) {
      this.TurnOff();
    };
    if Equals(vehicleState, vehicleEState.Destroyed) {
      this.TurnOff();
    };
  }

  protected cb func OnPlayerVehicleStateChange(value: Int32) -> Bool {
    this.EvaluateUIState();
  }

  private final func EvaluateUIState() -> Void {
    let playerState: gamePSMVehicle = IntEnum(this.m_psmBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle));
    let vehicleState: vehicleEState = IntEnum(this.m_vehicleBlackboard.GetInt(GetAllBlackboardDefs().Vehicle.VehicleState));
    if Equals(playerState, gamePSMVehicle.Driving) && Equals(vehicleState, vehicleEState.On) {
      if this.m_vehiclePS.GetIsUiQuestModified() {
        if this.m_vehiclePS.GetUiQuestState() {
          this.TurnOn();
        };
        return;
      };
      this.TurnOn();
    };
  }

  private final func TurnOn() -> Void {
    this.PlayLibraryAnimation(n"intro");
    this.TogglePanzerSpecificFX(true);
    this.m_root.SetVisible(true);
  }

  private final func TurnOff() -> Void {
    this.TogglePanzerSpecificFX(false);
    this.m_root.SetVisible(false);
  }

  protected cb func OnForwardVehicleQuestEnableUIEvent(evt: ref<ForwardVehicleQuestEnableUIEvent>) -> Bool {
    switch evt.mode {
      case vehicleQuestUIEnable.Gameplay:
        this.TurnOn();
        break;
      case vehicleQuestUIEnable.ForceEnable:
        this.TurnOn();
        break;
      case vehicleQuestUIEnable.ForceDisable:
        this.TurnOff();
    };
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if Equals(ListenerAction.GetType(action), gameinputActionType.AXIS_CHANGE) {
      if Equals(ListenerAction.GetName(action), n"right_stick_x") {
        this.m_rightStickX = ListenerAction.GetValue(action);
      } else {
        if Equals(ListenerAction.GetName(action), n"right_stick_y") {
          this.m_rightStickY = ListenerAction.GetValue(action);
        };
      };
    };
    inkWidgetRef.SetTranslation(this.m_Cori_S, this.m_rightStickX * 100.00, this.m_rightStickY * 61.00);
    inkWidgetRef.SetTranslation(this.m_Cori_M, this.m_rightStickX * 50.00, this.m_rightStickY * 30.50);
    inkWidgetRef.SetTranslation(this.m_trimmerArrow, this.m_rightStickX * 100.00, 0.00);
  }

  private final func TogglePanzerSpecificFX(toggle: Bool) -> Void {
    if this.m_vehicle == (this.m_vehicle as TankObject) {
      if toggle {
        GameObjectEffectHelper.StartEffectEvent(this.m_vehicle, n"terrain_scan", false);
      } else {
        GameObjectEffectHelper.BreakEffectLoopEvent(this.m_vehicle, n"terrain_scan");
      };
    };
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool;

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool;

  protected cb func OnZoomChange(evt: Float) -> Bool {
    this.m_currentZoom = evt;
  }

  protected cb func OnRpmMaxChanged(rpmMax: Float) -> Bool {
    inkTextRef.SetText(this.m_RPMValue, FloatToString(rpmMax));
  }

  protected cb func OnSpeedValueChanged(speedValue: Float) -> Bool {
    let value: String = FloatToStringPrec(AbsF(speedValue), 0);
    while StrLen(value) < 3 {
      value = "0" + value;
    };
    inkTextRef.SetText(this.m_SpeedValue, value);
  }

  protected cb func OnGearValueChanged(gearValue: Int32) -> Bool {
    if gearValue == 0 {
    };
  }

  protected cb func OnRpmValueChanged(rpmValue: Float) -> Bool {
    inkTextRef.SetText(this.m_RPMValue, FloatToString(rpmValue));
  }

  protected cb func OnLeanAngleChanged(leanAngle: Float) -> Bool {
    let forward: Vector4;
    let position: Vector4;
    let rotation: Float;
    let coriSmooth: Float = 0.15;
    let ownerObject: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    GameInstance.GetTargetingSystem(ownerObject.GetGame()).GetDefaultCrosshairData(GameInstance.GetPlayerSystem(ownerObject.GetGame()).GetLocalPlayerMainGameObject(), position, forward);
    rotation = Rad2Deg(AtanF(forward.X, forward.Y));
    inkWidgetRef.SetRotation(this.m_CompassRotation, -rotation);
    inkWidgetRef.SetRotation(this.m_LeanAngleValue, rotation);
    inkWidgetRef.SetRotation(this.m_CoriRotation, -leanAngle * coriSmooth);
    inkWidgetRef.SetRotation(this.m_LeanAngleValue, leanAngle);
  }

  protected cb func OnCameraModeChanged(mode: Bool) -> Bool;

  protected cb func OnStatsChanged(value: Variant) -> Bool {
    let incomingData: PlayerBioMonitor = FromVariant(value);
    this.m_previousHealth = this.m_currentHealth;
    this.m_maximumHealth = incomingData.maximumHealth;
    this.m_currentHealth = CeilF(GameInstance.GetStatPoolsSystem(this.m_playerObject.GetGame()).GetStatPoolValue(Cast(GetPlayer(this.m_playerObject.GetGame()).GetEntityID()), gamedataStatPoolType.Health, false));
    this.m_currentHealth = Clamp(this.m_currentHealth, 0, this.m_maximumHealth);
    let newX: Int32 = 670 - 670 - this.m_currentHealth * 67;
    inkWidgetRef.SetSize(this.healthBar, new Vector2(Cast(newX), 100.00));
    inkTextRef.SetText(this.healthStatus, IntToString(RoundF(Cast(this.m_currentHealth))) + "/" + IntToString(RoundF(Cast(this.m_maximumHealth))));
  }

  protected cb func OnIsTargetingFriendly(isTargetingFriendly: Bool) -> Bool {
    if isTargetingFriendly {
      this.PlayLibraryAnimation(n"friendlyHover");
    } else {
      this.PlayLibraryAnimation(n"friendlyHoverOut");
    };
  }

  private final func SpawnTargetIndicators() -> Void {
    let newEntry: TargetIndicatorEntry;
    let newTarget: wref<inkWidget>;
    let i: Int32 = 0;
    while i < this.m_targetWidgetPoolSize {
      newTarget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_targetHolder), this.m_targetWidgetLibraryName);
      newTarget.SetVisible(false);
      newEntry.indicator = newTarget;
      ArrayPush(this.m_targetIndicators, newEntry);
      i += 1;
    };
  }

  private final func EnableTargetIndicator(indicatorEntry: TargetIndicatorEntry, targetData: smartGunUITargetParameters) -> Void {
    let controller: wref<PanzerSmartWeaponTargetController>;
    let indicator: wref<inkWidget> = indicatorEntry.indicator;
    indicator.SetVisible(true);
    indicator.SetMargin(new inkMargin(targetData.pos.X * 0.50, targetData.pos.Y * 0.50, 0.00, 0.00));
    controller = indicator.GetController() as PanzerSmartWeaponTargetController;
    controller.SetData(targetData);
  }

  private final func DisableTargetIndicator(indicatorEntry: TargetIndicatorEntry) -> Void {
    let controller: wref<PanzerSmartWeaponTargetController>;
    let indicator: wref<inkWidget> = indicatorEntry.indicator;
    indicator.SetVisible(false);
    controller = indicator.GetController() as PanzerSmartWeaponTargetController;
    controller.StopAnimation();
  }

  protected cb func OnSmartGunParams(argParams: Variant) -> Bool {
    let currIndicator: TargetIndicatorEntry;
    let currTargetData: smartGunUITargetParameters;
    let currTargetID: EntityID;
    let freeIndicators: array<TargetIndicatorEntry>;
    let i: Int32;
    let j: Int32;
    let servicedTargets: array<Int32>;
    let smartData: ref<smartGunUIParameters> = FromVariant(argParams);
    let targetList: array<smartGunUITargetParameters> = smartData.targets;
    let numTargets: Int32 = ArraySize(targetList);
    let numIndicators: Int32 = ArraySize(this.m_targetIndicators);
    if numTargets > numIndicators {
      ArrayResize(targetList, numIndicators);
      numTargets = numIndicators;
    };
    freeIndicators = this.m_targetIndicators;
    i = 0;
    while i < numTargets {
      currTargetData = targetList[i];
      currTargetID = currTargetData.entityID;
      j = 0;
      while j < ArraySize(freeIndicators) {
        currIndicator = freeIndicators[j];
        if currTargetID == currIndicator.targetID {
          this.EnableTargetIndicator(currIndicator, currTargetData);
          ArrayPush(servicedTargets, i);
          ArrayRemove(freeIndicators, currIndicator);
        } else {
          j += 1;
        };
      };
      i += 1;
    };
    i = 0;
    while i < ArraySize(servicedTargets) {
      ArrayErase(targetList, ArrayPop(servicedTargets));
      i += 1;
    };
    numTargets = ArraySize(targetList);
    i = 0;
    while i < numTargets && ArraySize(freeIndicators) > 0 {
      this.EnableTargetIndicator(ArrayPop(freeIndicators), targetList[i]);
      i += 1;
    };
    i = 0;
    while i < ArraySize(freeIndicators) {
      this.DisableTargetIndicator(freeIndicators[i]);
      i += 1;
    };
  }
}

public class PanzerSmartWeaponTargetController extends inkLogicController {

  private edit let m_distanceText: inkTextRef;

  private let m_lockingAnimationProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.GetRootWidget().SetVisible(false);
  }

  public final func SetData(data: smartGunUITargetParameters) -> Void {
    let playbackOptions: inkAnimOptions;
    if Equals(data.state, gamesmartGunTargetState.Locking) {
      this.GetRootWidget().SetVisible(true);
      if !IsDefined(this.m_lockingAnimationProxy) {
        playbackOptions.dependsOnTimeDilation = true;
        this.m_lockingAnimationProxy = this.PlayLibraryAnimation(n"target", playbackOptions);
      };
    } else {
      this.GetRootWidget().SetVisible(Equals(data.state, gamesmartGunTargetState.Locked) || Equals(data.state, gamesmartGunTargetState.Unlocking));
      this.StopAnimation();
    };
    inkTextRef.SetText(this.m_distanceText, "Dis.\\n" + SpaceFill(IntToString(RoundMath(data.distance)), 2, ESpaceFillMode.JustifyRight, "0") + " m");
  }

  public final func StopAnimation() -> Void {
    if IsDefined(this.m_lockingAnimationProxy) {
      this.m_lockingAnimationProxy.GotoEndAndStop();
      this.m_lockingAnimationProxy = null;
    };
  }
}
