
public native class BaseVehicleHUDGameController extends inkHUDGameController {

  protected native const let mounted: Bool;

  protected cb func OnVehicleMounted() -> Bool;

  protected cb func OnVehicleUnmounted() -> Bool;
}

public class vehicleDebugUIGameController extends BaseVehicleHUDGameController {

  private let m_vehicleBlackboard: wref<IBlackboard>;

  private let m_vehicleBBStateConectionId: ref<CallbackHandle>;

  private let m_mountBBConnectionId: ref<CallbackHandle>;

  private let m_speedBBConnectionId: ref<CallbackHandle>;

  private let m_gearBBConnectionId: ref<CallbackHandle>;

  private let m_rpmValueBBConnectionId: ref<CallbackHandle>;

  private let m_rpmMaxBBConnectionId: ref<CallbackHandle>;

  private let m_radioStateBBConnectionId: ref<CallbackHandle>;

  private let m_radioNameBBConnectionId: ref<CallbackHandle>;

  private let m_radioState: Bool;

  private let m_radioName: CName;

  private let m_radioStateWidget: wref<inkText>;

  private let m_radioNameWidget: wref<inkText>;

  private let m_autopilotOnId: ref<CallbackHandle>;

  private let rootWidget: wref<inkCanvas>;

  private let speedTextWidget: wref<inkText>;

  private let gearTextWidget: wref<inkText>;

  private let rpmValueWidget: wref<inkText>;

  private let rpmGaugeForegroundWidget: wref<inkRectangle>;

  private let rpmGaugeMaxSize: Vector2;

  private let rpmMinValue: Float;

  private let rpmMaxValue: Float;

  private let rpmMaxValueInitialized: Bool;

  private let autopilotTextWidget: wref<inkText>;

  private let isInAutoPilot: Bool;

  private let useDebugUI: Bool;

  protected cb func OnInitialize() -> Bool {
    this.rootWidget = this.GetRootWidget() as inkCanvas;
    this.speedTextWidget = this.GetWidget(n"main_panel/speed_panel/speed") as inkText;
    this.gearTextWidget = this.GetWidget(n"main_panel/speed_panel/gear") as inkText;
    this.rpmValueWidget = this.GetWidget(n"main_panel/rpm_panel/rpm_value") as inkText;
    this.rpmGaugeForegroundWidget = this.GetWidget(n"main_panel/rpm_panel/rpmGauge/rpmGaugeForeground") as inkRectangle;
    this.autopilotTextWidget = this.GetWidget(n"main_panel/speed_panel/auto_pilot") as inkText;
    this.m_radioStateWidget = this.GetWidget(n"RADIO/RADIOSTATE") as inkText;
    this.m_radioNameWidget = this.GetWidget(n"RADIO/RADIONAME") as inkText;
    this.rootWidget.SetVisible(false);
    this.rpmGaugeMaxSize = this.rpmGaugeForegroundWidget.GetSize();
    this.useDebugUI = TweakDBInterface.GetBool(t"vehicles.showDebugUi", false);
    this.RegisterDebugCommand(n"OnActivateTest");
  }

