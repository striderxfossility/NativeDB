
public class SimpleBinkGameController extends DeviceInkGameControllerBase {

  @default(SimpleBinkGameController, true)
  protected let playCommonAd: Bool;

  @attrib(category, "OBSOLETE - Widget Paths")
  @default(SimpleBinkGameController, Video1)
  protected edit let m_Video1Path: CName;

  @attrib(category, "OBSOLETE - Widget Paths")
  @default(SimpleBinkGameController, Video2)
  protected edit let m_Video2Path: CName;

  @attrib(category, "Widget Refs")
  private edit let m_Video1: inkVideoRef;

  @attrib(category, "Widget Refs")
  private edit let m_Video2: inkVideoRef;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    if this.playCommonAd {
      this.StartVideo1();
    };
  }

  protected cb func OnUninitialize() -> Bool;

  public final func switchAd() -> Void {
    if this.playCommonAd {
      this.StartVideo2();
      this.playCommonAd = false;
    } else {
      this.StartVideo1();
      this.playCommonAd = true;
    };
  }

  public final func StartVideo2() -> Void {
    inkVideoRef.Stop(this.m_Video2);
    inkWidgetRef.SetVisible(this.m_Video1, false);
    inkWidgetRef.SetVisible(this.m_Video2, true);
    inkVideoRef.Play(this.m_Video2);
  }

  private final func StartVideo1() -> Void {
    inkVideoRef.Stop(this.m_Video1);
    inkWidgetRef.SetVisible(this.m_Video2, false);
    inkWidgetRef.SetVisible(this.m_Video1, true);
    inkVideoRef.Play(this.m_Video1);
  }
}
