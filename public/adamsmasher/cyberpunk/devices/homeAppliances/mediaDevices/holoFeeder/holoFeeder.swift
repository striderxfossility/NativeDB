
public class HoloFeeder extends Device {

  private let m_feederMesh: ref<IPlacedComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"feeder", n"IPlacedComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as HoloFeederController;
    this.m_feederMesh = EntityResolveComponentsInterface.GetComponent(ri, n"feeder") as IPlacedComponent;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected func CutPower() -> Void {
    this.TurnOff();
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOn();
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOff();
  }

  private final func TurnOn() -> Void {
    this.m_feederMesh.Toggle(true);
  }

  private final func TurnOff() -> Void {
    this.m_feederMesh.Toggle(false);
  }
}
