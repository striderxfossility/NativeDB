
public class ComputerInkGameController extends DeviceInkGameControllerBase {

  @attrib(customEditor, "TweakDBGroupInheritance;WidgetDefinition")
  protected edit let m_layoutID: TweakDBID;

  protected let m_currentLayoutLibraryID: CName;

  protected let m_mainLayout: wref<inkWidget>;

  protected let m_devicesMenuInitialized: Bool;

  protected let m_devicesMenuSpawned: Bool;

  protected let m_devicesMenuSpawnRequested: Bool;

  protected let m_menuInitialized: Bool;

  private let m_mainDisplayWidget: wref<inkVideo>;

  @default(ComputerInkGameController, EDocumentType.Invalid)
  private let m_forceOpenDocumentType: EDocumentType;

  private let m_forceOpenDocumentAdress: SDocumentAdress;

  private let m_onMailThumbnailWidgetsUpdateListener: ref<CallbackHandle>;

  private let m_onFileThumbnailWidgetsUpdateListener: ref<CallbackHandle>;

  private let m_onMailWidgetsUpdateListener: ref<CallbackHandle>;

  private let m_onFileWidgetsUpdateListener: ref<CallbackHandle>;

  private let m_onMenuButtonWidgetsUpdateListener: ref<CallbackHandle>;

  private let m_onMainMenuButtonWidgetsUpdateListener: ref<CallbackHandle>;

  private let m_onBannerWidgetsUpdateListener: ref<CallbackHandle>;

