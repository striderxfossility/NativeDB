
public class hubSelectorSingleCarouselController extends SelectorController {

  @default(hubSelectorSingleCarouselController, 7)
  @default(hubSelectorSingleSmallCarouselController, 5)
  protected let NUMBER_OF_WIDGETS: Int32;

  @default(hubSelectorSingleCarouselController, 10.0f)
  protected let WIDGETS_PADDING: Float;

  @default(hubSelectorSingleCarouselController, 0.8f)
  protected let SMALL_WIDGET_SCALE: Float;

  @default(hubSelectorSingleCarouselController, 1.0f)
  protected let SMALL_WIDGET_OPACITY: Float;

  @default(hubSelectorSingleCarouselController, 0.2f)
  protected let ANIMATION_TIME: Float;

  protected let DEFAULT_WIDGET_COLOR: HDRColor;

  protected let SELECTED_WIDGET_COLOR: HDRColor;

  protected edit let m_leftArrowWidget: inkWidgetRef;

  protected edit let m_rightArrowWidget: inkWidgetRef;

  protected edit let m_container: inkWidgetRef;

  protected edit let m_defaultColorDummy: inkWidgetRef;

  protected edit let m_activeColorDummy: inkWidgetRef;

  public let m_leftArrowController: wref<inkInputDisplayController>;

  public let m_rightArrowController: wref<inkInputDisplayController>;

  protected let m_elements: array<MenuData>;

  protected let m_centerElementIndex: Int32;

  protected let m_widgetsControllers: array<wref<HubMenuLabelContentContainer>>;

  protected let m_waitForSizes: Bool;

  protected let m_translationOnce: Bool;

  protected let m_currentIndex: Int32;

  protected let m_activeAnimations: array<ref<inkAnimProxy>>;

