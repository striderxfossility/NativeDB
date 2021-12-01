
public class sampleUIAnchorController extends inkLogicController {

  public edit let rectangleAnchor: inkRectangleRef;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnRelease", this, n"onButtonRelease");
  }

  public final func onButtonRelease(e: ref<inkPointerEvent>) -> Void {
    let buttonController: ref<sampleUIAnchorButton>;
    if e.IsAction(n"click") {
      buttonController = e.GetTarget().GetController() as sampleUIAnchorButton;
      inkWidgetRef.SetAnchor(this.rectangleAnchor, buttonController.anchorLocation);
    };
  }
}
