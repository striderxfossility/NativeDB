
public class fullscreenDpadSupported extends inkLogicController {

  public edit let m_targetPath_DpadUp: wref<inkWidget>;

  public edit let m_targetPath_DpadDown: wref<inkWidget>;

  public edit let m_targetPath_DpadLeft: wref<inkWidget>;

  public edit let m_targetPath_DpadRight: wref<inkWidget>;

  protected cb func OnInitialize() -> Bool {
    this.GetRootWidget().RegisterToCallback(n"OnRelease", this, n"OnRelease");
  }

  public final func SetDpadTargets(argLeft: wref<inkWidget>, argUp: wref<inkWidget>, argRight: wref<inkWidget>, argDown: wref<inkWidget>) -> Void {
    if IsDefined(argUp) {
      this.m_targetPath_DpadUp = argUp;
    };
    if IsDefined(argDown) {
      this.m_targetPath_DpadDown = argDown;
    };
    if IsDefined(argLeft) {
      this.m_targetPath_DpadLeft = argLeft;
    };
    if IsDefined(argRight) {
      this.m_targetPath_DpadRight = argRight;
    };
  }

  public final func SetDpadTargetsInList(mainList: ref<inkVerticalPanel>) -> Void {
    let currLogic: wref<inkButtonDpadSupportedController>;
    let currWidget: wref<inkWidget>;
    let lastWidget: wref<inkWidget>;
    let numItems: Int32 = mainList.GetNumChildren();
    let j: Int32 = 0;
    while j < numItems {
      currWidget = mainList.GetWidget(j);
      currLogic = currWidget.GetController() as inkButtonDpadSupportedController;
      currLogic.SetDpadUpTarget(j == 0 ? mainList.GetWidget(numItems - 1) : lastWidget);
      lastWidget = currWidget;
      currLogic.SetDpadDownTarget(j == numItems - 1 ? mainList.GetWidget(0) : mainList.GetWidget(j + 1));
      j = j + 1;
    };
  }

  protected cb func OnRelease(e: ref<inkPointerEvent>) -> Bool {
    let actionName: CName;
    let targetWidget: wref<inkWidget>;
    let currLogic: wref<inkButtonDpadSupportedController> = e.GetTarget().GetController() as inkButtonDpadSupportedController;
    if e.IsAction(n"up_button") {
      targetWidget = IsDefined(currLogic) ? currLogic.m_targetPath_DpadUp : this.m_targetPath_DpadUp;
    } else {
      if e.IsAction(n"down_button") {
        targetWidget = IsDefined(currLogic) ? currLogic.m_targetPath_DpadDown : this.m_targetPath_DpadDown;
      } else {
        if e.IsAction(n"left_button") {
          targetWidget = IsDefined(currLogic) ? currLogic.m_targetPath_DpadLeft : this.m_targetPath_DpadLeft;
        } else {
          if Equals(actionName, n"right_button") {
            targetWidget = IsDefined(currLogic) ? currLogic.m_targetPath_DpadRight : this.m_targetPath_DpadRight;
          };
        };
      };
    };
    if IsDefined(targetWidget) {
      this.SetCursorOverWidget(targetWidget);
    };
  }
}
