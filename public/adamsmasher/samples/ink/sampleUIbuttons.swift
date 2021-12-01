
public class SampleUIButtons extends inkLogicController {

  private edit let m_Button: inkWidgetRef;

  private edit let m_Toggle1: inkWidgetRef;

  private edit let m_Toggle2: inkWidgetRef;

  private edit let m_Toggle3: inkWidgetRef;

  private edit let m_RadioGroup: inkWidgetRef;

  private edit let m_Text: inkTextRef;

  protected cb func OnInitialize() -> Bool {
    let radio: wref<inkRadioGroupController>;
    let toggle: wref<inkToggleController>;
    let button: wref<inkButtonController> = inkWidgetRef.GetControllerByType(this.m_Button, n"inkButtonController") as inkButtonController;
    if IsDefined(button) {
      button.RegisterToCallback(n"OnButtonClick", this, n"OnButtonClick");
      button.RegisterToCallback(n"OnButtonHoldComplete", this, n"OnButtonHoldComplete");
    };
    toggle = inkWidgetRef.GetControllerByType(this.m_Toggle1, n"inkToggleController") as inkToggleController;
    if IsDefined(toggle) {
      toggle.RegisterToCallback(n"OnButtonClick", this, n"OnToggle1Click");
      toggle.RegisterToCallback(n"OnToggleChanged", this, n"OnToggle1Changed");
    };
    toggle = inkWidgetRef.GetControllerByType(this.m_Toggle2, n"inkToggleController") as inkToggleController;
    if IsDefined(toggle) {
      toggle.RegisterToCallback(n"OnButtonClick", this, n"OnToggle2Click");
      toggle.RegisterToCallback(n"OnToggleChanged", this, n"OnToggle2Changed");
    };
    toggle = inkWidgetRef.GetControllerByType(this.m_Toggle3, n"inkToggleController") as inkToggleController;
    if IsDefined(toggle) {
      toggle.RegisterToCallback(n"OnButtonClick", this, n"OnToggle3Click");
      toggle.RegisterToCallback(n"OnToggleChanged", this, n"OnToggle3Changed");
    };
    radio = inkWidgetRef.GetControllerByType(this.m_RadioGroup, n"inkRadioGroupController") as inkRadioGroupController;
    if IsDefined(radio) {
      radio.RegisterToCallback(n"OnValueChanged", this, n"OnRadioValueChanged");
    };
  }

  private final func SetText(text: String) -> Void {
    inkTextRef.SetText(this.m_Text, text);
  }

  private final func OnButtonClick(controller: wref<inkButtonController>) -> Void {
    this.SetText("Button clicked");
  }

  private final func OnButtonHoldComplete(controller: wref<inkButtonController>, cancelled: Bool) -> Void {
    this.SetText("Button hold complete: cancelled? " + cancelled);
  }

  private final func OnToggle1Changed(controller: wref<inkToggleController>, isToggled: Bool) -> Void {
    this.SetText("Toggle 1 changed : " + isToggled);
  }

  private final func OnToggle1Click(controller: wref<inkButtonController>) -> Void {
    this.SetText("Toggle 1 clicked");
  }

  private final func OnToggle2Changed(controller: wref<inkToggleController>, isToggled: Bool) -> Void {
    this.SetText("Toggle 2 changed : " + isToggled);
  }

  private final func OnToggle2Click(controller: wref<inkButtonController>) -> Void {
    this.SetText("Toggle 2 clicked");
  }

  private final func OnToggle3Changed(controller: wref<inkToggleController>, isToggled: Bool) -> Void {
    this.SetText("Toggle 3 changed : " + isToggled);
  }

  private final func OnToggle3Click(controller: wref<inkButtonController>) -> Void {
    this.SetText("Toggle 3 clicked");
  }

  private final func OnRadioValueChanged(controller: wref<inkRadioGroupController>, selectedIndex: Int32) -> Void {
    this.SetText("Radio group selected : " + selectedIndex);
  }
}
