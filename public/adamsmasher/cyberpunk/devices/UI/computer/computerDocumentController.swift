
public class ComputerDocumentWidgetController extends DeviceInkLogicControllerBase {

  @attrib(category, "Widget Refs")
  protected edit let m_titleWidget: inkTextRef;

  @attrib(category, "Widget Refs")
  protected edit let m_ownerNameWidget: inkTextRef;

  @attrib(category, "Widget Refs")
  protected edit let m_dateWidget: inkTextRef;

  @attrib(category, "Widget Refs")
  protected edit let m_datePanelWidget: inkTextRef;

  @attrib(category, "Widget Refs")
  protected edit let m_ownerPanelWidget: inkTextRef;

  @attrib(category, "Widget Refs")
  protected edit let m_textContentWidget: inkTextRef;

  @attrib(category, "Widget Refs")
  protected edit let m_textContentHolder: inkWidgetRef;

  @attrib(category, "Widget Refs")
  protected edit let m_videoContentWidget: inkVideoRef;

  @attrib(category, "Widget Refs")
  protected edit let m_imageContentWidget: inkImageRef;

  @attrib(category, "Widget Refs")
  protected edit let m_closeButtonWidget: inkWidgetRef;

  protected let m_documentType: EDocumentType;

  private let m_lastPlayedVideo: ResRef;

  public func Initialize(gameController: ref<ComputerInkGameController>, widgetData: SDocumentWidgetPackage) -> Void {
    inkTextRef.SetText(this.m_titleWidget, widgetData.title);
    this.m_documentType = widgetData.documentType;
    if IsStringValid(widgetData.owner) {
      inkTextRef.SetText(this.m_ownerNameWidget, widgetData.owner);
      if Equals(this.m_documentType, EDocumentType.MAIL) {
        inkTextRef.SetLocalizedTextScript(this.m_ownerPanelWidget, "LocKey#13237");
      } else {
        inkTextRef.SetLocalizedTextScript(this.m_ownerPanelWidget, "LocKey#13244");
      };
    } else {
      inkWidgetRef.SetVisible(this.m_ownerNameWidget, false);
      inkWidgetRef.SetVisible(this.m_ownerPanelWidget, false);
    };
    if IsStringValid(widgetData.date) {
      inkTextRef.SetText(this.m_dateWidget, widgetData.date);
      if Equals(this.m_documentType, EDocumentType.MAIL) {
        inkTextRef.SetLocalizedTextScript(this.m_datePanelWidget, "LocKey#13239");
      } else {
        inkTextRef.SetLocalizedTextScript(this.m_datePanelWidget, "LocKey#13236");
      };
    } else {
      inkWidgetRef.SetVisible(this.m_dateWidget, false);
      inkWidgetRef.SetVisible(this.m_datePanelWidget, false);
    };
    this.ResolveContent(widgetData);
    this.RegisterCloseButtonCallback(gameController);
    this.m_isInitialized = true;
  }

  private final func ResolveContent(widgetData: SDocumentWidgetPackage) -> Void {
    let imageRecord: wref<UIIcon_Record>;
    if Equals(this.m_lastPlayedVideo, widgetData.videoPath) && inkVideoRef.IsPlayingVideo(this.m_videoContentWidget) {
      inkWidgetRef.SetVisible(this.m_videoContentWidget, true);
      return;
    };
    this.StopVideo();
    if inkWidgetRef.Get(this.m_imageContentWidget) != null && TDBID.IsValid(widgetData.image) {
      imageRecord = TweakDBInterface.GetUIIconRecord(widgetData.image);
      if IsDefined(imageRecord) {
        inkWidgetRef.SetVisible(this.m_textContentWidget, false);
        inkWidgetRef.SetVisible(this.m_textContentHolder, false);
        inkWidgetRef.SetVisible(this.m_imageContentWidget, true);
        this.SetTexture(this.m_imageContentWidget, widgetData.image);
      };
    } else {
      if ResRef.IsValid(widgetData.videoPath) {
        inkWidgetRef.SetVisible(this.m_imageContentWidget, false);
        inkWidgetRef.SetVisible(this.m_textContentWidget, false);
        inkWidgetRef.SetVisible(this.m_textContentHolder, false);
        inkTextRef.SetText(this.m_textContentWidget, "");
        inkVideoRef.SetVideoPath(this.m_videoContentWidget, widgetData.videoPath);
        inkWidgetRef.SetVisible(this.m_videoContentWidget, true);
        inkVideoRef.Play(this.m_videoContentWidget);
        inkVideoRef.SetLoop(this.m_videoContentWidget, true);
        this.m_lastPlayedVideo = widgetData.videoPath;
      } else {
        inkWidgetRef.SetVisible(this.m_imageContentWidget, false);
        inkWidgetRef.SetVisible(this.m_textContentHolder, true);
        inkWidgetRef.SetVisible(this.m_textContentWidget, true);
        inkTextRef.SetText(this.m_textContentWidget, widgetData.content);
      };
    };
  }

  public final func StopVideo() -> Void {
    inkVideoRef.Stop(this.m_videoContentWidget);
    inkWidgetRef.SetVisible(this.m_videoContentWidget, false);
  }

  protected final func RegisterCloseButtonCallback(gameController: ref<DeviceInkGameControllerBase>) -> Void {
    let controller: ref<DeviceButtonLogicControllerBase>;
    if !this.m_isInitialized {
      if IsDefined(inkWidgetRef.Get(this.m_closeButtonWidget)) {
        if Equals(this.m_documentType, EDocumentType.MAIL) {
          inkWidgetRef.RegisterToCallback(this.m_closeButtonWidget, n"OnRelease", gameController, n"OnHideMailCallback");
        } else {
          inkWidgetRef.RegisterToCallback(this.m_closeButtonWidget, n"OnRelease", gameController, n"OnHideFileCallback");
        };
        controller = inkWidgetRef.GetController(this.m_closeButtonWidget) as DeviceButtonLogicControllerBase;
        if IsDefined(controller) {
          controller.RegisterAudioCallbacks(gameController);
        };
      };
    };
  }

  public final func GetDocumentType() -> EDocumentType {
    return this.m_documentType;
  }
}
