
public native class gameuiPhotoModeMenuController extends inkGameController {

  private edit let m_menuListRoot: inkWidgetRef;

  private edit let m_additionalListRoot: inkWidgetRef;

  private edit let m_radioButtons: inkCompoundRef;

  private edit let m_listContainerId: CName;

  private edit let m_menuArea: inkWidgetRef;

  private edit let m_additionalMenuArea: inkWidgetRef;

  private edit let m_inputCameraKbd: inkWidgetRef;

  private edit let m_inputCameraPad: inkWidgetRef;

  private edit let m_inputStickersKbd: inkWidgetRef;

  private edit let m_inputStickersPad: inkWidgetRef;

  private edit let m_inputSaveLoadKbd: inkWidgetRef;

  private edit let m_inputSaveLoadPad: inkWidgetRef;

  private edit let m_inputExit: inkWidgetRef;

  private edit let m_inputScreenshot: inkWidgetRef;

  private edit let m_cameraLocation: inkWidgetRef;

  private edit let m_inputBottomRoot: inkHorizontalPanelRef;

  private edit let m_ps4InputLibraryId: CName;

  private edit let m_xboxInputLibraryId: CName;

  private let ps4InputWidget: wref<inkWidget>;

  private let xboxInputWidget: wref<inkWidget>;

  private let m_menuPages: array<wref<inkWidget>>;

  private let m_topButtonsController: wref<PhotoModeTopBarController>;

  private let m_cameraLocationController: wref<PhotoModeCameraLocation>;

  private let m_currentPage: Uint32;

  private let m_IsHoverOver: Bool;

  private let m_holdSafeguard: Bool;

  private let m_notificationUserData: ref<inkGameNotificationData>;

  private let m_notificationToken: ref<inkGameNotificationToken>;

  private let loopAnimproxy: ref<inkAnimProxy>;

  private let m_uiVisiblityFadeAnim: ref<inkAnimProxy>;

  public final native func OnHoverStateChanged(hover: Bool) -> Void;

  public final native func OnAttributeUpdated(attributeKey: Uint32, attributeValue: Float) -> Void;

  public final native func OnAttributeSelected(attributeKey: Uint32) -> Void;

  public final native func OnEditCategoryChanged(editCategory: Uint32) -> Void;

  public final native func OnHoldComplete(attributeKey: Uint32, actionName: CName) -> Void;

  public final native func OnAnimationEnded(animationType: Uint32) -> Void;

  protected cb func OnInitialize() -> Bool {
    this.m_IsHoverOver = false;
    this.m_holdSafeguard = false;
    if !IsDefined(this.m_topButtonsController) {
      this.m_topButtonsController = inkWidgetRef.GetController(this.m_radioButtons) as PhotoModeTopBarController;
      this.m_topButtonsController.RegisterToCallback(n"OnValueChanged", this, n"OnTopBarValueChanged");
    };
    if !IsDefined(this.m_cameraLocationController) {
      this.m_cameraLocationController = inkWidgetRef.GetController(this.m_cameraLocation) as PhotoModeCameraLocation;
    };
    if inkWidgetRef.IsValid(this.m_menuArea) {
      inkWidgetRef.RegisterToCallback(this.m_menuArea, n"OnHoverOver", this, n"OnMenuHovered");
      inkWidgetRef.RegisterToCallback(this.m_menuArea, n"OnHoverOut", this, n"OnMenuHoverOut");
      inkWidgetRef.RegisterToCallback(this.m_additionalMenuArea, n"OnHoverOver", this, n"OnMenuHovered");
      inkWidgetRef.RegisterToCallback(this.m_additionalMenuArea, n"OnHoverOut", this, n"OnMenuHoverOut");
    };
    this.RegisterToCallback(n"OnSetAttributeOptionEnabled", this, n"OnSetAttributeOptionEnabled");
    this.RegisterToCallback(n"OnSetCategoryEnabled", this, n"OnSetCategoryEnabled");
    this.RegisterToCallback(n"OnSetStickerImage", this, n"OnSetStickerImage");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromCallback(n"OnSetAttributeOptionEnabled", this, n"OnSetAttributeOptionEnabled");
    this.UnregisterFromCallback(n"OnSetCategoryEnabled", this, n"OnSetCategoryEnabled");
    this.UnregisterFromCallback(n"OnSetStickerImage", this, n"OnSetStickerImage");
    if inkWidgetRef.IsValid(this.m_menuArea) {
      inkWidgetRef.UnregisterFromCallback(this.m_menuArea, n"OnHoverOver", this, n"OnMenuHovered");
      inkWidgetRef.UnregisterFromCallback(this.m_menuArea, n"OnHoverOut", this, n"OnMenuHoverOut");
      inkWidgetRef.UnregisterFromCallback(this.m_additionalMenuArea, n"OnHoverOver", this, n"OnMenuHovered");
      inkWidgetRef.UnregisterFromCallback(this.m_additionalMenuArea, n"OnHoverOut", this, n"OnMenuHoverOut");
    };
    if IsDefined(this.m_topButtonsController) {
      this.m_topButtonsController.UnregisterFromCallback(n"OnValueChanged", this, n"OnTopBarValueChanged");
    };
  }

  protected cb func OnIntroAnimEnded(e: ref<inkAnimProxy>) -> Bool {
    let options: inkAnimOptions;
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnPMButtonRelease");
    this.RegisterToGlobalInputCallback(n"OnPostOnHold", this, n"OnPMButtonHold");
    this.RegisterToGlobalInputCallback(n"OnPostOnHold", this, n"OnOptionHold");
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnOptionHoldRelease");
    this.OnAnimationEnded(0u);
    options.loopType = inkanimLoopType.Cycle;
    options.loopInfinite = true;
    this.loopAnimproxy = this.PlayLibraryAnimation(n"idle_loop", options);
  }

  protected cb func OnOutroAnimEnded(e: ref<inkAnimProxy>) -> Bool {
    this.OnAnimationEnded(1u);
  }

  protected cb func OnShow(reversedUI: Bool) -> Bool {
    let animproxy: ref<inkAnimProxy>;
    let i: Int32;
    let pageController: ref<PhotoModeListController>;
    let widget: wref<inkWidget> = this.GetRootWidget();
    widget.SetOpacity(1.00);
    if this.m_topButtonsController.GetCurrentIndex() != 0 {
      this.m_topButtonsController.Toggle(0);
    };
    i = 0;
    while i < ArraySize(this.m_menuPages) {
      pageController = this.GetMenuPage(Cast(i)) as PhotoModeListController;
      pageController.SetReversedUI(reversedUI);
      i += 1;
    };
    this.OnSetCurrentMenuPage(0u);
    animproxy = this.PlayLibraryAnimation(n"intro");
    animproxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnIntroAnimEnded");
    this.CloseWeaponsWheelAndStopEffects();
  }

  protected final func CloseWeaponsWheelAndStopEffects() -> Void {
    let radialMenuCloseEvt: ref<ForceRadialWheelShutdown> = new ForceRadialWheelShutdown();
    let requestStopPulse: ref<PulseFinishedRequest> = new PulseFinishedRequest();
    this.GetPlayerControlledObject().QueueEvent(radialMenuCloseEvt);
    this.GetPlayerControlledObject().GetHudManager().QueueRequest(requestStopPulse);
    GameObjectEffectHelper.StopEffectEvent(this.GetPlayerControlledObject(), n"fx_health_low");
  }

  protected cb func OnHide() -> Bool {
    let animproxy: ref<inkAnimProxy>;
    let playerHelthState: Uint32;
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnPMButtonRelease");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnHold", this, n"OnPMButtonHold");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnHold", this, n"OnOptionHold");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnOptionHoldRelease");
    if IsDefined(this.loopAnimproxy) {
      this.loopAnimproxy.Stop();
      this.loopAnimproxy = null;
    };
    animproxy = this.PlayLibraryAnimation(n"outro");
    animproxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnOutroAnimEnded");
    playerHelthState = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().PhotoMode).GetUint(GetAllBlackboardDefs().PhotoMode.PlayerHealthState);
    if playerHelthState == 1u {
      GameObjectEffectHelper.StartEffectEvent(this.GetPlayerControlledObject(), n"fx_health_low");
    };
    this.m_uiVisiblityFadeAnim = null;
    if IsDefined(this.m_cameraLocationController) {
      this.m_cameraLocationController.OnHide();
    };
  }

  protected cb func OnSetStickerImage(stickerIndex: Uint32, atlasPath: ResRef, imagePart: CName, imageIndex: Int32) -> Bool {
    let photoModeListItem: ref<PhotoModeMenuListItem> = this.GetMenuItem(35u);
    if IsDefined(photoModeListItem) {
      photoModeListItem.SetGridButtonImage(stickerIndex, atlasPath, imagePart, imageIndex);
    };
  }

  protected cb func OnSetScreenshotEnabled(screenshotVersion: Uint32) -> Bool {
    if screenshotVersion == 0u {
      inkWidgetRef.SetVisible(this.m_inputScreenshot, true);
    } else {
      inkWidgetRef.SetVisible(this.m_inputScreenshot, false);
      this.AddConsoleScreenshotInput(screenshotVersion);
    };
  }

  protected cb func OnUpdate(timeDelta: Float) -> Bool {
    let exitLocked: Bool;
    let i: Int32;
    let pageController: ref<PhotoModeListController>;
    let photoModeListItem: ref<PhotoModeMenuListItem> = this.GetCurrentSelectedMenuListItem();
    if IsDefined(photoModeListItem) {
      photoModeListItem.Update(timeDelta);
    };
    i = 0;
    while i < ArraySize(this.m_menuPages) {
      pageController = this.GetMenuPage(Cast(i)) as PhotoModeListController;
      pageController.Update(timeDelta);
      i += 1;
    };
    exitLocked = GameInstance.GetPhotoModeSystem(this.GetPlayerControlledObject().GetGame()).IsExitLocked();
    if exitLocked && inkWidgetRef.IsVisible(this.m_inputExit) {
      inkWidgetRef.SetVisible(this.m_inputExit, false);
    } else {
      if !exitLocked && !inkWidgetRef.IsVisible(this.m_inputExit) {
        inkWidgetRef.SetVisible(this.m_inputExit, true);
      };
    };
    if IsDefined(this.m_cameraLocationController) {
      this.m_cameraLocationController.RefreshValue(GameInstance.GetPhotoModeSystem(this.GetPlayerControlledObject().GetGame()));
    };
  }

  public final func SetCurrentMenuPage(page: Uint32) -> Void {
    let data: ref<PhotoModeMenuListItemData>;
    let firstVisible: Int32;
    let newPage: ref<PhotoModeListController>;
    let pageController: ref<PhotoModeListController>;
    let photoModeListItem: ref<PhotoModeMenuListItem>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_menuPages) {
      pageController = this.GetMenuPage(Cast(i)) as PhotoModeListController;
      if i == Cast(page) {
        pageController.ShowAnimated(0.15);
      } else {
        if i == Cast(this.m_currentPage) {
          pageController.HideAnimated(0.00);
        };
      };
      i += 1;
    };
    this.m_currentPage = page;
    newPage = this.GetMenuPage(page) as PhotoModeListController;
    firstVisible = newPage.GetFirstVisibleIndex();
    newPage.SetSelectedIndex(firstVisible);
    this.OnEditCategoryChanged(page);
    photoModeListItem = this.GetCurrentSelectedMenuListItem();
    data = photoModeListItem.GetData() as PhotoModeMenuListItemData;
    this.OnAttributeSelected(data.attributeKey);
  }

  protected cb func OnSetCurrentMenuPage(page: Uint32) -> Bool {
    this.SetCurrentMenuPage(page);
  }

  protected cb func OnTopBarValueChanged(controller: wref<inkRadioGroupController>, selectedIndex: Int32) -> Bool {
    this.OnSetCurrentMenuPage(Cast(selectedIndex));
  }

  protected cb func OnAddMenuItem(labelText: String, attributeKey: Uint32, page: Uint32) -> Bool {
    this.AddMenuItem(labelText, attributeKey, page, false);
  }

  protected cb func OnAddAdditionalMenuItem(labelText: String, attributeKey: Uint32, page: Uint32) -> Bool {
    this.AddMenuItem(labelText, attributeKey, page, true);
  }

  protected final func AddConsoleScreenshotInput(screenshotVersion: Uint32) -> Void {
    if screenshotVersion == 1u && this.ps4InputWidget == null {
      this.ps4InputWidget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_inputBottomRoot), this.m_ps4InputLibraryId);
      this.ps4InputWidget.SetMargin(50.00, 0.00, 0.00, 0.00);
      inkCompoundRef.ReorderChild(this.m_inputBottomRoot, this.ps4InputWidget, 2);
    } else {
      if screenshotVersion == 2u && this.xboxInputWidget == null {
        this.xboxInputWidget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_inputBottomRoot), this.m_xboxInputLibraryId);
        this.xboxInputWidget.SetMargin(50.00, 0.00, 0.00, 0.00);
        inkCompoundRef.ReorderChild(this.m_inputBottomRoot, this.xboxInputWidget, 2);
      };
    };
  }

  protected cb func OnAddingMenuItemsFinished() -> Bool {
    let pageController: ref<PhotoModeListController>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_menuPages) {
      pageController = this.GetMenuPage(Cast(i)) as PhotoModeListController;
      pageController.PostInitItems();
      i += 1;
    };
  }

  protected cb func OnForceAttributeVaulue(attribute: Uint32, value: Float) -> Bool {
    let photoModeListItem: ref<PhotoModeMenuListItem> = this.GetMenuItem(attribute);
    if IsDefined(photoModeListItem) {
      photoModeListItem.ForceValue(value);
    };
  }

  protected cb func OnFadeVisibility(opacity: Float) -> Bool {
    let animDef: ref<inkAnimDef>;
    let animInterp: ref<inkAnimTransparency>;
    let widget: wref<inkWidget> = this.GetRootWidget();
    if widget.GetOpacity() != opacity {
      animDef = new inkAnimDef();
      animInterp = new inkAnimTransparency();
      animInterp.SetStartTransparency(widget.GetOpacity());
      animInterp.SetEndTransparency(opacity);
      animInterp.SetDuration(0.30);
      animInterp.SetDirection(inkanimInterpolationDirection.To);
      animInterp.SetUseRelativeDuration(true);
      animDef.AddInterpolator(animInterp);
      if this.m_uiVisiblityFadeAnim != null {
        this.m_uiVisiblityFadeAnim.Stop();
      };
      this.m_uiVisiblityFadeAnim = widget.PlayAnimation(animDef);
    };
  }

  protected cb func OnHideForScreenshot() -> Bool {
    if this.m_uiVisiblityFadeAnim != null {
      this.m_uiVisiblityFadeAnim.Stop();
      this.m_uiVisiblityFadeAnim = null;
    };
  }

  protected cb func OnSetupGridSelector(attribute: Uint32, gridData: array<PhotoModeOptionGridButtonData>, elementsCount: Uint32, elementsInRow: Uint32) -> Bool {
    let photoModeListItem: ref<PhotoModeMenuListItem> = this.GetMenuItem(attribute);
    if IsDefined(photoModeListItem) {
      photoModeListItem.m_photoModeController = this;
      photoModeListItem.SetupGridSelector(gridData, elementsCount, elementsInRow);
      photoModeListItem.SetIsEnabled(true);
      this.OnAttributeUpdated(attribute, photoModeListItem.GetSliderValue());
    };
  }

  protected cb func OnSetupScrollBar(attribute: Uint32, startValue: Float, minValue: Float, maxValue: Float, step: Float, showPercents: Bool) -> Bool {
    let photoModeListItem: ref<PhotoModeMenuListItem> = this.GetMenuItem(attribute);
    if IsDefined(photoModeListItem) {
      photoModeListItem.m_photoModeController = this;
      photoModeListItem.SetupScrollBar(startValue, minValue, maxValue, step, showPercents);
      photoModeListItem.SetIsEnabled(true);
      this.OnAttributeUpdated(attribute, photoModeListItem.GetSliderValue());
    };
  }

  protected cb func OnSetupOptionSelector(attribute: Uint32, values: array<PhotoModeOptionSelectorData>, startData: Int32) -> Bool {
    let photoModeListItem: ref<PhotoModeMenuListItem> = this.GetMenuItem(attribute);
    if IsDefined(photoModeListItem) {
      photoModeListItem.m_photoModeController = this;
      photoModeListItem.SetupOptionSelector(values, startData);
      photoModeListItem.SetIsEnabled(true);
      this.OnAttributeUpdated(attribute, Cast(values[photoModeListItem.GetSelectedOptionIndex()].optionData));
    };
  }

  protected cb func OnSetupOptionButton(attribute: Uint32, value: PhotoModeOptionSelectorData) -> Bool {
    let photoModeListItem: ref<PhotoModeMenuListItem> = this.GetMenuItem(attribute);
    if IsDefined(photoModeListItem) {
      photoModeListItem.m_photoModeController = this;
      photoModeListItem.SetupOptionButton(value);
      photoModeListItem.SetIsEnabled(true);
      this.OnAttributeUpdated(attribute, Cast(photoModeListItem.GetSelectedOptionIndex()));
    };
  }

  protected cb func OnSetAttributeOptionEnabled(attributeKey: Uint32, enabled: Bool) -> Bool {
    let pageController: ref<PhotoModeListController>;
    let photoModeListItem: ref<PhotoModeMenuListItem> = this.GetMenuItem(attributeKey);
    if IsDefined(photoModeListItem) {
      photoModeListItem.SetIsEnabled(enabled);
      if !enabled {
        if this.GetCurrentSelectedMenuListItem() == photoModeListItem {
          pageController = this.GetMenuPage(this.m_currentPage) as PhotoModeListController;
          pageController.SetSelectedIndex(pageController.GetFirstVisibleIndex());
        };
      };
    };
  }

  protected cb func OnSetCategoryEnabled(category: Uint32, enabled: Bool) -> Bool {
    this.m_topButtonsController.SetToggleEnabled(Cast(category), enabled);
  }

  protected cb func OnPhotoModeFailedToOpenEvent() -> Bool {
    let notificationEvent: ref<UIInGameNotificationEvent> = new UIInGameNotificationEvent();
    notificationEvent.m_notificationType = UIInGameNotificationType.PhotoModeDisabledRestriction;
    GameInstance.GetUISystem(this.GetPlayerControlledObject().GetGame()).QueueEvent(new UIInGameNotificationRemoveEvent());
    GameInstance.GetUISystem(this.GetPlayerControlledObject().GetGame()).QueueEvent(notificationEvent);
  }

  protected cb func OnPhotoModeFailedToOpenComplete(data: ref<inkGameNotificationData>) -> Bool {
    this.m_notificationToken = null;
    this.m_notificationUserData = null;
  }

  protected cb func OnPhotoModeLastInputDeviceEvent(wasKeyboardMouse: Bool) -> Bool {
    let kbdWidget: inkWidgetRef;
    let padWidget: inkWidgetRef;
    inkWidgetRef.SetVisible(this.m_inputCameraKbd, false);
    inkWidgetRef.SetVisible(this.m_inputCameraPad, false);
    inkWidgetRef.SetVisible(this.m_inputStickersKbd, false);
    inkWidgetRef.SetVisible(this.m_inputStickersPad, false);
    inkWidgetRef.SetVisible(this.m_inputSaveLoadKbd, false);
    inkWidgetRef.SetVisible(this.m_inputSaveLoadPad, false);
    if this.m_currentPage == 4u {
      kbdWidget = this.m_inputStickersKbd;
      padWidget = this.m_inputStickersPad;
    } else {
      if this.m_currentPage == 5u {
        kbdWidget = this.m_inputSaveLoadKbd;
        padWidget = this.m_inputSaveLoadPad;
      } else {
        kbdWidget = this.m_inputCameraKbd;
        padWidget = this.m_inputCameraPad;
      };
    };
    if wasKeyboardMouse {
      inkWidgetRef.SetVisible(kbdWidget, true);
      inkWidgetRef.SetVisible(padWidget, false);
    } else {
      inkWidgetRef.SetVisible(kbdWidget, false);
      inkWidgetRef.SetVisible(padWidget, true);
    };
  }

  protected cb func OnSetInteractive(interactive: Bool) -> Bool {
    let i: Int32;
    let listItemWidget: wref<inkWidget>;
    let pageController: ref<ListController>;
    let photoModeListItem: ref<PhotoModeMenuListItem>;
    let j: Int32 = 0;
    while j < ArraySize(this.m_menuPages) {
      pageController = this.GetMenuPage(Cast(j));
      i = 0;
      while i < pageController.Size() {
        listItemWidget = pageController.GetItemAt(i);
        if IsDefined(listItemWidget) {
          photoModeListItem = listItemWidget.GetControllerByType(n"PhotoModeMenuListItem") as PhotoModeMenuListItem;
          photoModeListItem.SetInteractive(interactive);
        };
        i += 1;
      };
      j += 1;
    };
    this.m_topButtonsController.SetInteractive(interactive);
  }

  public final func GetMenuItem(attributeKey: Uint32) -> ref<PhotoModeMenuListItem> {
    let data: ref<PhotoModeMenuListItemData>;
    let i: Int32;
    let listItemWidget: wref<inkWidget>;
    let pageController: ref<ListController>;
    let photoModeListItem: ref<PhotoModeMenuListItem>;
    let j: Int32 = 0;
    while j < ArraySize(this.m_menuPages) {
      pageController = this.GetMenuPage(Cast(j));
      i = 0;
      while i < pageController.Size() {
        listItemWidget = pageController.GetItemAt(i);
        if IsDefined(listItemWidget) {
          photoModeListItem = listItemWidget.GetControllerByType(n"PhotoModeMenuListItem") as PhotoModeMenuListItem;
          data = photoModeListItem.GetData() as PhotoModeMenuListItemData;
          if data.attributeKey == attributeKey {
            return photoModeListItem;
          };
        };
        i += 1;
      };
      j += 1;
    };
    return null;
  }

  protected final func AddMenuPage(isAdditional: Bool) -> ref<ListController> {
    let newmenuList: wref<inkWidget>;
    let pageController: ref<ListController>;
    if isAdditional {
      newmenuList = this.SpawnFromLocal(inkWidgetRef.Get(this.m_additionalListRoot), this.m_listContainerId);
    } else {
      newmenuList = this.SpawnFromLocal(inkWidgetRef.Get(this.m_menuListRoot), this.m_listContainerId);
    };
    newmenuList.SetMargin(0.00, 100.00, 0.00, 0.00);
    ArrayPush(this.m_menuPages, newmenuList);
    pageController = newmenuList.GetController() as ListController;
    pageController.RegisterToCallback(n"OnItemSelected", this, n"OnMenuItemSelected");
    return pageController;
  }

  protected final func GetMenuPage(pageIndex: Uint32) -> ref<ListController> {
    return this.m_menuPages[Cast(pageIndex)].GetController() as ListController;
  }

  protected final func AddMenuItem(label: String, attributeKey: Uint32, page: Uint32, isAdditional: Bool) -> Void {
    let data: ref<PhotoModeMenuListItemData>;
    let pageController: ref<ListController>;
    if Cast(page) >= ArraySize(this.m_menuPages) {
      pageController = this.AddMenuPage(isAdditional);
    } else {
      pageController = this.GetMenuPage(page);
    };
    data = new PhotoModeMenuListItemData();
    data.label = label;
    data.attributeKey = attributeKey;
    pageController.PushData(data);
  }

  protected final func GetCurrentSelectedMenuListItem() -> ref<PhotoModeMenuListItem> {
    let listItemWidget: wref<inkWidget>;
    let pageController: ref<ListController> = this.GetMenuPage(this.m_currentPage);
    let itemIndex: Int32 = pageController.GetSelectedIndex();
    if itemIndex >= 0 {
      listItemWidget = pageController.GetItemAt(itemIndex);
      if IsDefined(listItemWidget) {
        return listItemWidget.GetControllerByType(n"PhotoModeMenuListItem") as PhotoModeMenuListItem;
      };
    };
    return null;
  }

  protected cb func OnPMButtonRelease(evt: ref<inkPointerEvent>) -> Bool {
    let photoModeListItem: ref<PhotoModeMenuListItem>;
    let pageController: ref<PhotoModeListController> = this.GetMenuPage(this.m_currentPage) as PhotoModeListController;
    pageController.HandleInputWithVisibilityCheck(evt, null);
    this.m_topButtonsController.HandleInput(evt, this);
    photoModeListItem = this.GetCurrentSelectedMenuListItem();
    if IsDefined(photoModeListItem) {
      photoModeListItem.HandleReleasedInput(evt, this);
    };
  }

  protected cb func OnPMButtonHold(evt: ref<inkPointerEvent>) -> Bool {
    let photoModeListItem: ref<PhotoModeMenuListItem> = this.GetCurrentSelectedMenuListItem();
    if IsDefined(photoModeListItem) {
      photoModeListItem.HandleHoldInput(evt, this);
    };
  }

  protected cb func OnMenuItemSelected(index: Int32, target: ref<ListItemController>) -> Bool {
    let photoModeListItem: ref<PhotoModeMenuListItem> = target as PhotoModeMenuListItem;
    let data: ref<PhotoModeMenuListItemData> = photoModeListItem.GetData() as PhotoModeMenuListItemData;
    this.OnAttributeSelected(data.attributeKey);
  }

  protected cb func OnMenuHovered(e: ref<inkPointerEvent>) -> Bool {
    if !this.m_IsHoverOver {
      this.OnHoverStateChanged(true);
      this.SetCursorContext(n"Hover");
    };
    this.m_IsHoverOver = true;
  }

  protected cb func OnMenuHoverOut(e: ref<inkPointerEvent>) -> Bool {
    if this.m_IsHoverOver {
      this.OnHoverStateChanged(false);
      this.SetCursorContext(n"Default");
    };
    this.m_IsHoverOver = false;
  }

  protected cb func OnOptionHold(evt: ref<inkPointerEvent>) -> Bool {
    let data: ref<PhotoModeMenuListItemData>;
    let photoModeListItem: ref<PhotoModeMenuListItem>;
    let progress: Float = evt.GetHoldProgress();
    if evt.IsAction(n"PhotoMode_SaveSettings") || evt.IsAction(n"PhotoMode_LoadSettings") {
      photoModeListItem = this.GetCurrentSelectedMenuListItem();
      if IsDefined(photoModeListItem) {
        if progress >= 1.00 && !this.m_holdSafeguard {
          this.m_holdSafeguard = true;
          photoModeListItem.SetHoldProgress(1.00);
          data = photoModeListItem.GetData() as PhotoModeMenuListItemData;
          if evt.IsAction(n"PhotoMode_SaveSettings") {
            this.OnHoldComplete(data.attributeKey, n"PhotoMode_SaveSettings");
          } else {
            if evt.IsAction(n"PhotoMode_LoadSettings") {
              this.OnHoldComplete(data.attributeKey, n"PhotoMode_LoadSettings");
            };
          };
        } else {
          photoModeListItem.SetHoldProgress(progress);
        };
      };
    };
  }

  protected cb func OnOptionHoldRelease(evt: ref<inkPointerEvent>) -> Bool {
    this.m_holdSafeguard = false;
    let photoModeListItem: ref<PhotoModeMenuListItem> = this.GetCurrentSelectedMenuListItem();
    if IsDefined(photoModeListItem) {
      photoModeListItem.SetHoldProgress(0.00);
    };
  }
}

