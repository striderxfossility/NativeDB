
public class vehicleUIGameController extends inkHUDGameController {

  private let m_vehicleBlackboard: wref<IBlackboard>;

  private let m_vehicle: wref<VehicleObject>;

  private let m_vehiclePS: ref<VehicleComponentPS>;

  private let m_vehicleBBStateConectionId: ref<CallbackHandle>;

  private let m_vehicleCollisionBBStateID: ref<CallbackHandle>;

  private let m_vehicleBBUIActivId: ref<CallbackHandle>;

  private let m_rootWidget: wref<inkWidget>;

  private let m_UIEnabled: Bool;

  private let m_startAnimProxy: ref<inkAnimProxy>;

  private let m_loopAnimProxy: ref<inkAnimProxy>;

  private let m_endAnimProxy: ref<inkAnimProxy>;

  private let m_loopingBootProxy: ref<inkAnimProxy>;

  private edit let m_speedometerWidget: inkWidgetRef;

  private edit let m_tachometerWidget: inkWidgetRef;

  private edit let m_timeWidget: inkWidgetRef;

  private edit let m_instruments: inkWidgetRef;

  private edit let m_gearBox: inkWidgetRef;

  private edit let m_radio: inkWidgetRef;

  private edit let m_analogTachWidget: inkWidgetRef;

  private edit let m_analogSpeedWidget: inkWidgetRef;

  private let m_isVehicleReady: Bool;

  private final func SetupModule(widget: inkWidgetRef, vehicle: wref<VehicleObject>, vehBB: wref<IBlackboard>) -> Void {
    let moduleController: wref<IVehicleModuleController>;
    if !inkWidgetRef.IsValid(widget) {
      return;
    };
    moduleController = inkWidgetRef.GetController(widget) as IVehicleModuleController;
    if moduleController == null {
      return;
    };
    moduleController.RegisterCallbacks(vehicle, vehBB, this);
  }

  private final func UnregisterModule(widget: inkWidgetRef) -> Void {
    let moduleController: wref<IVehicleModuleController>;
    if !inkWidgetRef.IsValid(widget) {
      return;
    };
    moduleController = inkWidgetRef.GetController(widget) as IVehicleModuleController;
    if moduleController == null {
      return;
    };
    moduleController.UnregisterCallbacks();
  }