  protected cb func OnInitialize() -> Bool {
    let controller: ref<HubMenuLabelContentContainer>;
    let widget: wref<inkWidget>;
    this.m_leftArrowController = inkWidgetRef.GetController(this.m_leftArrowWidget) as inkInputDisplayController;
    this.m_rightArrowController = inkWidgetRef.GetController(this.m_rightArrowWidget) as inkInputDisplayController;
    this.DEFAULT_WIDGET_COLOR = inkWidgetRef.GetTintColor(this.m_defaultColorDummy);
    this.SELECTED_WIDGET_COLOR = inkWidgetRef.GetTintColor(this.m_activeColorDummy);
    this.m_centerElementIndex = this.NUMBER_OF_WIDGETS / 2;
    let i: Int32 = 0;
    while i < this.NUMBER_OF_WIDGETS {
      widget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_container), n"menu_element");
      widget.SetRenderTransformPivot(0.50, 1.00);
      widget.SetAnchor(inkEAnchor.Centered);
      widget.SetAnchorPoint(0.50, 0.50);
      controller = widget.GetController() as HubMenuLabelContentContainer;
      controller.RegisterToCallback(n"OnRelease", this, n"OnMenuLabelClick");
      controller.RegisterToCallback(n"OnHoverOver", this, n"OnMenuLabelHover");
      controller.RegisterToCallback(n"OnHoverOut", this, n"OnMenuLabelHoverOut");
      controller.SetCarouselPosition(i);
      if i == this.m_centerElementIndex {
        controller.SetInteractive(false);
      };
      ArrayPush(this.m_widgetsControllers, controller);
      i += 1;
    };
    this.UpdateArrowsVisibility();
  }

  protected cb func OnMenuLabelClick(e: ref<inkPointerEvent>) -> Bool {
    let controller: ref<HubMenuLabelContentContainer>;
    let direction: inkSelectorChangeDirection;
    let targetPosition: Int32;
    if e.IsAction(n"click") {
      controller = e.GetCurrentTarget().GetController() as HubMenuLabelContentContainer;
      if controller.GetCarouselPosition() != this.m_centerElementIndex {
        this.PlaySound(n"TabButton", n"OnPress");
        targetPosition = this.m_centerElementIndex - controller.GetCarouselPosition();
        if controller.GetCarouselPosition() < this.m_centerElementIndex {
          direction = inkSelectorChangeDirection.Prior;
        } else {
          if controller.GetCarouselPosition() > this.m_centerElementIndex {
            direction = inkSelectorChangeDirection.Next;
          };
        };
        this.SetCurrIndexWithDirection(this.GetLoopedValue(this.m_currentIndex - targetPosition, this.GetValuesCount()), direction);
      };
    };
  }

  protected cb func OnMenuLabelHover(e: ref<inkPointerEvent>) -> Bool {
    let controller: ref<HubMenuLabelContentContainer> = e.GetCurrentTarget().GetController() as HubMenuLabelContentContainer;
    controller.SetTintColor(this.SELECTED_WIDGET_COLOR);
  }

  protected cb func OnMenuLabelHoverOut(e: ref<inkPointerEvent>) -> Bool {
    let controller: ref<HubMenuLabelContentContainer> = e.GetCurrentTarget().GetController() as HubMenuLabelContentContainer;
    controller.SetTintColor(this.DEFAULT_WIDGET_COLOR);
  }

  public final func SetupMenu(data: array<MenuData>, startIdentifier: Int32) -> Void {
    let i: Int32;
    let startIndex: Int32;
    this.Clear();
    ArrayClear(this.m_elements);
    startIndex = 0;
    i = 0;
    while i < ArraySize(data) {
      ArrayPush(this.m_elements, data[i]);
      this.AddValue(data[i].label);
      if data[i].identifier == startIdentifier {
        startIndex = i;
      };
      i += 1;
    };
    this.SetCurrIndex(startIndex);
    this.SetFinishedValues(startIndex);
    this.m_currentIndex = startIndex;
    this.UpdateArrowsVisibility();
  }

  public final func ScrollTo(data: MenuData) -> Void {
    let startIndex: Int32 = 0;
    let i: Int32 = 0;
    while i < ArraySize(this.m_elements) {
      if this.m_elements[i].identifier == data.identifier {
        startIndex = i;
      };
      i += 1;
    };
    this.SetCurrIndex(startIndex);
    this.SetFinishedValues(startIndex);
    this.m_currentIndex = startIndex;
    this.UpdateArrowsVisibility();
  }

  private final func UpdateArrowsVisibility() -> Void {
    this.m_leftArrowController.SetVisible(ArraySize(this.m_elements) > 1);
    this.m_rightArrowController.SetVisible(ArraySize(this.m_elements) > 1);
  }

  protected cb func OnUpdateValue(value: String, index: Int32, changeDirection: inkSelectorChangeDirection) -> Bool {
    this.m_currentIndex = index;
    this.Animate(index, changeDirection);
  }

  protected final func GetLoopedValue(value: Int32, limit: Int32) -> Int32 {
    return value >= 0 ? value % limit : limit + (value + 1) % limit - 1;
  }

  protected final func SetFinishedValues(selectedIndex: Int32) -> Void {
    let emptyData: MenuData;
    let i: Int32;
    let realIndex: Int32;
    let limit: Int32 = this.GetValuesCount();
    if limit == 1 {
      this.m_widgetsControllers[this.m_centerElementIndex].SetData(this.m_elements[0]);
      i = 0;
      while i < this.NUMBER_OF_WIDGETS {
        if i != this.m_centerElementIndex {
          this.m_widgetsControllers[i].SetData(emptyData);
        };
        i += 1;
      };
    } else {
      i = 0;
      while i < this.NUMBER_OF_WIDGETS {
        realIndex = this.GetLoopedValue(selectedIndex - this.NUMBER_OF_WIDGETS / 2 + i, limit);
        this.m_widgetsControllers[i].SetData(this.m_elements[realIndex]);
        i += 1;
      };
    };
    this.m_waitForSizes = true;
  }

  protected cb func OnArrangeChildrenComplete() -> Bool {
    let i: Int32;
    if this.m_waitForSizes {
      i = 0;
      while i < ArraySize(this.m_activeAnimations) {
        this.m_activeAnimations[i].Stop();
        i += 1;
      };
      ArrayClear(this.m_activeAnimations);
      this.ResetAnimatedStates();
      this.m_waitForSizes = false;
    };
  }

  protected final func GetTranslations(targetIndex: Int32) -> array<Float> {
    let prevSidesMaxWidth: Float;
    let resultTranslations: array<Float>;
    let sidesMaxWidth: Float;
    let sidesTranslation: Float;
    let i: Int32 = 0;
    while i < this.NUMBER_OF_WIDGETS {
      ArrayPush(resultTranslations, 0.00);
      i += 1;
    };
    targetIndex = this.m_centerElementIndex + targetIndex != 0 ? targetIndex > 0 ? 1 : -1 : 0;
    sidesTranslation = this.m_widgetsControllers[targetIndex].GetRealDesiredWidth() / 2.00 + this.WIDGETS_PADDING;
    i = 1;
    while i <= this.NUMBER_OF_WIDGETS / 2 + 1 {
      sidesMaxWidth = MaxF(this.m_widgetsControllers[targetIndex - i].GetRealDesiredWidth(), this.m_widgetsControllers[targetIndex + i].GetRealDesiredWidth());
      sidesTranslation += prevSidesMaxWidth / 2.00 + sidesMaxWidth / 2.00 + this.WIDGETS_PADDING;
      resultTranslations[targetIndex - i] = -sidesTranslation;
      resultTranslations[targetIndex + i] = sidesTranslation;
      prevSidesMaxWidth = sidesMaxWidth;
      i += 1;
    };
    return resultTranslations;
  }

  protected final func GetMaskTargetWidth(targetIndex: Int32) -> Float {
    let nonZeroPrevSidesMaxWidth: Float;
    let prevSidesMaxWidth: Float;
    let sidesMaxWidth: Float;
    targetIndex = this.m_centerElementIndex + targetIndex != 0 ? targetIndex > 0 ? 1 : -1 : 0;
    let sidesTranslation: Float = this.m_widgetsControllers[targetIndex].GetRealDesiredWidth() / 2.00 + this.WIDGETS_PADDING;
    let i: Int32 = 1;
    while i <= this.NUMBER_OF_WIDGETS / 2 + 1 {
      sidesMaxWidth = MaxF(this.m_widgetsControllers[targetIndex - i].GetRealDesiredWidth(), this.m_widgetsControllers[targetIndex + i].GetRealDesiredWidth());
      sidesTranslation += prevSidesMaxWidth / 2.00 + sidesMaxWidth / 2.00 + this.WIDGETS_PADDING;
      nonZeroPrevSidesMaxWidth = prevSidesMaxWidth;
      prevSidesMaxWidth = sidesMaxWidth;
      i += 1;
    };
    return (sidesTranslation - nonZeroPrevSidesMaxWidth + this.WIDGETS_PADDING * 2.00) * 2.00;
  }

  protected final func ResetAnimatedStates() -> Void {
    let sidesMaxWidth: Float;
    let translations: array<Float>;
    let widgetLeft: ref<HubMenuLabelContentContainer>;
    let widgetRight: ref<HubMenuLabelContentContainer>;
    let i: Int32 = 1;
    while i <= this.NUMBER_OF_WIDGETS / 2 {
      widgetLeft = this.m_widgetsControllers[this.m_centerElementIndex - i];
      widgetRight = this.m_widgetsControllers[this.m_centerElementIndex + i];
      sidesMaxWidth = MaxF(widgetLeft.GetRealDesiredWidth(), widgetRight.GetRealDesiredWidth());
      widgetLeft.GetRootWidget().SetWidth(sidesMaxWidth);
      widgetRight.GetRootWidget().SetWidth(sidesMaxWidth);
      i += 1;
    };
    inkWidgetRef.Get(this.m_container).SetSize(new Vector2(this.GetMaskTargetWidth(0), inkWidgetRef.GetHeight(this.m_container)));
    i = 0;
    while i < this.NUMBER_OF_WIDGETS {
      if i == this.m_centerElementIndex {
        this.m_widgetsControllers[i].GetRootWidget().SetScale(new Vector2(1.00, 1.00));
        this.m_widgetsControllers[i].GetRootWidget().SetOpacity(1.00);
        this.m_widgetsControllers[i].SetTintColor(this.SELECTED_WIDGET_COLOR);
      } else {
        this.m_widgetsControllers[i].GetRootWidget().SetScale(new Vector2(this.SMALL_WIDGET_SCALE, this.SMALL_WIDGET_SCALE));
        this.m_widgetsControllers[i].GetRootWidget().SetOpacity(this.SMALL_WIDGET_OPACITY);
        this.m_widgetsControllers[i].SetTintColor(this.DEFAULT_WIDGET_COLOR);
      };
      i += 1;
    };
    translations = this.GetTranslations(0);
    i = 0;
    while i < this.NUMBER_OF_WIDGETS {
      this.m_widgetsControllers[i].GetRootWidget().SetTranslation(translations[i], 0.00);
      i += 1;
    };
  }

  protected final func Animate(targetIndex: Int32, direction: inkSelectorChangeDirection) -> Void {
    let i: Int32;
    let prevVector: Vector2;
    let translations: array<Float>;
    let offset: Int32 = 0;
    if Equals(direction, inkSelectorChangeDirection.Prior) {
      offset = -1;
    } else {
      if Equals(direction, inkSelectorChangeDirection.Next) {
        offset = 1;
      };
    };
    translations = this.GetTranslations(offset);
    i = 0;
    while i < this.NUMBER_OF_WIDGETS {
      prevVector = this.m_widgetsControllers[i].GetRootWidget().GetTranslation();
      this.AddActiveProxy(this.TranslationAnimation(this.m_widgetsControllers[i].GetRootWidget(), prevVector.X, translations[i]));
      i += 1;
    };
    this.AddActiveProxy(this.ScaleAnimation(this.m_widgetsControllers[this.m_centerElementIndex].GetRootWidget(), 1.00, this.SMALL_WIDGET_SCALE));
    this.AddActiveProxy(this.OpacityAnimation(this.m_widgetsControllers[this.m_centerElementIndex].GetRootWidget(), 1.00, this.SMALL_WIDGET_OPACITY));
    this.AddActiveProxy(this.ColorAnimation(this.m_widgetsControllers[this.m_centerElementIndex].GetTintedWidgets(), this.SELECTED_WIDGET_COLOR, this.DEFAULT_WIDGET_COLOR));
    this.AddActiveProxy(this.ScaleAnimation(this.m_widgetsControllers[this.m_centerElementIndex + offset].GetRootWidget(), this.SMALL_WIDGET_SCALE, 1.00));
    this.AddActiveProxy(this.OpacityAnimation(this.m_widgetsControllers[this.m_centerElementIndex + offset].GetRootWidget(), this.SMALL_WIDGET_OPACITY, 1.00));
    this.AddActiveProxy(this.ColorAnimation(this.m_widgetsControllers[this.m_centerElementIndex + offset].GetTintedWidgets(), this.DEFAULT_WIDGET_COLOR, this.SELECTED_WIDGET_COLOR));
    this.m_translationOnce = true;
  }

  protected final func AddActiveProxy(proxy: ref<inkAnimProxy>) -> Void {
    ArrayPush(this.m_activeAnimations, proxy);
  }

  protected final func AddActiveProxy(proxies: array<ref<inkAnimProxy>>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(proxies) {
      ArrayPush(this.m_activeAnimations, proxies[i]);
      i += 1;
    };
  }

  protected func ScaleAnimation(targetWidget: wref<inkWidget>, startScale: Float, endScale: Float) -> ref<inkAnimProxy> {
    let proxy: ref<inkAnimProxy>;
    let moveElementsAnimDef: ref<inkAnimDef> = new inkAnimDef();
    let scaleInterpolator: ref<inkAnimScale> = new inkAnimScale();
    scaleInterpolator.SetType(inkanimInterpolationType.Linear);
    scaleInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    scaleInterpolator.SetDirection(inkanimInterpolationDirection.FromTo);
    scaleInterpolator.SetStartScale(new Vector2(startScale, startScale));
    scaleInterpolator.SetEndScale(new Vector2(endScale, endScale));
    scaleInterpolator.SetDuration(this.ANIMATION_TIME);
    moveElementsAnimDef.AddInterpolator(scaleInterpolator);
    proxy = targetWidget.PlayAnimation(moveElementsAnimDef);
    proxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnScaleCompleted");
    return proxy;
  }

  protected func TranslationAnimation(targetWidget: wref<inkWidget>, startTranslation: Float, endTranslation: Float) -> ref<inkAnimProxy> {
    let proxy: ref<inkAnimProxy>;
    let moveElementsAnimDef: ref<inkAnimDef> = new inkAnimDef();
    let translationInterpolator: ref<inkAnimTranslation> = new inkAnimTranslation();
    translationInterpolator.SetType(inkanimInterpolationType.Linear);
    translationInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    translationInterpolator.SetDirection(inkanimInterpolationDirection.FromTo);
    translationInterpolator.SetStartTranslation(new Vector2(startTranslation, 0.00));
    translationInterpolator.SetEndTranslation(new Vector2(endTranslation, 0.00));
    translationInterpolator.SetDuration(this.ANIMATION_TIME);
    moveElementsAnimDef.AddInterpolator(translationInterpolator);
    proxy = targetWidget.PlayAnimation(moveElementsAnimDef);
    proxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnTranslationCompleted");
    return proxy;
  }

  protected func SizeAnimation(targetWidget: wref<inkWidget>, startSize: Vector2, endSize: Vector2) -> ref<inkAnimProxy> {
    let proxy: ref<inkAnimProxy>;
    let moveElementsAnimDef: ref<inkAnimDef> = new inkAnimDef();
    let sizeInterpolator: ref<inkAnimSize> = new inkAnimSize();
    sizeInterpolator.SetType(inkanimInterpolationType.Linear);
    sizeInterpolator.SetMode(inkanimInterpolationMode.EasyOut);
    sizeInterpolator.SetDirection(inkanimInterpolationDirection.FromTo);
    sizeInterpolator.SetStartSize(startSize);
    sizeInterpolator.SetEndSize(endSize);
    sizeInterpolator.SetDuration(this.ANIMATION_TIME * 1.50);
    moveElementsAnimDef.AddInterpolator(sizeInterpolator);
    proxy = targetWidget.PlayAnimation(moveElementsAnimDef);
    proxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnSizeCompleted");
    return proxy;
  }

  protected func OpacityAnimation(targetWidget: wref<inkWidget>, startOpacity: Float, endOpacity: Float) -> ref<inkAnimProxy> {
    let proxy: ref<inkAnimProxy>;
    let moveElementsAnimDef: ref<inkAnimDef> = new inkAnimDef();
    let transparencyInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    transparencyInterpolator.SetType(inkanimInterpolationType.Linear);
    transparencyInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    transparencyInterpolator.SetDirection(inkanimInterpolationDirection.FromTo);
    transparencyInterpolator.SetStartTransparency(startOpacity);
    transparencyInterpolator.SetEndTransparency(endOpacity);
    transparencyInterpolator.SetDuration(this.ANIMATION_TIME);
    moveElementsAnimDef.AddInterpolator(transparencyInterpolator);
    proxy = targetWidget.PlayAnimation(moveElementsAnimDef);
    proxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnOpacityCompleted");
    return proxy;
  }

  protected func ColorAnimation(targetWidgets: array<wref<inkWidget>>, startColor: HDRColor, endColor: HDRColor) -> array<ref<inkAnimProxy>> {
    let i: Int32;
    let proxies: array<ref<inkAnimProxy>>;
    let proxy: ref<inkAnimProxy>;
    let colorElementsAnimDef: ref<inkAnimDef> = new inkAnimDef();
    let colorInterpolator: ref<inkAnimColor> = new inkAnimColor();
    colorInterpolator.SetType(inkanimInterpolationType.Linear);
    colorInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    colorInterpolator.SetDirection(inkanimInterpolationDirection.FromTo);
    colorInterpolator.SetStartColor(startColor);
    colorInterpolator.SetEndColor(endColor);
    colorInterpolator.SetDuration(this.ANIMATION_TIME);
    colorElementsAnimDef.AddInterpolator(colorInterpolator);
    i = 0;
    while i < ArraySize(targetWidgets) {
      proxy = targetWidgets[i].PlayAnimation(colorElementsAnimDef);
      ArrayPush(proxies, proxy);
      i += 1;
    };
    proxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnColorCompleted");
    return proxies;
  }

  protected cb func OnTranslationCompleted(anim: ref<inkAnimProxy>) -> Bool {
    if this.m_translationOnce {
      this.SetFinishedValues(this.m_currentIndex);
      this.ResetAnimatedStates();
      this.m_translationOnce = false;
    };
  }
}

