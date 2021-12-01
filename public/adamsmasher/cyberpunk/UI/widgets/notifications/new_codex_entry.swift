
public class NewCodexEntryGameController extends inkGameController {

  private edit let m_label: inkTextRef;

  private let m_animationProxy: ref<inkAnimProxy>;

  private let m_data: ref<NewCodexEntryUserData>;

  protected cb func OnInitialize() -> Bool {
    this.m_data = this.GetRootWidget().GetUserData(n"NewCodexEntryUserData") as NewCodexEntryUserData;
    this.Setup();
  }

  private final func Setup() -> Void {
    inkTextRef.SetText(this.m_label, this.m_data.data);
    this.PlayIntroAnimation();
  }

  private final func PlayIntroAnimation() -> Void {
    this.m_animationProxy = this.PlayLibraryAnimation(n"Outro");
    this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnOutroAnimFinished");
  }

  protected cb func OnOutroAnimFinished(anim: ref<inkAnimProxy>) -> Bool {
    let fakeData: ref<inkGameNotificationData>;
    this.m_data.token.TriggerCallback(fakeData);
  }
}
