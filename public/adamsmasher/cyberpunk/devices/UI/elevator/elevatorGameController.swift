
public class ElevatorInkGameController extends DeviceInkGameControllerBase {

  @attrib(category, "Widget Refs")
  private edit let m_verticalPanel: inkVerticalPanelRef;

  @attrib(category, "Widget Refs")
  private edit let m_currentFloorTextWidget: inkTextRef;

  @attrib(category, "Widget Refs")
  private edit let m_openCloseButtonWidgets: inkCanvasRef;

  @attrib(category, "Widget Refs")
  private edit let m_elevatorUpArrowsWidget: inkFlexRef;

  @attrib(category, "Widget Refs")
  private edit let m_elevatorDownArrowsWidget: inkFlexRef;

  @attrib(category, "Widget Refs")
  private edit let m_waitingStateWidget: inkCanvasRef;

  @attrib(category, "Widget Refs")
  private edit let m_dataScanningWidget: inkCanvasRef;

  @attrib(category, "Widget Refs")
  private edit let m_elevatorStoppedWidget: inkCanvasRef;

  protected let m_isPlayerScanned: Bool;

  protected let m_isPaused: Bool;

  protected let m_isAuthorized: Bool;

  protected let m_animProxy: ref<inkAnimProxy>;

  protected edit const let m_buttonSizes: array<Float>;

  private let m_onChangeFloorListener: ref<CallbackHandle>;

  private let m_onPlayerScannedListener: ref<CallbackHandle>;

  private let m_onPausedChangeListener: ref<CallbackHandle>;

  protected func SetupWidgets() -> Void {
    if !this.m_isInitialized {
      this.InitializeCurrentFloorName();
    };
  }

  protected final func InitializeCurrentFloorName() -> Void {
    let lift: ref<LiftDevice> = this.GetOwner() as LiftDevice;
    if IsDefined(lift) {
      this.SetCurrentFloorOnUI(lift.GetBlackboard().GetString(lift.GetBlackboardDef() as ElevatorDeviceBlackboardDef.CurrentFloor));
    };
  }

  public func UpdateActionWidgets(widgetsData: array<SActionWidgetPackage>) -> Void {
    let animOptions: inkAnimOptions;
    let i: Int32;
    let isAuthorized: Bool;
    let isListEmpty: Bool;
    let isMoving: Int32;
    let isOn: Bool;
    let isPowered: Bool;
    let widget: ref<inkWidget>;
    this.HideActionWidgets();
    inkWidgetRef.SetVisible(this.m_elevatorDownArrowsWidget, false);
    inkWidgetRef.SetVisible(this.m_elevatorUpArrowsWidget, false);
    inkWidgetRef.SetVisible(this.m_waitingStateWidget, false);
    inkWidgetRef.SetVisible(this.m_dataScanningWidget, false);
    inkWidgetRef.SetVisible(this.m_elevatorStoppedWidget, false);
    this.m_animProxy.Pause();
    animOptions.loopType = inkanimLoopType.Cycle;
    animOptions.loopInfinite = true;
    if IsDefined(this.GetOwner() as LiftDevice) {
      isMoving = (this.GetOwner() as LiftDevice).GetMovingMode();
      isPowered = (this.GetOwner() as LiftDevice).GetDevicePS().IsPowered();
      isOn = (this.GetOwner() as LiftDevice).GetDevicePS().IsON();
      isAuthorized = (this.GetOwner() as LiftDevice).GetDevicePS().IsPlayerAuthorized();
    };
    if this.m_isPaused {
      inkWidgetRef.SetVisible(this.m_elevatorStoppedWidget, true);
      this.m_animProxy = this.PlayLibraryAnimation(n"elevator_stopped", animOptions);
      return;
    };
    if !this.m_isPlayerScanned && isPowered && isOn {
      this.m_isPlayerScanned = this.GetOwner().GetBlackboard().GetBool(GetAllBlackboardDefs().ElevatorDeviceBlackboard.isPlayerScanned);
      if !this.m_isPlayerScanned {
        inkWidgetRef.SetVisible(this.m_dataScanningWidget, true);
        this.m_animProxy = this.PlayLibraryAnimation(n"data_scanning", animOptions);
        return;
      };
    };
    i = 0;
    while i < ArraySize(widgetsData) {
      widget = this.GetActionWidget(widgetsData[i]);
      if widget == null {
        this.CreateActionWidgetAsync(inkWidgetRef.Get(this.m_verticalPanel), widgetsData[i]);
      } else {
        this.RefreshFloor(widget, widgetsData[i], i, ArraySize(widgetsData));
      };
      i += 1;
    };
    if !isAuthorized {
      (widget.GetController() as DeviceButtonLogicControllerBase).SetButtonSize(100.00, this.m_buttonSizes[0]);
      return;
    };
    isListEmpty = ArraySize(widgetsData) == 0;
    if isListEmpty {
      if isMoving > 0 {
        inkWidgetRef.SetVisible(this.m_elevatorUpArrowsWidget, true);
        (inkWidgetRef.GetController(this.m_elevatorUpArrowsWidget) as ElevatorArrowsLogicController).PlayAnimationsArrowsUp();
      } else {
        if isMoving < 0 {
          inkWidgetRef.SetVisible(this.m_elevatorDownArrowsWidget, true);
          (inkWidgetRef.GetController(this.m_elevatorDownArrowsWidget) as ElevatorArrowsLogicController).PlayAnimationsArrowsDown();
        } else {
          if isMoving == 0 {
            this.HideActionWidgets();
            inkWidgetRef.SetVisible(this.m_waitingStateWidget, true);
            this.m_animProxy = this.PlayLibraryAnimation(n"waiting_for_elevator", animOptions);
          };
        };
      };
    };
  }

