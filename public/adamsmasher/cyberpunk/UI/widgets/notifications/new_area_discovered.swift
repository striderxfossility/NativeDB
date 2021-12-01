
public class NewAreaGameController extends inkHUDGameController {

  private edit let m_label: inkTextRef;

  private let m_animationProxy: ref<inkAnimProxy>;

  private let m_data: ref<NewAreaDiscoveredUserData>;

  protected cb func OnInitialize() -> Bool;

  private final func Setup() -> Void;

  private final func PlayIntroAnimation() -> Void {
    this.m_animationProxy = this.PlayLibraryAnimation(n"Outro");
    this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnOutroAnimFinished");
  }

  protected cb func OnOutroAnimFinished(anim: ref<inkAnimProxy>) -> Bool {
    let fakeData: ref<inkGameNotificationData>;
    this.m_data.token.TriggerCallback(fakeData);
  }
}

public static exec func ChangeArea(gameInstance: GameInstance) -> Void {
  let player: ref<PlayerPuppet> = GetPlayer(gameInstance);
  let Blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().UI_Map);
  if IsDefined(Blackboard) {
    Blackboard.SetString(GetAllBlackboardDefs().UI_Map.currentLocation, "NEW AREA TEST");
    Blackboard.SignalString(GetAllBlackboardDefs().UI_Map.currentLocation);
  };
}