  protected cb func OnInitialize() -> Bool {
    this.m_vehicle = this.GetOwnerEntity() as VehicleObject;
    this.m_vehiclePS = this.m_vehicle.GetVehiclePS();
    this.m_rootWidget = this.GetRootWidget();
    this.m_vehicleBlackboard = this.m_vehicle.GetBlackboard();
    if this.IsUIactive() {
      this.ActivateUI();
    };
    if IsDefined(this.m_vehicleBlackboard) {
      if !IsDefined(this.m_vehicleBBUIActivId) {
        this.m_vehicleBBUIActivId = this.m_vehicleBlackboard.RegisterListenerBool(GetAllBlackboardDefs().Vehicle.IsUIActive, this, n"OnActivateUI");
      };
    };
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_vehicleBBUIActivId) {
      this.m_vehicleBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().Vehicle.IsUIActive, this.m_vehicleBBUIActivId);
    };
    this.UnregisterBlackBoardCallbacks();
  }

  private final func ActivateUI() -> Void {
    this.m_rootWidget.SetVisible(true);
    this.RegisterBlackBoardCallbacks();
    this.CheckIfVehicleShouldTurnOn();
  }

  private final func DeactivateUI() -> Void {
    this.UnregisterBlackBoardCallbacks();
    this.m_rootWidget.SetVisible(false);
  }

  protected cb func OnActivateUI(activate: Bool) -> Bool {
    let evt: ref<VehicleUIactivateEvent> = new VehicleUIactivateEvent();
    if activate {
      evt.m_activate = true;
    } else {
      evt.m_activate = false;
    };
    this.QueueEvent(evt);
  }

  protected cb func OnActivateUIEvent(evt: ref<VehicleUIactivateEvent>) -> Bool {
    if evt.m_activate {
      this.ActivateUI();
    } else {
      this.DeactivateUI();
    };
  }

  protected cb func OnVehicleReady(ready: Bool) -> Bool {
    if ready {
      this.m_rootWidget.SetVisible(true);
    } else {
      if !ready {
        this.m_rootWidget.SetVisible(false);
      };
    };
    this.m_isVehicleReady = ready;
  }

  private final func RegisterBlackBoardCallbacks() -> Void {
    if IsDefined(this.m_vehicleBlackboard) {
      this.SetupModule(this.m_speedometerWidget, this.m_vehicle, this.m_vehicleBlackboard);
      this.SetupModule(this.m_tachometerWidget, this.m_vehicle, this.m_vehicleBlackboard);
      this.SetupModule(this.m_timeWidget, this.m_vehicle, this.m_vehicleBlackboard);
      this.SetupModule(this.m_instruments, this.m_vehicle, this.m_vehicleBlackboard);
      this.SetupModule(this.m_gearBox, this.m_vehicle, this.m_vehicleBlackboard);
      this.SetupModule(this.m_radio, this.m_vehicle, this.m_vehicleBlackboard);
      this.SetupModule(this.m_analogTachWidget, this.m_vehicle, this.m_vehicleBlackboard);
      this.SetupModule(this.m_analogSpeedWidget, this.m_vehicle, this.m_vehicleBlackboard);
      if !IsDefined(this.m_vehicleBBStateConectionId) {
        this.m_vehicleBBStateConectionId = this.m_vehicleBlackboard.RegisterListenerInt(GetAllBlackboardDefs().Vehicle.VehicleState, this, n"OnVehicleStateChanged");
      };
      if !IsDefined(this.m_vehicleCollisionBBStateID) {
        this.m_vehicleCollisionBBStateID = this.m_vehicleBlackboard.RegisterListenerBool(GetAllBlackboardDefs().Vehicle.Collision, this, n"OnVehicleCollision");
      };
      this.InitializeWidgetStyleSheet(this.m_vehicle);
    };
  }

  private final func UnregisterBlackBoardCallbacks() -> Void {
    if IsDefined(this.m_vehicleBlackboard) {
      this.UnregisterModule(this.m_speedometerWidget);
      this.UnregisterModule(this.m_tachometerWidget);
      this.UnregisterModule(this.m_timeWidget);
      this.UnregisterModule(this.m_instruments);
      this.UnregisterModule(this.m_gearBox);
      this.UnregisterModule(this.m_analogTachWidget);
      this.UnregisterModule(this.m_analogSpeedWidget);
      if IsDefined(this.m_vehicleBBStateConectionId) {
        this.m_vehicleBlackboard.UnregisterListenerInt(GetAllBlackboardDefs().Vehicle.VehicleState, this.m_vehicleBBStateConectionId);
      };
      if IsDefined(this.m_vehicleCollisionBBStateID) {
        this.m_vehicleBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().Vehicle.Collision, this.m_vehicleCollisionBBStateID);
      };
    };
  }

  private final func IsUIactive() -> Bool {
    if IsDefined(this.m_vehicleBlackboard) && this.m_vehicleBlackboard.GetBool(GetAllBlackboardDefs().Vehicle.IsUIActive) {
      return true;
    };
    return false;
  }

  private final func InitializeWidgetStyleSheet(veh: wref<VehicleObject>) -> Void {
    let record: wref<Vehicle_Record> = veh.GetRecord();
    let styleSheetPath: ResRef = record.WidgetStyleSheetPath();
    this.m_rootWidget.SetStyle(styleSheetPath);
  }

  private final func CheckIfVehicleShouldTurnOn() -> Void {
    if this.m_vehiclePS.GetIsUiQuestModified() {
      if this.m_vehiclePS.GetUiQuestState() {
        this.TurnOn();
      };
      return;
    };
    if this.m_vehicleBlackboard.GetInt(GetAllBlackboardDefs().Vehicle.VehicleState) == EnumInt(vehicleEState.On) {
      this.TurnOn();
    };
  }

  protected cb func OnVehicleStateChanged(state: Int32) -> Bool {
    if this.m_vehiclePS.GetIsUiQuestModified() {
      return false;
    };
    if state == EnumInt(vehicleEState.On) {
      this.TurnOn();
    };
    if state == EnumInt(vehicleEState.Default) {
      this.TurnOff();
    };
    if state == EnumInt(vehicleEState.Disabled) {
      this.TurnOff();
    };
    if state == EnumInt(vehicleEState.Destroyed) {
      this.TurnOff();
    };
  }

  private final func TurnOn() -> Void {
    this.KillBootupProxy();
    if this.m_UIEnabled {
      this.PlayIdleLoop();
    } else {
      this.m_UIEnabled = true;
      this.m_startAnimProxy = this.PlayLibraryAnimation(n"start");
      this.m_startAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnStartAnimFinished");
      this.EvaluateWidgetStyle(GameInstance.GetTimeSystem(this.m_vehicle.GetGame()).GetGameTime());
    };
  }

  private final func TurnOff() -> Void {
    this.m_UIEnabled = false;
    this.KillBootupProxy();
    if IsDefined(this.m_startAnimProxy) {
      this.m_startAnimProxy.Stop();
    };
    if IsDefined(this.m_loopAnimProxy) {
      this.m_loopAnimProxy.Stop();
    };
    this.m_endAnimProxy = this.PlayLibraryAnimation(n"end");
    this.m_endAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnEndAnimFinished");
  }

  protected cb func OnStartAnimFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.PlayIdleLoop();
  }

  private final func PlayIdleLoop() -> Void {
    let animOptions: inkAnimOptions;
    animOptions.loopType = inkanimLoopType.Cycle;
    animOptions.loopInfinite = true;
    this.m_loopAnimProxy = this.PlayLibraryAnimation(n"loop", animOptions);
  }

  protected cb func OnEndAnimFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.m_rootWidget.SetState(n"inactive");
  }

  private final func PlayLibraryAnim(animName: CName) -> Void {
    this.PlayLibraryAnimation(animName);
  }

  public final func EvaluateWidgetStyle(time: GameTime) -> Void {
    let currTime: GameTime;
    let sunRise: GameTime;
    let sunSet: GameTime;
    if this.m_UIEnabled {
      sunSet = GameTime.MakeGameTime(0, 20, 0, 0);
      sunRise = GameTime.MakeGameTime(0, 5, 0, 0);
      currTime = GameTime.MakeGameTime(0, GameTime.Hours(time), GameTime.Minutes(time), GameTime.Seconds(time));
      if currTime <= sunSet && currTime >= sunRise {
        if NotEquals(this.m_rootWidget.GetState(), n"day") {
          this.m_rootWidget.SetState(n"day");
        };
      } else {
        if NotEquals(this.m_rootWidget.GetState(), n"night") {
          this.m_rootWidget.SetState(n"night");
        };
      };
    };
  }

  protected cb func OnVehicleCollision(collision: Bool) -> Bool {
    this.PlayLibraryAnimation(n"glitch");
  }

  protected cb func OnForwardVehicleQuestEnableUIEvent(evt: ref<ForwardVehicleQuestEnableUIEvent>) -> Bool {
    switch evt.mode {
      case vehicleQuestUIEnable.Gameplay:
        this.CheckIfVehicleShouldTurnOn();
        break;
      case vehicleQuestUIEnable.ForceEnable:
        this.TurnOn();
        break;
      case vehicleQuestUIEnable.ForceDisable:
        this.TurnOff();
    };
  }

  protected cb func OnVehiclePanzerBootupUIQuestEvent(evt: ref<VehiclePanzerBootupUIQuestEvent>) -> Bool {
    let animOptions: inkAnimOptions;
    this.m_UIEnabled = true;
    this.m_rootWidget.SetVisible(true);
    animOptions.loopType = inkanimLoopType.Cycle;
    animOptions.loopInfinite = true;
    switch evt.mode {
      case panzerBootupUI.UnbootedIdle:
        this.KillBootupProxy();
        this.m_loopingBootProxy = this.PlayLibraryAnimation(n"1_unbooted_idle", animOptions);
        break;
      case panzerBootupUI.BootingAttempt:
        this.KillBootupProxy();
        this.m_loopingBootProxy = this.PlayLibraryAnimation(n"2_booting_attempt", animOptions);
        break;
      case panzerBootupUI.BootingSuccess:
        this.KillBootupProxy();
        this.m_loopingBootProxy = this.PlayLibraryAnimation(n"3_booting_success");
        break;
      case panzerBootupUI.Loop:
        this.KillBootupProxy();
        this.m_loopingBootProxy = this.PlayLibraryAnimation(n"loop", animOptions);
    };
  }

  private final func KillBootupProxy() -> Void {
    if IsDefined(this.m_loopingBootProxy) {
      this.m_loopingBootProxy.Stop();
    };
  }

  protected cb func OnForwardVehicleQuestUIEffectEvent(evt: ref<ForwardVehicleQuestUIEffectEvent>) -> Bool {
    if evt.glitch {
      this.PlayLibraryAnimation(n"glitch");
    };
    if evt.panamVehicleStartup {
      this.PlayLibraryAnimation(n"start_panam");
    };
    if evt.panamScreenType1 {
      this.PlayLibraryAnimation(n"panam_screen_type1");
    };
    if evt.panamScreenType2 {
      this.PlayLibraryAnimation(n"panam_screen_type2");
    };
    if evt.panamScreenType3 {
      this.PlayLibraryAnimation(n"panam_screen_type3");
    };
    if evt.panamScreenType4 {
      this.PlayLibraryAnimation(n"panam_screen_type4");
    };
  }
}

