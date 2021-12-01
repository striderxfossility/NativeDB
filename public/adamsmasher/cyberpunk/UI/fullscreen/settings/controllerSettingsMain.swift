
public class ControllerSettingsGameController extends gameuiMenuGameController {

  private edit let m_buttonHintsManagerRef: inkWidgetRef;

  private let m_buttonHintsController: wref<ButtonHints>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_buttonHintsController = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsManagerRef), r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root").GetController() as ButtonHints;
    this.m_buttonHintsController.AddButtonHint(n"back", GetLocalizedText("Common-Access-Close"));
  }
}
