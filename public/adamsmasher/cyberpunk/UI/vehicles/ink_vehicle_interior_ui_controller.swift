
public class vehicleInteriorUIGameController extends inkHUDGameController {

  private let m_vehicleBlackboard: wref<IBlackboard>;

  private let m_vehicleBBStateConectionId: ref<CallbackHandle>;

  private let m_vehicleBBReadyConectionId: ref<CallbackHandle>;

  private let m_vehicleBBUIActivId: ref<CallbackHandle>;

  private let m_speedBBConnectionId: ref<CallbackHandle>;

  private let m_gearBBConnectionId: ref<CallbackHandle>;

  private let m_rpmValueBBConnectionId: ref<CallbackHandle>;

  private let m_rpmMaxBBConnectionId: ref<CallbackHandle>;

  private let m_autopilotOnId: ref<CallbackHandle>;

  private let m_rootWidget: wref<inkCanvas>;

  private edit let m_speedTextWidget: inkTextRef;

  private edit let m_gearTextWidget: inkTextRef;

  private edit let m_rpmValueWidget: inkTextRef;

  private edit let m_rpmGaugeForegroundWidget: inkRectangleRef;

  private edit let m_autopilotTextWidget: inkTextRef;

  private let m_activeChunks: Int32;

  private edit let m_chunksNumber: Int32;

  private edit let m_dynamicRpmPath: CName;

  private edit let m_rpmPerChunk: Int32;

  private edit let m_hasRevMax: Bool;

  private let m_rpmGaugeMaxSize: Vector2;

  private let m_rpmMaxValue: Float;

  private let m_isInAutoPilot: Bool;

  private let m_isVehicleReady: Bool;