public class hubSelectorController extends SelectorController {

  public edit let m_leftArrowWidget: inkWidgetRef;

  public edit let m_rightArrowWidget: inkWidgetRef;

  public edit let m_menuLabelHolder: inkHorizontalPanelRef;

  public let m_selectedMenuLabel: wref<HubMenuLabelController>;

  private let m_previouslySelectedMenuLabel: wref<HubMenuLabelController>;

  private let hubElementsData: array<MenuData>;

  private let m_previousIndex: Int32;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.RegisterToCallback(this.m_leftArrowWidget, n"OnRelease", this, n"OnLeft");
    inkWidgetRef.RegisterToCallback(this.m_rightArrowWidget, n"OnRelease", this, n"OnRight");
  }

  public final func AddMenuTab(data: MenuData) -> Void {
    let menuLabelController: ref<HubMenuLabelController>;
    let selectedIndex: Int32;
    let widget: wref<inkWidget>;
    let childrenNum: Int32 = inkCompoundRef.GetNumChildren(this.m_menuLabelHolder);
    if inkCompoundRef.GetNumChildren(this.m_menuLabelHolder) < 3 {
      widget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_menuLabelHolder), n"menu_label");
      if !IsDefined(widget) {
        widget = this.SpawnFromExternal(inkWidgetRef.Get(this.m_menuLabelHolder), r"base\\gameplay\\gui\\fullscreen\\hub_menu\\new_hub.inkwidget", n"menu_label");
      };
      menuLabelController = widget.GetController() as HubMenuLabelController;
      menuLabelController.SetData(data);
      menuLabelController.RegisterToCallback(n"OnRelease", this, n"OnMenuLabelClick");
    };
    this.m_selectedMenuLabel.SetActive(false);
    selectedIndex = CeilF(Cast(childrenNum - 1) / 2.00);
    this.m_selectedMenuLabel = inkCompoundRef.GetWidgetByIndex(this.m_menuLabelHolder, selectedIndex).GetController() as HubMenuLabelController;
    this.m_selectedMenuLabel.SetActive(true);
    ArrayPush(this.hubElementsData, data);
  }

  public final func RemoveOldTabs() -> Void {
    ArrayClear(this.hubElementsData);
    inkCompoundRef.RemoveAllChildren(this.m_menuLabelHolder);
  }

  public final func RegisterToMenuTabCallback(eventName: CName, object: ref<IScriptable>, functionName: CName) -> Void {
    let widget: wref<inkWidget>;
    let i: Int32 = 0;
    while i < inkCompoundRef.GetNumChildren(this.m_menuLabelHolder) {
      widget = inkCompoundRef.GetWidgetByIndex(this.m_menuLabelHolder, i);
      widget.RegisterToCallback(eventName, object, functionName);
      i += 1;
    };
  }

  protected final func CycleInRange(index: Int32, range: Int32) -> Int32 {
    if index > 0 {
      return index % range;
    };
    if index < 0 {
      return range + index % range;
    };
    return 0;
  }

  protected final func GetNearestWidgetsData(index: Int32) -> array<MenuData> {
    let result: array<MenuData>;
    let i: Int32 = -1;
    while i <= 1 {
      ArrayPush(result, this.hubElementsData[this.CycleInRange(index + i, this.GetValuesCount())]);
      i += 1;
    };
    return result;
  }

  protected cb func OnUpdateValue(value: String, index: Int32, changeDirection: inkSelectorChangeDirection) -> Bool {
    let i: Int32;
    let menuLabelController: ref<HubMenuLabelController>;
    let idx: Int32 = this.GetCurrIndex();
    let valuesSize: Int32 = this.GetValuesCount();
    let relativeChange: Int32 = idx - this.m_previousIndex;
    this.m_previousIndex = idx;
    if relativeChange == valuesSize - 1 || relativeChange * -1 == valuesSize - 1 {
      relativeChange *= -1;
    };
    if valuesSize <= 1 {
      (inkCompoundRef.GetWidgetByIndex(this.m_menuLabelHolder, i + 1).GetController() as HubMenuLabelController).SetData(this.hubElementsData[idx]);
    } else {
      i = valuesSize > 2 ? -1 : 0;
      while i <= 1 {
        menuLabelController = inkCompoundRef.GetWidgetByIndex(this.m_menuLabelHolder, i + valuesSize > 2 ? 1 : 0).GetController() as HubMenuLabelController;
        menuLabelController.SetTargetData(this.hubElementsData[this.CycleInRange(idx + i, valuesSize)], relativeChange);
        if i == 0 {
          menuLabelController.SetActive(true);
        };
        i += 1;
      };
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

  protected cb func OnMenuLabelClick(e: ref<inkPointerEvent>) -> Bool {
    let clickedIndex: Int32;
    let logicController: ref<HubMenuLabelController>;
    let target: wref<inkWidget>;
    let visibleElements: Int32;
    if e.IsAction(n"click") {
      target = e.GetTarget();
      logicController = target.GetController() as HubMenuLabelController;
      clickedIndex = this.DetermineIndex(logicController);
      visibleElements = inkCompoundRef.GetNumChildren(this.m_menuLabelHolder);
      if visibleElements > 1 {
        if clickedIndex == visibleElements - 1 {
          this.Next();
        } else {
          if clickedIndex == 0 {
            this.Prior();
          };
        };
      };
    };
  }

  private final func FindLabel(label: String) -> ref<HubMenuLabelController> {
    let selectedLabel: wref<HubMenuLabelController>;
    let i: Int32 = 0;
    while i < inkCompoundRef.GetNumChildren(this.m_menuLabelHolder) {
      selectedLabel = inkCompoundRef.GetWidgetByIndex(this.m_menuLabelHolder, i).GetController() as HubMenuLabelController;
      if Equals(selectedLabel.m_data.label, label) {
        return selectedLabel;
      };
      i += 1;
    };
    return null;
  }

  private final func DetermineIndex(controller: ref<HubMenuLabelController>) -> Int32 {
    let selectedLabel: wref<HubMenuLabelController>;
    let i: Int32 = 0;
    while i < inkCompoundRef.GetNumChildren(this.m_menuLabelHolder) {
      selectedLabel = inkCompoundRef.GetWidgetByIndex(this.m_menuLabelHolder, i).GetController() as HubMenuLabelController;
      if selectedLabel == controller {
        return i;
      };
      i += 1;
    };
    return i;
  }
}

public class HubMenuLabelContentContainer extends inkLogicController {

  protected edit let m_label: inkTextRef;

  protected edit let m_icon: inkImageRef;

  protected edit let m_desiredSizeWrapper: inkWidgetRef;

  protected edit let m_border: inkBorderRef;

  protected let m_carouselPosition: Int32;

  public let m_labelName: String;

  public let m_data: MenuData;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.SetVisible(this.m_border, false);
    inkWidgetRef.SetVisible(this.m_icon, false);
  }

  public func SetData(data: MenuData) -> Void {
    this.m_data = data;
    this.m_labelName = this.m_data.label;
    inkTextRef.SetText(this.m_label, this.m_labelName);
    inkTextRef.SetLocalizedTextScript(this.m_label, StringToName(this.m_labelName));
    if NotEquals(this.m_data.icon, n"") {
      inkWidgetRef.SetVisible(this.m_icon, true);
      inkImageRef.SetTexturePart(this.m_icon, this.m_data.icon);
    } else {
      inkWidgetRef.SetVisible(this.m_icon, false);
    };
  }

  public func SetCarouselPosition(carouselPosition: Int32) -> Void {
    this.m_carouselPosition = carouselPosition;
  }

  public func SetInteractive(value: Bool) -> Void {
    inkWidgetRef.SetInteractive(this.m_desiredSizeWrapper, value);
  }

  public func GetCarouselPosition() -> Int32 {
    return this.m_carouselPosition;
  }

  public func GetIdentifier() -> Int32 {
    return this.m_data.identifier;
  }

  public func GetSize() -> Float {
    return this.GetRootWidget().GetWidth();
  }

  public func GetRealDesiredSize() -> Vector2 {
    return inkWidgetRef.GetDesiredSize(this.m_desiredSizeWrapper);
  }

  public func GetRealDesiredWidth() -> Float {
    return inkWidgetRef.GetDesiredWidth(this.m_desiredSizeWrapper);
  }

  public func GetTintedWidgets() -> array<wref<inkWidget>> {
    let result: array<wref<inkWidget>>;
    ArrayPush(result, inkWidgetRef.Get(this.m_label));
    ArrayPush(result, inkWidgetRef.Get(this.m_icon));
    return result;
  }

  public func SetTintColor(color: HDRColor) -> Void {
    inkWidgetRef.SetTintColor(this.m_label, color);
    inkWidgetRef.SetTintColor(this.m_icon, color);
  }
}

