
public abstract class BaseButtonView extends inkLogicController {

  protected let m_ButtonController: wref<inkButtonController>;

  protected cb func OnInitialize() -> Bool {
    this.m_ButtonController = this.GetControllerByBaseType(n"inkButtonController") as inkButtonController;
    if IsDefined(this.m_ButtonController) {
      this.m_ButtonController.RegisterToCallback(n"OnButtonStateChanged", this, n"OnButtonStateChanged");
      this.ButtonStateChanged(this.m_ButtonController.GetState(), this.m_ButtonController.GetState());
      this.m_ButtonController.RegisterToCallback(n"OnButtonHoldProgressChanged", this, n"OnButtonHoldProgressChanged");
      this.ButtonHoldProgressChanged(this.m_ButtonController.GetHoldProgress());
    };
  }

  protected cb func OnButtonStateChanged(controller: wref<inkButtonController>, oldState: inkEButtonState, newState: inkEButtonState) -> Bool {
    this.ButtonStateChanged(oldState, newState);
  }

  protected cb func OnButtonHoldProgressChanged(controller: wref<inkButtonController>, progress: Float) -> Bool {
    this.ButtonHoldProgressChanged(progress);
  }

  protected func ButtonStateChanged(oldState: inkEButtonState, newState: inkEButtonState) -> Void;

  protected func ButtonHoldProgressChanged(progress: Float) -> Void;

  public final func GetParentButton() -> wref<inkButtonController> {
    return this.m_ButtonController;
  }
}