public class PhotoModeMenuListItem extends ListItemController {

  private edit let m_ScrollBarRef: inkWidgetRef;

  private edit let m_CounterLabelRef: inkTextRef;

  private edit let m_TextLabelRef: inkTextRef;

  private edit let m_OptionSelectorRef: inkWidgetRef;

  private edit let m_LeftArrow: inkWidgetRef;

  private edit let m_RightArrow: inkWidgetRef;

  private edit let m_LeftButton: inkWidgetRef;

  private edit let m_RightButton: inkWidgetRef;

  private edit let m_OptionLabelRef: inkTextRef;

  private edit let m_SelectedWidgetRef: inkWidgetRef;

  private edit let m_TextRootWidgetRef: inkWidgetRef;

  private edit let m_SliderRootWidgetRef: inkWidgetRef;

  private edit let m_OptionSelectorRootWidgetRef: inkWidgetRef;

  private edit let m_HoldButtonRootWidgetRef: inkWidgetRef;

  private edit let m_ScrollBarLineRef: inkWidgetRef;

  private edit let m_ScrollBarHandleRef: inkWidgetRef;

  private edit let m_ScrollSlidingAreaRef: inkWidgetRef;

  private edit let m_HoldProgressRef: inkWidgetRef;

  private edit let m_GridRoot: inkWidgetRef;

