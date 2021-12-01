
public class sampleUIAnchorButton extends inkLogicController {

  public edit let anchorLocation: inkEAnchor;

  protected cb func OnInitialize() -> Bool {
    this.GetWidget(n"Background").SetAnchor(this.anchorLocation);
  }
}
