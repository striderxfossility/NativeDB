
public class ElevatorFloorTerminal extends Terminal {

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as ElevatorFloorTerminalController;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  protected cb func OnPerformedAction(evt: ref<PerformedAction>) -> Bool {
    super.OnPerformedAction(evt);
    GameObject.PlayMetadataEvent(this, n"ui_generic_set_14_positive");
  }

  private func InitializeScreenDefinition() -> Void {
    if !TDBID.IsValid(this.m_screenDefinition.screenDefinition) {
      this.m_screenDefinition.screenDefinition = t"DevicesUIDefinitions.Terminal_9x16";
    };
    if !TDBID.IsValid(this.m_screenDefinition.style) {
      this.m_screenDefinition.style = t"DevicesUIStyles.Zetatech";
    };
  }

  public func OnMaraudersMapDeviceDebug(sink: ref<MaraudersMapDevicesSink>) -> Void {
    let doorShouldOpenFrontLeftRight: array<Bool>;
    let elevatorFloorSetup: ElevatorFloorSetup;
    let iter: Int32;
    let keycards: array<TweakDBID>;
    this.OnMaraudersMapDeviceDebug(sink);
    sink.BeginCategory("LIFT TERMINAL DEVICE");
    sink.EndCategory();
    elevatorFloorSetup = (this.GetDevicePS() as ElevatorFloorTerminalControllerPS).GetElevatorFloorSetup();
    doorShouldOpenFrontLeftRight = elevatorFloorSetup.doorShouldOpenFrontLeftRight;
    keycards = this.GetDevicePS().GetKeycards();
    sink.PushString("Marker ", ToString(elevatorFloorSetup.m_floorMarker));
    sink.PushBool("Is Hidden", elevatorFloorSetup.m_isHidden);
    sink.PushBool("Is Inactive", elevatorFloorSetup.m_isInactive);
    sink.PushString("Floor Name", elevatorFloorSetup.m_floorName);
    sink.PushString("Floor Display Name", NameToString(elevatorFloorSetup.m_floorDisplayName));
    sink.PushString("Is Elevator at this floor", ToString((this.GetDevicePS() as ElevatorFloorTerminalControllerPS).IsElevatorAtThisFloor()));
    sink.PushString("Doors opening on that floor", "");
    iter = 0;
    while iter < ArraySize(doorShouldOpenFrontLeftRight) {
      sink.PushBool("Door " + IntToString(iter), doorShouldOpenFrontLeftRight[iter]);
      iter = iter + 1;
    };
    sink.PushString("KEYCARDS: ", "");
    iter = 0;
    while iter < ArraySize(keycards) {
      sink.PushString("Keycard" + IntToString(iter) + " ", TDBID.ToStringDEBUG(keycards[iter]));
      iter = iter + 1;
    };
  }

  protected func ShouldAlwasyRefreshUIInLogicAra() -> Bool {
    return true;
  }
}
