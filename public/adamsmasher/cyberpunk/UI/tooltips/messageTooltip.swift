
public class MessageTooltip extends AGenericTooltipController {

  protected edit let m_Title: inkTextRef;

  protected edit let m_Description: inkTextRef;

  private let m_animProxy: ref<inkAnimProxy>;

  public func SetData(tooltipData: ref<ATooltipData>) -> Void {
    let messageData: ref<MessageTooltipData> = tooltipData as MessageTooltipData;
    if IsDefined(messageData) {
      inkTextRef.SetText(this.m_Title, messageData.Title);
      if messageData.TitleLocalizationPackage.GetParamsCount() > 0 {
        inkTextRef.SetTextParameters(this.m_Title, messageData.TitleLocalizationPackage.GetTextParams());
      };
      inkTextRef.SetText(this.m_Description, messageData.Description);
      if messageData.DescriptionLocalizationPackage.GetParamsCount() > 0 {
        inkTextRef.SetTextParameters(this.m_Description, messageData.DescriptionLocalizationPackage.GetTextParams());
      };
    };
  }

  public func Show() -> Void {
    if !this.m_Root.IsVisible() {
      this.PlayAnim(n"description_tooltip_intro", n"OnIntroComplete", true);
      this.m_Root.SetAffectsLayoutWhenHidden(true);
    };
  }

  private final func PlayAnim(animName: CName, callback: CName, opt forceVisible: Bool) -> Void {
    if forceVisible {
      this.m_Root.SetVisible(true);
    };
    if this.m_animProxy != null {
      this.m_animProxy.Stop(true);
      this.m_animProxy = null;
    };
    this.m_animProxy = this.PlayLibraryAnimation(animName);
    if IsDefined(this.m_animProxy) {
      this.m_animProxy.RegisterToCallback(inkanimEventType.OnFinish, this, callback);
    };
  }

  protected cb func OnIntroComplete(proxy: ref<inkAnimProxy>) -> Bool;

  protected cb func OnOutroComplete(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_Root.SetVisible(false);
    this.m_Root.SetAffectsLayoutWhenHidden(false);
  }
}

public class MessageDescTooltip extends MessageTooltip {

  protected edit let m_titleWrapper: inkWidgetRef;

  protected edit let m_descriptionWrapper: inkWidgetRef;

  protected edit let m_descriptionLine: inkWidgetRef;

  public func SetData(tooltipData: ref<ATooltipData>) -> Void {
    let messageData: ref<MessageTooltipData>;
    this.SetData(tooltipData);
    messageData = tooltipData as MessageTooltipData;
    if IsDefined(messageData) {
      inkWidgetRef.SetVisible(this.m_descriptionWrapper, NotEquals(messageData.Description, ""));
      inkWidgetRef.SetVisible(this.m_descriptionLine, NotEquals(messageData.Description, "") && NotEquals(messageData.Title, ""));
      inkWidgetRef.SetVisible(this.m_titleWrapper, NotEquals(messageData.Title, ""));
    };
  }
}
