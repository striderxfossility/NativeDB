
public class GravityChangeTrigger extends GameObject {

  public let m_gravityType: EGravityType;

  @default(GravityChangeTrigger, Locomotion)
  public let m_regularStateMachineName: CName;

  @default(GravityChangeTrigger, LocomotionLowGravity)
  public let m_lowGravityStateMachineName: CName;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"trigger", n"gameStaticTriggerComponent", false);
  }

  protected cb func OnAreaEnter(trigger: ref<AreaEnteredEvent>) -> Bool {
    this.SwitchGravity(this.m_gravityType);
  }

  protected cb func OnAreaExit(trigger: ref<AreaExitedEvent>) -> Bool {
    if Equals(this.m_gravityType, EGravityType.LowGravity) {
      this.SwitchGravity(EGravityType.Regular);
    } else {
      this.SwitchGravity(EGravityType.LowGravity);
    };
  }

  private final func SwitchGravity(gravityType: EGravityType) -> Void {
    let swapEvent: ref<PSMAddOnDemandStateMachine> = new PSMAddOnDemandStateMachine();
    let player: ref<PlayerPuppet> = GetPlayer(this.GetGame());
    if Equals(gravityType, EGravityType.LowGravity) {
      swapEvent.stateMachineName = n"LocomotionLowGravity";
    } else {
      swapEvent.stateMachineName = n"Locomotion";
    };
    player.QueueEvent(swapEvent);
  }
}