  private edit let m_GridTopRow: inkWidgetRef;

  private edit let m_GridBottomRow: inkWidgetRef;

  private let m_ScrollBar: wref<inkSliderController>;

  private let m_OptionSelector: wref<SelectorController>;

  private let m_OptionSelectorValues: array<PhotoModeOptionSelectorData>;

  private let m_GridSelector: wref<PhotoModeGridList>;

  private let m_SliderValue: Float;

  private let m_StepValue: Float;

  private let m_SliderShowPercents: Bool;

  public let m_photoModeController: wref<gameuiPhotoModeMenuController>;

  private let m_holdBgInitMargin: inkMargin;

  private let m_allowHold: Bool;

  private let m_inputDirection: Int32;

  private let m_inputStepTime: Float;

  private let m_inputHoldTime: Float;

  private let m_arrowClickedTime: Float;

  private let m_isSelected: Bool;

  private let m_fadeAnim: ref<inkAnimProxy>;

  private let m_RightArrowInitOpacity: Float;

  private let m_LeftArrowInitOpacity: Float;

  private let m_ScrollBarHandleInitOpacity: Float;

  private let m_ScrollBarLineInitOpacity: Float;

  protected cb func OnInitialize() -> Bool {
    this.m_RightArrowInitOpacity = inkWidgetRef.GetOpacity(this.m_RightArrow);
    this.m_LeftArrowInitOpacity = inkWidgetRef.GetOpacity(this.m_LeftArrow);
    this.m_ScrollBarHandleInitOpacity = inkWidgetRef.GetOpacity(this.m_ScrollBarHandleRef);
    this.m_ScrollBarLineInitOpacity = inkWidgetRef.GetOpacity(this.m_ScrollBarLineRef);
    if inkWidgetRef.IsValid(this.m_ScrollBarRef) {
      this.m_ScrollBar = inkWidgetRef.GetControllerByType(this.m_ScrollBarRef, n"inkSliderController") as inkSliderController;
    };
    if IsDefined(this.m_ScrollBar) {
      this.m_ScrollBar.RegisterToCallback(n"OnSliderValueChanged", this, n"OnScrollBarValueChanged");
    };
    if inkWidgetRef.IsValid(this.m_OptionSelectorRef) {
      this.m_OptionSelector = inkWidgetRef.GetController(this.m_OptionSelectorRef) as SelectorController;
    };
    inkWidgetRef.SetVisible(this.m_SelectedWidgetRef, false);
    inkWidgetRef.SetOpacity(this.m_SelectedWidgetRef, 0.00);
    this.RegisterToCallback(n"OnSelected", this, n"OnSelected");
    this.RegisterToCallback(n"OnDeselected", this, n"OnDeselected");
    this.RegisterToCallback(n"OnAddedToList", this, n"OnAddedToList");
    this.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
    if inkWidgetRef.IsValid(this.m_LeftArrow) {
      inkWidgetRef.RegisterToCallback(this.m_LeftButton, n"OnRelease", this, n"OnOptionLeft");
      inkWidgetRef.SetOpacity(this.m_LeftArrow, 0.00);
    };
    if inkWidgetRef.IsValid(this.m_RightArrow) {
      inkWidgetRef.RegisterToCallback(this.m_RightButton, n"OnRelease", this, n"OnOptionRight");
      inkWidgetRef.SetOpacity(this.m_RightArrow, 0.00);
    };
    if inkWidgetRef.IsValid(this.m_HoldProgressRef) {
      this.m_holdBgInitMargin = inkWidgetRef.GetMargin(this.m_HoldProgressRef);
    };
    inkWidgetRef.SetOpacity(this.m_ScrollBarHandleRef, this.m_ScrollBarLineInitOpacity);
    inkWidgetRef.SetOpacity(this.m_ScrollBarLineRef, 0.01);
    inkWidgetRef.Get(this.m_ScrollBarHandleRef).BindProperty(n"tintColor", n"MainColors.Red");
    inkWidgetRef.Get(this.m_CounterLabelRef).BindProperty(n"tintColor", n"MainColors.Red");
    this.m_allowHold = false;
    this.m_arrowClickedTime = 0.00;
    this.m_isSelected = false;
    this.ResetInputHold();
    super.OnInitialize();
  }

