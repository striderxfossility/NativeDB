
public class TerminalMainLayoutWidgetController extends inkLogicController {

  @attrib(category, "Widget Refs")
  private edit let m_thumbnailsListSlot: inkWidgetRef;

  @attrib(category, "Widget Refs")
  private edit let m_deviceSlot: inkWidgetRef;

  @attrib(category, "Widget Refs")
  private edit let m_returnButton: inkWidgetRef;

  @attrib(category, "Widget Refs")
  private edit let m_titleWidget: inkTextRef;

  @attrib(category, "Widget Refs")
  private edit let m_backgroundImage: inkImageRef;

  @attrib(category, "Widget Refs")
  private edit let m_backgroundImageTrace: inkImageRef;

  protected let m_isInitialized: Bool;

  private let m_main_canvas: wref<inkWidget>;

  protected cb func OnInitialize() -> Bool {
    this.m_main_canvas = this.GetRootWidget();
    inkWidgetRef.SetVisible(this.m_returnButton, false);
  }

  public func Initialize(gameController: ref<TerminalInkGameControllerBase>) -> Void {
    let title: String;
    if !this.m_isInitialized {
      this.m_main_canvas.SetVisible(true);
    };
    if IsDefined(inkWidgetRef.Get(this.m_titleWidget)) {
      title = gameController.GetTerminalTitle();
      if IsStringValid(title) {
        inkTextRef.SetLocalizedTextScript(this.m_titleWidget, title);
      };
    };
    this.m_isInitialized = true;
  }

  public final func HideBackgroundIcon() -> Void {
    inkWidgetRef.SetVisible(this.m_backgroundImage, false);
    inkWidgetRef.SetVisible(this.m_backgroundImageTrace, false);
  }

  public final func ShowBackgroundIcon() -> Void {
    inkWidgetRef.SetVisible(this.m_backgroundImage, true);
    inkWidgetRef.SetVisible(this.m_backgroundImageTrace, true);
  }

  public final const func GetReturnButton() -> ref<inkWidget> {
    return inkWidgetRef.Get(this.m_returnButton);
  }

  public final const func GetDevicesSlot() -> ref<inkWidget> {
    return inkWidgetRef.Get(this.m_deviceSlot);
  }

  public final const func GetThumbnailListSlot() -> ref<inkWidget> {
    return inkWidgetRef.Get(this.m_thumbnailsListSlot);
  }

  public final const func GetMainCanvas() -> ref<inkWidget> {
    return this.m_main_canvas;
  }
}