public class IVehicleModuleController extends inkLogicController {

  public func RegisterCallbacks(vehicle: wref<VehicleObject>, vehBB: wref<IBlackboard>, gameController: wref<vehicleUIGameController>) -> Void;

  public func UnregisterCallbacks() -> Void;
}

public class speedometerLogicController extends IVehicleModuleController {

  private edit let m_speedTextWidget: inkTextRef;

  private let m_speedBBConnectionId: ref<CallbackHandle>;

  private let m_vehBB: wref<IBlackboard>;

  private let m_vehicle: wref<VehicleObject>;

  public func RegisterCallbacks(vehicle: wref<VehicleObject>, vehBB: wref<IBlackboard>, gameController: wref<vehicleUIGameController>) -> Void {
    if IsDefined(vehBB) {
      if !IsDefined(this.m_speedBBConnectionId) {
        this.m_speedBBConnectionId = vehBB.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this, n"OnSpeedValueChanged");
        this.m_vehBB = vehBB;
        this.m_vehicle = vehicle;
      };
    };
  }

  public func UnregisterCallbacks() -> Void {
    if IsDefined(this.m_vehBB) {
      if IsDefined(this.m_speedBBConnectionId) {
        this.m_vehBB.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this.m_speedBBConnectionId);
      };
    };
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_vehBB) {
      if IsDefined(this.m_speedBBConnectionId) {
        this.m_vehBB.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this.m_speedBBConnectionId);
      };
    };
  }

  public final func OnSpeedValueChanged(speed: Float) -> Void {
    let multiplier: Float;
    if speed < 0.00 {
      inkTextRef.SetText(this.m_speedTextWidget, "0");
    } else {
      multiplier = GameInstance.GetStatsDataSystem(this.m_vehicle.GetGame()).GetValueFromCurve(n"vehicle_ui", speed, n"speed_to_multiplier");
      inkTextRef.SetText(this.m_speedTextWidget, IntToString(RoundMath(speed * multiplier)));
    };
  }
}