  private let m_onGlitchingStateChangedListener: ref<CallbackHandle>;

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
    if IsDefined(this.m_mainDisplayWidget) {
      this.m_mainDisplayWidget.Stop();
    };
  }

  protected func SetupWidgets() -> Void {
    if !this.m_isInitialized {
      this.ResolveInitialMenuType();
      this.m_mainDisplayWidget = this.GetWidget(n"main_display") as inkVideo;
      this.m_mainDisplayWidget.SetVisible(false);
      this.InitializeMainLayout();
    };
  }

  protected func InitializeMainLayout() -> Void {
    let layoutRecord: ref<WidgetDefinition_Record>;
    let newLibraryID: CName;
    let screenDef: ScreenDefinitionPackage;
    let spawnData: ref<AsyncSpawnData>;
    if !TDBID.IsValid(this.m_layoutID) {
      this.m_layoutID = t"DevicesUIDefinitions.ComputerLayoutWidget";
    };
    screenDef = this.GetScreenDefinition();
    layoutRecord = TweakDBInterface.GetWidgetDefinitionRecord(this.m_layoutID);
    if IsDefined(screenDef.screenDefinition) {
      newLibraryID = this.GetCurrentFullLibraryID(layoutRecord, screenDef.screenDefinition.ComputerScreenType(), screenDef.style);
    };
    if Equals(this.m_currentLayoutLibraryID, newLibraryID) {
      return;
    };
    if this.m_mainLayout != null {
      (this.GetRootWidget() as inkCompoundWidget).RemoveChild(this.m_mainLayout);
    };
    spawnData = new AsyncSpawnData();
    spawnData.Initialize(this, n"OnMainLayoutSpawned", ToVariant(null), this);
    if IsDefined(screenDef.screenDefinition) {
      this.m_currentLayoutLibraryID = this.RequestWidgetFromLibrary(this.GetRootWidget(), layoutRecord, screenDef.screenDefinition.ComputerScreenType(), screenDef.style, spawnData);
    };
  }

  protected final func IsMainLayoutInitialized() -> Bool {
    return this.m_mainLayout != null;
  }

  protected cb func OnMainLayoutSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let controller: ref<ComputerMainLayoutWidgetController>;
    this.m_mainLayout = widget;
    if IsDefined(this.m_mainLayout) {
      this.m_mainLayout.SetAnchor(inkEAnchor.Fill);
      controller = this.GetMainLayoutController();
      if IsDefined(controller) {
        controller.Initialize(this);
      };
      this.SetDevicesMenu(this, this.GetMainLayoutController().GetDevicesMenuContainer());
      this.RegisterCloseWindowButtonCallback();
    };
  }

  public func SetDevicesMenu(gameController: ref<ComputerInkGameController>, parentWidget: wref<inkWidget>) -> Void {
    let path: ResRef;
    let spawnData: ref<AsyncSpawnData>;
    if this.IsDevicesManuSpawnRequested() {
      return;
    };
    path = gameController.GetTerminalInkLibraryPath(gameController.GetScreenDefinition());
    spawnData = new AsyncSpawnData();
    spawnData.Initialize(this, n"OnDevicesMenuSpawned", ToVariant(null), this);
    this.AsyncSpawnFromExternal(parentWidget, path, n"Root", this, n"OnDevicesMenuSpawned", spawnData);
    this.m_devicesMenuSpawnRequested = true;
  }

  protected cb func OnDevicesMenuSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let devicesMenu: ref<inkWidget> = widget;
    if IsDefined(devicesMenu) {
      devicesMenu.SetAnchor(inkEAnchor.Fill);
      devicesMenu.SetVisible(false);
      this.GetMainLayoutController().SetDevicesMenu(devicesMenu);
      this.m_devicesMenuSpawned = true;
      if this.GetOwner().IsReadyForUI() {
        this.Refresh(this.GetOwner().GetDeviceState());
      };
    };
  }

  protected final func IsDevicesManuSpawned() -> Bool {
    return this.m_devicesMenuSpawned;
  }

  protected final func IsDevicesManuSpawnRequested() -> Bool {
    return this.m_devicesMenuSpawnRequested;
  }

  public func GetComputerInkLibraryPath(screenDefinition: ScreenDefinitionPackage) -> String {
    let path: String;
    screenDefinition.screenDefinition.ComputerScreenType().LibraryPath();
    return path;
  }

  public func GetTerminalInkLibraryPath(screenDefinition: ScreenDefinitionPackage) -> ResRef {
    return screenDefinition.screenDefinition.TerminalScreenType().LibraryPath();
  }

  public func Refresh(state: EDeviceStatus) -> Void {
    this.SetupWidgets();
    this.InitializeMainLayout();
    if !this.IsMainLayoutInitialized() || !this.IsDevicesManuSpawned() {
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

  protected func RegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.RegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      this.m_onMailThumbnailWidgetsUpdateListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef() as ComputerDeviceBlackboardDef.MailThumbnailWidgetsData, this, n"OnMailThumbnailWidgetsUpdate");
      this.m_onFileThumbnailWidgetsUpdateListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef() as ComputerDeviceBlackboardDef.FileThumbnailWidgetsData, this, n"OnFileThumbnailWidgetsUpdate");
      this.m_onMailWidgetsUpdateListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef() as ComputerDeviceBlackboardDef.MailWidgetsData, this, n"OnMailWidgetsUpdate");
      this.m_onFileWidgetsUpdateListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef() as ComputerDeviceBlackboardDef.FileWidgetsData, this, n"OnFileWidgetsUpdate");
      this.m_onMenuButtonWidgetsUpdateListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef() as ComputerDeviceBlackboardDef.MenuButtonWidgetsData, this, n"OnMenuButtonWidgetsUpdate");
      this.m_onMainMenuButtonWidgetsUpdateListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef() as ComputerDeviceBlackboardDef.MainMenuButtonWidgetsData, this, n"OnMainMenuButtonWidgetsUpdate");
      this.m_onBannerWidgetsUpdateListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef() as ComputerDeviceBlackboardDef.BannerWidgetsData, this, n"OnBannerWidgetsUpdate");
      this.m_onGlitchingStateChangedListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef().GlitchData, this, n"OnGlitchingStateChanged");
    };
  }

  protected func UnRegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.UnRegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef() as ComputerDeviceBlackboardDef.MailThumbnailWidgetsData, this.m_onMailThumbnailWidgetsUpdateListener);
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef() as ComputerDeviceBlackboardDef.FileThumbnailWidgetsData, this.m_onFileThumbnailWidgetsUpdateListener);
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef() as ComputerDeviceBlackboardDef.MailWidgetsData, this.m_onMailWidgetsUpdateListener);
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef() as ComputerDeviceBlackboardDef.FileWidgetsData, this.m_onFileWidgetsUpdateListener);
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef() as ComputerDeviceBlackboardDef.MenuButtonWidgetsData, this.m_onMenuButtonWidgetsUpdateListener);
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef() as ComputerDeviceBlackboardDef.MainMenuButtonWidgetsData, this.m_onMainMenuButtonWidgetsUpdateListener);
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef() as ComputerDeviceBlackboardDef.BannerWidgetsData, this.m_onBannerWidgetsUpdateListener);
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef().GlitchData, this.m_onGlitchingStateChangedListener);
    };
  }

  private final func ResolveInitialMenuType() -> Void {
    let element: SBreadcrumbElementData;
    let menuType: EComputerMenuType = (this.GetOwner() as Computer).GetInitialMenuType();
    switch menuType {
      case EComputerMenuType.MAILS:
        element.elementName = "mails";
        break;
      case EComputerMenuType.FILES:
        element.elementName = "files";
        break;
      case EComputerMenuType.SYSTEM:
        element.elementName = "devices";
        break;
      case EComputerMenuType.NEWSFEED:
        element.elementName = "newsFeed";
        break;
      case EComputerMenuType.MAIN:
        element.elementName = "mainMenu";
        break;
      case EComputerMenuType.INTERNET:
        element.elementName = "internet";
        break;
      default:
    };
    this.GoDown(element);
  }

  protected cb func OnBannerWidgetsUpdate(value: Variant) -> Bool {
    let widgetsData: array<SBannerWidgetPackage> = FromVariant(value);
    this.UpdateBannersWidgets(widgetsData);
  }

  protected cb func OnMailThumbnailWidgetsUpdate(value: Variant) -> Bool {
    let widgetsData: array<SDocumentThumbnailWidgetPackage> = FromVariant(value);
    this.UpdateMailsThumbnailsWidgets(widgetsData);
  }

  protected cb func OnFileThumbnailWidgetsUpdate(value: Variant) -> Bool {
    let widgetsData: array<SDocumentThumbnailWidgetPackage> = FromVariant(value);
    this.UpdateFilesThumbnailsWidgets(widgetsData);
  }

  protected cb func OnMailWidgetsUpdate(value: Variant) -> Bool {
    let widgetsData: array<SDocumentWidgetPackage> = FromVariant(value);
    this.UpdateMailsWidgets(widgetsData);
  }

  protected cb func OnFileWidgetsUpdate(value: Variant) -> Bool {
    let widgetsData: array<SDocumentWidgetPackage> = FromVariant(value);
    this.UpdateFilesWidgets(widgetsData);
  }

  protected cb func OnMenuButtonWidgetsUpdate(value: Variant) -> Bool {
    let widgetsData: array<SComputerMenuButtonWidgetPackage> = FromVariant(value);
    this.UpdateMenuButtonsWidgets(widgetsData);
  }

  protected cb func OnMainMenuButtonWidgetsUpdate(value: Variant) -> Bool {
    let widgetsData: array<SComputerMenuButtonWidgetPackage> = FromVariant(value);
    this.UpdateMainMenuButtonsWidgets(widgetsData);
  }

  public func UpdateActionWidgets(widgetsData: array<SActionWidgetPackage>) -> Void {
    let widget: ref<inkWidget>;
    let i: Int32 = 0;
    while i < ArraySize(widgetsData) {
      if Equals(widgetsData[i].wasInitalized, true) {
        widget = this.GetActionWidget(widgetsData[i]);
        if widget == null {
          widget = this.AddActionWidget(this.GetMainLayoutController().GetOffButton(), widgetsData[i]);
        };
        this.InitializeActionWidget(widget, widgetsData[i]);
      };
      i += 1;
    };
  }

  public func UpdateMenuButtonsWidgets(widgetsData: array<SComputerMenuButtonWidgetPackage>) -> Void {
    this.InitializeMenuButtons(widgetsData);
  }

  public func UpdateMainMenuButtonsWidgets(widgetsData: array<SComputerMenuButtonWidgetPackage>) -> Void {
    this.InitializeMainMenuButtons(widgetsData);
  }

  public func UpdateBannersWidgets(widgetsData: array<SBannerWidgetPackage>) -> Void {
    this.InitializeBanners(widgetsData);
  }

  public func UpdateMailsWidgets(widgetsData: array<SDocumentWidgetPackage>) -> Void {
    this.InitializeMails(widgetsData);
  }

  public func UpdateFilesWidgets(widgetsData: array<SDocumentWidgetPackage>) -> Void {
    this.InitializeFiles(widgetsData);
  }

  public func UpdateMailsThumbnailsWidgets(widgetsData: array<SDocumentThumbnailWidgetPackage>) -> Void {
    this.InitializeMailsThumbnails(widgetsData);
  }

  public func UpdateFilesThumbnailsWidgets(widgetsData: array<SDocumentThumbnailWidgetPackage>) -> Void {
    this.InitializeFilesThumbnails(widgetsData);
  }

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }

  protected final func ShowNewsfeed() -> Void {
    this.GetMainLayoutController().ShowNewsfeed();
    this.RequestBannerWidgetsUpdate();
  }

  protected final func ShowMails() -> Void {
    this.GetMainLayoutController().ShowMails();
    this.RequestMailThumbnailWidgetsUpdate();
  }

  protected final func ShowFiles() -> Void {
    this.GetMainLayoutController().ShowFiles();
    this.RequestFileThumbnailWidgetsUpdate();
  }

  protected final func ShowDevices() -> Void {
    if !this.IsDevicesManuSpawned() {
      return;
    };
    this.GetMainLayoutController().ShowDevices();
    if !this.m_devicesMenuInitialized {
      this.m_devicesMenuInitialized = true;
      this.RequestUIRefresh();
    };
  }

  protected final func ShowMainMenu() -> Void {
    this.GetMainLayoutController().ShowMainMenu();
    this.GetMainLayoutController().HideWindow();
    this.RequestMenuButtonWidgetsUpdate();
  }

  protected final func ShowInternet() -> Void {
    let internetData: SInternetData = (this.GetOwner().GetDevicePS() as ComputerControllerPS).GetInternetData();
    this.GetMainLayoutController().ShowInternet(internetData.startingPage);
    this.RequestMainMenuButtonWidgetsUpdate();
  }

  protected func TurnOn() -> Void {
    this.m_rootWidget.SetVisible(true);
    if (this.GetOwner() as Computer).IsInSleepMode() {
      this.GetMainLayoutController().ShowScreenSaver();
      this.GetMainLayoutController().HideWallpaper();
    } else {
      this.GetMainLayoutController().HideScreenSaver();
      this.GetMainLayoutController().ShowWallpaper();
      this.RequestActionWidgetsUpdate();
      this.ResolveBreadcrumbLevel();
    };
  }

  protected func TurnOff() -> Void {
    this.m_rootWidget.SetVisible(false);
    this.ClearBreadcrumbStack();
    this.m_devicesMenuInitialized = false;
    this.ResolveInitialMenuType();
  }

  protected func ResolveBreadcrumbLevel() -> Void {
    let activeElement: SBreadcrumbElementData;
    let element: SBreadcrumbElementData;
    if !this.GetOwner().GetDevicePS().IsPlayerAuthorized() || this.GetOwner().HasActiveStaticHackingSkillcheck() {
      this.ShowDevices();
      return;
    };
    activeElement = this.GetActiveBreadcrumbElement();
    element = this.GetCurrentBreadcrumbElement();
    if !IsStringValid(element.elementName) {
      element.elementName = "mainMenu";
      this.GoDown(element);
    };
    if Equals(activeElement.elementName, element.elementName) {
      this.HideMenuByName(element.elementName);
    };
    this.ShowMenuByName(element.elementName);
    if NotEquals(element.elementName, "mainMenu") {
      this.RequestMenuButtonWidgetsUpdate();
    };
    this.SetActiveBreadcrumbElement(element);
  }

  private final func ShowMenuByName(elementName: String) -> Void {
    switch elementName {
      case "mails":
        this.ShowMails();
        break;
      case "files":
        this.ShowFiles();
        break;
      case "devices":
        this.ShowDevices();
        break;
      case "newsFeed":
        this.ShowNewsfeed();
        break;
      case "mainMenu":
        this.ShowMainMenu();
        break;
      case "internet":
        this.ShowInternet();
        break;
      default:
    };
    if IsStringValid(elementName) && NotEquals(elementName, "mainMenu") {
      this.GetMainLayoutController().MarkManuButtonAsSelected(elementName);
    };
  }

  private final func HideMenuByName(elementName: String) -> Void {
    switch elementName {
      case "mails":
        this.GetMainLayoutController().HideMails();
        break;
      case "files":
        this.GetMainLayoutController().HideFiles();
        break;
      case "devices":
        this.GetMainLayoutController().HideDevices();
        break;
      case "newsFeed":
        this.GetMainLayoutController().HideNewsFeed();
        break;
      case "mainMenu":
        this.GetMainLayoutController().HideMainMenu();
        break;
      case "internet":
        this.GetMainLayoutController().HideInternet();
        break;
      default:
    };
  }

  private final func GoToMenu(menuID: String) -> Void {
    let breadcrumbUpdateData: SBreadCrumbUpdateData;
    let element: SBreadcrumbElementData;
    let elementName: String;
    if !IsStringValid(menuID) {
      return;
    };
    element = this.GetCurrentBreadcrumbElement();
    elementName = element.elementName;
    if Equals(elementName, "mainMenu") {
      this.RequestMenuButtonWidgetsUpdate();
    };
    if NotEquals(elementName, menuID) {
      this.GoUp();
      element.elementName = menuID;
      this.GoDown(element);
    };
    if Equals(elementName, "devices") {
      breadcrumbUpdateData.context = n"system_refresh";
      this.RequestBeadcrumbBarUpdate(breadcrumbUpdateData);
    };
    this.ResolveBreadcrumbLevel();
  }

  private final func GetMenuName(menuType: EComputerMenuType) -> String {
    let menuName: String;
    switch menuType {
      case EComputerMenuType.MAIN:
        menuName = "mainMenu";
        break;
      case EComputerMenuType.MAILS:
        menuName = "mails";
        break;
      case EComputerMenuType.FILES:
        menuName = "files";
        break;
      case EComputerMenuType.INTERNET:
        menuName = "internet";
        break;
      case EComputerMenuType.SYSTEM:
        menuName = "devices";
        break;
      case EComputerMenuType.NEWSFEED:
        menuName = "newsFeed";
        break;
      default:
    };
    return menuName;
  }

  private final func OpenDocument(documentType: EDocumentType, adress: SDocumentAdress) -> Void {
    let controller: ref<ComputerDocumentThumbnailWidgetController>;
    if Equals(documentType, EDocumentType.MAIL) {
      controller = this.GetMainLayoutController().GetMailThumbnailController(adress);
    } else {
      if Equals(documentType, EDocumentType.FILE) {
        controller = this.GetMainLayoutController().GetFileThumbnailController(adress);
      };
    };
    this.OpenDocument(controller);
  }

  public final func OpenDocument(controller: ref<ComputerDocumentThumbnailWidgetController>) -> Void {
    let docStateEvt: ref<SetDocumentStateEvent>;
    let documentType: EDocumentType;
    if controller == null {
      return;
    };
    docStateEvt = new SetDocumentStateEvent();
    documentType = controller.GetDocumentType();
    docStateEvt.documentType = documentType;
    docStateEvt.isOpened = true;
    docStateEvt.documentAdress = controller.GetDocumentAdress();
    if Equals(documentType, EDocumentType.MAIL) {
      this.RequestMailWidgetUpdate(controller.GetDocumentAdress());
      this.GetMainLayoutController().MarkMailThumbnailAsSelected(controller);
    } else {
      if Equals(documentType, EDocumentType.FILE) {
        this.RequestFileWidgetUpdate(controller.GetDocumentAdress());
        this.GetMainLayoutController().MarkFileThumbnailAsSelected(controller);
      };
    };
    controller.OpenDocument();
    this.ResolveQuestInfo(controller.GetQuestInfo());
    this.GetOwner().QueueEvent(docStateEvt);
  }

  public final const func GetForceOpenDocumentType() -> EDocumentType {
    return this.m_forceOpenDocumentType;
  }

  public final const func GetForceOpenDocumentAdress() -> SDocumentAdress {
    return this.m_forceOpenDocumentAdress;
  }

  public final func ResetForceOpenDocumentData() -> Void {
    let invalidAdress: SDocumentAdress;
    this.m_forceOpenDocumentType = EDocumentType.Invalid;
    this.m_forceOpenDocumentAdress = invalidAdress;
  }

  protected cb func OnGoToMenuEvent(evt: ref<GoToMenuEvent>) -> Bool {
    if evt.ownerID == this.GetOwner().GetEntityID() {
      if evt.wakeUp {
        this.GetMainLayoutController().HideScreenSaver();
      };
      this.GoToMenu(this.GetMenuName(evt.menuType));
    };
  }

  protected cb func OnOpenDocumentEvent(evt: ref<OpenDocumentEvent>) -> Bool {
    let activeMenuID: String;
    let isReady: Bool;
    if evt.ownerID == this.GetOwner().GetEntityID() {
      if evt.wakeUp {
        this.GetMainLayoutController().HideScreenSaver();
      };
      activeMenuID = this.GetActiveBreadcrumbElementName();
      if Equals(evt.documentType, EDocumentType.MAIL) && NotEquals(activeMenuID, "mails") {
        this.GoToMenu("mails");
      } else {
        if Equals(evt.documentType, EDocumentType.FILE) && NotEquals(activeMenuID, "files") {
          this.GoToMenu("files");
        } else {
          isReady = true;
        };
      };
      if isReady {
        this.OpenDocument(evt.documentType, evt.documentAdress);
      } else {
        this.m_forceOpenDocumentType = evt.documentType;
        this.m_forceOpenDocumentAdress = evt.documentAdress;
      };
    };
  }

  protected final func RegisterCloseWindowButtonCallback() -> Void {
    this.GetMainLayoutController().GetWindowCloseButton().RegisterToCallback(n"OnRelease", this, n"OnWindowCloseCallback");
  }

  protected cb func OnWindowCloseCallback(e: ref<inkPointerEvent>) -> Bool {
    if this.IsInteractivityBlocked() {
      return false;
    };
    if e.IsAction(n"click") {
      this.GetMainLayoutController().HideWindow();
    };
  }

  protected cb func OnMenuButtonCallback(e: ref<inkPointerEvent>) -> Bool {
    let controller: ref<ComputerMenuButtonController>;
    if this.IsInteractivityBlocked() {
      return false;
    };
    if e.IsAction(n"click") {
      controller = e.GetCurrentTarget().GetController() as ComputerMenuButtonController;
      if IsDefined(controller) {
        this.GoToMenu(controller.GetMenuID());
      };
    };
  }

  protected cb func OnDocumentThumbnailCallback(e: ref<inkPointerEvent>) -> Bool {
    let controller: ref<ComputerDocumentThumbnailWidgetController>;
    if this.IsInteractivityBlocked() {
      return false;
    };
    if e.IsAction(n"click") {
      controller = e.GetCurrentTarget().GetController() as ComputerDocumentThumbnailWidgetController;
      this.OpenDocument(controller);
    };
  }

  protected cb func OnHideFullBannerCallback(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.GetMainLayoutController().HideFullBanner();
    };
  }

  protected cb func OnHideMailCallback(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.GetMainLayoutController().HideMails();
    };
  }

  protected cb func OnHideFileCallback(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.GetMainLayoutController().HideFiles();
    };
  }

  protected cb func OnShowFullBannerCallback(e: ref<inkPointerEvent>) -> Bool {
    let controller: ref<ComputerBannerWidgetController>;
    if e.IsAction(n"click") {
      controller = e.GetCurrentTarget().GetController() as ComputerBannerWidgetController;
      if IsDefined(controller) {
        this.GetMainLayoutController().ShowFullBanner(this, controller.GetBannerData());
      };
    };
  }

  private final func ResolveQuestInfo(questInfo: QuestInfo) -> Void {
    if IsNameValid(questInfo.factName) {
      AddFact(this.GetOwner().GetGame(), questInfo.factName, 1);
    };
  }

  public func GetMainLayoutController() -> ref<ComputerMainLayoutWidgetController> {
    return this.m_mainLayout.GetController() as ComputerMainLayoutWidgetController;
  }

  protected final func InitializeMails(widgetsData: array<SDocumentWidgetPackage>) -> Void {
    this.GetMainLayoutController().InitializeMails(this, widgetsData);
  }

  protected final func InitializeFiles(widgetsData: array<SDocumentWidgetPackage>) -> Void {
    this.GetMainLayoutController().InitializeFiles(this, widgetsData);
  }

  protected final func InitializeMailsThumbnails(widgetsData: array<SDocumentThumbnailWidgetPackage>) -> Void {
    this.GetMainLayoutController().InitializeMailsThumbnails(this, widgetsData);
  }

  private final func InitializeFilesThumbnails(widgetsData: array<SDocumentThumbnailWidgetPackage>) -> Void {
    this.GetMainLayoutController().InitializeFilesThumbnails(this, widgetsData);
  }

  protected final func InitializeBanners(widgetsData: array<SBannerWidgetPackage>) -> Void {
    this.GetMainLayoutController().InitializeBanners(this, widgetsData);
  }

  protected final func InitializeMainMenuButtons(widgetsData: array<SComputerMenuButtonWidgetPackage>) -> Void {
    this.GetMainLayoutController().InitializeMainMenuButtons(this, widgetsData);
  }

  protected final func InitializeMenuButtons(widgetsData: array<SComputerMenuButtonWidgetPackage>) -> Void {
    this.GetMainLayoutController().InitializeMenuButtons(this, widgetsData);
    this.m_menuInitialized = true;
  }

  public final func RequestMenuButtonWidgetsUpdate() -> Void {
    let menuWidgetsEvent: ref<RequestComputerMenuWidgetsUpdateEvent> = new RequestComputerMenuWidgetsUpdateEvent();
    menuWidgetsEvent.screenDefinition = this.GetOwner().GetScreenDefinition();
    this.GetOwner().QueueEvent(menuWidgetsEvent);
  }

  protected final func RequestMainMenuButtonWidgetsUpdate() -> Void {
    let menuWidgetsEvent: ref<RequestComputerMainMenuWidgetsUpdateEvent> = new RequestComputerMainMenuWidgetsUpdateEvent();
    menuWidgetsEvent.screenDefinition = this.GetOwner().GetScreenDefinition();
    this.GetOwner().QueueEvent(menuWidgetsEvent);
  }

  protected final func RequestFileThumbnailWidgetsUpdate() -> Void {
    let documentThumbnailEvent: ref<RequestDocumentThumbnailWidgetsUpdateEvent> = new RequestDocumentThumbnailWidgetsUpdateEvent();
    documentThumbnailEvent.documentType = EDocumentType.FILE;
    documentThumbnailEvent.screenDefinition = this.GetOwner().GetScreenDefinition();
    this.GetOwner().QueueEvent(documentThumbnailEvent);
  }

  protected final func RequestMailThumbnailWidgetsUpdate() -> Void {
    let documentThumbnailEvent: ref<RequestDocumentThumbnailWidgetsUpdateEvent> = new RequestDocumentThumbnailWidgetsUpdateEvent();
    documentThumbnailEvent.documentType = EDocumentType.MAIL;
    documentThumbnailEvent.screenDefinition = this.GetOwner().GetScreenDefinition();
    this.GetOwner().QueueEvent(documentThumbnailEvent);
  }

  public final func RequestMailWidgetUpdate(documentAdress: SDocumentAdress) -> Void {
    let documentEvent: ref<RequestDocumentWidgetUpdateEvent> = new RequestDocumentWidgetUpdateEvent();
    documentEvent.documentType = EDocumentType.MAIL;
    documentEvent.documentAdress = documentAdress;
    documentEvent.screenDefinition = this.GetOwner().GetScreenDefinition();
    this.GetOwner().QueueEvent(documentEvent);
  }

  public final func RequestFileWidgetUpdate(documentAdress: SDocumentAdress) -> Void {
    let documentEvent: ref<RequestDocumentWidgetUpdateEvent> = new RequestDocumentWidgetUpdateEvent();
    documentEvent.documentType = EDocumentType.FILE;
    documentEvent.documentAdress = documentAdress;
    documentEvent.screenDefinition = this.GetOwner().GetScreenDefinition();
    this.GetOwner().QueueEvent(documentEvent);
  }

  protected final func RequestBannerWidgetsUpdate() -> Void {
    let bannerEvent: ref<RequestBannerWidgetUpdateEvent> = new RequestBannerWidgetUpdateEvent();
    bannerEvent.screenDefinition = this.GetOwner().GetScreenDefinition();
    this.GetOwner().QueueEvent(bannerEvent);
  }

  private func StartGlitchingScreen(glitchData: GlitchData) -> Void {
    let glitchVideoPath: ResRef;
    if Equals(glitchData.state, EGlitchState.SUBLIMINAL_MESSAGE) {
      glitchVideoPath = (this.GetOwner() as Computer).GetBroadcastGlitchVideoPath();
    } else {
      glitchVideoPath = (this.GetOwner() as Computer).GetDefaultGlitchVideoPath();
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
