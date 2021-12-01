
public class EngagementScreenGameController extends gameuiMenuGameController {

  private edit let m_backgroundVideo: inkVideoRef;

  private edit let m_text: inkRichTextBoxRef;

  private edit let m_textShadow: inkRichTextBoxRef;

  private edit let m_textContainer: inkCompoundRef;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  protected cb func OnInitialize() -> Bool {
    inkVideoRef.Play(this.m_backgroundVideo);
  }

  protected cb func OnUninitialize() -> Bool {
    inkVideoRef.Stop(this.m_backgroundVideo);
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
  }
}
