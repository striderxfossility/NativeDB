
public class PhotoModeListController extends ListController {

  private edit let m_LogoWidget: inkWidgetRef;

  private edit let m_Panel: inkVerticalPanelRef;

  private let m_fadeAnim: ref<inkAnimProxy>;

  private let m_isAnimating: Bool;

  private let m_animationTime: Float;

  private let m_animationTarget: Float;

  private let m_elementsAnimationTime: Float;

  private let m_elementsAnimationDelay: Float;

  private let m_currentElementAnimation: Int32;

  public final func SetReversedUI(isReversed: Bool) -> Void {
    let listElement: wref<inkWidget>;
    let photoModeListItem: ref<PhotoModeMenuListItem>;
    let i: Int32 = 0;
    while i < this.Size() {
      listElement = this.GetItemAt(i);
      photoModeListItem = listElement.GetControllerByType(n"PhotoModeMenuListItem") as PhotoModeMenuListItem;
      photoModeListItem.SetReversedUI(isReversed);
      i += 1;
    };
  }

  private final func OnVisbilityChanged(visible: Bool) -> Void {
    let controller: ref<PhotoModeMenuListItem>;
    let listElement: wref<inkWidget>;
    let i: Int32 = 0;
    while i < this.Size() {
      listElement = this.GetItemAt(i);
      if IsDefined(listElement) {
        controller = listElement.GetControllerByType(n"PhotoModeMenuListItem") as PhotoModeMenuListItem;
        if IsDefined(controller) {
          controller.OnVisbilityChanged(visible);
        };
      };
      i += 1;
    };
  }

  private final func PlayFadeAnimation(fadeIn: Bool) -> Void {
    this.m_elementsAnimationTime = 0.00;
    this.m_currentElementAnimation = 0;
    if fadeIn {
      this.GetRootWidget().SetVisible(true);
      this.SetAllItemsOpacity(0.00);
      this.PlayLibraryAnimation(n"list_container_in");
      this.OnVisbilityChanged(true);
    } else {
      this.PlayLibraryAnimation(n"list_container_out");
    };
  }

  private final func PlayFadeElementAnimation(fadeIn: Bool) -> Void {
    let listElement: wref<inkWidget> = this.GetItemAt(this.m_currentElementAnimation);
    let photoModeListItem: ref<PhotoModeMenuListItem> = listElement.GetControllerByType(n"PhotoModeMenuListItem") as PhotoModeMenuListItem;
    if fadeIn {
      listElement.SetOpacity(1.00);
      photoModeListItem.PlayLibraryAnimation(n"option_in");
    } else {
      photoModeListItem.PlayLibraryAnimation(n"option_out");
    };
    this.m_elementsAnimationTime = this.m_elementsAnimationDelay;
    this.m_currentElementAnimation += 1;
    if this.m_currentElementAnimation >= this.Size() {
      this.m_currentElementAnimation = -1;
      if !fadeIn {
        this.GetRootWidget().SetVisible(false);
        this.OnVisbilityChanged(false);
      };
    };
  }

  private final func SetAllItemsOpacity(opacity: Float) -> Void {
    let listElement: wref<inkWidget>;
    let i: Int32 = 0;
    while i < this.Size() {
      listElement = this.GetItemAt(i);
      listElement.SetOpacity(opacity);
      i += 1;
    };
  }

  public final func ShowAnimated(delay: Float) -> Void {
    this.m_animationTime = -delay;
    this.m_animationTarget = 1.00;
    this.m_isAnimating = true;
    this.m_currentElementAnimation = -1;
  }

  public final func HideAnimated(delay: Float) -> Void {
    this.m_animationTime = -delay;
    this.m_animationTarget = 0.00;
    this.m_isAnimating = true;
    this.m_currentElementAnimation = -1;
  }

