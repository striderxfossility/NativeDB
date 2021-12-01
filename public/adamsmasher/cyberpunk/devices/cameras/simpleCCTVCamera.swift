
public class CCTVCamera extends GameObject {

  private let m_mesh: ref<MeshComponent>;

  private let m_camera: ref<CameraComponent>;

  @default(CCTVCamera, false)
  private let m_isControlled: Bool;

  private let m_cachedPuppetID: EntityID;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"cameraMesh", n"MeshComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"cameraComp", n"CameraComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_mesh = EntityResolveComponentsInterface.GetComponent(ri, n"cameraMesh") as MeshComponent;
    this.m_camera = EntityResolveComponentsInterface.GetComponent(ri, n"cameraComp") as CameraComponent;
    this.m_camera.SetIsHighPriority(true);
  }

  protected final func Rotate(deltaYaw: Float) -> Void {
    let orientationEA: EulerAngles;
    let currentRotationMat: Matrix = Quaternion.ToMatrix(this.m_mesh.GetLocalOrientation());
    let currentRotationEA: EulerAngles = Matrix.GetRotation(currentRotationMat);
    orientationEA.Pitch = currentRotationEA.Pitch;
    orientationEA.Yaw = currentRotationEA.Yaw + deltaYaw;
    this.m_mesh.SetLocalOrientation(EulerAngles.ToQuat(orientationEA));
  }

  protected final func TakeControl(val: Bool) -> Void {
    this.m_isControlled = val;
    if val {
      this.m_cachedPuppetID = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject().GetEntityID();
      GameInstance.GetPlayerSystem(this.GetGame()).LocalPlayerControlExistingObject(this.GetEntityID());
      this.m_camera.Activate(1.00);
      this.RegisterInputListener(this, n"CameraMouseX");
      this.RegisterInputListener(this, n"CameraAim");
      this.RegisterInputListener(this, n"UI_Exit");
    } else {
      this.UnregisterInputListener(this);
      this.m_camera.Deactivate(1.00);
      GameInstance.GetPlayerSystem(this.GetGame()).LocalPlayerControlExistingObject(this.m_cachedPuppetID);
      this.m_cachedPuppetID = new EntityID();
    };
  }

  protected cb func OnAreaEnter(trigger: ref<AreaEnteredEvent>) -> Bool {
    this.TakeControl(true);
  }

  protected cb func OnAreaExit(trigger: ref<AreaExitedEvent>) -> Bool;

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if Equals(ListenerAction.GetName(action), n"CameraMouseX") {
      if this.m_isControlled {
        this.Rotate(-ListenerAction.GetValue(action) * 0.10);
      };
    };
    if Equals(ListenerAction.GetName(action), n"CameraAim") {
      if ListenerAction.IsButtonJustPressed(action) {
        this.m_camera.SetZoom(2.00);
      } else {
        if ListenerAction.IsButtonJustReleased(action) {
          this.m_camera.SetZoom(0.00);
        };
      };
    };
    if Equals(ListenerAction.GetName(action), n"UI_Exit") {
      if ListenerAction.IsButtonJustPressed(action) {
        this.TakeControl(false);
      };
    };
  }
}
