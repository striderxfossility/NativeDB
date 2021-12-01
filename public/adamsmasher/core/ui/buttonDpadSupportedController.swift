
public class inkButtonDpadSupportedController extends inkButtonAnimatedController {

  public edit let m_targetPath_DpadUp: wref<inkWidget>;

  public edit let m_targetPath_DpadDown: wref<inkWidget>;

  public edit let m_targetPath_DpadLeft: wref<inkWidget>;

  public edit let m_targetPath_DpadRight: wref<inkWidget>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
  }

  public final func SetDpadTargets(argLeft: wref<inkWidget>, argUp: wref<inkWidget>, argRight: wref<inkWidget>, argDown: wref<inkWidget>) -> Void {
    if IsDefined(argLeft) {
      this.m_targetPath_DpadLeft = argLeft;
    };
    if IsDefined(argUp) {
      this.m_targetPath_DpadUp = argUp;
    };
    if IsDefined(argRight) {
      this.m_targetPath_DpadRight = argRight;
    };
    if IsDefined(argDown) {
      this.m_targetPath_DpadDown = argDown;
    };
  }

  public final func SetDpadLeftTarget(argNew: wref<inkWidget>) -> Void {
    this.m_targetPath_DpadLeft = argNew;
  }

  public final func SetDpadUpTarget(argNew: wref<inkWidget>) -> Void {
    this.m_targetPath_DpadUp = argNew;
  }

  public final func SetDpadRightTarget(argNew: wref<inkWidget>) -> Void {
    this.m_targetPath_DpadRight = argNew;
  }

  public final func SetDpadDownTarget(argNew: wref<inkWidget>) -> Void {
    this.m_targetPath_DpadDown = argNew;
  }
}