  protected cb func OnActivateTest(value: Bool) -> Bool;

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_vehicleBlackboard) {
      this.m_vehicleBlackboard.UnregisterListenerInt(GetAllBlackboardDefs().Vehicle.VehicleState, this.m_vehicleBBStateConectionId);
      this.m_vehicleBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this.m_speedBBConnectionId);
      this.m_vehicleBlackboard.UnregisterListenerInt(GetAllBlackboardDefs().Vehicle.GearValue, this.m_gearBBConnectionId);
      this.m_vehicleBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMValue, this.m_rpmValueBBConnectionId);
      this.m_vehicleBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMMax, this.m_rpmMaxBBConnectionId);
      this.m_vehicleBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().Vehicle.IsAutopilotOn, this.m_autopilotOnId);
      this.m_vehicleBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().Vehicle.VehRadioState, this.m_radioStateBBConnectionId);
      this.m_vehicleBlackboard.UnregisterListenerName(GetAllBlackboardDefs().Vehicle.VehRadioStationName, this.m_radioNameBBConnectionId);
    };
  }

  protected cb func OnVehicleMounted() -> Bool {
    let playerPuppet: wref<GameObject>;
    let vehicle: wref<VehicleObject>;
    if this.useDebugUI {
      playerPuppet = this.GetOwnerEntity() as PlayerPuppet;
      vehicle = GetMountedVehicle(playerPuppet);
      this.m_vehicleBlackboard = vehicle.GetBlackboard();
      if IsDefined(this.m_vehicleBlackboard) {
        this.m_vehicleBBStateConectionId = this.m_vehicleBlackboard.RegisterListenerInt(GetAllBlackboardDefs().Vehicle.VehicleState, this, n"OnVehicleStateChanged");
        this.m_speedBBConnectionId = this.m_vehicleBlackboard.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this, n"OnSpeedValueChanged");
        this.m_gearBBConnectionId = this.m_vehicleBlackboard.RegisterListenerInt(GetAllBlackboardDefs().Vehicle.GearValue, this, n"OnGearValueChanged");
        this.m_rpmValueBBConnectionId = this.m_vehicleBlackboard.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMValue, this, n"OnRpmValueChanged");
        this.m_rpmMaxBBConnectionId = this.m_vehicleBlackboard.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMMax, this, n"OnRpmMaxChanged");
        this.m_autopilotOnId = this.m_vehicleBlackboard.RegisterListenerBool(GetAllBlackboardDefs().Vehicle.IsAutopilotOn, this, n"OnAutopilotChanged");
        this.m_radioStateBBConnectionId = this.m_vehicleBlackboard.RegisterListenerBool(GetAllBlackboardDefs().Vehicle.VehRadioState, this, n"OnRadioStateChanged");
        this.m_radioNameBBConnectionId = this.m_vehicleBlackboard.RegisterListenerName(GetAllBlackboardDefs().Vehicle.VehRadioStationName, this, n"OnRadioNameChanged");
      };
    };
  }

  protected cb func OnVehicleUnmounted() -> Bool {
    if IsDefined(this.m_vehicleBlackboard) {
      this.m_vehicleBlackboard.UnregisterListenerInt(GetAllBlackboardDefs().Vehicle.VehicleState, this.m_vehicleBBStateConectionId);
      this.m_vehicleBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this.m_speedBBConnectionId);
      this.m_vehicleBlackboard.UnregisterListenerInt(GetAllBlackboardDefs().Vehicle.GearValue, this.m_gearBBConnectionId);
      this.m_vehicleBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMValue, this.m_rpmValueBBConnectionId);
      this.m_vehicleBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMMax, this.m_rpmMaxBBConnectionId);
      this.m_vehicleBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().Vehicle.IsAutopilotOn, this.m_autopilotOnId);
      this.m_vehicleBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().Vehicle.VehRadioState, this.m_radioStateBBConnectionId);
      this.m_vehicleBlackboard.UnregisterListenerName(GetAllBlackboardDefs().Vehicle.VehRadioStationName, this.m_radioNameBBConnectionId);
    };
    this.rootWidget.SetVisible(false);
  }

  protected cb func OnVehicleStateChanged(state: Int32) -> Bool {
    if this.useDebugUI {
      if state == EnumInt(vehicleEState.On) {
        this.rootWidget.SetVisible(true);
      };
      if state != EnumInt(vehicleEState.On) {
        this.rootWidget.SetVisible(false);
      };
    };
  }

  protected cb func OnSpeedValueChanged(speedValue: Float) -> Bool {
    if speedValue < 0.00 {
      this.speedTextWidget.SetText(IntToString(RoundMath(speedValue * 3.60) * -1));
    } else {
      this.speedTextWidget.SetText(IntToString(RoundMath(speedValue * 3.60)));
    };
  }

  protected cb func OnGearValueChanged(gearValue: Int32) -> Bool {
    if gearValue == 0 {
      this.gearTextWidget.SetText("R");
    } else {
      if gearValue == -1 {
        this.gearTextWidget.SetText("N");
      } else {
        this.gearTextWidget.SetText(IntToString(gearValue));
      };
    };
  }

  protected cb func OnRpmValueChanged(rpmValue: Float) -> Bool {
    this.rpmValueWidget.SetText(IntToString(RoundMath(rpmValue)));
    this.rpmGaugeForegroundWidget.SetSize(new Vector2((rpmValue * this.rpmGaugeMaxSize.X) / this.rpmMaxValue, this.rpmGaugeMaxSize.Y));
  }

  protected cb func OnRpmMaxChanged(rpmMax: Float) -> Bool {
    this.rpmMaxValue = rpmMax + 1000.00;
  }

  protected cb func OnAutopilotChanged(autopilotOn: Bool) -> Bool {
    this.isInAutoPilot = autopilotOn;
    this.RefreshUI();
  }

  private final func RefreshUI() -> Void {
    if this.isInAutoPilot {
      this.autopilotTextWidget.SetVisible(this.isInAutoPilot);
    } else {
      this.autopilotTextWidget.SetVisible(this.isInAutoPilot);
    };
  }

  protected cb func OnRadioStateChanged(state: Bool) -> Bool {
    if state {
      this.m_radioState = true;
    } else {
      if !state {
        this.m_radioState = false;
      };
    };
    this.m_radioStateWidget.SetText(BoolToString(this.m_radioState));
  }

  protected cb func OnRadioNameChanged(stationName: CName) -> Bool {
    this.m_radioNameWidget.SetText(NameToString(stationName));
  }
}
