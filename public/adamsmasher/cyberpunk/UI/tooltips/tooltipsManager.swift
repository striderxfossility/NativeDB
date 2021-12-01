
public native class gameuiTooltipsManager extends inkLogicController {

  private edit const let m_TooltipRequesters: array<inkWidgetRef>;

  private edit const let m_GenericTooltipsNames: array<CName>;

  private edit const let m_TooltipLibrariesReferences: array<TooltipWidgetReference>;

  private edit const let m_TooltipLibrariesStyledReferences: array<TooltipWidgetStyledReference>;

  @default(gameuiTooltipsManager, base/gameplay/gui/common/tooltip/tooltipslibrary_4k.inkwidget)
  private edit let m_TooltipsLibrary: ResRef;

  @default(gameuiTooltipsManager, base/gameplay/gui/common/tooltip/tooltip_menu.inkstyle)
  private edit let m_MenuTooltipStylePath: ResRef;

  @default(gameuiTooltipsManager, base/gameplay/gui/common/tooltip/tooltip_hud.inkstyle)
  private edit let m_HudTooltipStylePath: ResRef;

  private let m_IndexedTooltips: array<wref<AGenericTooltipController>>;

  private let m_NamedTooltips: array<ref<NamedTooltipController>>;

  private let introAnim: ref<inkAnimProxy>;

  private final native func SetCustomMargin(margin: inkMargin) -> Void;

  private final native func SetFollowsCursor(followsCursor: Bool) -> Void;

  private final native func AttachToWidget(widget: wref<inkWidget>, opt placement: gameuiETooltipPlacement) -> Void;

  private final native func UnAttachFromWidget() -> Void;

  private final native func GetTooltipsContainerRef() -> inkWidgetRef;

  private final native func RefreshTooltipsPosition() -> Void;

  private final native func ResetTooltipsPosition() -> Void;

  private final native func MarkToShow() -> Void;

  private final static native func FindAttachmentSlot(widget: wref<inkWidget>) -> wref<gameuiTooltipAttachmentSlot>;

  protected cb func OnInitialize() -> Bool {
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(this.m_TooltipRequesters);
    while i < limit {
      inkWidgetRef.RegisterToCallback(this.m_TooltipRequesters[i], n"OnRequestTooltip", this, n"OnRequestTooltip");
      i += 1;
    };
  }

  public final func Setup() -> Void {
    this.Setup(ETooltipsStyle.Menus);
  }

  public final func Setup(tooltipStyle: ETooltipsStyle) -> Void {
    this.Setup(tooltipStyle, true);
  }

  public final func Setup(tooltipStyle: ETooltipsStyle, followCursor: Bool) -> Void {
    let defaultStyleResRef: ResRef;
    let tooltipsContainerRef: inkWidgetRef = this.GetTooltipsContainerRef();
    let tooltipsContainer: wref<inkWidget> = inkWidgetRef.Get(tooltipsContainerRef);
    if !IsDefined(tooltipsContainer) {
      LogUIError("[TooltipManager] Tried to setup without valid container for tooltips!");
      return;
    };
    defaultStyleResRef = this.GetDefaultStyleResRef(tooltipStyle);
    tooltipsContainer.SetAffectsLayoutWhenHidden(true);
    this.SetupIndexedWidgets(tooltipStyle, tooltipsContainer, defaultStyleResRef);
    this.SetupNamedWidgets(tooltipStyle, tooltipsContainer, defaultStyleResRef);
    this.SetupStyledNamedWidgets(tooltipStyle, tooltipsContainer);
    this.SetFollowsCursor(followCursor);
    this.ResetTooltipsPosition();
  }

  private final func GetDefaultStyleResRef(tooltipStyle: ETooltipsStyle) -> ResRef {
    if Equals(tooltipStyle, ETooltipsStyle.Menus) {
      return ResRef.IsValid(this.m_MenuTooltipStylePath) ? this.m_MenuTooltipStylePath : r"base\\gameplay\\gui\\common\\tooltip\\tooltip_menu.inkstyle";
    };
    return ResRef.IsValid(this.m_HudTooltipStylePath) ? this.m_HudTooltipStylePath : r"base\\gameplay\\gui\\common\\tooltip\\tooltip_hud.inkstyle";
  }

  private final func SetupIndexedWidgets(tooltipStyle: ETooltipsStyle, tooltipsContainer: wref<inkWidget>, styleResRef: ResRef) -> Void {
    let i: Int32;
    let limit: Int32;
    let tooltipSpawnedCallbackData: ref<TooltipSpawnedCallbackData>;
    if !ResRef.IsValid(this.m_TooltipsLibrary) {
      this.m_TooltipsLibrary = r"base\\gameplay\\gui\\common\\tooltip\\tooltipslibrary_4k.inkwidget";
    };
    i = 0;
    limit = ArraySize(this.m_GenericTooltipsNames);
    while i < limit {
      tooltipSpawnedCallbackData = new TooltipSpawnedCallbackData();
      tooltipSpawnedCallbackData.index = i;
      tooltipSpawnedCallbackData.tooltipStyle = tooltipStyle;
      tooltipSpawnedCallbackData.styleResRef = styleResRef;
      this.AsyncSpawnFromExternal(tooltipsContainer, this.m_TooltipsLibrary, this.m_GenericTooltipsNames[i], this, n"OnTooltipWidgetSpawned", tooltipSpawnedCallbackData);
      i += 1;
    };
  }

  private final func SetupNamedWidgets(tooltipStyle: ETooltipsStyle, tooltipsContainer: wref<inkWidget>, styleResRef: ResRef) -> Void {
    let libraryReference: inkWidgetLibraryReference;
    let tooltipSpawnedCallbackData: ref<TooltipSpawnedCallbackData>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_TooltipLibrariesReferences) {
      libraryReference = this.m_TooltipLibrariesReferences[i].m_widgetLibraryReference;
      if inkWidgetLibraryResource.IsValid(libraryReference.widgetLibrary) {
        tooltipSpawnedCallbackData = new TooltipSpawnedCallbackData();
        tooltipSpawnedCallbackData.identifier = this.m_TooltipLibrariesReferences[i].m_identifier;
        tooltipSpawnedCallbackData.tooltipStyle = tooltipStyle;
        tooltipSpawnedCallbackData.styleResRef = styleResRef;
        this.AsyncSpawnFromExternal(tooltipsContainer, inkWidgetLibraryResource.GetPath(libraryReference.widgetLibrary), libraryReference.widgetItem, this, n"OnTooltipWidgetSpawned", tooltipSpawnedCallbackData);
      };
      i += 1;
    };
  }

  private final func SetupStyledNamedWidgets(tooltipStyle: ETooltipsStyle, tooltipsContainer: wref<inkWidget>) -> Void {
    let libraryReference: inkWidgetLibraryReference;
    let styleResRef: ResRef;
    let tooltipSpawnedCallbackData: ref<TooltipSpawnedCallbackData>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_TooltipLibrariesStyledReferences) {
      styleResRef = Equals(tooltipStyle, ETooltipsStyle.HUD) ? this.m_TooltipLibrariesStyledReferences[i].m_hudTooltipStylePath : this.m_TooltipLibrariesStyledReferences[i].m_menuTooltipStylePath;
      if !ResRef.IsValid(styleResRef) {
        styleResRef = Equals(tooltipStyle, ETooltipsStyle.HUD) ? r"base\\gameplay\\gui\\common\\tooltip\\tooltip_menu.inkstyle" : r"base\\gameplay\\gui\\common\\tooltip\\tooltip_hud.inkstyle";
      };
      libraryReference = this.m_TooltipLibrariesStyledReferences[i].m_widgetLibraryReference;
      if inkWidgetLibraryResource.IsValid(libraryReference.widgetLibrary) {
        tooltipSpawnedCallbackData = new TooltipSpawnedCallbackData();
        tooltipSpawnedCallbackData.identifier = this.m_TooltipLibrariesReferences[i].m_identifier;
        tooltipSpawnedCallbackData.tooltipStyle = tooltipStyle;
        tooltipSpawnedCallbackData.styleResRef = styleResRef;
        this.AsyncSpawnFromExternal(tooltipsContainer, inkWidgetLibraryResource.GetPath(libraryReference.widgetLibrary), libraryReference.widgetItem, this, n"OnTooltipWidgetSpawned", tooltipSpawnedCallbackData);
      };
      i += 1;
    };
  }

  protected cb func OnTooltipWidgetSpawned(tooltipWidget: ref<inkWidget>, callbackData: ref<TooltipSpawnedCallbackData>) -> Bool {
    let namedControllerRef: ref<NamedTooltipController>;
    let tooltipController: wref<AGenericTooltipController>;
    if !IsDefined(tooltipWidget) {
      LogUIError("[TooltipManager] Failed to spawn tooltip widget! Missing import?");
      return false;
    };
    this.SetupWidgetAttachment(tooltipWidget, callbackData.tooltipStyle);
    tooltipController = tooltipWidget.GetController() as AGenericTooltipController;
    if IsDefined(tooltipController) {
      tooltipController.SetStyle(callbackData.styleResRef);
      tooltipController.Hide();
      if callbackData.index > -1 {
        if ArraySize(this.m_IndexedTooltips) < callbackData.index {
          ArrayResize(this.m_IndexedTooltips, callbackData.index);
        };
        ArrayInsert(this.m_IndexedTooltips, callbackData.index, tooltipController);
      } else {
        namedControllerRef = new NamedTooltipController();
        namedControllerRef.identifier = callbackData.identifier;
        namedControllerRef.controller = tooltipController;
        ArrayPush(this.m_NamedTooltips, namedControllerRef);
      };
    };
  }

  private final func SetupWidgetAttachment(widget: wref<inkWidget>, tooltipStyle: ETooltipsStyle) -> Void {
    if IsDefined(widget) {
      if Equals(tooltipStyle, ETooltipsStyle.Menus) {
        widget.SetVAlign(inkEVerticalAlign.Top);
        widget.SetHAlign(inkEHorizontalAlign.Left);
        widget.SetAnchorPoint(0.00, 0.00);
      } else {
        widget.SetVAlign(inkEVerticalAlign.Bottom);
        widget.SetHAlign(inkEHorizontalAlign.Right);
        widget.SetAnchorPoint(0.00, 1.00);
      };
    };
  }

  protected cb func OnUninitialize() -> Bool {
    let i: Int32;
    let limit: Int32;
    this.HideTooltips();
    i = 0;
    limit = ArraySize(this.m_TooltipRequesters);
    while i < limit {
      inkWidgetRef.UnregisterFromCallback(this.m_TooltipRequesters[i], n"OnRequestTooltip", this, n"OnRequestTooltip");
      i += 1;
    };
  }

  private final func GetNamedWidget(identifier: CName) -> wref<AGenericTooltipController> {
    let i: Int32 = 0;
    while i < ArraySize(this.m_NamedTooltips) {
      if Equals(this.m_NamedTooltips[i].identifier, identifier) {
        return this.m_NamedTooltips[i].controller;
      };
      i += 1;
    };
    return null;
  }

  public final func ShowTooltips(tooltipsData: array<ref<ATooltipData>>) -> Void {
    this.ShowTooltips(tooltipsData, new inkMargin(30.00, 20.00, 0.00, 0.00));
  }

  public final func ShowTooltipsAtWidget(tooltipData: array<ref<ATooltipData>>, widget: wref<inkWidget>) -> Void {
    this.SetFollowsCursor(false);
    this.ShowTooltips(tooltipData, new inkMargin(0.00, 0.00, 0.00, 0.00), true);
    this.AttachToWidget(widget, gameuiETooltipPlacement.RightTop);
  }

  public final func ShowTooltipsAtWidget(tooltipData: array<ref<ATooltipData>>, widget: wref<inkWidget>, placement: gameuiETooltipPlacement) -> Void {
    this.SetFollowsCursor(false);
    this.ShowTooltips(tooltipData, new inkMargin(0.00, 0.00, 0.00, 0.00), true);
    this.AttachToWidget(widget, placement);
  }

  public final func ShowTooltips(tooltipData: array<ref<ATooltipData>>, margin: inkMargin, opt playAnim: Bool) -> Void {
    let i: Int32;
    let identifiedData: ref<IdentifiedWrappedTooltipData>;
    let limit: Int32;
    let tooltipController: wref<AGenericTooltipController>;
    this.HideTooltips();
    this.SetCustomMargin(margin);
    limit = ArraySize(tooltipData);
    i = 0;
    while i < limit {
      identifiedData = tooltipData[i] as IdentifiedWrappedTooltipData;
      if IsDefined(identifiedData) && IsNameValid(identifiedData.m_identifier) {
        tooltipController = this.GetNamedWidget(identifiedData.m_identifier);
      } else {
        if i >= ArraySize(this.m_IndexedTooltips) {
          LogUIError("[TooltipManager] Tried to use not spawned tooltip!");
          return;
        };
        tooltipController = this.m_IndexedTooltips[i];
      };
      if IsDefined(tooltipController) {
        tooltipController.SetData(IsDefined(identifiedData) ? identifiedData.m_data : tooltipData[i]);
        tooltipController.Show();
      };
      i += 1;
    };
    if limit > 0 {
      this.MarkToShow();
    };
    if playAnim {
      if IsDefined(this.introAnim) && this.introAnim.IsPlaying() {
        this.introAnim.Stop();
      };
      this.introAnim = this.PlayLibraryAnimation(n"intro");
    };
  }

  public final func ShowTooltip(tooltipData: ref<ATooltipData>) -> Void {
    this.ShowTooltip(0, tooltipData);
  }

  public final func ShowTooltip(identifier: CName, tooltipData: ref<ATooltipData>) -> Void {
    let controller: wref<AGenericTooltipController> = this.GetNamedWidget(identifier);
    this.ShowTooltip(controller, tooltipData);
  }

  public final func ShowTooltip(index: Int32, tooltipData: ref<ATooltipData>) -> Void {
    this.ShowTooltip(this.m_IndexedTooltips[index], tooltipData);
  }

  public final func ShowTooltip(tooltipController: wref<AGenericTooltipController>, tooltipData: ref<ATooltipData>) -> Void {
    this.ShowTooltip(tooltipController, tooltipData, new inkMargin(30.00, 20.00, 0.00, 0.00));
  }

  public final func ShowTooltipAtPosition(index: Int32, position: Vector2, tooltipData: ref<ATooltipData>) -> Void {
    this.ShowTooltipAtPosition(this.m_IndexedTooltips[index], position, tooltipData);
  }

  public final func ShowTooltipAtPosition(identifier: CName, position: Vector2, tooltipData: ref<ATooltipData>) -> Void {
    let controller: wref<AGenericTooltipController> = this.GetNamedWidget(identifier);
    this.ShowTooltipAtPosition(controller, position, tooltipData);
  }

  public final func ShowTooltipAtPosition(tooltipController: wref<AGenericTooltipController>, position: Vector2, tooltipData: ref<ATooltipData>) -> Void {
    let newPosition: Vector2;
    let tooltipWidget: wref<inkWidget>;
    if IsDefined(tooltipController) {
      this.SetFollowsCursor(false);
      this.ResetTooltipsPosition();
      tooltipWidget = tooltipController.GetRootWidget();
      newPosition = WidgetUtils.GlobalToLocal(tooltipWidget, position);
      this.ShowTooltip(tooltipController, tooltipData, new inkMargin(0.00, 0.00, 0.00, 0.00));
      tooltipWidget.SetTranslation(newPosition);
    };
  }

  public final func ShowTooltipAtWidget(index: Int32, widget: wref<inkWidget>, tooltipData: ref<ATooltipData>, opt placement: gameuiETooltipPlacement, opt playAnim: Bool, opt margin: inkMargin) -> Void {
    this.ShowTooltipAtWidget(this.m_IndexedTooltips[index], widget, tooltipData, placement, playAnim, margin);
  }

  public final func ShowTooltipAtWidget(identifier: CName, widget: wref<inkWidget>, tooltipData: ref<ATooltipData>, opt placement: gameuiETooltipPlacement, opt playAnim: Bool, opt margin: inkMargin) -> Void {
    let controller: wref<AGenericTooltipController> = this.GetNamedWidget(identifier);
    this.ShowTooltipAtWidget(controller, widget, tooltipData, placement, playAnim, margin);
  }

  public final func ShowTooltipAtWidget(tooltipController: wref<AGenericTooltipController>, widget: wref<inkWidget>, tooltipData: ref<ATooltipData>, opt placement: gameuiETooltipPlacement, opt playAnim: Bool, opt margin: inkMargin) -> Void {
    let tooltipWidget: wref<inkWidget>;
    if IsDefined(tooltipController) {
      this.SetFollowsCursor(false);
      this.ResetTooltipsPosition();
      tooltipWidget = tooltipController.GetRootWidget();
      tooltipWidget.SetMargin(margin);
      this.ShowTooltip(tooltipController, tooltipData, margin);
      this.AttachToWidget(widget, placement);
      if playAnim {
        if IsDefined(this.introAnim) && this.introAnim.IsPlaying() {
          this.introAnim.Stop();
        };
        this.introAnim = this.PlayLibraryAnimation(n"intro");
      };
    };
  }

  public final func ShowTooltipInSlot(index: Int32, tooltipData: ref<ATooltipData>, widget: wref<inkWidget>) -> Void {
    this.ShowTooltipInSlot(this.m_IndexedTooltips[index], tooltipData, widget);
  }

  public final func ShowTooltipInSlot(identifier: CName, tooltipData: ref<ATooltipData>, widget: wref<inkWidget>) -> Void {
    let controller: wref<AGenericTooltipController> = this.GetNamedWidget(identifier);
    this.ShowTooltipInSlot(controller, tooltipData, widget);
  }

  public final func ShowTooltipInSlot(tooltipController: wref<AGenericTooltipController>, tooltipData: ref<ATooltipData>, widget: wref<inkWidget>) -> Void {
    let tooltipWidget: wref<inkWidget>;
    let slotController: wref<gameuiTooltipAttachmentSlot> = gameuiTooltipsManager.FindAttachmentSlot(widget);
    if slotController == null {
      return;
    };
    if IsDefined(tooltipController) {
      this.SetFollowsCursor(false);
      this.ResetTooltipsPosition();
      this.ShowTooltip(tooltipController, tooltipData, new inkMargin(0.00, 0.00, 0.00, 0.00));
      tooltipWidget = tooltipController.GetRootWidget();
      tooltipWidget.Reparent(slotController.GetRootWidget() as inkCompoundWidget);
    };
  }

  public final func AttachToCursor() -> Void {
    this.SetFollowsCursor(true);
    this.UnAttachFromWidget();
  }

  public final func ShowTooltip(index: Int32, tooltipData: ref<ATooltipData>, margin: inkMargin) -> Void {
    if index < 0 && index >= ArraySize(this.m_IndexedTooltips) {
      LogUIError("[TooltipManager] Tried to use not spawned tooltip!");
      return;
    };
    this.ShowTooltip(this.m_IndexedTooltips[index], tooltipData, margin);
  }

  public final func ShowTooltip(identifier: CName, tooltipData: ref<ATooltipData>, margin: inkMargin) -> Void {
    let controller: wref<AGenericTooltipController> = this.GetNamedWidget(identifier);
    this.ShowTooltip(controller, tooltipData, margin);
  }

  public final func ShowTooltip(tooltipController: wref<AGenericTooltipController>, tooltipData: ref<ATooltipData>, margin: inkMargin) -> Void {
    this.HideTooltips();
    if tooltipController == null {
      LogUIError("[TooltipManager] Tried to use not spawned tooltip!");
      return;
    };
    this.SetCustomMargin(margin);
    if IsDefined(tooltipController) {
      tooltipController.SetData(tooltipData);
      tooltipController.Show();
    };
    this.MarkToShow();
  }

  public final func HideTooltips() -> Void {
    let i: Int32;
    let limit: Int32;
    let previousListEnd: Int32;
    let tooltipController: wref<AGenericTooltipController>;
    let tooltipWidget: wref<inkWidget>;
    this.ResetTooltipsPosition();
    i = 0;
    limit = ArraySize(this.m_IndexedTooltips);
    while i < limit {
      tooltipController = this.m_IndexedTooltips[i];
      if IsDefined(tooltipController) {
        tooltipController.Hide();
        tooltipWidget = tooltipController.GetRootWidget();
        tooltipWidget.Reparent(inkWidgetRef.Get(this.GetTooltipsContainerRef()) as inkCompoundWidget, i);
        this.UnAttachFromWidget();
      };
      i += 1;
    };
    previousListEnd = i;
    i = 0;
    limit = ArraySize(this.m_NamedTooltips);
    while i < limit {
      tooltipController = this.m_NamedTooltips[i].controller;
      if IsDefined(tooltipController) {
        tooltipController.Hide();
        tooltipWidget = tooltipController.GetRootWidget();
        tooltipWidget.Reparent(inkWidgetRef.Get(this.GetTooltipsContainerRef()) as inkCompoundWidget, previousListEnd + i);
        this.UnAttachFromWidget();
      };
      i += 1;
    };
  }

  public final func RefreshTooltip(index: Int32) -> Void {
    let tooltipController: wref<AGenericTooltipController> = this.m_IndexedTooltips[index];
    if IsDefined(tooltipController) {
      tooltipController.Refresh();
    };
  }

  public final func RefreshTooltip(identifier: CName) -> Void {
    let tooltipController: wref<AGenericTooltipController> = this.GetNamedWidget(identifier);
    if IsDefined(tooltipController) {
      tooltipController.Refresh();
    };
  }

  private final func OnRequestTooltip(widget: wref<inkWidget>) -> Void;
}
