
public class DeviceInkLogicControllerBase extends inkLogicController {

  @attrib(category, "Widget Refs")
  protected edit let m_targetWidgetRef: inkWidgetRef;

  @attrib(category, "Widget Refs")
  protected edit let m_displayNameWidget: inkTextRef;

  protected let m_isInitialized: Bool;

  protected let m_targetWidget: wref<inkWidget>;

  protected cb func OnInitialize() -> Bool {
    if inkWidgetRef.Get(this.m_targetWidgetRef) == null {
      this.m_targetWidget = this.GetRootWidget();
    } else {
      this.m_targetWidget = inkWidgetRef.Get(this.m_targetWidgetRef);
    };
  }

  public final func IsInitialized() -> Bool {
    return this.m_isInitialized;
  }
}
