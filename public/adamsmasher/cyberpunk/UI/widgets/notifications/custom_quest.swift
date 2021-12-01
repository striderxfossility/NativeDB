
public class CustomQuestNotificationGameController extends inkHUDGameController {

  private edit let m_label: inkTextRef;

  private edit let m_desc: inkTextRef;

  private edit let m_icon: inkImageRef;

  private edit let m_fluffHeader: inkTextRef;

  private let m_root: wref<inkWidget>;

  private let m_data: ref<CustomQuestNotificationUserData>;

  private let m_animationProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.m_data = this.GetRootWidget().GetUserData(n"CustomQuestNotificationUserData") as CustomQuestNotificationUserData;
    this.Setup();
  }

  private final func Setup() -> Void {
    inkTextRef.SetText(this.m_label, this.m_data.data.header);
    inkTextRef.SetText(this.m_desc, this.m_data.data.desc);
    if NotEquals(this.m_data.data.icon, n"") {
      inkWidgetRef.SetVisible(this.m_icon, true);
      inkImageRef.SetTexturePart(this.m_icon, this.m_data.data.icon);
    } else {
      inkWidgetRef.SetVisible(this.m_icon, false);
    };
    if NotEquals(this.m_data.data.fluffHeader, "") {
      inkTextRef.SetText(this.m_fluffHeader, this.m_data.data.fluffHeader);
    } else {
      inkTextRef.SetText(this.m_fluffHeader, GetLocalizedText("UI-ResourceExports-Message"));
    };
    this.PlayAnimation(n"outro_safe");
  }

  private final func PlayAnimation(animName: CName) -> Void {
    this.m_root.SetVisible(true);
    this.m_animationProxy = this.PlayLibraryAnimation(animName);
    this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnOutroAnimFinished");
  }

  protected cb func OnOutroAnimFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.m_root.SetVisible(false);
  }
}

public static exec func TestCustomQuestNotification(gameInstance: GameInstance) -> Void {
  let fakeData: CustomQuestNotificationData;
  let player: ref<PlayerPuppet> = GetPlayer(gameInstance);
  let Blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().UI_CustomQuestNotification);
  fakeData.header = "TEST";
  fakeData.desc = "REALLY LONG TEXT, REALLY LONG TEXT";
  fakeData.icon = n"danger_zone_icon";
  if IsDefined(Blackboard) {
    Blackboard.SetVariant(GetAllBlackboardDefs().UI_CustomQuestNotification.data, ToVariant(fakeData));
    Blackboard.SignalVariant(GetAllBlackboardDefs().UI_CustomQuestNotification.data);
  };
}
