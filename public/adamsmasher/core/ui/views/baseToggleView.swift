
public abstract class BaseToggleView extends inkLogicController {

  protected let m_ToggleController: wref<inkToggleController>;

  protected let m_OldState: inkEToggleState;

  protected cb func OnInitialize() -> Bool {
    this.m_ToggleController = this.GetControllerByType(n"inkToggleController") as inkToggleController;
    if IsDefined(this.m_ToggleController) {
      this.m_ToggleController.RegisterToCallback(n"OnButtonStateChanged", this, n"OnButtonStateChanged");
      this.m_OldState = this.m_ToggleController.GetToggleState();
      this.ToggleStateChanged(this.m_OldState, this.m_ToggleController.GetToggleState());
    };
  }

  protected cb func OnButtonStateChanged(controller: wref<inkButtonController>, oldState: inkEButtonState, newState: inkEButtonState) -> Bool {
    let newToggleState: inkEToggleState = this.m_ToggleController.GetToggleState();
    this.ToggleStateChanged(this.m_OldState, newToggleState);
    this.m_OldState = newToggleState;
  }

  protected func ToggleStateChanged(oldState: inkEToggleState, newState: inkEToggleState) -> Void;

  public final func GetParentButton() -> wref<inkToggleController> {
    return this.m_ToggleController;
  }
}
