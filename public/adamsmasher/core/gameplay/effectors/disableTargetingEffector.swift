
public class DisableTargetingEffector extends Effector {

  private let m_owner: wref<GameObject>;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void;

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.m_owner = owner;
    this.SignalEvent(false);
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    this.SignalEvent(true);
  }

  protected final func SignalEvent(toggle: Bool) -> Void {
    let targetingEvent: ref<ToggleTargetingComponentsEvent> = new ToggleTargetingComponentsEvent();
    targetingEvent.toggle = toggle;
    this.m_owner.QueueEvent(targetingEvent);
  }
}