public class HubMenuLabelController extends inkLogicController {

  protected edit let m_container: inkCompoundRef;

  protected let m_wrapper: wref<inkWidget>;

  protected let m_wrapperNext: wref<inkWidget>;

  protected let m_wrapperController: wref<HubMenuLabelContentContainer>;

  protected let m_wrapperNextController: wref<HubMenuLabelContentContainer>;

  public let m_data: MenuData;

  protected let m_watchForSize: Bool;

  protected let m_watchForInstatnSize: Bool;

  protected let m_once: Bool;

  protected let m_direction: Int32;

  protected cb func OnInitialize() -> Bool {
    this.m_wrapper = this.SpawnFromLocal(inkWidgetRef.Get(this.m_container), n"menu_label_content");
    if !IsDefined(this.m_wrapper) {
      this.m_wrapper = this.SpawnFromExternal(inkWidgetRef.Get(this.m_container), r"base\\gameplay\\gui\\fullscreen\\hub_menu\\new_hub.inkwidget", n"menu_label_content");
    };
    this.m_wrapper.SetAnchor(inkEAnchor.Fill);
    this.m_wrapper.SetTranslation(0.00, 0.00);
    this.m_wrapperNext = this.SpawnFromLocal(inkWidgetRef.Get(this.m_container), n"menu_label_content");
    if !IsDefined(this.m_wrapperNext) {
      this.m_wrapperNext = this.SpawnFromExternal(inkWidgetRef.Get(this.m_container), r"base\\gameplay\\gui\\fullscreen\\hub_menu\\new_hub.inkwidget", n"menu_label_content");
    };
    this.m_wrapperNext.SetAnchor(inkEAnchor.Fill);
    this.m_wrapperNext.SetTranslation(400.00, 0.00);
    this.m_wrapperController = this.m_wrapper.GetController() as HubMenuLabelContentContainer;
    this.m_wrapperNextController = this.m_wrapperNext.GetController() as HubMenuLabelContentContainer;
  }

