
public class PhoneContactItemVirtualController extends inkVirtualCompoundItemController {

  private edit let m_label: inkTextRef;

  private edit let m_msgCount: inkTextRef;

  private edit let m_msgIndicator: inkWidgetRef;

  private edit let m_questFlag: inkWidgetRef;

  private edit let m_regFlag: inkWidgetRef;

  private let m_animProxyQuest: ref<inkAnimProxy>;

  private let m_animProxySelection: ref<inkAnimProxy>;

  private let m_contactData: ref<ContactData>;

  public final func GetContactData() -> ref<ContactData> {
    return this.m_contactData;
  }

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnSelected", this, n"OnSelected");
    this.RegisterToCallback(n"OnDeselected", this, n"OnDeselected");
  }

  protected cb func OnDataChanged(value: Variant) -> Bool {
    let playbackOptions: inkAnimOptions;
    this.m_contactData = FromVariant(value) as ContactData;
    inkTextRef.SetText(this.m_label, this.m_contactData.localizedName);
    inkWidgetRef.SetVisible(this.m_questFlag, this.m_contactData.questRelated);
    inkWidgetRef.SetVisible(this.m_regFlag, !this.m_contactData.questRelated);
    if IsDefined(this.m_animProxySelection) {
      this.m_animProxySelection.GotoStartAndStop(true);
      this.m_animProxySelection = null;
    };
    if IsDefined(this.m_animProxyQuest) {
      this.m_animProxyQuest.Stop(true);
    };
    if this.m_contactData.questRelated {
      playbackOptions.loopType = inkanimLoopType.PingPong;
      playbackOptions.loopInfinite = true;
      this.m_animProxyQuest = this.PlayLibraryAnimation(n"questMarker", playbackOptions);
    };
    if ArraySize(this.m_contactData.unreadMessages) > 0 {
      inkWidgetRef.SetVisible(this.m_msgIndicator, true);
      inkTextRef.SetText(this.m_msgCount, ToString(ArraySize(this.m_contactData.unreadMessages)));
    } else {
      inkWidgetRef.SetVisible(this.m_msgIndicator, false);
    };
  }

  protected cb func OnSelected(itemController: wref<inkVirtualCompoundItemController>, discreteNav: Bool) -> Bool {
    if IsDefined(this.m_animProxySelection) {
      this.m_animProxySelection.GotoStartAndStop(true);
      this.m_animProxySelection = null;
    };
    this.m_animProxySelection = this.PlayLibraryAnimation(n"contactSelected");
    this.GetRootWidget().SetState(n"Active");
  }

  protected cb func OnDeselected(itemController: wref<inkVirtualCompoundItemController>) -> Bool {
    if IsDefined(this.m_animProxySelection) {
      this.m_animProxySelection.GotoStartAndStop(true);
      this.m_animProxySelection = null;
    };
    this.GetRootWidget().SetState(n"Default");
  }
}
