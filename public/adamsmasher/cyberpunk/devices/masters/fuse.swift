
public class Fuse extends InteractiveMasterDevice {

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"DeviceTimetable", n"DeviceTimetable", true);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as FuseController;
  }

  protected cb func OnPersitentStateInitialized(evt: ref<GameAttachedEvent>) -> Bool {
    super.OnPersitentStateInitialized(evt);
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  public const func GetDefaultHighlight() -> ref<FocusForcedHighlightData> {
    return null;
  }

  public const func IsGameplayRelevant() -> Bool {
    return false;
  }

  public const func ShouldSendGameAttachedEventToPS() -> Bool {
    return false;
  }
}
