
public class TrafficLight extends Device {

  protected let m_lightState: worldTrafficLightColor;

  protected let m_trafficLightMesh: ref<PhysicalMeshComponent>;

  protected let m_destroyedMesh: ref<PhysicalMeshComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"traffic_light_device", n"PhysicalMeshComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"traffic_light_destroyed", n"PhysicalMeshComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_trafficLightMesh = EntityResolveComponentsInterface.GetComponent(ri, n"traffic_light_device") as PhysicalMeshComponent;
    this.m_destroyedMesh = EntityResolveComponentsInterface.GetComponent(ri, n"traffic_light_destroyed") as PhysicalMeshComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as TrafficLightController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    if (this.GetDevicePS() as TrafficLightControllerPS).IsMasterDestroyed() {
      this.DeactivateDeviceSilent();
    } else {
      this.ActivateDevice();
    };
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected cb func OnTrafficLightChangeEvent(evt: ref<TrafficLightChangeEvent>) -> Bool {
    if NotEquals(this.m_lightState, evt.lightColor) && this.GetDevicePS().IsInitialized() {
      this.TurnOffLights();
      if Equals(evt.lightColor, worldTrafficLightColor.YELLOW) {
        this.CommenceLightChangeSequence(this.m_lightState);
        this.m_lightState = evt.lightColor;
      } else {
        this.m_lightState = evt.lightColor;
        this.CompleteLightChangeSequence();
      };
    };
  }

  protected func CommenceLightChangeSequence(color: worldTrafficLightColor) -> Void {
    if Equals(color, worldTrafficLightColor.RED) {
      this.CommenceChangeToGreen();
    } else {
      this.CommenceChangeToRed();
    };
  }

  protected func CommenceChangeToRed() -> Void {
    this.HandleYellowLight(true);
  }

  protected func CommenceChangeToGreen() -> Void {
    this.HandleRedLight(true);
    this.HandleYellowLight(true);
  }

  protected func CompleteLightChangeSequence() -> Void {
    if Equals(this.m_lightState, worldTrafficLightColor.RED) {
      this.HandleRedLight(true);
    } else {
      this.HandleGreenLight(true);
    };
  }

  protected cb func OnMasterDeviceDestroyed(evt: ref<MasterDeviceDestroyed>) -> Bool {
    let delayEvent: ref<DelayEvent>;
    let meshInterface: ref<PhysicalBodyInterface> = this.m_destroyedMesh.CreatePhysicalBodyInterface();
    meshInterface.ToggleKinematic(true);
    meshInterface.AddLinearImpulse(new Vector4(0.00, 0.50, 0.00, 0.00), true);
    delayEvent = new DelayEvent();
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, delayEvent, RandRangeF(5.00, 10.00));
  }

  protected cb func OnDelayEvent(evt: ref<DelayEvent>) -> Bool {
    this.m_destroyedMesh.Toggle(false);
  }

  protected func TurnOnDevice() -> Void {
    this.DetermineLightsFixedState();
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffLights();
  }

  protected func DeactivateDevice() -> Void {
    this.TurnOffLights();
    this.GetDevicePS().GetDeviceOperationsContainer().Execute(n"death_VFX", this);
    this.m_trafficLightMesh.Toggle(false);
    this.m_destroyedMesh.Toggle(true);
  }

  protected final func DeactivateDeviceSilent() -> Void {
    this.TurnOffLights();
    this.m_trafficLightMesh.Toggle(false);
  }

  protected func ActivateDevice() -> Void {
    if this.GetDevicePS().IsON() {
      this.DetermineLightsFixedState();
    };
    if IsDefined(this.m_trafficLightMesh) {
      this.m_trafficLightMesh.Toggle(true);
    };
    if IsDefined(this.m_destroyedMesh) {
      this.m_destroyedMesh.Toggle(false);
    };
  }

  protected final func HandleRedLight(enable: Bool) -> Void {
    let toggleEvent: ref<ToggleLightByNameEvent> = new ToggleLightByNameEvent();
    toggleEvent.toggle = enable;
    toggleEvent.componentName = n"red";
    this.QueueEvent(toggleEvent);
  }

  protected func HandleYellowLight(enable: Bool) -> Void {
    let toggleEvent: ref<ToggleLightByNameEvent> = new ToggleLightByNameEvent();
    toggleEvent.toggle = enable;
    toggleEvent.componentName = n"yellow";
    this.QueueEvent(toggleEvent);
  }

  protected func HandleGreenLight(enable: Bool) -> Void {
    let toggleEvent: ref<ToggleLightByNameEvent> = new ToggleLightByNameEvent();
    toggleEvent.toggle = enable;
    toggleEvent.componentName = n"green";
    this.QueueEvent(toggleEvent);
  }

  protected final func TurnOffLights() -> Void {
    let evt: ref<ToggleLightEvent> = new ToggleLightEvent();
    evt.toggle = false;
    this.QueueEvent(evt);
  }

  protected func DetermineLightsFixedState() -> Void {
    this.TurnOffLights();
    if !this.GetDevicePS().IsON() {
      return;
    };
    if Equals(this.m_lightState, worldTrafficLightColor.RED) {
      this.HandleRedLight(true);
    } else {
      this.HandleGreenLight(true);
    };
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.GenericRole;
  }
}
