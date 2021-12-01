
public native class SelectorController extends inkLogicController {

  @default(SelectorController, Panel/Label)
  public edit let m_labelPath: CName;

  @default(SelectorController, Panel/Value)
  public edit let m_valuePath: CName;

  @default(SelectorController, Panel/LeftArrow)
  public edit let m_leftArrowPath: CName;

  @default(SelectorController, Panel/RightArrow)
  public edit let m_rightArrowPath: CName;

  protected let m_label: wref<inkText>;

  protected let m_value: wref<inkText>;

  protected let m_leftArrow: wref<inkWidget>;

  protected let m_rightArrow: wref<inkWidget>;

  protected let m_rightArrowButton: wref<inkButtonController>;

  protected let m_leftArrowButton: wref<inkButtonController>;

  public final native func AddValues(values: array<String>) -> Void;

  public final native func AddValue(value: String) -> Void;

  public final native func Clear() -> Void;

  public final native func GetValues() -> array<String>;

  public final native func GetValuesCount() -> Int32;

  public final native func IsCyclical() -> Bool;

  public final native func GetCurrIndex() -> Int32;

  public final native func SetCurrIndex(index: Int32) -> Void;

  public final native func SetCurrIndexWithDirection(index: Int32, changeDirection: inkSelectorChangeDirection) -> Void;

  public final native func Next() -> Int32;

  public final native func Prior() -> Void;

  public final func SetLabel(label: String) -> Void {
    if IsDefined(this.m_label) {
      this.m_label.SetText(label);
    };
  }

  protected cb func OnInitialize() -> Bool {
    if IsNameValid(this.m_labelPath) {
      this.m_label = this.GetWidget(this.m_labelPath) as inkText;
    };
    this.m_value = this.GetWidget(this.m_valuePath) as inkText;
    this.m_leftArrow = this.GetWidget(this.m_leftArrowPath);
    if IsDefined(this.m_leftArrow) {
      this.m_leftArrow.RegisterToCallback(n"OnRelease", this, n"OnLeft");
      this.m_leftArrowButton = this.m_leftArrow.GetControllerByType(n"inkButtonController") as inkButtonController;
    };
    this.m_rightArrow = this.GetWidget(this.m_rightArrowPath);
    if IsDefined(this.m_rightArrow) {
      this.m_rightArrow.RegisterToCallback(n"OnRelease", this, n"OnRight");
      this.m_rightArrowButton = this.m_rightArrow.GetControllerByType(n"inkButtonController") as inkButtonController;
    };
  }

  protected cb func OnUpdateValue(value: String, index: Int32, changeDirection: inkSelectorChangeDirection) -> Bool {
    let valuesCount: Int32 = this.GetValuesCount();
    let hasMoreThanOneValue: Bool = valuesCount > 1;
    let isCyclical: Bool = this.IsCyclical();
    if IsDefined(this.m_value) {
      this.m_value.SetText(value);
    };
    if hasMoreThanOneValue {
      if !isCyclical && IsDefined(this.m_leftArrowButton) {
        this.m_leftArrowButton.SetEnabled(this.GetCurrIndex() != 0);
      };
      if !isCyclical && IsDefined(this.m_rightArrowButton) {
        this.m_rightArrowButton.SetEnabled(this.GetCurrIndex() != valuesCount - 1);
      };
    } else {
      this.m_leftArrowButton.SetEnabled(false);
      this.m_rightArrowButton.SetEnabled(false);
    };
  }

  protected cb func OnLeft(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.Prior();
    };
  }

  protected cb func OnRight(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.Next();
    };
  }
}
