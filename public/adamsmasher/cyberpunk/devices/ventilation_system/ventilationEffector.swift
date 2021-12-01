
public class VentilationEffector extends ActivatedDeviceTransfromAnim {

  protected let m_effectComponent: ref<IPlacedComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"particleComponent", n"IPlacedComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_effectComponent = EntityResolveComponentsInterface.GetComponent(ri, n"particleComponent") as IPlacedComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as VentilationEffectorController;
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    if Equals(this.GetDeviceState(), EDeviceStatus.ON) {
      this.SetEffects(true);
    } else {
      this.SetEffects(false);
    };
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected func PushPersistentData() -> Void {
    this.PushPersistentData();
  }

  protected cb func OnToggleEffect(evt: ref<ToggleEffect>) -> Bool {
    if Equals(this.GetDeviceState(), EDeviceStatus.ON) {
      this.SetEffects(true);
    } else {
      this.SetEffects(false);
    };
    this.SetGameplayRoleToNone();
  }

  protected final func SetEffects(state: Bool) -> Void {
    this.m_effectComponent.Toggle(state);
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.SpreadGas;
  }
}