  public func SetData(data: MenuData) -> Void {
    this.m_data = data;
    this.m_watchForInstatnSize = true;
    this.m_wrapperController.SetData(data);
  }

  public func SetTargetData(data: MenuData, direction: Int32) -> Void {
    this.m_data = data;
    this.m_direction = direction;
    if direction != 0 {
      this.m_watchForSize = true;
      this.m_wrapperNextController.SetData(data);
    } else {
      this.m_watchForInstatnSize = true;
      this.m_wrapperController.SetData(data);
    };
  }

  public func SetActive(active: Bool) -> Void {
    inkWidgetRef.SetState(this.m_container, active ? n"Selected" : n"Unselected");
  }

  protected cb func OnArrangeChildrenComplete() -> Bool {
    let desiredWidth: Float;
    if this.m_watchForSize {
      desiredWidth = this.m_wrapperNext.GetDesiredWidth();
      this.ResizeAnimation(inkWidgetRef.Get(this.m_container), desiredWidth);
      this.SwipeAnimation(this.m_wrapper, 0.00, this.m_direction > 0 ? -desiredWidth : desiredWidth);
      this.SwipeAnimation(this.m_wrapperNext, this.m_direction > 0 ? desiredWidth : -desiredWidth, 0.00);
      this.m_once = true;
      this.m_watchForSize = false;
    };
    if this.m_watchForInstatnSize {
      inkWidgetRef.SetSize(this.m_container, this.m_wrapper.GetDesiredSize());
      this.m_watchForInstatnSize = false;
    };
  }

