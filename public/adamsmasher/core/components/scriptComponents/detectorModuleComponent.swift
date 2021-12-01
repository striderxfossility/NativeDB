
public class DetectorModuleComponent extends ScriptableComponent {

  protected cb func OnSenseVisibilityEvent(evt: ref<SenseVisibilityEvent>) -> Bool {
    let revealEvent: ref<RevealObjectEvent> = new RevealObjectEvent();
    revealEvent.reason.reason = n"FlatheadThreatSharing";
    if GameInstance.GetStatsSystem(this.GetOwner().GetGame()).GetStatBoolValue(Cast(this.GetOwner().GetEntityID()), gamedataStatType.CanShareThreatsWithPlayer) {
      if evt.isVisible && IsDefined(evt.target as ScriptedPuppet) && ScriptedPuppet.IsAlive(evt.target) {
        revealEvent.reveal = true;
        evt.target.QueueEvent(revealEvent);
      };
      if !evt.isVisible && IsDefined(evt.target as ScriptedPuppet) {
        revealEvent.reveal = false;
        evt.target.QueueEvent(revealEvent);
      };
    };
  }
}