  private let m_HudRedLineAnimation: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    let vehicle: wref<VehicleObject> = this.GetOwnerEntity() as VehicleObject;
    this.m_rootWidget = this.GetRootWidget() as inkCanvas;
    this.m_rootWidget.SetVisible(false);
    this.m_rpmGaugeMaxSize = inkWidgetRef.GetSize(this.m_rpmGaugeForegroundWidget);
    this.m_vehicleBlackboard = vehicle.GetBlackboard();
    if this.IsUIactive() {
      this.ActivateUI();
    };
    if IsDefined(this.m_vehicleBlackboard) {
      this.m_vehicleBBUIActivId = this.m_vehicleBlackboard.RegisterListenerBool(GetAllBlackboardDefs().Vehicle.IsUIActive, this, n"OnActivateUI");
    };
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_vehicleBlackboard) {
      this.m_vehicleBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().Vehicle.IsUIActive, this.m_vehicleBBUIActivId);
      this.UnregisterBlackBoardCallbacks();
    };
  }

  private final func RegisterBlackBoardCallbacks() -> Void {
    if IsDefined(this.m_vehicleBlackboard) {
      if !IsDefined(this.m_vehicleBBStateConectionId) {
        this.m_vehicleBBStateConectionId = this.m_vehicleBlackboard.RegisterListenerInt(GetAllBlackboardDefs().Vehicle.VehicleState, this, n"OnVehicleStateChanged");
      };
      if !IsDefined(this.m_speedBBConnectionId) {
        this.m_speedBBConnectionId = this.m_vehicleBlackboard.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this, n"OnSpeedValueChanged");
      };
      if !IsDefined(this.m_gearBBConnectionId) {
        this.m_gearBBConnectionId = this.m_vehicleBlackboard.RegisterListenerInt(GetAllBlackboardDefs().Vehicle.GearValue, this, n"OnGearValueChanged");
      };
      if !IsDefined(this.m_rpmValueBBConnectionId) {
        this.m_rpmValueBBConnectionId = this.m_vehicleBlackboard.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMValue, this, n"OnRpmValueChanged");
      };
      if !IsDefined(this.m_rpmMaxBBConnectionId) {
        this.m_rpmMaxBBConnectionId = this.m_vehicleBlackboard.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMMax, this, n"OnRpmMaxChanged");
      };
      if !IsDefined(this.m_autopilotOnId) {
        this.m_autopilotOnId = this.m_vehicleBlackboard.RegisterListenerBool(GetAllBlackboardDefs().Vehicle.IsAutopilotOn, this, n"OnAutopilotChanged");
      };
      if !IsDefined(this.m_vehicleBBReadyConectionId) {
        this.m_vehicleBBReadyConectionId = this.m_vehicleBlackboard.RegisterListenerBool(GetAllBlackboardDefs().Vehicle.VehicleReady, this, n"OnVehicleReady");
      };
    };
  }

  private final func UnregisterBlackBoardCallbacks() -> Void {
    if IsDefined(this.m_vehicleBlackboard) {
      if IsDefined(this.m_vehicleBBStateConectionId) {
        this.m_vehicleBlackboard.UnregisterListenerInt(GetAllBlackboardDefs().Vehicle.VehicleState, this.m_vehicleBBStateConectionId);
      };
      if IsDefined(this.m_speedBBConnectionId) {
        this.m_vehicleBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this.m_speedBBConnectionId);
      };
      if IsDefined(this.m_gearBBConnectionId) {
        this.m_vehicleBlackboard.UnregisterListenerInt(GetAllBlackboardDefs().Vehicle.GearValue, this.m_gearBBConnectionId);
      };
      if IsDefined(this.m_rpmValueBBConnectionId) {
        this.m_vehicleBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMValue, this.m_rpmValueBBConnectionId);
      };
      if IsDefined(this.m_rpmMaxBBConnectionId) {
        this.m_vehicleBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMMax, this.m_rpmMaxBBConnectionId);
      };
      if IsDefined(this.m_autopilotOnId) {
        this.m_vehicleBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().Vehicle.IsAutopilotOn, this.m_autopilotOnId);
      };
      if IsDefined(this.m_vehicleBBReadyConectionId) {
        this.m_vehicleBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().Vehicle.VehicleReady, this.m_vehicleBBReadyConectionId);
      };
    };
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

  private final func ActivateUI() -> Void {
    this.m_rootWidget.SetVisible(true);
    this.RegisterBlackBoardCallbacks();
  }

  private final func DeactivateUI() -> Void {
    this.UnregisterBlackBoardCallbacks();
    this.m_rootWidget.SetVisible(false);
  }

  private final func IsUIactive() -> Bool {
    if IsDefined(this.m_vehicleBlackboard) && this.m_vehicleBlackboard.GetBool(GetAllBlackboardDefs().Vehicle.IsUIActive) {
      return true;
    };
    return false;
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

  protected cb func OnVehicleStateChanged(state: Int32) -> Bool {
    if state == EnumInt(vehicleEState.On) {
      this.m_rootWidget.SetVisible(true);
    };
    if state != EnumInt(vehicleEState.On) {
      this.m_rootWidget.SetVisible(false);
    };
  }

  protected cb func OnRpmMaxChanged(rpmMax: Float) -> Bool {
    this.m_rpmMaxValue = rpmMax + 1000.00;
    let rpm: Int32 = Cast(rpmMax);
    let level: Float = Cast(rpm / this.m_rpmPerChunk);
    let levelInt: Int32 = Cast(level);
    this.EvaluateRPMMeterWidget(levelInt);
  }

  protected cb func OnSpeedValueChanged(speedValue: Float) -> Bool {
    if speedValue < 0.00 {
      inkTextRef.SetText(this.m_speedTextWidget, "0");
    } else {
      inkTextRef.SetText(this.m_speedTextWidget, IntToString(RoundMath(speedValue * 2.24)));
    };
  }

  protected cb func OnGearValueChanged(gearValue: Int32) -> Bool {
    if gearValue == 0 {
      inkTextRef.SetText(this.m_gearTextWidget, "UI-Cyberpunk-Vehicles-Gears-Neutral");
    } else {
      inkTextRef.SetText(this.m_gearTextWidget, IntToString(gearValue));
    };
  }

  protected cb func OnRpmValueChanged(rpmValue: Float) -> Bool {
    inkTextRef.SetText(this.m_rpmValueWidget, IntToString(RoundMath(rpmValue)));
    if rpmValue > 7800.00 {
      this.m_HudRedLineAnimation = this.PlayLibraryAnimation(n"redLine");
    };
    this.drawRPMGaugeFull(rpmValue);
    inkWidgetRef.SetSize(this.m_rpmGaugeForegroundWidget, new Vector2((rpmValue * this.m_rpmGaugeMaxSize.X) / this.m_rpmMaxValue, this.m_rpmGaugeMaxSize.Y));
  }

  public final func drawRPMGaugeFull(rpmValue: Float) -> Void {
    let rpm: Int32 = Cast(rpmValue);
    let level: Float = Cast(rpm / this.m_rpmPerChunk);
    let levelInt: Int32 = Cast(level);
    this.EvaluateRPMMeterWidget(levelInt);
  }

  private final func EvaluateRPMMeterWidget(currentAmountOfChunks: Int32) -> Void {
    if currentAmountOfChunks == this.m_activeChunks {
      return;
    };
    this.RedrawRPM(currentAmountOfChunks);
  }

  private final func RedrawRPM(currentAmountOfChunks: Int32) -> Void {
    let chunkToModify: String;
    let i: Int32;
    let widgetToModify: wref<inkRectangle>;
    let difference: Int32 = Abs(currentAmountOfChunks - this.m_activeChunks);
    let increasing: Bool = currentAmountOfChunks > this.m_activeChunks;
    if increasing {
      i = this.m_activeChunks;
      while i <= this.m_activeChunks + difference {
        chunkToModify = NameToString(this.m_dynamicRpmPath) + IntToString(i);
        widgetToModify = this.GetWidget(StringToName(chunkToModify)) as inkRectangle;
        widgetToModify.SetVisible(true);
        widgetToModify.SetOpacity(1.00);
        i += 1;
      };
    } else {
      i = this.m_activeChunks;
      while i >= this.m_activeChunks - difference {
        chunkToModify = NameToString(this.m_dynamicRpmPath) + IntToString(i);
        widgetToModify = this.GetWidget(StringToName(chunkToModify)) as inkRectangle;
        widgetToModify.SetVisible(false);
        i -= 1;
      };
    };
    this.m_activeChunks = currentAmountOfChunks;
  }

  private final func AddChunk() -> Void {
    let chunkToActivate: String;
    let i: Int32;
    let widgetToShow: wref<inkRectangle>;
    if IsNameValid(this.m_dynamicRpmPath) {
      i = 1;
      while i <= this.m_activeChunks {
        chunkToActivate = NameToString(this.m_dynamicRpmPath) + IntToString(i);
        widgetToShow = this.GetWidget(StringToName(chunkToActivate)) as inkRectangle;
        widgetToShow.SetVisible(true);
        widgetToShow.SetOpacity(1.00);
        i += 1;
      };
    };
  }

  private final func RemoveChunk() -> Void {
    let chunkToRemove: String;
    let i: Int32;
    let widgetToHide: wref<inkRectangle>;
    if IsNameValid(this.m_dynamicRpmPath) {
      i = this.m_chunksNumber;
      while i > this.m_activeChunks {
        chunkToRemove = NameToString(this.m_dynamicRpmPath) + IntToString(i);
        widgetToHide = this.GetWidget(StringToName(chunkToRemove)) as inkRectangle;
        widgetToHide.SetVisible(false);
        i -= 1;
      };
    };
  }

  protected cb func OnAutopilotChanged(autopilotOn: Bool) -> Bool {
    this.m_isInAutoPilot = autopilotOn;
    this.RefreshUI();
  }

  private final func RefreshUI() -> Void {
    if this.m_isInAutoPilot {
      inkWidgetRef.SetVisible(this.m_autopilotTextWidget, this.m_isInAutoPilot);
    } else {
      inkWidgetRef.SetVisible(this.m_autopilotTextWidget, this.m_isInAutoPilot);
    };
  }
}
