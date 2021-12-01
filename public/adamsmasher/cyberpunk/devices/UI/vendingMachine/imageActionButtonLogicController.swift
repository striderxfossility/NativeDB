
public class ImageActionButtonLogicController extends DeviceActionWidgetControllerBase {

  @attrib(category, "Widget Refs")
  private edit let m_tallImageWidget: inkImageRef;

  protected let m_price: Int32;

  public func Initialize(gameController: ref<DeviceInkGameControllerBase>, widgetData: SActionWidgetPackage) -> Void {
    let action: ref<DispenceItemFromVendor>;
    this.Initialize(gameController, widgetData);
    action = widgetData.action as DispenceItemFromVendor;
    if IsDefined(action) {
      inkImageRef.SetTexturePart(this.m_tallImageWidget, action.GetAtlasTexture());
      this.m_price = action.GetPrice();
    };
  }

  public final func GetPrice() -> Int32 {
    return this.m_price;
  }
}