  public final func SetReversedUI(isRevesed: Bool) -> Void {
    if isRevesed {
      inkWidgetRef.SetMargin(this.m_TextRootWidgetRef, 1040.00, 0.00, 0.00, 0.00);
      inkWidgetRef.SetAnchor(this.m_TextLabelRef, inkEAnchor.CenterRight);
      inkWidgetRef.SetAnchorPoint(this.m_TextLabelRef, 1.00, 0.50);
      inkWidgetRef.SetMargin(this.m_TextLabelRef, 0.00, 0.00, 100.00, 0.00);
      inkWidgetRef.SetMargin(this.m_SliderRootWidgetRef, 80.00, 0.00, 0.00, 0.00);
      inkWidgetRef.SetMargin(this.m_OptionSelectorRootWidgetRef, 80.00, 0.00, 0.00, 0.00);
      inkWidgetRef.SetMargin(this.m_HoldButtonRootWidgetRef, 0.00, 0.00, 0.00, 0.00);
    } else {
      inkWidgetRef.SetMargin(this.m_TextRootWidgetRef, 0.00, 0.00, 0.00, 0.00);
      inkWidgetRef.SetAnchor(this.m_TextLabelRef, inkEAnchor.CenterLeft);
      inkWidgetRef.SetAnchorPoint(this.m_TextLabelRef, 0.00, 0.50);
      inkWidgetRef.SetMargin(this.m_TextLabelRef, 30.00, 0.00, 0.00, 0.00);
      inkWidgetRef.SetMargin(this.m_SliderRootWidgetRef, 530.00, 0.00, 0.00, 0.00);
      inkWidgetRef.SetMargin(this.m_OptionSelectorRootWidgetRef, 530.00, 0.00, 0.00, 0.00);
      inkWidgetRef.SetMargin(this.m_HoldButtonRootWidgetRef, 450.00, 0.00, 0.00, 0.00);
    };
  }

