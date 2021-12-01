
public class TarotPreviewGameController extends inkGameController {

  private edit let m_background: inkWidgetRef;

  private edit let m_previewImage: inkImageRef;

  private edit let m_previewTitle: inkTextRef;

  private edit let m_previewDescription: inkTextRef;

  private let m_data: ref<TarotCardPreviewData>;

  protected cb func OnInitialize() -> Bool {
    this.m_data = this.GetRootWidget().GetUserData(n"TarotCardPreviewData") as TarotCardPreviewData;
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnGlobalRelease");
    this.Show(this.m_data.cardData);
  }

  protected final func Show(data: TarotCardData) -> Void {
    InkImageUtils.RequestSetImage(this, this.m_previewImage, "UIIcon." + NameToString(data.imagePath) + "_BIG");
    inkTextRef.SetText(this.m_previewTitle, data.label);
    inkTextRef.SetText(this.m_previewDescription, data.desc);
    this.PlayLibraryAnimation(n"panel_intro");
  }

  protected cb func OnGlobalRelease(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"cancel") || evt.IsAction(n"click") {
      this.m_data.token.TriggerCallback(null);
    };
  }
}
