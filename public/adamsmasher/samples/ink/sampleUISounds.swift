
public class sampleUISoundsLogicController extends inkLogicController {

  private let textWidget: wref<inkText>;

  protected cb func OnInitialize() -> Bool {
    this.textWidget = this.GetWidget(n"sample_button/button_text") as inkText;
  }

  public final func OnHoverOver(button: wref<inkWidget>) -> Void {
    this.textWidget.SetText("Press to start scanning");
  }

  public final func OnHoverOut(button: wref<inkWidget>) -> Void {
    this.textWidget.SetText("Scanning is stopped");
  }

  public final func OnPress(button: wref<inkWidget>) -> Void {
    this.textWidget.SetText("Scanning ...");
  }

  public final func OnRelease(button: wref<inkWidget>) -> Void {
    this.textWidget.SetText("Scanning complete");
  }
}