  private final func PlayFadeAnimation(widget: inkWidgetRef, opacity: Float) -> Void {
    let animDef: ref<inkAnimDef>;
    let animInterp: ref<inkAnimTransparency>;
    if inkWidgetRef.GetOpacity(widget) == opacity {
      return;
    };
    animDef = new inkAnimDef();
    animInterp = new inkAnimTransparency();
    animInterp.SetStartTransparency(inkWidgetRef.GetOpacity(widget));
    animInterp.SetEndTransparency(opacity);
    animInterp.SetDuration(0.30);
    animInterp.SetDirection(inkanimInterpolationDirection.To);
    animInterp.SetUseRelativeDuration(true);
    animDef.AddInterpolator(animInterp);
    if this.m_fadeAnim != null {
      this.m_fadeAnim.Stop();
    };
    this.m_fadeAnim = inkWidgetRef.PlayAnimation(widget, animDef);
  }

  private final func SetSelectedVisualState(isSelected: Bool) -> Void {
    inkWidgetRef.SetVisible(this.m_SelectedWidgetRef, true);
    if isSelected {
      if this.m_OptionSelector.GetValuesCount() > 1 {
        inkWidgetRef.SetOpacity(this.m_RightArrow, this.m_RightArrowInitOpacity);
        inkWidgetRef.SetOpacity(this.m_LeftArrow, this.m_LeftArrowInitOpacity);
      } else {
        inkWidgetRef.SetOpacity(this.m_RightArrow, 0.00);
        inkWidgetRef.SetOpacity(this.m_LeftArrow, 0.00);
      };
      inkWidgetRef.SetOpacity(this.m_ScrollBarHandleRef, this.m_ScrollBarHandleInitOpacity);
      inkWidgetRef.SetOpacity(this.m_ScrollBarLineRef, this.m_ScrollBarLineInitOpacity);
      inkWidgetRef.Get(this.m_ScrollBarHandleRef).BindProperty(n"tintColor", n"MainColors.Blue");
      inkWidgetRef.Get(this.m_CounterLabelRef).BindProperty(n"tintColor", n"MainColors.DarkRed");
      inkWidgetRef.Get(this.m_OptionLabelRef).BindProperty(n"tintColor", n"MainColors.Blue");
      if !this.m_isSelected {
        inkWidgetRef.SetOpacity(this.m_SelectedWidgetRef, 0.00);
      };
      if IsDefined(this.m_GridSelector) {
        this.m_GridSelector.OnSelected();
      };
    } else {
      inkWidgetRef.SetOpacity(this.m_RightArrow, 0.00);
      inkWidgetRef.SetOpacity(this.m_LeftArrow, 0.00);
      inkWidgetRef.SetOpacity(this.m_ScrollBarHandleRef, this.m_ScrollBarLineInitOpacity);
      inkWidgetRef.SetOpacity(this.m_ScrollBarLineRef, 0.01);
      inkWidgetRef.Get(this.m_ScrollBarHandleRef).BindProperty(n"tintColor", n"MainColors.Red");
      inkWidgetRef.Get(this.m_CounterLabelRef).BindProperty(n"tintColor", n"MainColors.Red");
      inkWidgetRef.Get(this.m_OptionLabelRef).BindProperty(n"tintColor", n"MainColors.Red");
      if IsDefined(this.m_GridSelector) {
        this.m_GridSelector.OnDeSelected();
      };
    };
  }

