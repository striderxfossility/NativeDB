
public class PhotoModeTopBarController extends inkRadioGroupController {

  private edit const let m_photoModeTogglesArray: array<inkWidgetRef>;

  protected cb func OnInitialize() -> Bool {
    let toggle: ref<PhotoModeToggle>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_photoModeTogglesArray) {
      toggle = inkWidgetRef.GetController(this.m_photoModeTogglesArray[i]) as PhotoModeToggle;
      if IsDefined(toggle) {
        toggle.m_photoModeGroupController = this;
        this.AddToggle(toggle);
      };
      i += 1;
    };
    this.Toggle(0);
  }

  public final func SetInteractive(interactive: Bool) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_photoModeTogglesArray) {
      inkWidgetRef.SetInteractive(this.m_photoModeTogglesArray[i], interactive);
      i += 1;
    };
  }

  public final func SelectToggle(toggleToSelect: ref<PhotoModeToggle>) -> Void {
    let toggle: ref<PhotoModeToggle>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_photoModeTogglesArray) {
      toggle = inkWidgetRef.GetController(this.m_photoModeTogglesArray[i]) as PhotoModeToggle;
      if toggle == toggleToSelect {
        if i != this.GetCurrentIndex() {
          this.Toggle(i);
        };
        return;
      };
      i += 1;
    };
  }

  public final func SetToggleEnabled(index: Int32, enabled: Bool) -> Void {
    let photoModeToggle: wref<PhotoModeToggle> = this.GetController(index) as PhotoModeToggle;
    if IsDefined(photoModeToggle) {
      photoModeToggle.SetEnabledOnTopBar(enabled);
    };
    if !enabled && index == this.GetCurrentIndex() {
      if !this.SelectNextToggle(index) {
        this.SelectPreviousToggle(index);
      };
    };
  }

  protected final func SelectNextToggle(currentIndex: Int32) -> Bool {
    let photoModeToggle: wref<PhotoModeToggle>;
    let indexToSet: Int32 = currentIndex + 1;
    if indexToSet < ArraySize(this.m_photoModeTogglesArray) {
      photoModeToggle = this.GetController(indexToSet) as PhotoModeToggle;
      if !photoModeToggle.GetEnabledOnTopBar() {
        return this.SelectNextToggle(indexToSet);
      };
      this.Toggle(indexToSet);
      return true;
    };
    return false;
  }

  protected final func SelectPreviousToggle(currentIndex: Int32) -> Bool {
    let photoModeToggle: wref<PhotoModeToggle>;
    let indexToSet: Int32 = currentIndex - 1;
    if indexToSet >= 0 {
      photoModeToggle = this.GetController(indexToSet) as PhotoModeToggle;
      if !photoModeToggle.GetEnabledOnTopBar() {
        return this.SelectPreviousToggle(indexToSet);
      };
      this.Toggle(indexToSet);
      return true;
    };
    return false;
  }

  public final func HandleInput(e: ref<inkPointerEvent>, opt gameCtrl: wref<inkGameController>) -> Void {
    if e.IsAction(n"PhotoMode_Next_Menu") {
      this.SelectNextToggle(this.GetCurrentIndex());
    } else {
      if e.IsAction(n"PhotoMode_Prior_Menu") {
        this.SelectPreviousToggle(this.GetCurrentIndex());
      };
    };
  }
}