  protected final func RefreshFloor(widget: ref<inkWidget>, widgetData: SActionWidgetPackage, floorNumber: Int32, maxFloors: Int32) -> Void {
    this.InitializeActionWidget(widget, widgetData);
    switch maxFloors {
      case 1:
        (widget.GetController() as DeviceButtonLogicControllerBase).SetButtonSize(100.00, this.m_buttonSizes[0]);
        break;
      case 2:
        (widget.GetController() as DeviceButtonLogicControllerBase).SetButtonSize(100.00, this.m_buttonSizes[1]);
        break;
      case 3:
        (widget.GetController() as DeviceButtonLogicControllerBase).SetButtonSize(100.00, this.m_buttonSizes[2]);
        break;
      case 4:
        (widget.GetController() as DeviceButtonLogicControllerBase).SetButtonSize(100.00, this.m_buttonSizes[3]);
        break;
      case 5:
        (widget.GetController() as DeviceButtonLogicControllerBase).SetButtonSize(100.00, this.m_buttonSizes[4]);
    };
    inkCompoundRef.ReorderChild(this.m_verticalPanel, widget, floorNumber);
  }

  protected cb func OnActionWidgetSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    super.OnActionWidgetSpawned(widget, userData);
    this.Refresh(this.GetOwner().GetDeviceState());
  }

  public final func SetCurrentFloorOnUI(floorName: String) -> Void {
    inkTextRef.SetLetterCase(this.m_currentFloorTextWidget, textLetterCase.UpperCase);
    inkTextRef.SetLocalizedTextScript(this.m_currentFloorTextWidget, floorName);
  }

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }

  protected func RegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.RegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      this.m_onChangeFloorListener = blackboard.RegisterListenerString(this.GetOwner().GetBlackboardDef() as ElevatorDeviceBlackboardDef.CurrentFloor, this, n"OnChangeFloor");
      this.m_onPlayerScannedListener = blackboard.RegisterListenerBool(this.GetOwner().GetBlackboardDef() as ElevatorDeviceBlackboardDef.isPlayerScanned, this, n"OnPlayerScanned");
      this.m_onPausedChangeListener = blackboard.RegisterListenerBool(this.GetOwner().GetBlackboardDef() as ElevatorDeviceBlackboardDef.isPaused, this, n"OnPausedChange");
    };
  }

  protected func UnRegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.UnRegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      blackboard.UnregisterListenerString(this.GetOwner().GetBlackboardDef() as ElevatorDeviceBlackboardDef.CurrentFloor, this.m_onChangeFloorListener);
      blackboard.UnregisterListenerBool(this.GetOwner().GetBlackboardDef() as ElevatorDeviceBlackboardDef.isPlayerScanned, this.m_onPlayerScannedListener);
      blackboard.UnregisterListenerBool(this.GetOwner().GetBlackboardDef() as ElevatorDeviceBlackboardDef.isPaused, this.m_onPausedChangeListener);
    };
  }

  protected cb func OnPlayerScanned(value: Bool) -> Bool {
    if NotEquals(this.m_isPlayerScanned, value) {
      this.m_isPlayerScanned = value;
      this.Refresh(this.GetOwner().GetDeviceState());
    };
  }

  protected cb func OnPausedChange(value: Bool) -> Bool {
    if NotEquals(this.m_isPaused, value) {
      this.m_isPaused = value;
      this.Refresh(this.GetOwner().GetDeviceState());
    };
  }

  protected cb func OnChangeFloor(value: String) -> Bool {
    this.SetCurrentFloorOnUI(value);
  }

  public func Refresh(state: EDeviceStatus) -> Void {
    this.SetupWidgets();
    this.Refresh(state);
    this.RequestActionWidgetsUpdate();
  }
}

public class ElevatorTerminalFakeGameController extends DeviceInkGameControllerBase {

  private edit let m_elevatorTerminalWidget: inkCanvasRef;

  public func Refresh(state: EDeviceStatus) -> Void {
    let widgetPackage: SDeviceWidgetPackage;
    this.Refresh(state);
    (inkWidgetRef.GetController(this.m_elevatorTerminalWidget) as ElevatorTerminalLogicController).Initialize(this, widgetPackage);
  }
}