  protected cb func OnSelected(target: wref<ListItemController>) -> Bool {
    this.SetSelectedVisualState(true);
    this.PlayFadeAnimation(this.m_SelectedWidgetRef, 1.00);
    this.SetHoldProgress(0.00);
    this.ResetInputHold();
    this.m_isSelected = true;
  }

  protected cb func OnDeselected(parent: wref<ListItemController>) -> Bool {
    this.SetSelectedVisualState(false);
    this.PlayFadeAnimation(this.m_SelectedWidgetRef, 0.00);
    inkWidgetRef.SetMargin(this.m_HoldProgressRef, this.m_holdBgInitMargin);
    this.SetHoldProgress(0.00);
    this.ResetInputHold();
    this.m_isSelected = false;
  }

  protected cb func OnAddedToList(target: wref<ListItemController>) -> Bool;

  public final func OnVisbilityChanged(visible: Bool) -> Void {
    if IsDefined(this.m_GridSelector) {
      this.m_GridSelector.OnVisbilityChanged(visible);
    };
  }

  public final func SetInteractive(interactive: Bool) -> Void {
    this.GetRootWidget().SetInteractive(interactive);
    inkWidgetRef.SetInteractive(this.m_TextRootWidgetRef, interactive);
    inkWidgetRef.SetInteractive(this.m_OptionLabelRef, interactive);
    if this.m_ScrollBar.GetRootWidget().IsVisible() {
      inkWidgetRef.SetInteractive(this.m_ScrollSlidingAreaRef, interactive);
    };
    if this.m_OptionSelector.GetRootWidget().IsVisible() {
      inkWidgetRef.SetInteractive(this.m_LeftButton, interactive);
      inkWidgetRef.SetInteractive(this.m_RightButton, interactive);
    };
  }

  public final func SetIsEnabled(enabled: Bool) -> Void {
    this.GetRootWidget().SetVisible(enabled);
  }

  public final func ForceValue(value: Float) -> Void {
    let i: Int32;
    let setIndex: Int32;
    let data: ref<PhotoModeMenuListItemData> = this.GetData() as PhotoModeMenuListItemData;
    if this.m_ScrollBar.GetRootWidget().IsVisible() {
      this.m_ScrollBar.ChangeValue(value);
      this.m_photoModeController.OnAttributeUpdated(data.attributeKey, value);
    };
    if this.m_OptionSelector.GetRootWidget().IsVisible() {
      setIndex = 0;
      i = 0;
      while i < ArraySize(this.m_OptionSelectorValues) {
        if this.m_OptionSelectorValues[i].optionData == Cast(value) {
          setIndex = i;
        };
        i += 1;
      };
      this.m_OptionSelector.SetCurrIndex(setIndex);
      this.m_photoModeController.OnAttributeUpdated(data.attributeKey, Cast(this.m_OptionSelectorValues[setIndex].optionData));
    };
  }

