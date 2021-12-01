
public class DeviceConnectionsHighlightSystem extends ScriptableSystem {

  private let m_highlightedDeviceID: EntityID;

  private let m_highlightedConnectionsIDs: array<EntityID>;

  private final func OnHighlightConnectionsRequest(request: ref<HighlightConnectionsRequest>) -> Void {
    let highlightComponentEvent: ref<HighlightConnectionComponentEvent>;
    let i: Int32;
    let targetID: EntityID;
    if !request.isTriggeredByMasterDevice {
      this.TurnOffAllHighlights();
      this.m_highlightedDeviceID = request.requestingDevice;
    };
    highlightComponentEvent = new HighlightConnectionComponentEvent();
    highlightComponentEvent.IsHighlightON = request.shouldHighlight;
    i = 0;
    while i < ArraySize(request.highlightTargets) {
      targetID = Cast(ResolveNodeRefWithEntityID(request.highlightTargets[i], request.requestingDevice));
      ArrayPush(this.m_highlightedConnectionsIDs, targetID);
      GameInstance.GetPersistencySystem(this.GetGameInstance()).QueueEntityEvent(targetID, highlightComponentEvent);
      i += 1;
    };
  }

  private final func TurnOffAllHighlights() -> Void {
    let highlightComponentEvent: ref<HighlightConnectionComponentEvent> = new HighlightConnectionComponentEvent();
    highlightComponentEvent.IsHighlightON = false;
    let i: Int32 = 0;
    while i < ArraySize(this.m_highlightedConnectionsIDs) {
      GameInstance.GetPersistencySystem(this.GetGameInstance()).QueueEntityEvent(this.m_highlightedConnectionsIDs[i], highlightComponentEvent);
      i += 1;
    };
    ArrayClear(this.m_highlightedConnectionsIDs);
    this.m_highlightedDeviceID = Cast(GlobalNodeID.GetRoot());
  }
}