public class tachometerLogicController extends IVehicleModuleController {

  private edit let m_rpmValueWidget: inkTextRef;

  private edit let m_rpmGaugeForegroundWidget: inkRectangleRef;

  private edit let m_scaleX: Bool;

  private let m_rpmValueBBConnectionId: ref<CallbackHandle>;

  private let m_vehBB: wref<IBlackboard>;

  private let m_rpmGaugeMaxSize: Vector2;

  private let m_rpmMaxValue: Float;

  private let m_rpmMinValue: Float;

  public func RegisterCallbacks(vehicle: wref<VehicleObject>, vehBB: wref<IBlackboard>, gameController: wref<vehicleUIGameController>) -> Void {
    let record: wref<Vehicle_Record>;
    let vehEngineData: wref<VehicleEngineData_Record>;
    if IsDefined(vehBB) {
      if !IsDefined(this.m_rpmValueBBConnectionId) {
        this.m_rpmValueBBConnectionId = vehBB.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMValue, this, n"OnRpmValueChanged");
        this.m_rpmGaugeMaxSize = inkWidgetRef.GetSize(this.m_rpmGaugeForegroundWidget);
        record = vehicle.GetRecord();
        vehEngineData = record.VehEngineData();
        this.m_rpmMinValue = vehEngineData.MinRPM();
        this.m_rpmMaxValue = vehEngineData.MaxRPM();
        this.m_vehBB = vehBB;
      };
    };
  }

  public func UnregisterCallbacks() -> Void {
    if IsDefined(this.m_vehBB) {
      if IsDefined(this.m_rpmValueBBConnectionId) {
        this.m_vehBB.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMValue, this.m_rpmValueBBConnectionId);
      };
    };
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_vehBB) {
      if IsDefined(this.m_rpmValueBBConnectionId) {
        this.m_vehBB.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMValue, this.m_rpmValueBBConnectionId);
      };
    };
  }

  public final func SetupRPMDefaultState() -> Void {
    this.m_rpmMaxValue = this.m_rpmMaxValue + 1500.00;
    if this.m_scaleX {
      inkWidgetRef.SetSize(this.m_rpmGaugeForegroundWidget, new Vector2((this.m_rpmMinValue * this.m_rpmGaugeMaxSize.X) / this.m_rpmMaxValue, this.m_rpmGaugeMaxSize.Y));
    } else {
      inkWidgetRef.SetSize(this.m_rpmGaugeForegroundWidget, new Vector2(this.m_rpmGaugeMaxSize.X, (this.m_rpmMinValue * this.m_rpmGaugeMaxSize.Y) / this.m_rpmMaxValue));
    };
  }

  public final func OnRpmValueChanged(rpmValue: Float) -> Void {
    if this.m_scaleX {
      inkWidgetRef.SetSize(this.m_rpmGaugeForegroundWidget, new Vector2((rpmValue * this.m_rpmGaugeMaxSize.X) / this.m_rpmMaxValue, this.m_rpmGaugeMaxSize.Y));
    } else {
      inkWidgetRef.SetSize(this.m_rpmGaugeForegroundWidget, new Vector2(this.m_rpmGaugeMaxSize.X, (rpmValue * this.m_rpmGaugeMaxSize.Y) / this.m_rpmMaxValue));
    };
    inkTextRef.SetText(this.m_rpmValueWidget, IntToString(RoundMath(rpmValue)));
  }
}