  public final func SetupGridSelector(gridData: array<PhotoModeOptionGridButtonData>, elementsCount: Uint32, elementsInRow: Uint32) -> Void {
    let visibleSize: Float;
    let widgetToHide: wref<inkWidget>;
    let rootSize: Vector2 = this.GetRootWidget().GetSize();
    let rows: Int32 = Cast(elementsCount) / Cast(elementsInRow);
    if Cast(elementsCount) % Cast(elementsInRow) != 0 {
      rows += 1;
    };
    if IsDefined(this.m_ScrollBar) {
      widgetToHide = this.m_ScrollBar.GetRootWidget();
      widgetToHide.SetVisible(false);
      widgetToHide as inkCompoundWidget.RemoveAllChildren();
      inkWidgetRef.SetVisible(this.m_CounterLabelRef, false);
      inkWidgetRef.SetInteractive(this.m_ScrollSlidingAreaRef, false);
    };
    if IsDefined(this.m_OptionSelector) {
      widgetToHide = this.m_OptionSelector.GetRootWidget();
      widgetToHide.SetVisible(false);
      widgetToHide as inkCompoundWidget.RemoveAllChildren();
    };
    if inkWidgetRef.IsValid(this.m_GridRoot) {
      this.m_GridSelector = inkWidgetRef.GetControllerByType(this.m_GridRoot, n"PhotoModeGridList") as PhotoModeGridList;
      if Cast(elementsInRow) > 5 {
        inkWidgetRef.SetMargin(this.m_GridRoot, 30.00, 0.00, 0.00, 0.00);
        inkWidgetRef.SetSize(this.m_GridRoot, 1475.00, 80.00);
        rootSize.X += 50.00;
      };
      visibleSize = this.m_GridSelector.Setup(this, rows, Cast(elementsInRow));
      this.m_GridSelector.SetGridData(gridData);
      this.GetRootWidget().SetSize(rootSize.X, visibleSize);
    };
  }

  public final func SetupScrollBar(startValue: Float, minValue: Float, maxValue: Float, step: Float, showPercents: Bool) -> Void {
    let widgetToHide: wref<inkWidget>;
    this.m_StepValue = step;
    this.m_SliderShowPercents = showPercents;
    if IsDefined(this.m_ScrollBar) {
      this.m_ScrollBar.Setup(minValue, maxValue, startValue, step);
    };
    if IsDefined(this.m_OptionSelector) {
      widgetToHide = this.m_OptionSelector.GetRootWidget();
      widgetToHide.SetVisible(false);
      widgetToHide as inkCompoundWidget.RemoveAllChildren();
    };
    if inkWidgetRef.IsValid(this.m_GridRoot) {
      inkWidgetRef.SetVisible(this.m_GridRoot, false);
    };
  }

  public final func SetupOptionSelector(values: array<PhotoModeOptionSelectorData>, startData: Int32) -> Void {
    let i: Int32;
    let startIndex: Int32;
    let widgetToHide: wref<inkWidget>;
    this.m_StepValue = 1.00;
    if IsDefined(this.m_ScrollBar) {
      widgetToHide = this.m_ScrollBar.GetRootWidget();
      widgetToHide.SetVisible(false);
      widgetToHide as inkCompoundWidget.RemoveAllChildren();
      inkWidgetRef.SetVisible(this.m_CounterLabelRef, false);
      inkWidgetRef.SetInteractive(this.m_ScrollSlidingAreaRef, false);
    };
    if IsDefined(this.m_OptionSelector) {
      startIndex = 0;
      this.m_OptionSelectorValues = values;
      this.m_OptionSelector.Clear();
      i = 0;
      while i < ArraySize(this.m_OptionSelectorValues) {
        if this.m_OptionSelectorValues[i].optionData == startData {
          startIndex = i;
        };
        this.m_OptionSelector.AddValue(this.m_OptionSelectorValues[i].optionText);
        i += 1;
      };
      this.m_OptionSelector.SetCurrIndex(startIndex);
      if inkWidgetRef.IsVisible(this.m_SelectedWidgetRef) {
        this.OnSelected(null);
      };
    };
    if inkWidgetRef.IsValid(this.m_GridRoot) {
      inkWidgetRef.SetVisible(this.m_GridRoot, false);
    };
  }

  public final func SetupOptionButton(value: PhotoModeOptionSelectorData) -> Void {
    let values: array<PhotoModeOptionSelectorData>;
    ArrayPush(values, value);
    this.SetupOptionSelector(values, 0);
    inkWidgetRef.SetVisible(this.m_LeftArrow, false);
    inkWidgetRef.SetVisible(this.m_RightArrow, false);
    inkWidgetRef.SetVisible(this.m_LeftButton, false);
    inkWidgetRef.SetVisible(this.m_RightButton, false);
    this.m_allowHold = true;
  }

  public final func GetSliderValue() -> Float {
    return this.m_SliderValue;
  }

  public final func GetSelectedOptionIndex() -> Int32 {
    if IsDefined(this.m_OptionSelector) {
      return this.m_OptionSelector.GetCurrIndex();
    };
    return -1;
  }

  public final func GetGridSelector() -> wref<PhotoModeGridList> {
    return this.m_GridSelector;
  }

  public final func SetGridButtonImage(buttonIndex: Uint32, atlasPath: ResRef, imagePart: CName, buttonData: Int32) -> Void {
    if IsDefined(this.m_GridSelector) {
      this.m_GridSelector.SetGridButtonImage(buttonIndex, atlasPath, imagePart, buttonData);
    };
  }

  public final func SetSelectedGridButton(index: Int32) -> Void {
    if IsDefined(this.m_GridSelector) {
      this.m_GridSelector.SelectButton(index);
    };
  }

  public final func SetHoldProgress(progress: Float) -> Void {
    let margin: inkMargin;
    if this.m_allowHold {
      margin = this.m_holdBgInitMargin;
      margin.right = this.m_holdBgInitMargin.right * (1.00 - progress);
      inkWidgetRef.SetMargin(this.m_HoldProgressRef, margin);
    };
  }

  public final func HandleHoldInput(e: ref<inkPointerEvent>, opt gameCtrl: wref<inkGameController>) -> Void {
    if this.m_ScrollBar.GetRootWidget().IsVisible() {
      if e.IsAction(n"PhotoMode_Left_Button") {
        this.m_inputDirection = -1;
      } else {
        if e.IsAction(n"PhotoMode_Right_Button") {
          this.m_inputDirection = 1;
        };
      };
    };
  }

