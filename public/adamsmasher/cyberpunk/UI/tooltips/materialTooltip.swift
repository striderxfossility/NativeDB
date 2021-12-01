
public class MaterialTooltip extends AGenericTooltipController {

  protected edit let m_titleWrapper: inkWidgetRef;

  protected edit let m_descriptionWrapper: inkWidgetRef;

  protected edit let m_descriptionLine: inkWidgetRef;

  protected edit let m_Title: inkTextRef;

  protected edit let m_BasePrice: inkTextRef;

  protected edit let m_Price: inkTextRef;

  private let m_animProxy: ref<inkAnimProxy>;

  public func SetData(tooltipData: ref<ATooltipData>) -> Void {
    let priceReducted: Bool;
    let messageData: ref<MaterialTooltipData> = tooltipData as MaterialTooltipData;
    if IsDefined(messageData) {
      inkTextRef.SetText(this.m_Title, messageData.Title);
      priceReducted = messageData.BaseMaterialQuantity != messageData.MaterialQuantity;
      inkTextRef.SetText(this.m_BasePrice, IntToString(messageData.BaseMaterialQuantity));
      inkTextRef.SetText(this.m_Price, IntToString(messageData.MaterialQuantity));
      inkWidgetRef.SetVisible(this.m_descriptionWrapper, priceReducted);
      inkWidgetRef.SetVisible(this.m_descriptionLine, priceReducted && NotEquals(messageData.Title, ""));
      inkWidgetRef.SetVisible(this.m_titleWrapper, NotEquals(messageData.Title, ""));
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
