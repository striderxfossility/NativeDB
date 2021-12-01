
public class RegisterFastTravelPointsEvent extends Event {

  public inline edit let fastTravelNodes: array<ref<FastTravelPointData>>;

  public final func GetFriendlyDescription() -> String {
    return "Register Fast Travel Points";
  }
}

public class FastTravelComponent extends ScriptableComponent {

  private inline let m_fastTravelNodes: array<ref<FastTravelPointData>>;

  protected final func OnGameAttach() -> Void;

  protected final func OnGameDetach() -> Void;

  public final const func GetFasttravelNodes() -> array<ref<FastTravelPointData>> {
    return this.m_fastTravelNodes;
  }

  private final func GetFastTravelSystem() -> ref<FastTravelSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetOwner().GetGame()).Get(n"FastTravelSystem") as FastTravelSystem;
  }

  private final func PerformFastTravel(pointData: ref<FastTravelPointData>, player: ref<GameObject>) -> Void {
    let request: ref<PerformFastTravelRequest>;
    if player == null {
      return;
    };
    request = new PerformFastTravelRequest();
    request.pointData = pointData;
    request.player = player;
    this.GetFastTravelSystem().QueueRequest(request);
  }

  protected cb func OnRegisterFastTravelPoints(evt: ref<RegisterFastTravelPointsEvent>) -> Bool {
    let request: ref<RegisterFastTravelPointRequest>;
    let i: Int32 = 0;
    while i < ArraySize(evt.fastTravelNodes) {
      ArrayPush(this.m_fastTravelNodes, evt.fastTravelNodes[i]);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_fastTravelNodes) {
      request = new RegisterFastTravelPointRequest();
      request.pointData = this.m_fastTravelNodes[i];
      request.requesterID = this.GetOwner().GetEntityID();
      this.GetFastTravelSystem().QueueRequest(request);
      i += 1;
    };
  }

  protected cb func OnFastTravelAction(evt: ref<FastTravelDeviceAction>) -> Bool {
    this.PerformFastTravel(evt.GetFastTravelPointData(), evt.GetExecutor());
  }
}
