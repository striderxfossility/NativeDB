
public class InputDeviceController extends ScriptableComponent {

  private let m_isStarted: Bool;

  public final static func Start(self: ref<InputDeviceController>) -> Void {
    if self.m_isStarted {
      return;
    };
    self.m_isStarted = true;
    InputDeviceController.RegisterListeners(self);
  }

  public final static func Stop(self: ref<InputDeviceController>) -> Void {
    if !self.m_isStarted {
      return;
    };
    self.m_isStarted = false;
    InputDeviceController.UnregsiterListeners(self);
  }

  private final static func RegisterListeners(self: ref<InputDeviceController>) -> Void {
    let deviceBase: ref<Device> = self.GetOwner() as Device;
    if IsDefined(deviceBase) {
      self.GetOwner().RegisterInputListener(self, deviceBase.GetInputContextName());
    };
  }

  private final static func UnregsiterListeners(self: ref<InputDeviceController>) -> Void {
    let deviceBase: ref<Device> = self.GetOwner() as Device;
    if IsDefined(deviceBase) {
      self.GetOwner().UnregisterInputListener(self);
    };
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool;
}