  public final func Update(timeDelta: Float) -> Void {
    if this.m_isAnimating {
      this.m_animationTime += timeDelta;
      if this.m_animationTime >= 0.00 {
        this.PlayFadeAnimation(this.m_animationTarget == 1.00);
        this.m_isAnimating = false;
      };
    };
    if this.m_currentElementAnimation >= 0 {
      this.m_elementsAnimationTime -= timeDelta;
      if this.m_elementsAnimationTime <= 0.00 {
        this.PlayFadeElementAnimation(this.m_animationTarget == 1.00);
      };
    };
  }

  public final func PostInitItems() -> Void {
    this.m_elementsAnimationTime = 0.00;
    this.m_elementsAnimationDelay = 0.03;
    this.m_currentElementAnimation = -1;
    this.Refresh();
    inkCompoundRef.ReorderChild(this.m_Panel, inkWidgetRef.Get(this.m_LogoWidget), this.Size());
    this.GetRootWidget().SetVisible(false);
  }

  public final func HandleInputWithVisibilityCheck(e: ref<inkPointerEvent>, opt gameCtrl: wref<inkGameController>) -> Void {
    let widgetHStack: ref<inkHorizontalPanel> = this.GetRootWidget() as inkHorizontalPanel;
    let listElement: wref<inkWidget> = this.GetItemAt(this.GetSelectedIndex());
    let photoModeListItem: ref<PhotoModeMenuListItem> = listElement.GetControllerByType(n"PhotoModeMenuListItem") as PhotoModeMenuListItem;
    let gridSelector: wref<PhotoModeGridList> = photoModeListItem.GetGridSelector();
    if IsDefined(widgetHStack) {
      if e.IsAction(n"left_button") {
        this.SelectPriorVisible(this.GetSelectedIndex());
      } else {
        if e.IsAction(n"right_button") {
          this.SelectNextVisible(this.GetSelectedIndex());
        };
      };
    } else {
      if e.IsAction(n"up_button") {
        if gridSelector == null || Equals(gridSelector.TrySelectUp(), false) {
          this.SelectPriorVisible(this.GetSelectedIndex());
        };
      } else {
        if e.IsAction(n"down_button") {
          if gridSelector == null || Equals(gridSelector.TrySelectDown(), false) {
            this.SelectNextVisible(this.GetSelectedIndex());
          };
        } else {
          if e.IsAction(n"PhotoMode_Left_Button") {
            if IsDefined(gridSelector) {
              gridSelector.TrySelectLeft();
            };
          } else {
            if e.IsAction(n"PhotoMode_Right_Button") {
              if IsDefined(gridSelector) {
                gridSelector.TrySelectRight();
              };
            };
          };
        };
      };
    };
  }

  public final func GetFirstVisibleIndex() -> Int32 {
    let listElement: wref<inkWidget>;
    let i: Int32 = 0;
    while i < this.Size() {
      listElement = this.GetItemAt(i);
      if listElement.IsVisible() {
        return i;
      };
      i += 1;
    };
    return 0;
  }

  protected final func SelectPriorVisible(currentIndex: Int32) -> Bool {
    let listElement: wref<inkWidget>;
    let indexToSet: Int32 = currentIndex - 1;
    if indexToSet >= 0 {
      listElement = this.GetItemAt(indexToSet);
      if !listElement.IsVisible() {
        if this.SelectPriorVisible(indexToSet) {
          this.Prior();
          return true;
        };
        return false;
      };
      this.Prior();
      return true;
    };
    return false;
  }

  protected final func SelectNextVisible(currentIndex: Int32) -> Bool {
    let listElement: wref<inkWidget>;
    let indexToSet: Int32 = currentIndex + 1;
    if indexToSet < this.Size() {
      listElement = this.GetItemAt(indexToSet);
      if !listElement.IsVisible() {
        if this.SelectNextVisible(indexToSet) {
          this.Next();
          return true;
        };
        return false;
      };
      this.Next();
      return true;
    };
    return false;
  }
}
