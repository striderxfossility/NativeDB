
public class CodexEntryViewController extends inkLogicController {

  private edit let m_titleText: inkTextRef;

  private edit let m_descriptionText: inkTextRef;

  private edit let m_imageWidget: inkImageRef;

  private edit let m_imageWidgetFallback: inkWidgetRef;

  private edit let m_imageWidgetWrapper: inkWidgetRef;

  private edit let m_scrollWidget: inkWidgetRef;

  private edit let m_contentWrapper: inkWidgetRef;

  private edit let m_noEntrySelectedWidget: inkWidgetRef;

  private let m_data: ref<GenericCodexEntryData>;

  private let m_scroll: wref<inkScrollController>;

  protected cb func OnInitialize() -> Bool {
    this.m_scroll = inkWidgetRef.GetControllerByType(this.m_scrollWidget, n"inkScrollController") as inkScrollController;
    inkWidgetRef.SetVisible(this.m_noEntrySelectedWidget, true);
    inkWidgetRef.SetVisible(this.m_contentWrapper, false);
    inkWidgetRef.SetVisible(this.m_imageWidgetFallback, false);
  }

  public final func ShowEntry(data: ref<GenericCodexEntryData>) -> Void {
    let iconRecord: ref<UIIcon_Record>;
    this.m_data = data;
    this.m_scroll = inkWidgetRef.GetControllerByType(this.m_scrollWidget, n"inkScrollController") as inkScrollController;
    this.m_scroll.SetScrollPosition(0.00);
    inkTextRef.SetText(this.m_descriptionText, data.m_description);
    if inkWidgetRef.IsValid(this.m_titleText) {
      inkTextRef.SetText(this.m_titleText, data.m_title);
    };
    if inkWidgetRef.IsValid(this.m_imageWidget) {
      if TDBID.IsValid(this.m_data.m_imageId) {
        iconRecord = TweakDBInterface.GetUIIconRecord(this.m_data.m_imageId);
        inkWidgetRef.SetVisible(this.m_imageWidget, true);
        inkImageRef.SetAtlasResource(this.m_imageWidget, iconRecord.AtlasResourcePath());
        inkImageRef.SetTexturePart(this.m_imageWidget, iconRecord.AtlasPartName());
        inkWidgetRef.SetVisible(this.m_imageWidgetWrapper, true);
      } else {
        inkWidgetRef.SetVisible(this.m_imageWidget, false);
        inkWidgetRef.SetVisible(this.m_imageWidgetWrapper, false);
      };
    };
    inkWidgetRef.SetVisible(this.m_noEntrySelectedWidget, false);
    inkWidgetRef.SetVisible(this.m_contentWrapper, true);
  }

  protected cb func OnIconCallback(e: ref<iconAtlasCallbackData>) -> Bool {
    if NotEquals(e.loadResult, inkIconResult.Success) {
      inkWidgetRef.SetVisible(this.m_imageWidget, false);
      inkWidgetRef.SetVisible(this.m_imageWidgetWrapper, false);
    } else {
      inkWidgetRef.SetVisible(this.m_imageWidget, true);
      inkWidgetRef.SetVisible(this.m_imageWidgetWrapper, true);
    };
  }
}
