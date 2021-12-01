
public class ElevatorTerminalLogicController extends DeviceWidgetControllerBase {

  @attrib(category, "Widget Refs")
  private edit let m_elevatorUpArrowsWidget: inkFlexRef;

  @attrib(category, "Widget Refs")
  private edit let m_elevatorDownArrowsWidget: inkFlexRef;

  private let m_forcedElevatorArrowsState: EForcedElevatorArrowsState;

  protected cb func OnInitialize() -> Bool;

  public func Initialize(gameController: ref<DeviceInkGameControllerBase>, widgetData: SDeviceWidgetPackage) -> Void {
    let isListEmpty: Bool;
    let terminal: ref<Terminal> = gameController.GetOwnerEntity() as Terminal;
    this.m_forcedElevatorArrowsState = (terminal.GetDevicePS() as TerminalControllerPS).GetForcedElevatorArrowsState();
    this.Initialize(gameController, widgetData);
    isListEmpty = ArraySize(widgetData.actionWidgets) == 0;
    inkWidgetRef.SetVisible(this.m_elevatorDownArrowsWidget, false);
    inkWidgetRef.SetVisible(this.m_elevatorUpArrowsWidget, false);
    if NotEquals(this.m_forcedElevatorArrowsState, EForcedElevatorArrowsState.Disabled) {
      this.ForceFakeElevatorArrows(this.m_forcedElevatorArrowsState);
      return;
    };
    if isListEmpty {
      if Equals((widgetData.customData as LiftWidgetCustomData).GetMovementState(), gamePlatformMovementState.MovingUp) {
        inkWidgetRef.SetVisible(this.m_elevatorUpArrowsWidget, true);
        (inkWidgetRef.GetController(this.m_elevatorDownArrowsWidget) as ElevatorArrowsLogicController).PlayAnimationsArrowsUp();
      } else {
        if Equals((widgetData.customData as LiftWidgetCustomData).GetMovementState(), gamePlatformMovementState.MovingDown) {
          inkWidgetRef.SetVisible(this.m_elevatorDownArrowsWidget, true);
          (inkWidgetRef.GetController(this.m_elevatorDownArrowsWidget) as ElevatorArrowsLogicController).PlayAnimationsArrowsDown();
        };
      };
    } else {
      inkWidgetRef.SetVisible(this.m_actionsListWidget, true);
    };
  }

  public final func ForceFakeElevatorArrows(arrowsState: EForcedElevatorArrowsState) -> Void {
    inkWidgetRef.SetVisible(this.m_actionsListWidget, false);
    inkWidgetRef.SetVisible(this.m_elevatorDownArrowsWidget, false);
    inkWidgetRef.SetVisible(this.m_elevatorUpArrowsWidget, false);
    if Equals(arrowsState, EForcedElevatorArrowsState.ArrowsUp) {
      (inkWidgetRef.GetController(this.m_elevatorUpArrowsWidget) as ElevatorArrowsLogicController).PlayAnimationsArrowsUp();
      inkWidgetRef.SetVisible(this.m_elevatorUpArrowsWidget, true);
    } else {
      (inkWidgetRef.GetController(this.m_elevatorDownArrowsWidget) as ElevatorArrowsLogicController).PlayAnimationsArrowsDown();
      inkWidgetRef.SetVisible(this.m_elevatorDownArrowsWidget, true);
    };
  }
}