  public final func HandleReleasedInput(e: ref<inkPointerEvent>, opt gameCtrl: wref<inkGameController>) -> Void {
    let optionValue: Int32;
    let data: ref<PhotoModeMenuListItemData> = this.GetData() as PhotoModeMenuListItemData;
    if this.m_OptionSelector.GetRootWidget().IsVisible() {
      if e.IsAction(n"PhotoMode_Left_Button") {
        this.m_OptionSelector.Prior();
        this.StartArrowClickedEffect(this.m_LeftArrow);
        optionValue = this.m_OptionSelectorValues[this.m_OptionSelector.GetCurrIndex()].optionData;
        this.m_photoModeController.OnAttributeUpdated(data.attributeKey, Cast(optionValue));
      } else {
        if e.IsAction(n"PhotoMode_Right_Button") {
          this.m_OptionSelector.Next();
          this.StartArrowClickedEffect(this.m_RightArrow);
          optionValue = this.m_OptionSelectorValues[this.m_OptionSelector.GetCurrIndex()].optionData;
          this.m_photoModeController.OnAttributeUpdated(data.attributeKey, Cast(optionValue));
        };
      };
    };
    if this.m_ScrollBar.GetRootWidget().IsVisible() {
      if e.IsAction(n"PhotoMode_Left_Button") || e.IsAction(n"PhotoMode_Right_Button") {
        this.ResetInputHold();
      };
    };
    if IsDefined(this.m_GridSelector) {
      this.m_GridSelector.HandleReleasedInput(e, gameCtrl);
    };
  }

  protected cb func OnScrollBarValueChanged(controller: wref<inkSliderController>, progress: Float, newValue: Float) -> Bool {
    let data: ref<PhotoModeMenuListItemData>;
    let intFractionValue: Int32;
    let intNewValue: Int32;
    let minusSign: String;
    let newValuePercent: Float;
    let scrollBarRange: Float;
    let stepDigits: Int32;
    if this.m_SliderShowPercents {
      scrollBarRange = MaxF(AbsF(this.m_ScrollBar.GetMaxValue()), AbsF(this.m_ScrollBar.GetMinValue()));
      newValuePercent = (100.00 * newValue) / scrollBarRange;
      intNewValue = RoundMath(newValuePercent);
      if intNewValue == 0 && newValue < 0.00 {
        minusSign = "-";
      };
      inkTextRef.SetText(this.m_CounterLabelRef, minusSign + IntToString(intNewValue));
    } else {
      intNewValue = Cast(newValue);
      intFractionValue = Cast(100.00 * AbsF(newValue) % 1.00);
      stepDigits = Cast(this.m_StepValue * 100.00) % 10 == 0 ? 10 : 1;
      if intNewValue == 0 && newValue < 0.00 {
        minusSign = "-";
      };
      if this.m_StepValue % 1.00 == 0.00 {
        inkTextRef.SetText(this.m_CounterLabelRef, minusSign + IntToString(intNewValue));
      } else {
        if intFractionValue < 10 && intFractionValue != 0 {
          inkTextRef.SetText(this.m_CounterLabelRef, minusSign + IntToString(intNewValue) + ".0" + IntToString(intFractionValue));
        } else {
          intFractionValue = intFractionValue / stepDigits;
          inkTextRef.SetText(this.m_CounterLabelRef, minusSign + IntToString(intNewValue) + "." + IntToString(intFractionValue));
        };
      };
    };
    this.m_SliderValue = newValue;
    data = this.GetData() as PhotoModeMenuListItemData;
    this.m_photoModeController.OnAttributeUpdated(data.attributeKey, this.m_SliderValue);
  }

  protected cb func OnOptionLeft(e: ref<inkPointerEvent>) -> Bool {
    let optionValue: Int32;
    let data: ref<PhotoModeMenuListItemData> = this.GetData() as PhotoModeMenuListItemData;
    if e.IsAction(n"click") && this.m_OptionSelector.GetRootWidget().IsVisible() {
      this.StartArrowClickedEffect(this.m_LeftArrow);
      optionValue = this.m_OptionSelectorValues[this.m_OptionSelector.GetCurrIndex()].optionData;
      this.m_photoModeController.OnAttributeUpdated(data.attributeKey, Cast(optionValue));
    };
  }

  protected cb func OnOptionRight(e: ref<inkPointerEvent>) -> Bool {
    let optionValue: Int32;
    let data: ref<PhotoModeMenuListItemData> = this.GetData() as PhotoModeMenuListItemData;
    if e.IsAction(n"click") && this.m_OptionSelector.GetRootWidget().IsVisible() {
      this.StartArrowClickedEffect(this.m_RightArrow);
      optionValue = this.m_OptionSelectorValues[this.m_OptionSelector.GetCurrIndex()].optionData;
      this.m_photoModeController.OnAttributeUpdated(data.attributeKey, Cast(optionValue));
    };
  }

  public final func GridElementAction(elementIndex: Int32, buttonData: Int32) -> Void {
    let photoModeListItem: ref<PhotoModeMenuListItem>;
    let data: ref<PhotoModeMenuListItemData> = this.GetData() as PhotoModeMenuListItemData;
    if data.attributeKey == 35u {
      this.m_photoModeController.SetCurrentMenuPage(6u);
      this.m_photoModeController.OnAttributeUpdated(data.attributeKey, Cast(elementIndex));
      photoModeListItem = this.m_photoModeController.GetMenuItem(36u);
      photoModeListItem.SetSelectedGridButton(buttonData + 1);
    } else {
      if data.attributeKey == 36u {
        this.m_photoModeController.SetCurrentMenuPage(4u);
        this.m_photoModeController.OnAttributeUpdated(data.attributeKey, Cast(buttonData));
      };
    };
  }

  public final func GridElementSelected(elementIndex: Int32) -> Void {
    let data: ref<PhotoModeMenuListItemData> = this.GetData() as PhotoModeMenuListItemData;
    if data.attributeKey == 35u {
      this.m_photoModeController.OnAttributeUpdated(data.attributeKey, Cast(elementIndex));
    };
  }

  private final func StartArrowClickedEffect(widget: inkWidgetRef) -> Void {
    inkWidgetRef.SetOpacity(widget, 0.00);
    this.m_arrowClickedTime = 0.10;
  }

  public final func ResetInputHold() -> Void {
    this.m_inputDirection = 0;
    this.m_inputHoldTime = 0.00;
    this.m_inputStepTime = 0.00;
  }

  public final func Update(timeDelta: Float) -> Void {
    if IsDefined(this.m_GridSelector) {
      this.m_GridSelector.Update(timeDelta);
    };
    if this.m_arrowClickedTime > 0.00 {
      this.m_arrowClickedTime -= timeDelta;
      if this.m_arrowClickedTime <= 0.00 {
        this.SetSelectedVisualState(this.m_isSelected);
        this.m_arrowClickedTime = 0.00;
      };
    };
    if this.m_inputDirection != 0 {
      this.m_inputHoldTime += timeDelta;
      this.m_inputStepTime -= timeDelta;
      if this.m_inputStepTime <= 0.00 {
        if this.m_inputHoldTime > 0.40 {
          this.m_inputStepTime = 0.01;
        } else {
          if this.m_inputHoldTime > 0.20 {
            this.m_inputStepTime = 0.07;
          } else {
            this.m_inputStepTime = 0.20;
          };
        };
        if this.m_inputDirection == -1 {
          this.m_ScrollBar.Prior();
        } else {
          if this.m_inputDirection == 1 {
            this.m_ScrollBar.Next();
          };
        };
      };
    };
  }
}
