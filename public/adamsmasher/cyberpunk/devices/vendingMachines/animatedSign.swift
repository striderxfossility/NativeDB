
public class AnimatedSign extends InteractiveDevice {

  private let m_animFeature: ref<AnimFeature_AnimatedDevice>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
  }

  protected func TurnOnDevice() -> Void {
    this.UpdateAnimState();
    this.TurnOnDevice();
  }

  protected func TurnOffDevice() -> Void {
    this.UpdateAnimState();
    this.TurnOffDevice();
  }

  private final func UpdateAnimState() -> Void {
    if !IsDefined(this.m_animFeature) {
      this.m_animFeature = new AnimFeature_AnimatedDevice();
    };
    if this.GetDevicePS().IsON() {
      this.m_animFeature.isOn = true;
      this.m_animFeature.isOff = false;
    } else {
      this.m_animFeature.isOn = false;
      this.m_animFeature.isOff = true;
    };
    AnimationControllerComponent.ApplyFeature(this, n"AnimatedDevice", this.m_animFeature);
  }
}
