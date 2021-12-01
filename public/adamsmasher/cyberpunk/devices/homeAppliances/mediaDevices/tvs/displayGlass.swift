
public class DisplayGlass extends InteractiveDevice {

  protected let m_collider: ref<IPlacedComponent>;

  protected let m_isDestroyed: Bool;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"tv_ui", n"worlduiWidgetComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"block_vision", n"IPlacedComponent", false);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_uiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"tv_ui") as worlduiWidgetComponent;
    this.m_collider = EntityResolveComponentsInterface.GetComponent(ri, n"block_vision") as IPlacedComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as DisplayGlassController;
  }

  protected cb func OnPersitentStateInitialized(evt: ref<GameAttachedEvent>) -> Bool {
    super.OnPersitentStateInitialized(evt);
  }

  protected cb func OnDetach() -> Bool {
    super.OnDetach();
  }

  protected cb func OnToggleGlassTint(evt: ref<ToggleGlassTint>) -> Bool {
    this.UpdateGlassState();
  }

  protected cb func OnToggleGlassTintHack(evt: ref<ToggleGlassTintHack>) -> Bool {
    this.UpdateGlassState();
  }

  protected cb func OnQuestForceTintGlass(evt: ref<QuestForceTintGlass>) -> Bool {
    this.UpdateGlassState();
  }

  protected cb func OnQuestForceClearGlass(evt: ref<QuestForceClearGlass>) -> Bool {
    this.UpdateGlassState();
  }

  protected final func UpdateGlassState() -> Void {
    if !this.m_isDestroyed {
      this.ToggleTintGlass((this.GetDevicePS() as DisplayGlassControllerPS).IsTinted());
    };
    this.UpdateDeviceState();
  }

  protected cb func OnPhysicalDestructionEvent(evt: ref<PhysicalDestructionEvent>) -> Bool {
    if evt.levelOfDestruction == 0u && !this.m_isDestroyed {
      this.m_collider.Toggle(false);
      this.m_isDestroyed = true;
      this.GetDevicePS().ForceDisableDevice();
    };
  }

  private final func ToggleTintGlass(on: Bool) -> Void {
    let ps: ref<DisplayGlassControllerPS>;
    if !this.m_isDestroyed {
      ps = this.GetDevicePS() as DisplayGlassControllerPS;
      if ps.UsesAppearances() {
        if on {
          this.SetMeshAppearance(ps.GetTintAppearance());
        } else {
          this.SetMeshAppearance(ps.GetClearAppearance());
        };
      } else {
        this.m_uiComponent.Toggle(on);
      };
      this.m_collider.Toggle(on);
    };
  }

  protected func TurnOnDevice() -> Void {
    this.ToggleTintGlass((this.GetDevicePS() as DisplayGlassControllerPS).IsTinted());
  }

  protected func TurnOffDevice() -> Void {
    this.ToggleTintGlass(false);
  }

  protected func CutPower() -> Void {
    this.ToggleTintGlass(false);
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.ControlSelf;
  }
}