  protected cb func OnSwipeCompleted(anim: ref<inkAnimProxy>) -> Bool {
    if this.m_once {
      this.m_wrapperController.SetData(this.m_data);
      this.m_once = false;
    };
  }

  protected func SwipeAnimation(targetWidget: wref<inkWidget>, startTranslation: Float, endTranslation: Float) -> ref<inkAnimDef> {
    let proxy: ref<inkAnimProxy>;
    let moveElementsAnimDef: ref<inkAnimDef> = new inkAnimDef();
    let translationInterpolator: ref<inkAnimTranslation> = new inkAnimTranslation();
    translationInterpolator.SetType(inkanimInterpolationType.Linear);
    translationInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    translationInterpolator.SetDirection(inkanimInterpolationDirection.FromTo);
    translationInterpolator.SetStartTranslation(new Vector2(startTranslation, 0.00));
    translationInterpolator.SetEndTranslation(new Vector2(endTranslation, 0.00));
    translationInterpolator.SetDuration(0.30);
    moveElementsAnimDef.AddInterpolator(translationInterpolator);
    proxy = targetWidget.PlayAnimation(moveElementsAnimDef);
    proxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnSwipeCompleted");
    return moveElementsAnimDef;
  }

  protected func ResizeAnimation(targetWidget: wref<inkWidget>, width: Float) -> ref<inkAnimDef> {
    let resizeElementsAnimDef: ref<inkAnimDef> = new inkAnimDef();
    let sizeInterpolator: ref<inkAnimSize> = new inkAnimSize();
    sizeInterpolator.SetType(inkanimInterpolationType.Linear);
    sizeInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    sizeInterpolator.SetDirection(inkanimInterpolationDirection.FromTo);
    sizeInterpolator.SetStartSize(inkWidgetRef.GetSize(this.m_container));
    sizeInterpolator.SetEndSize(new Vector2(width, this.m_wrapper.GetDesiredHeight()));
    sizeInterpolator.SetDuration(0.08);
    resizeElementsAnimDef.AddInterpolator(sizeInterpolator);
    inkWidgetRef.PlayAnimation(this.m_container, resizeElementsAnimDef);
    return resizeElementsAnimDef;
  }
}
