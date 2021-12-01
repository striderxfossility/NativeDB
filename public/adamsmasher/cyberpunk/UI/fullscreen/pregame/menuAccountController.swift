
public native class MenuAccountLogicController extends inkLogicController {

  private edit let m_playerId: inkTextRef;

  private edit let m_changeAccountLabelTextRef: inkTextRef;

  private edit let m_inputDisplayControllerRef: inkWidgetRef;

  private let m_changeAccountEnabled: Bool;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
  }

  protected cb func OnButtonRelease(evt: ref<inkPointerEvent>) -> Bool {
    if this.m_changeAccountEnabled {
      if evt.IsAction(n"change_account") {
        this.ChangeAccountRequest();
      };
    };
  }

  private final func SetChangeAccountEnabled(enabled: Bool) -> Void {
    this.m_changeAccountEnabled = enabled;
    inkWidgetRef.SetVisible(this.m_inputDisplayControllerRef, enabled);
    inkWidgetRef.SetVisible(this.m_changeAccountLabelTextRef, enabled);
    inkWidgetRef.SetVisible(this.m_playerId, enabled);
  }

  private final func SetPlayerName(playerName: String) -> Void {
    inkTextRef.SetText(this.m_playerId, playerName);
  }

  private final native func ChangeAccountRequest() -> Void;
}
