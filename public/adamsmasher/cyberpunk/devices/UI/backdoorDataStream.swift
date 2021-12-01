
public class BackdoorDataStreamController extends BackdoorInkGameController {

  private edit let m_idleGroup: inkWidgetRef;

  private edit let m_idleVPanelC1: inkWidgetRef;

  private edit let m_idleVPanelC2: inkWidgetRef;

  private edit let m_idleVPanelC3: inkWidgetRef;

  private edit let m_idleVPanelC4: inkWidgetRef;

  private edit let m_hackedGroup: inkWidgetRef;

  private edit let m_idleCanvas1: inkWidgetRef;

  private edit let m_idleCanvas2: inkWidgetRef;

  private edit let m_idleCanvas3: inkWidgetRef;

  private edit let m_idleCanvas4: inkWidgetRef;

  private edit let m_canvasC1: inkWidgetRef;

  private edit let m_canvasC2: inkWidgetRef;

  private edit let m_canvasC3: inkWidgetRef;

  private edit let m_canvasC4: inkWidgetRef;

  protected func StartGlitching() -> Void {
    inkWidgetRef.SetVisible(this.m_idleVPanelC1, true);
    inkWidgetRef.SetVisible(this.m_idleVPanelC2, true);
    inkWidgetRef.SetVisible(this.m_idleVPanelC3, true);
    inkWidgetRef.SetVisible(this.m_idleVPanelC4, true);
    this.PlayLibraryAnimation(n"glitchingModules");
  }

  protected func EnableHackedGroup() -> Void;

  protected func ShutdownModule(module: Int32) -> Void {
    if module == 0 {
      this.PlayLibraryAnimation(n"shutdownModules");
    };
  }

  protected func BootModule(module: Int32) -> Void {
    if module == 0 {
      this.PlayLibraryAnimation(n"bootModules");
    };
  }
}

public class TextSpawnerController extends inkLogicController {

  @default(TextSpawnerController, 6)
  private edit let amountOfRows: Int32;

  private edit let lineTextWidgetID: CName;

  private let texts: array<wref<inkWidget>>;

  protected cb func OnInitialize() -> Bool {
    let text: String;
    let widget: wref<inkText>;
    let i: Int32 = 0;
    while i < this.amountOfRows {
      widget = this.SpawnFromLocal(this.GetRootWidget(), this.lineTextWidgetID) as inkText;
      widget.SetAnchor(inkEAnchor.CenterLeft);
      text = widget.GetText();
      widget.SetTextDirect(text);
      ArrayPush(this.texts, widget);
      i += 1;
    };
  }
}