public class gametimeLogicController extends IVehicleModuleController {

  private edit let m_gametimeTextWidget: inkTextRef;

  private let m_gametimeBBConnectionId: ref<CallbackHandle>;

  private let m_vehBB: wref<IBlackboard>;

  private let m_vehicle: wref<VehicleObject>;

  private let m_parent: wref<vehicleUIGameController>;

  public func RegisterCallbacks(vehicle: wref<VehicleObject>, vehBB: wref<IBlackboard>, gameController: wref<vehicleUIGameController>) -> Void {
    if IsDefined(vehBB) {
      if !IsDefined(this.m_gametimeBBConnectionId) {
        this.m_gametimeBBConnectionId = vehBB.RegisterListenerString(GetAllBlackboardDefs().Vehicle.GameTime, this, n"OnGameTimeChanged");
        this.m_vehBB = vehBB;
        this.m_vehicle = vehicle;
        this.m_parent = gameController;
      };
    };
  }

  public func UnregisterCallbacks() -> Void {
    if IsDefined(this.m_vehBB) {
      if IsDefined(this.m_gametimeBBConnectionId) {
        this.m_vehBB.UnregisterListenerString(GetAllBlackboardDefs().Vehicle.GameTime, this.m_gametimeBBConnectionId);
      };
    };
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_vehBB) {
      if IsDefined(this.m_gametimeBBConnectionId) {
        this.m_vehBB.UnregisterListenerString(GetAllBlackboardDefs().Vehicle.GameTime, this.m_gametimeBBConnectionId);
      };
    };
  }

  public final func OnGameTimeChanged(time: String) -> Void {
    let currenTtime: GameTime;
    inkTextRef.SetText(this.m_gametimeTextWidget, time);
    currenTtime = GameInstance.GetTimeSystem(this.m_vehicle.GetGame()).GetGameTime();
    this.m_parent.EvaluateWidgetStyle(currenTtime);
  }
}

public class instrumentPanelLogicController extends IVehicleModuleController {

  private edit let m_lightStateImageWidget: inkImageRef;

  private edit let m_cautionStateImageWidget: inkImageRef;

  private let m_lightStateBBConnectionId: ref<CallbackHandle>;

  private let m_cautionStateBBConnectionId: ref<CallbackHandle>;

  private let m_vehBB: wref<IBlackboard>;

  public func RegisterCallbacks(vehicle: wref<VehicleObject>, vehBB: wref<IBlackboard>, gameController: wref<vehicleUIGameController>) -> Void {
    if IsDefined(vehBB) {
      if !IsDefined(this.m_lightStateBBConnectionId) {
        this.m_lightStateBBConnectionId = vehBB.RegisterListenerInt(GetAllBlackboardDefs().Vehicle.LightMode, this, n"OnLightModeChanged");
      };
      if !IsDefined(this.m_cautionStateBBConnectionId) {
        this.m_cautionStateBBConnectionId = vehBB.RegisterListenerInt(GetAllBlackboardDefs().Vehicle.DamageState, this, n"OnCautionStateChanged");
      };
      this.m_vehBB = vehBB;
      this.ForceUpdate();
    };
  }

