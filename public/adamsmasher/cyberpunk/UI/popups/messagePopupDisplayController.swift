
public class MessagePopupDisplayController extends inkLogicController {

  protected edit let m_title: inkTextRef;

  protected edit let m_message: inkTextRef;

  protected edit let m_image: inkImageRef;

  public final func SetData(data: PopupData, opt settings: PopupSettings) -> Void {
    inkTextRef.SetText(this.m_title, data.title);
    inkTextRef.SetText(this.m_message, data.message);
    if TDBID.IsValid(data.iconID) {
      inkWidgetRef.SetVisible(this.m_image, true);
      InkImageUtils.RequestSetImage(this, this.m_image, data.iconID);
    } else {
      inkWidgetRef.SetVisible(this.m_image, false);
    };
  }
}
