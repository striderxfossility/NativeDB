
public abstract class AGenericTooltipController extends inkLogicController {

  protected let m_Root: wref<inkCompoundWidget>;

  protected cb func OnInitialize() -> Bool {
    this.m_Root = this.GetRootCompoundWidget();
  }

  public func SetStyle(styleResPath: ResRef) -> Void;

  public func Show() -> Void {
    this.m_Root.SetVisible(true);
    this.m_Root.SetAffectsLayoutWhenHidden(true);
  }

  public func Hide() -> Void {
    this.m_Root.SetVisible(false);
    this.m_Root.SetAffectsLayoutWhenHidden(false);
  }

  public func SetData(tooltipData: ref<ATooltipData>) -> Void;

  public func Refresh() -> Void;
}