  public func UnregisterCallbacks() -> Void {
    if IsDefined(this.m_vehBB) {
      if IsDefined(this.m_lightStateBBConnectionId) {
        this.m_vehBB.UnregisterListenerInt(GetAllBlackboardDefs().Vehicle.LightMode, this.m_lightStateBBConnectionId);
      };
      if IsDefined(this.m_cautionStateBBConnectionId) {
        this.m_vehBB.UnregisterListenerInt(GetAllBlackboardDefs().Vehicle.DamageState, this.m_cautionStateBBConnectionId);
      };
    };
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_vehBB) {
      if IsDefined(this.m_lightStateBBConnectionId) {
        this.m_vehBB.UnregisterListenerInt(GetAllBlackboardDefs().Vehicle.LightMode, this.m_lightStateBBConnectionId);
      };
      if IsDefined(this.m_cautionStateBBConnectionId) {
        this.m_vehBB.UnregisterListenerInt(GetAllBlackboardDefs().Vehicle.DamageState, this.m_cautionStateBBConnectionId);
      };
    };
  }

  protected final func ForceUpdate() -> Void {
    this.OnLightModeChanged(this.m_vehBB.GetInt(GetAllBlackboardDefs().Vehicle.LightMode));
    this.OnCautionStateChanged(this.m_vehBB.GetInt(GetAllBlackboardDefs().Vehicle.DamageState));
  }

  public final func OnLightModeChanged(state: Int32) -> Void {
    if state == EnumInt(vehicleELightMode.Off) {
      inkWidgetRef.SetOpacity(this.m_lightStateImageWidget, 0.00);
    } else {
      if state == EnumInt(vehicleELightMode.On) {
        inkWidgetRef.SetOpacity(this.m_lightStateImageWidget, 0.50);
      } else {
        if state == EnumInt(vehicleELightMode.HighBeams) {
          inkWidgetRef.SetOpacity(this.m_lightStateImageWidget, 1.00);
        };
      };
    };
  }

  public final func OnCautionStateChanged(state: Int32) -> Void {
    if state == 2 {
      inkWidgetRef.SetOpacity(this.m_cautionStateImageWidget, 1.00);
    };
  }
}

public class gearboxLogicController extends IVehicleModuleController {

  private edit let m_gearboxRImageWidget: inkImageRef;

  private edit let m_gearboxNImageWidget: inkImageRef;

  private edit let m_gearboxDImageWidget: inkImageRef;

  private let m_gearboxBBConnectionId: ref<CallbackHandle>;

  private let m_vehBB: wref<IBlackboard>;

  public func RegisterCallbacks(vehicle: wref<VehicleObject>, vehBB: wref<IBlackboard>, gameController: wref<vehicleUIGameController>) -> Void {
    if IsDefined(vehBB) {
      if !IsDefined(this.m_gearboxBBConnectionId) {
        this.m_gearboxBBConnectionId = vehBB.RegisterListenerInt(GetAllBlackboardDefs().Vehicle.GearValue, this, n"OnGearBoxChanged");
        this.m_vehBB = vehBB;
      };
      this.ForceUpdate();
    };
  }

  public func UnregisterCallbacks() -> Void {
    if IsDefined(this.m_vehBB) {
      if IsDefined(this.m_gearboxBBConnectionId) {
        this.m_vehBB.UnregisterListenerInt(GetAllBlackboardDefs().Vehicle.GearValue, this.m_gearboxBBConnectionId);
      };
    };
  }

