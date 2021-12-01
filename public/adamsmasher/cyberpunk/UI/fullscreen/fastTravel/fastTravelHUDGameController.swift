
public class FastTravelGameController extends inkGameController {

  private edit let m_fastTravelPointsList: inkCompoundRef;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  protected cb func OnInitialize() -> Bool {
    this.Initialize();
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
  }

  private final func Initialize() -> Void {
    let controller: ref<FastTravelButtonLogicController>;
    let currWidget: wref<inkWidget>;
    let i: Int32;
    let points: array<ref<FastTravelPointData>> = this.GetFastTravelSystem().GetFastTravelPoints();
    inkCompoundRef.RemoveAllChildren(this.m_fastTravelPointsList);
    i = 0;
    while i < ArraySize(points) {
      currWidget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_fastTravelPointsList), n"fastTravelPoint");
      controller = currWidget.GetController() as FastTravelButtonLogicController;
      if controller != null {
        controller.Initialize(points[i]);
        currWidget.RegisterToCallback(n"OnRelease", this, n"OnPerformFastTravel");
      };
      i += 1;
    };
  }

  private final func GetFastTravelSystem() -> ref<FastTravelSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetOwner().GetGame()).Get(n"FastTravelSystem") as FastTravelSystem;
  }

  private final func GetOwner() -> ref<GameObject> {
    return this.GetOwnerEntity() as GameObject;
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

  protected cb func OnPerformFastTravel(e: ref<inkPointerEvent>) -> Bool {
    let controller: ref<FastTravelButtonLogicController>;
    let player: ref<GameObject>;
    if e.IsAction(n"click") {
      controller = e.GetCurrentTarget().GetController() as FastTravelButtonLogicController;
      if controller != null {
        player = GameInstance.GetPlayerSystem(this.GetOwner().GetGame()).GetLocalPlayerMainGameObject();
        this.PerformFastTravel(controller.GetFastTravelPointData(), player);
        this.m_menuEventDispatcher.SpawnEvent(n"OnCloseHubMenu");
      };
    };
  }
}
