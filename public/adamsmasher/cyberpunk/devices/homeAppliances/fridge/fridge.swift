
public class Fridge extends InteractiveDevice {

  private let m_animFeature: ref<AnimFeature_SimpleDevice>;

  private let m_factOnDoorOpened: CName;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as FridgeController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    this.UpdateDoorAnimState();
  }

  protected cb func OnOpenDoor(evt: ref<ToggleOpenFridge>) -> Bool {
    this.UpdateDeviceState();
    this.UpdateDoorAnimState();
    this.UpdateFactDB();
  }

  private final func UpdateDoorAnimState() -> Void {
    if !IsDefined(this.m_animFeature) {
      this.m_animFeature = new AnimFeature_SimpleDevice();
    };
    this.m_animFeature.isOpen = false;
    if (this.GetDevicePS() as FridgeControllerPS).IsOpen() {
      this.m_animFeature.isOpen = true;
    };
    AnimationControllerComponent.ApplyFeature(this, n"DeviceFridge", this.m_animFeature);
  }

  private final func UpdateFactDB() -> Void {
    let factValue: Int32 = 0;
    if (this.GetDevicePS() as FridgeControllerPS).IsOpen() {
      factValue = 1;
    };
    AddFact(this.GetGame(), this.m_factOnDoorOpened);
    SetFactValue(this.GetGame(), this.m_factOnDoorOpened, factValue);
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }
}