  protected final func ForceUpdate() -> Void {
    this.OnGearBoxChanged(this.m_vehBB.GetInt(GetAllBlackboardDefs().Vehicle.GearValue));
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_vehBB) {
      if IsDefined(this.m_gearboxBBConnectionId) {
        this.m_vehBB.UnregisterListenerInt(GetAllBlackboardDefs().Vehicle.GearValue, this.m_gearboxBBConnectionId);
      };
    };
  }

  public final func OnGearBoxChanged(gear: Int32) -> Void {
    if gear == 0 {
      inkWidgetRef.SetOpacity(this.m_gearboxRImageWidget, 1.00);
      inkWidgetRef.SetOpacity(this.m_gearboxNImageWidget, 0.00);
      inkWidgetRef.SetOpacity(this.m_gearboxDImageWidget, 0.10);
    } else {
      if gear >= 0 {
        inkWidgetRef.SetOpacity(this.m_gearboxRImageWidget, 0.10);
        inkWidgetRef.SetOpacity(this.m_gearboxNImageWidget, 0.10);
        inkWidgetRef.SetOpacity(this.m_gearboxDImageWidget, 1.00);
      } else {
        if gear <= 0 {
          inkWidgetRef.SetOpacity(this.m_gearboxRImageWidget, 0.10);
          inkWidgetRef.SetOpacity(this.m_gearboxNImageWidget, 1.10);
          inkWidgetRef.SetOpacity(this.m_gearboxDImageWidget, 0.10);
        };
      };
    };
  }
}

public class RadioLogicController extends IVehicleModuleController {

  private edit let radioTextWidget: inkTextRef;

  private edit let radioEQWidget: inkCanvasRef;

  private let m_radioStateBBConnectionId: ref<CallbackHandle>;

  private let m_radioNameBBConnectionId: ref<CallbackHandle>;

  private let m_vehBB: wref<IBlackboard>;

  private let m_eqLoopAnimProxy: ref<inkAnimProxy>;

  private let m_radioTextWidgetSize: Vector2;

  public func RegisterCallbacks(vehicle: wref<VehicleObject>, vehBB: wref<IBlackboard>, gameController: wref<vehicleUIGameController>) -> Void {
    if IsDefined(vehBB) {
      if !IsDefined(this.m_radioStateBBConnectionId) {
        this.m_radioStateBBConnectionId = vehBB.RegisterListenerBool(GetAllBlackboardDefs().Vehicle.VehRadioState, this, n"OnRadioStateChanged");
      };
      if !IsDefined(this.m_radioNameBBConnectionId) {
        this.m_radioNameBBConnectionId = vehBB.RegisterListenerName(GetAllBlackboardDefs().Vehicle.VehRadioStationName, this, n"OnRadioNameChanged");
      };
      this.m_vehBB = vehBB;
    };
  }

  public func UnregisterCallbacks() -> Void {
    if IsDefined(this.m_vehBB) {
      if IsDefined(this.m_radioStateBBConnectionId) {
        this.m_vehBB.UnregisterListenerBool(GetAllBlackboardDefs().Vehicle.VehRadioState, this.m_radioStateBBConnectionId);
      };
      if IsDefined(this.m_radioNameBBConnectionId) {
        this.m_vehBB.UnregisterListenerName(GetAllBlackboardDefs().Vehicle.VehRadioStationName, this.m_radioNameBBConnectionId);
      };
    };
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_vehBB) {
      if IsDefined(this.m_radioStateBBConnectionId) {
        this.m_vehBB.UnregisterListenerBool(GetAllBlackboardDefs().Vehicle.VehRadioState, this.m_radioStateBBConnectionId);
      };
      if IsDefined(this.m_radioNameBBConnectionId) {
        this.m_vehBB.UnregisterListenerName(GetAllBlackboardDefs().Vehicle.VehRadioStationName, this.m_radioNameBBConnectionId);
      };
    };
  }

  public final func OnRadioStateChanged(state: Bool) -> Void {
    let playbackOptions: inkAnimOptions;
    if state {
      inkWidgetRef.SetVisible(this.radioTextWidget, true);
      inkWidgetRef.SetVisible(this.radioEQWidget, true);
      playbackOptions.loopInfinite = true;
      playbackOptions.loopType = inkanimLoopType.Cycle;
      this.m_eqLoopAnimProxy = this.PlayLibraryAnimation(n"eq_loop", playbackOptions);
    } else {
      if IsDefined(this.m_eqLoopAnimProxy) {
        this.m_eqLoopAnimProxy.Stop();
        inkWidgetRef.SetVisible(this.radioTextWidget, false);
        inkWidgetRef.SetVisible(this.radioEQWidget, false);
      };
    };
  }

  public final func OnRadioNameChanged(station: CName) -> Void {
    inkTextRef.SetText(this.radioTextWidget, NameToString(station));
    this.m_radioTextWidgetSize = inkWidgetRef.GetSize(this.radioTextWidget);
  }
}

public class analogTachLogicController extends IVehicleModuleController {

  private edit let m_analogTachNeedleWidget: inkWidgetRef;

