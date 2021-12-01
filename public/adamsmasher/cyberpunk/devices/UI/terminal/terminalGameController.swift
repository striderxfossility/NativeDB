
public class TerminalInkGameControllerBase extends MasterDeviceInkGameControllerBase {

  @attrib(customEditor, "TweakDBGroupInheritance;WidgetDefinition")
  protected edit let m_layoutID: TweakDBID;

  protected let m_currentLayoutLibraryID: CName;

  protected let m_mainLayout: wref<inkWidget>;

  protected let m_currentlyActiveDevices: array<PersistentID>;

  private let m_mainDisplayWidget: wref<inkVideo>;

  private let m_terminalTitle: String;

  private let m_onGlitchingStateChangedListener: ref<CallbackHandle>;

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
    if IsDefined(this.m_mainDisplayWidget) {
      this.m_mainDisplayWidget.Stop();
    };
  }

  protected func SetupWidgets() -> Void {
    if !this.m_isInitialized {
      this.m_mainDisplayWidget = this.GetWidget(n"main_display") as inkVideo;
      this.m_mainDisplayWidget.SetVisible(false);
      this.InitializeMainLayout();
    };
  }

  protected func RegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.RegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      this.m_onGlitchingStateChangedListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef().GlitchData, this, n"OnGlitchingStateChanged");
    };
  }

  protected func UnRegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.UnRegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef().GlitchData, this.m_onGlitchingStateChangedListener);
    };
  }

  private final func SetupTerminalTitle() -> Void {
    if (this.GetOwner() as InteractiveMasterDevice).ShouldShowTerminalTitle() {
      this.m_terminalTitle = this.GetOwner().GetDisplayName();
    };
  }

  public final const func GetTerminalTitle() -> String {
    return this.m_terminalTitle;
  }

  protected func InitializeMainLayout() -> Void {
    let layoutRecord: ref<WidgetDefinition_Record>;
    let newLibraryID: CName;
    let screenDef: ScreenDefinitionPackage;
    let spawnData: ref<AsyncSpawnData>;
    if !TDBID.IsValid(this.m_layoutID) {
      this.m_layoutID = t"DevicesUIDefinitions.TerminalLayoutWidget";
    };
    screenDef = this.GetScreenDefinition();
    layoutRecord = TweakDBInterface.GetWidgetDefinitionRecord(this.m_layoutID);
    newLibraryID = this.GetCurrentFullLibraryID(layoutRecord, screenDef.screenDefinition.TerminalScreenType(), screenDef.style);
    if Equals(this.m_currentLayoutLibraryID, newLibraryID) {
      return;
    };
    if this.m_mainLayout != null {
      (this.GetRootWidget() as inkCompoundWidget).RemoveChild(this.m_mainLayout);
    };
    spawnData = new AsyncSpawnData();
    spawnData.Initialize(this, n"OnMainLayoutSpawned", ToVariant(null), this);
    this.m_currentLayoutLibraryID = this.RequestWidgetFromLibrary(this.GetRootWidget(), layoutRecord, screenDef.screenDefinition.TerminalScreenType(), screenDef.style, spawnData);
    this.SetupTerminalTitle();
  }

  protected final func IsMainLayoutInitialized() -> Bool {
    return this.m_mainLayout != null;
  }

  protected cb func OnMainLayoutSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let controller: ref<TerminalMainLayoutWidgetController>;
    this.m_mainLayout = widget;
    this.m_mainLayout.SetAnchor(inkEAnchor.Fill);
    controller = this.GetMainLayoutController();
    if IsDefined(controller) {
      this.RegisterReturnButtonCallback();
      controller.Initialize(this);
    };
    if this.GetOwner().IsReadyForUI() {
      this.Refresh(this.GetOwner().GetDeviceState());
    };
  }

  protected func UpdateThumbnailWidgets(widgetsData: array<SThumbnailWidgetPackage>) -> Void {
    let i: Int32;
    let widget: ref<inkWidget>;
    this.UpdateThumbnailWidgets(widgetsData);
    this.GetMainLayoutController().GetDevicesSlot().SetVisible(false);
    this.GetMainLayoutController().GetThumbnailListSlot().SetVisible(true);
    this.GetMainLayoutController().GetReturnButton().SetVisible(false);
    if ArraySize(widgetsData) == 1 {
      if !this.IsOwner(widgetsData[i].ownerID) {
        ArrayClear(this.m_currentlyActiveDevices);
        ArrayPush(this.m_currentlyActiveDevices, widgetsData[i].ownerID);
        this.RequestDeviceWidgetsUpdate(this.m_currentlyActiveDevices);
      };
    } else {
      i = 0;
      while i < ArraySize(widgetsData) {
        widget = this.GetThumbnailWidget(widgetsData[i]);
        if widget == null {
          this.CreateThumbnailWidgetAsync(this.GetMainLayoutController().GetThumbnailListSlot(), widgetsData[i]);
        } else {
          this.InitializeThumbnailWidget(widget, widgetsData[i]);
        };
        i += 1;
      };
    };
    this.GoUp();
  }

  protected func UpdateDeviceWidgets(widgetsData: array<SDeviceWidgetPackage>) -> Void {
    let element: SBreadcrumbElementData;
    let i: Int32;
    let widget: ref<inkWidget>;
    this.UpdateDeviceWidgets(widgetsData);
    ArrayClear(this.m_currentlyActiveDevices);
    this.GetMainLayoutController().GetDevicesSlot().SetVisible(true);
    this.GetMainLayoutController().GetThumbnailListSlot().SetVisible(false);
    this.GetMainLayoutController().HideBackgroundIcon();
    if ArraySize(this.m_thumbnailWidgetsData) > 1 {
      this.GetMainLayoutController().GetReturnButton().SetVisible(true);
    };
    i = 0;
    while i < ArraySize(widgetsData) {
      if !this.IsOwner(widgetsData[i].ownerID) {
        ArrayPush(this.m_currentlyActiveDevices, widgetsData[i].ownerID);
      };
      widget = this.GetDeviceWidget(widgetsData[i]);
      if widget == null {
        this.CreateDeviceWidgetAsync(this.GetMainLayoutController().GetDevicesSlot(), widgetsData[i]);
      } else {
        this.InitializeDeviceWidget(widget, widgetsData[i]);
      };
      i += 1;
    };
    element = this.GetCurrentBreadcrumbElement();
    if NotEquals(element.elementName, "device") {
      element.elementName = "device";
      this.GoDown(element);
    };
  }

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }

  protected func Refresh(state: EDeviceStatus) -> Void {
    this.SetupWidgets();
    this.InitializeMainLayout();
    if !this.IsMainLayoutInitialized() {
      return;
    };
    switch state {
      case EDeviceStatus.ON:
        this.TurnOn();
        break;
      case EDeviceStatus.OFF:
        this.TurnOff();
        break;
      case EDeviceStatus.UNPOWERED:
        this.TurnOff();
        break;
      case EDeviceStatus.DISABLED:
        this.TurnOff();
        break;
      default:
    };
    this.Refresh(state);
  }

  protected final func RegisterReturnButtonCallback() -> Void {
    this.GetMainLayoutController().GetReturnButton().RegisterToCallback(n"OnRelease", this, n"OnReturnCallback");
  }

  protected cb func OnReturnCallback(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.GoUp();
      this.ResolveBreadcrumbLevel();
    };
  }

  protected func ResolveBreadcrumbLevel() -> Void {
    let element: SBreadcrumbElementData;
    if !this.GetOwner().GetDevicePS().IsPlayerAuthorized() || this.GetOwner().HasActiveStaticHackingSkillcheck() {
      this.RequestDeviceWidgetsUpdate();
      return;
    };
    if ArraySize(this.m_currentlyActiveDevices) == 0 {
      this.ClearBreadcrumbStack();
    };
    element = this.GetCurrentBreadcrumbElement();
    if !IsStringValid(element.elementName) {
      this.RequestThumbnailWidgetsUpdate();
      this.GetMainLayoutController().ShowBackgroundIcon();
    } else {
      if Equals(element.elementName, "device") {
        this.RequestDeviceWidgetsUpdate(this.m_currentlyActiveDevices);
        this.GetMainLayoutController().HideBackgroundIcon();
      };
    };
  }

  public func UpdateBreadCrumbBar(data: SBreadCrumbUpdateData) -> Void {
    let currentElement: SBreadcrumbElementData = this.GetCurrentBreadcrumbElement();
    if NotEquals(data.elementName, currentElement.elementName) {
      if !IsStringValid(data.elementName) {
        this.ClearBreadcrumbStack();
        this.ResolveBreadcrumbLevel();
      };
    };
  }

  public func GetMainLayoutController() -> ref<TerminalMainLayoutWidgetController> {
    return this.m_mainLayout.GetController() as TerminalMainLayoutWidgetController;
  }

  protected final func TurnOn() -> Void {
    this.m_mainLayout.SetVisible(true);
    this.ResolveBreadcrumbLevel();
  }

  protected final func TurnOff() -> Void {
    this.ClearBreadcrumbStack();
    this.m_mainLayout.SetVisible(false);
  }

  private func StartGlitchingScreen(glitchData: GlitchData) -> Void {
    let glitchVideoPath: ResRef;
    if Equals(glitchData.state, EGlitchState.SUBLIMINAL_MESSAGE) {
      glitchVideoPath = (this.GetOwner() as InteractiveMasterDevice).GetBroadcastGlitchVideoPath();
    } else {
      glitchVideoPath = (this.GetOwner() as InteractiveMasterDevice).GetDefaultGlitchVideoPath();
    };
    if ResRef.IsValid(glitchVideoPath) {
      this.m_mainDisplayWidget.SetVisible(true);
      this.m_mainLayout.SetVisible(false);
      this.StopVideo();
      this.PlayVideo(glitchVideoPath, true, n"");
    };
  }

  private func StopGlitchingScreen() -> Void {
    this.StopVideo();
    this.m_mainDisplayWidget.SetVisible(false);
    this.m_mainLayout.SetVisible(true);
  }

  public final func PlayVideo(videoPath: ResRef, looped: Bool, audioEvent: CName) -> Void {
    this.m_mainDisplayWidget.SetVideoPath(videoPath);
    this.m_mainDisplayWidget.SetLoop(looped);
    if IsNameValid(audioEvent) {
      this.m_mainDisplayWidget.SetAudioEvent(audioEvent);
    };
    this.m_mainDisplayWidget.Play();
  }

  public final func StopVideo() -> Void {
    this.m_mainDisplayWidget.Stop();
  }
}
