
public class DeviceConnectionHighlightComponent extends ScriptableComponent {

  protected cb func OnDeviceConnectionHighlightEvent(evt: ref<HighlightConnectionComponentEvent>) -> Bool {
    if evt.IsHighlightON {
      this.SendForceVisionApperaceEvent(true, this.GetOwner());
    } else {
      this.SendForceVisionApperaceEvent(false, this.GetOwner());
    };
  }

  private final func SendForceVisionApperaceEvent(enable: Bool, target: ref<GameObject>) -> Void {
    let evt: ref<ForceVisionApperanceEvent> = new ForceVisionApperanceEvent();
    let highlight: ref<FocusForcedHighlightData> = target.GetDefaultHighlight();
    evt.forcedHighlight = highlight;
    evt.apply = enable;
    target.QueueEvent(evt);
  }
}
