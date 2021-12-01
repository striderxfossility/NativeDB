
public class ComputerBannerWidgetController extends DeviceInkLogicControllerBase {

  @attrib(category, "Widget Refs")
  protected edit let m_titleWidget: inkTextRef;

  @attrib(category, "Widget Refs")
  protected edit let m_textContentWidget: inkTextRef;

  @attrib(category, "Widget Refs")
  protected edit let m_videoContentWidget: inkVideoRef;

  @attrib(category, "Widget Refs")
  protected edit let m_imageContentWidget: inkImageRef;

  @attrib(category, "Widget Refs")
  protected edit let m_bannerButtonWidget: inkWidgetRef;

  private let m_bannerData: SBannerWidgetPackage;

  private let m_lastPlayedVideo: ResRef;

  public func Initialize(gameController: ref<ComputerInkGameController>, widgetData: SBannerWidgetPackage) -> Void {
    inkTextRef.SetText(this.m_titleWidget, widgetData.title);
    inkTextRef.SetText(this.m_textContentWidget, widgetData.description);
    this.ResolveContent(widgetData.content);
    this.RegisterBannerCallback(gameController);
    this.m_bannerData = widgetData;
    this.m_isInitialized = true;
  }

  protected final func ResolveContent(content: ResRef) -> Void {
    if Equals(this.m_lastPlayedVideo, content) && inkVideoRef.IsPlayingVideo(this.m_videoContentWidget) {
      inkWidgetRef.SetVisible(this.m_videoContentWidget, true);
      return;
    };
    this.StopVideo();
    inkVideoRef.SetVideoPath(this.m_videoContentWidget, content);
    inkWidgetRef.SetVisible(this.m_imageContentWidget, false);
    inkWidgetRef.SetVisible(this.m_videoContentWidget, true);
    inkVideoRef.Play(this.m_videoContentWidget);
    inkVideoRef.SetLoop(this.m_videoContentWidget, true);
    this.m_lastPlayedVideo = content;
  }

  public final func StopVideo() -> Void {
    inkVideoRef.Stop(this.m_videoContentWidget);
    inkWidgetRef.SetVisible(this.m_videoContentWidget, false);
  }

  protected final func RegisterBannerCallback(gameController: ref<DeviceInkGameControllerBase>) -> Void {
    let controller: ref<DeviceButtonLogicControllerBase>;
    if !this.m_isInitialized {
      if IsDefined(inkWidgetRef.Get(this.m_bannerButtonWidget)) {
        controller = inkWidgetRef.GetController(this.m_bannerButtonWidget) as DeviceButtonLogicControllerBase;
        if IsDefined(controller) {
          controller.RegisterAudioCallbacks(gameController);
        };
      };
      this.GetRootWidget().RegisterToCallback(n"OnRelease", gameController, n"OnShowFullBannerCallback");
    };
  }

  public final func GetBannerData() -> SBannerWidgetPackage {
    return this.m_bannerData;
  }
}