  private edit let m_analogTachNeedleMinRotation: Float;

  private edit let m_analogTachNeedleMaxRotation: Float;

  private let m_rpmValueBBConnectionId: ref<CallbackHandle>;

  private let m_vehBB: wref<IBlackboard>;

  private let m_rpmMaxValue: Float;

  private let m_rpmMinValue: Float;

  public func RegisterCallbacks(vehicle: wref<VehicleObject>, vehBB: wref<IBlackboard>, gameController: wref<vehicleUIGameController>) -> Void {
    let record: wref<Vehicle_Record>;
    let vehEngineData: wref<VehicleEngineData_Record>;
    if IsDefined(vehBB) {
      if !IsDefined(this.m_rpmValueBBConnectionId) {
        this.m_rpmValueBBConnectionId = vehBB.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMValue, this, n"OnRpmValueChanged");
        record = vehicle.GetRecord();
        vehEngineData = record.VehEngineData();
        this.m_rpmMinValue = vehEngineData.MinRPM();
        this.m_rpmMaxValue = vehEngineData.MaxRPM();
        this.m_vehBB = vehBB;
      };
    };
  }

  public func UnregisterCallbacks() -> Void {
    if IsDefined(this.m_vehBB) {
      if IsDefined(this.m_rpmValueBBConnectionId) {
        this.m_vehBB.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMValue, this.m_rpmValueBBConnectionId);
      };
    };
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_vehBB) {
      if IsDefined(this.m_rpmValueBBConnectionId) {
        this.m_vehBB.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMValue, this.m_rpmValueBBConnectionId);
      };
    };
  }

  public final func OnRpmValueChanged(rpmValue: Float) -> Void {
    let normalizedRPM: Float = rpmValue / this.m_rpmMaxValue;
    let desiredRotation: Float = normalizedRPM * (this.m_analogTachNeedleMaxRotation + AbsF(this.m_analogTachNeedleMinRotation));
    desiredRotation = desiredRotation - AbsF(this.m_analogTachNeedleMinRotation);
    inkWidgetRef.SetRotation(this.m_analogTachNeedleWidget, desiredRotation);
  }
}

public class analogSpeedometerLogicController extends IVehicleModuleController {

  private edit let m_analogSpeedNeedleWidget: inkWidgetRef;

  private edit let m_analogSpeedNeedleMinRotation: Float;

  private edit let m_analogSpeedNeedleMaxRotation: Float;

  private edit let m_analogSpeedNeedleMaxValue: Float;

  private let m_speedBBConnectionId: ref<CallbackHandle>;

  private let m_vehBB: wref<IBlackboard>;

  private let m_vehicle: wref<VehicleObject>;

  public func RegisterCallbacks(vehicle: wref<VehicleObject>, vehBB: wref<IBlackboard>, gameController: wref<vehicleUIGameController>) -> Void {
    if IsDefined(vehBB) {
      if !IsDefined(this.m_speedBBConnectionId) {
        this.m_speedBBConnectionId = vehBB.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this, n"OnSpeedValueChanged");
        this.m_vehBB = vehBB;
        this.m_vehicle = vehicle;
      };
    };
  }

  public func UnregisterCallbacks() -> Void {
    if IsDefined(this.m_vehBB) {
      if IsDefined(this.m_speedBBConnectionId) {
        this.m_vehBB.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this.m_speedBBConnectionId);
      };
    };
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_vehBB) {
      if IsDefined(this.m_speedBBConnectionId) {
        this.m_vehBB.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this.m_speedBBConnectionId);
      };
    };
  }

  public final func OnSpeedValueChanged(speed: Float) -> Void {
    let multiplier: Float = GameInstance.GetStatsDataSystem(this.m_vehicle.GetGame()).GetValueFromCurve(n"vehicle_ui", speed, n"speed_to_multiplier");
    let speedMPH: Float = Cast(RoundMath(speed * multiplier));
    let normalizedSpeed: Float = ClampF(speedMPH / this.m_analogSpeedNeedleMaxValue, 0.00, 1.00);
    let desiredRotation: Float = normalizedSpeed * (this.m_analogSpeedNeedleMaxRotation + AbsF(this.m_analogSpeedNeedleMinRotation));
    desiredRotation = desiredRotation - AbsF(this.m_analogSpeedNeedleMinRotation);
    inkWidgetRef.SetRotation(this.m_analogSpeedNeedleWidget, desiredRotation);
  }
}
