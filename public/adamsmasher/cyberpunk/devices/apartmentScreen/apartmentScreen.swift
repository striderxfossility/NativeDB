
public class ApartmentScreen extends LcdScreen {

  public let timeSystemCallbackID: Uint32;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"ui", n"worlduiWidgetComponent", false);
    super.OnRequestComponents(ri);
  }

  public func ResavePersistentData(ps: ref<PersistentState>) -> Bool {
    return false;
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as ApartmentScreenController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    this.RegisterDayUpdateCallback();
  }

  protected cb func OnDetach() -> Bool {
    this.RegisterDayUpdateCallback();
    super.OnDetach();
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  private final func RegisterDayUpdateCallback() -> Void {
    let evt: ref<DayPassedEvent> = new DayPassedEvent();
    let timeout: GameTime = GameTime.MakeGameTime(0, 24, 0, 0);
    let entryTime: GameTime = GameTime.MakeGameTime(0, 24, 0, 0);
    this.timeSystemCallbackID = GameInstance.GetTimeSystem(this.GetGame()).RegisterIntervalListener(this, evt, entryTime, timeout, -1);
  }

  private final func UnregisterDayUpdateCallback() -> Void {
    if this.timeSystemCallbackID > 0u {
      GameInstance.GetTimeSystem(this.GetGame()).UnregisterListener(this.timeSystemCallbackID);
    };
  }

  protected cb func OnDayPassed(evt: ref<DayPassedEvent>) -> Bool {
    (this.GetDevicePS() as ApartmentScreenControllerPS).UpdateRentState();
  }

  public final const func GetCurrentRentStatus() -> ERentStatus {
    return (this.GetDevicePS() as ApartmentScreenControllerPS).GetCurrentRentStatus();
  }

  public final const func GetCurrentOverdueValue() -> Int32 {
    return (this.GetDevicePS() as ApartmentScreenControllerPS).GetCurrentOverdueValue();
  }
}
