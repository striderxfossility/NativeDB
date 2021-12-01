
public class ComputerMainLayoutWidgetController extends inkLogicController {

  @attrib(category, "Widget Refs")
  protected edit let m_screenSaverSlot: inkWidgetRef;

  @attrib(category, "Widget Refs")
  protected edit let m_wallpaperSlot: inkWidgetRef;

  @attrib(category, "Widget Refs")
  protected edit let m_menuButtonList: inkWidgetRef;

  @attrib(category, "Widget Refs")
  protected edit let m_menuContainer: inkWidgetRef;

  @attrib(category, "Widget Refs")
  protected edit let m_internetContainer: inkWidgetRef;

  @attrib(category, "Widget Refs")
  protected edit let m_offButton: inkWidgetRef;

  @attrib(category, "Widget Refs")
  protected edit let m_windowCloseButton: inkWidgetRef;

  @attrib(category, "Widget Refs")
  protected edit let m_windowContainer: inkWidgetRef;

  @attrib(category, "Widget Refs")
  protected edit let m_windowHeader: inkTextRef;

  @attrib(category, "TweakDB")
  @attrib(customEditor, "TweakDBGroupInheritance;WidgetDefinition")
  protected edit let m_menuMailsID: TweakDBID;

  @attrib(category, "TweakDB")
  @attrib(customEditor, "TweakDBGroupInheritance;WidgetDefinition")
  protected edit let m_menuFilesID: TweakDBID;

  @attrib(category, "TweakDB")
  @attrib(customEditor, "TweakDBGroupInheritance;WidgetDefinition")
  protected edit let m_menuNewsFeedID: TweakDBID;

  @attrib(category, "TweakDB")
  @attrib(customEditor, "TweakDBGroupInheritance;WidgetDefinition")
  protected edit let m_menuMainID: TweakDBID;

  @attrib(category, "TweakDB")
  @attrib(customEditor, "TweakDBGroupInheritance;WidgetDefinition")
  protected edit let m_internetBrowserID: TweakDBID;

  @attrib(category, "TweakDB")
  @attrib(customEditor, "TweakDBGroupInheritance;WidgetDefinition")
  protected edit let m_screenSaverID: TweakDBID;

  @attrib(category, "TweakDB")
  @attrib(customEditor, "TweakDBGroupInheritance;WidgetDefinition")
  protected edit let m_wallpaperID: TweakDBID;

  @attrib(category, "Animations")
  @default(ComputerMainLayoutWidgetController, windowClose_16x9)
  protected edit let m_windowCloseAanimation: CName;

  @attrib(category, "Animations")
  @default(ComputerMainLayoutWidgetController, windowOpen_16x9)
  protected edit let m_windowOpenAanimation: CName;

  protected let m_currentScreenSaverLibraryID: CName;

  protected let m_currentWallpaperLibraryID: CName;

  private let m_computerMenuButtonWidgetsData: array<SComputerMenuButtonWidgetPackage>;

  protected let m_mailsMenu: wref<inkWidget>;

  protected let m_filesMenu: wref<inkWidget>;

  protected let m_devicesMenu: wref<inkWidget>;

  protected let m_newsFeedMenu: wref<inkWidget>;

  protected let m_internetData: wref<inkWidget>;

  protected let m_mainMenu: wref<inkWidget>;

  protected let m_screenSaver: wref<inkWidget>;

  protected let m_wallpaper: wref<inkWidget>;

  protected let m_isInitialized: Bool;

  private let m_devicesMenuInitialized: Bool;

  private let m_isWindowOpened: Bool;

  private let m_activeWindowID: String;

  @default(ComputerMainLayoutWidgetController, EComputerMenuType.INVALID)
  private let m_menuToOpen: EComputerMenuType;

  public func Initialize(gameController: ref<ComputerInkGameController>) -> Void {
    this.HideWindow();
    this.SetScreenSaver(gameController, inkWidgetRef.Get(this.m_screenSaverSlot));
    this.SetWallpaper(gameController, inkWidgetRef.Get(this.m_wallpaperSlot));
    this.SetFilesMenu(gameController, this.GetFilesMenuContainer());
    this.SetMailsMenu(gameController, this.GetMailsMenuContainer());
    this.SetNewsFeedMenu(gameController, this.GetNewsfeedMenuContainer());
    this.SetMainMenu(gameController);
    this.SetInternetMenu(gameController);
    this.m_isInitialized = true;
  }

  public func InitializeMenuButtons(gameController: ref<ComputerInkGameController>, widgetsData: array<SComputerMenuButtonWidgetPackage>) -> Void {
    let i: Int32;
    let widget: ref<inkWidget>;
    this.HideMenuButtonWidgets();
    i = 0;
    while i < ArraySize(widgetsData) {
      widget = this.GetMenuButtonWidget(widgetsData[i], gameController);
      if widget == null {
        widget = this.CreateMenuButtonWidget(gameController, inkWidgetRef.Get(this.m_menuButtonList), widgetsData[i]);
        this.AddMenuButtonWidget(widget, widgetsData[i], gameController);
      };
      this.InitializeMenuButtonWidget(gameController, widget, widgetsData[i]);
      i += 1;
    };
  }

  public func SetScreenSaver(gameController: ref<ComputerInkGameController>, parentWidget: wref<inkWidget>) -> Void {
    let newLibraryID: CName;
    let screenSaverRecord: ref<WidgetDefinition_Record>;
    let spawnData: ref<AsyncSpawnData>;
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    if !TDBID.IsValid(this.m_screenSaverID) {
      this.m_screenSaverID = t"DevicesUIDefinitions.ComputerScreenSaverWidget";
    };
    screenSaverRecord = TweakDBInterface.GetWidgetDefinitionRecord(this.m_screenSaverID);
    newLibraryID = gameController.GetCurrentFullLibraryID(screenSaverRecord, screenDef.screenDefinition.ComputerScreenType(), screenDef.style);
    if Equals(this.m_currentScreenSaverLibraryID, newLibraryID) {
      return;
    };
    if this.m_screenSaver != null {
      (inkWidgetRef.Get(this.m_screenSaverSlot) as inkCompoundWidget).RemoveChild(this.m_screenSaver);
    };
    this.m_currentScreenSaverLibraryID = newLibraryID;
    spawnData = new AsyncSpawnData();
    spawnData.Initialize(this, n"OnScreenSaverSpawned", ToVariant(null), this);
    gameController.RequestWidgetFromLibrary(parentWidget, TweakDBInterface.GetWidgetDefinitionRecord(this.m_screenSaverID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style, spawnData);
  }

  protected cb func OnScreenSaverSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_screenSaver = widget;
    if IsDefined(this.m_screenSaver) {
      this.m_screenSaver.SetAnchor(inkEAnchor.Centered);
      this.m_screenSaver.SetAnchorPoint(0.50, 0.50);
    };
  }

  public func SetWallpaper(gameController: ref<ComputerInkGameController>, parentWidget: wref<inkWidget>) -> Void {
    let newLibraryID: CName;
    let screenSaverRecord: ref<WidgetDefinition_Record>;
    let spawnData: ref<AsyncSpawnData>;
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    if !TDBID.IsValid(this.m_wallpaperID) {
      this.m_wallpaperID = t"DevicesUIDefinitions.ComputerWallpaperWidget";
    };
    screenSaverRecord = TweakDBInterface.GetWidgetDefinitionRecord(this.m_wallpaperID);
    newLibraryID = gameController.GetCurrentFullLibraryID(screenSaverRecord, screenDef.screenDefinition.ComputerScreenType(), screenDef.style);
    if Equals(this.m_currentWallpaperLibraryID, newLibraryID) {
      return;
    };
    if this.m_screenSaver != null {
      (inkWidgetRef.Get(this.m_wallpaperSlot) as inkCompoundWidget).RemoveChild(this.m_wallpaper);
    };
    this.m_currentWallpaperLibraryID = newLibraryID;
    spawnData = new AsyncSpawnData();
    spawnData.Initialize(this, n"OnWallpaperSpawned", ToVariant(null), this);
    gameController.RequestWidgetFromLibrary(parentWidget, TweakDBInterface.GetWidgetDefinitionRecord(this.m_wallpaperID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style, spawnData);
  }

  protected cb func OnWallpaperSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_wallpaper = widget;
    if IsDefined(this.m_wallpaper) {
      this.m_wallpaper.SetAnchor(inkEAnchor.Centered);
      this.m_screenSaver.SetAnchorPoint(0.50, 0.50);
      this.m_wallpaper.SetVisible(false);
    };
  }

  public func SetMailsMenu(gameController: ref<ComputerInkGameController>, parentWidget: wref<inkWidget>) -> Void {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    if !TDBID.IsValid(this.m_menuMailsID) {
      this.m_menuMailsID = t"DevicesUIDefinitions.MenuMailsWidget";
    };
    this.m_mailsMenu = gameController.FindWidgetInLibrary(parentWidget, TweakDBInterface.GetWidgetDefinitionRecord(this.m_menuMailsID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style);
    if this.m_mailsMenu != null {
      this.m_mailsMenu.SetAnchor(inkEAnchor.Fill);
      this.m_mailsMenu.SetVisible(false);
    };
  }

  public func SetFilesMenu(gameController: ref<ComputerInkGameController>, parentWidget: wref<inkWidget>) -> Void {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    if !TDBID.IsValid(this.m_menuFilesID) {
      this.m_menuFilesID = t"DevicesUIDefinitions.MenuFilesWidget";
    };
    this.m_filesMenu = gameController.FindWidgetInLibrary(parentWidget, TweakDBInterface.GetWidgetDefinitionRecord(this.m_menuFilesID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style);
    if this.m_filesMenu != null {
      this.m_filesMenu.SetAnchor(inkEAnchor.Fill);
      this.m_filesMenu.SetVisible(false);
    };
  }

  public func SetDevicesMenu(widget: ref<inkWidget>) -> Void {
    this.m_devicesMenu = widget;
    this.m_devicesMenu.SetAnchor(inkEAnchor.Fill);
  }

  public func SetNewsFeedMenu(gameController: ref<ComputerInkGameController>, parentWidget: wref<inkWidget>) -> Void {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    if !TDBID.IsValid(this.m_menuNewsFeedID) {
      this.m_menuNewsFeedID = t"DevicesUIDefinitions.MenuNewsFeedWidget";
    };
    this.m_newsFeedMenu = gameController.FindWidgetInLibrary(parentWidget, TweakDBInterface.GetWidgetDefinitionRecord(this.m_menuNewsFeedID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style);
    if this.m_newsFeedMenu != null {
      this.m_newsFeedMenu.SetAnchor(inkEAnchor.Fill);
      this.m_newsFeedMenu.SetVisible(false);
    };
  }

  public func SetMainMenu(gameController: ref<ComputerInkGameController>) -> Void {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    if !TDBID.IsValid(this.m_menuMainID) {
      this.m_menuMainID = t"DevicesUIDefinitions.MenuMainWidget";
    };
    this.m_mainMenu = gameController.FindWidgetInLibrary(inkWidgetRef.Get(this.m_menuContainer), TweakDBInterface.GetWidgetDefinitionRecord(this.m_menuMainID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style);
    if this.m_mainMenu != null {
      this.m_mainMenu.SetAnchor(inkEAnchor.Fill);
      this.m_mainMenu.SetVisible(false);
    };
  }

  public func SetInternetMenu(gameController: ref<ComputerInkGameController>) -> Void {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    if !TDBID.IsValid(this.m_internetBrowserID) {
      this.m_internetBrowserID = t"DevicesUIDefinitions.InternetBrowserWidget";
    };
    if inkWidgetRef.IsValid(this.m_internetContainer) {
      this.m_internetData = this.FindWidgetInLibrary(inkWidgetRef.Get(this.m_internetContainer), TweakDBInterface.GetWidgetDefinitionRecord(this.m_internetBrowserID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style);
    } else {
      this.m_internetData = this.FindWidgetInLibrary(inkWidgetRef.Get(this.m_menuContainer), TweakDBInterface.GetWidgetDefinitionRecord(this.m_internetBrowserID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style);
    };
    this.m_internetData.SetAnchor(inkEAnchor.Fill);
    this.m_internetData.SetVisible(false);
  }

  public final func ShowScreenSaver() -> Void {
    inkWidgetRef.SetVisible(this.m_screenSaverSlot, true);
  }

  public final func HideScreenSaver() -> Void {
    inkWidgetRef.SetVisible(this.m_screenSaverSlot, false);
  }

  public final func ShowWallpaper() -> Void {
    this.m_wallpaper.SetVisible(true);
  }

  public final func HideWallpaper() -> Void {
    if IsDefined(this.m_wallpaper) {
      this.m_wallpaper.SetVisible(false);
    };
  }

  public func ShowNewsfeed() -> Void {
    this.GetFileMenuController().HideFileThumbnailWidgets();
    this.GetMailMenuController().HideFileThumbnailWidgets();
    this.m_newsFeedMenu.SetVisible(true);
    this.m_mailsMenu.SetVisible(false);
    this.m_filesMenu.SetVisible(false);
    this.m_devicesMenu.SetVisible(false);
    this.m_mainMenu.SetVisible(false);
    this.m_internetData.SetVisible(false);
    this.ShowWindow("LocKey#40", EComputerMenuType.NEWSFEED);
    if Equals(this.m_menuToOpen, EComputerMenuType.NEWSFEED) {
      this.m_newsFeedMenu.SetVisible(false);
    };
  }

  public func ShowMails() -> Void {
    this.GetFileMenuController().HideFileThumbnailWidgets();
    this.GetNewsFeedController().HideBannerWidgets();
    this.m_mailsMenu.SetVisible(true);
    this.m_filesMenu.SetVisible(false);
    this.m_devicesMenu.SetVisible(false);
    this.m_newsFeedMenu.SetVisible(false);
    this.m_mainMenu.SetVisible(false);
    this.m_internetData.SetVisible(false);
    this.HideFullBanner();
    this.ShowWindow("LocKey#42", EComputerMenuType.MAILS);
    if Equals(this.m_menuToOpen, EComputerMenuType.MAILS) {
      this.m_mailsMenu.SetVisible(false);
    };
  }

  public func ShowFiles() -> Void {
    this.GetMailMenuController().HideFileThumbnailWidgets();
    this.GetNewsFeedController().HideBannerWidgets();
    this.m_filesMenu.SetVisible(true);
    this.m_mailsMenu.SetVisible(false);
    this.m_devicesMenu.SetVisible(false);
    this.m_newsFeedMenu.SetVisible(false);
    this.m_mainMenu.SetVisible(false);
    this.m_internetData.SetVisible(false);
    this.HideFullBanner();
    this.ShowWindow("LocKey#41", EComputerMenuType.FILES);
    if Equals(this.m_menuToOpen, EComputerMenuType.FILES) {
      this.m_filesMenu.SetVisible(false);
    };
  }

  public func ShowDevices() -> Void {
    this.m_devicesMenu.SetVisible(true);
    this.m_mailsMenu.SetVisible(false);
    this.m_filesMenu.SetVisible(false);
    this.m_mainMenu.SetVisible(false);
    this.m_newsFeedMenu.SetVisible(false);
    this.m_internetData.SetVisible(false);
    this.HideFullBanner();
    this.ShowWindow("LocKey#43", EComputerMenuType.SYSTEM);
    if Equals(this.m_menuToOpen, EComputerMenuType.SYSTEM) {
      this.m_devicesMenu.SetVisible(false);
    };
  }

  public func ShowMainMenu() -> Void {
    this.GetFileMenuController().HideFileThumbnailWidgets();
    this.GetNewsFeedController().HideBannerWidgets();
    this.GetMailMenuController().HideFileThumbnailWidgets();
    this.m_mailsMenu.SetVisible(false);
    this.m_filesMenu.SetVisible(false);
    this.m_devicesMenu.SetVisible(false);
    this.m_newsFeedMenu.SetVisible(false);
    this.m_internetData.SetVisible(false);
  }

  public func ShowInternet(startingPage: String) -> Void {
    this.GetNewsFeedController().HideBannerWidgets();
    this.GetFileMenuController().HideFileThumbnailWidgets();
    this.GetMailMenuController().HideFileThumbnailWidgets();
    this.GetInternetController().SetDefaultPage(startingPage);
    this.m_mailsMenu.SetVisible(false);
    this.m_filesMenu.SetVisible(false);
    this.m_devicesMenu.SetVisible(false);
    this.m_newsFeedMenu.SetVisible(false);
    this.m_internetData.SetVisible(true);
    this.m_mainMenu.SetVisible(false);
    this.HideFullBanner();
    this.ShowWindow("LocKey#113", EComputerMenuType.INTERNET);
    if Equals(this.m_menuToOpen, EComputerMenuType.INTERNET) {
      this.m_internetData.SetVisible(false);
    };
  }

  public final func ShowWindow(header: String, menuType: EComputerMenuType) -> Void {
    if this.m_isWindowOpened && NotEquals(this.m_activeWindowID, header) {
      this.m_menuToOpen = menuType;
      this.HideWindow();
      return;
    };
    this.GetWindowContainer().SetVisible(true);
    this.GetWindowHeader().SetText(header);
    if !this.m_isWindowOpened && IsNameValid(this.m_windowOpenAanimation) {
      this.PlayLibraryAnimation(this.m_windowOpenAanimation).RegisterToCallback(inkanimEventType.OnFinish, this, n"OnWindowOpened");
    };
    this.m_isWindowOpened = true;
    this.m_activeWindowID = header;
  }

  protected cb func OnWindowOpened(e: ref<inkAnimProxy>) -> Bool {
    e.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnWindowOpened");
  }

  public final func HideWindow() -> Void {
    this.DeselectAllManuButtons();
    if this.m_isWindowOpened && IsNameValid(this.m_windowCloseAanimation) {
      this.PlayLibraryAnimation(this.m_windowCloseAanimation).RegisterToCallback(inkanimEventType.OnFinish, this, n"OnWindowClosed");
    } else {
      this.GetWindowContainer().SetVisible(false);
    };
    this.m_isWindowOpened = false;
    this.m_activeWindowID = "";
  }

  protected cb func OnWindowClosed(e: ref<inkAnimProxy>) -> Bool {
    e.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnWindowClosed");
    this.GetWindowContainer().SetVisible(false);
    this.ResolveWindowClose();
  }

  private final func ResolveWindowClose() -> Void {
    let menuToOpen: EComputerMenuType = this.m_menuToOpen;
    this.m_menuToOpen = EComputerMenuType.INVALID;
    if Equals(menuToOpen, EComputerMenuType.INVALID) {
      return;
    };
    if Equals(menuToOpen, EComputerMenuType.INTERNET) {
      this.ShowInternet(this.GetInternetController().GetDefaultpage());
    } else {
      if Equals(menuToOpen, EComputerMenuType.SYSTEM) {
        this.ShowDevices();
      } else {
        if Equals(menuToOpen, EComputerMenuType.MAILS) {
          this.ShowMails();
        } else {
          if Equals(menuToOpen, EComputerMenuType.FILES) {
            this.ShowFiles();
          } else {
            if Equals(menuToOpen, EComputerMenuType.NEWSFEED) {
              this.ShowNewsfeed();
            } else {
              if Equals(menuToOpen, EComputerMenuType.MAIN) {
                this.ShowMainMenu();
              };
            };
          };
        };
      };
    };
  }

  public final func MarkManuButtonAsSelected(controller: ref<ComputerMenuButtonController>) -> Void {
    let currentController: ref<ComputerMenuButtonController>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_computerMenuButtonWidgetsData) {
      if this.m_computerMenuButtonWidgetsData[i].widget != null {
        currentController = this.m_computerMenuButtonWidgetsData[i].widget.GetController() as ComputerMenuButtonController;
        if IsDefined(currentController) && currentController == controller {
          currentController.ToggleSelection(true);
        } else {
          currentController.ToggleSelection(false);
        };
      };
      i += 1;
    };
  }

  public final func MarkManuButtonAsSelected(menuID: String) -> Void {
    let currentController: ref<ComputerMenuButtonController>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_computerMenuButtonWidgetsData) {
      if this.m_computerMenuButtonWidgetsData[i].widget != null {
        currentController = this.m_computerMenuButtonWidgetsData[i].widget.GetController() as ComputerMenuButtonController;
        if IsDefined(currentController) && Equals(currentController.GetMenuID(), menuID) {
          currentController.ToggleSelection(true);
        } else {
          currentController.ToggleSelection(false);
        };
      };
      i += 1;
    };
  }

  public final func DeselectAllManuButtons() -> Void {
    let currentController: ref<ComputerMenuButtonController>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_computerMenuButtonWidgetsData) {
      if this.m_computerMenuButtonWidgetsData[i].widget != null {
        currentController = this.m_computerMenuButtonWidgetsData[i].widget.GetController() as ComputerMenuButtonController;
        if IsDefined(currentController) {
          currentController.ToggleSelection(false);
        };
      };
      i += 1;
    };
  }

  protected final func GetWindowContainer() -> wref<inkWidget> {
    return inkWidgetRef.Get(this.m_windowContainer);
  }

  protected final func GetWindowHeader() -> wref<inkText> {
    return inkWidgetRef.Get(this.m_windowHeader) as inkText;
  }

  public final func GetOffButton() -> wref<inkWidget> {
    return inkWidgetRef.Get(this.m_offButton);
  }

  public final func GetWindowCloseButton() -> wref<inkWidget> {
    return inkWidgetRef.Get(this.m_windowCloseButton);
  }

  public final func GetMenuContainer() -> wref<inkWidget> {
    return inkWidgetRef.Get(this.m_menuContainer);
  }

  public func GetDevicesMenuContainer() -> wref<inkWidget> {
    return inkWidgetRef.Get(this.m_menuContainer);
  }

  public func GetNewsfeedMenuContainer() -> wref<inkWidget> {
    return inkWidgetRef.Get(this.m_menuContainer);
  }

  public func GetMailsMenuContainer() -> wref<inkWidget> {
    return inkWidgetRef.Get(this.m_menuContainer);
  }

  public func GetFilesMenuContainer() -> wref<inkWidget> {
    return inkWidgetRef.Get(this.m_menuContainer);
  }

  protected final func GetFileMenuController() -> ref<ComputerMenuWidgetController> {
    return this.m_filesMenu.GetController() as ComputerMenuWidgetController;
  }

  public final func GetFileThumbnailController(adress: SDocumentAdress) -> ref<ComputerDocumentThumbnailWidgetController> {
    return this.GetFileMenuController().GetThumbnailController(adress);
  }

  protected final func GetMailMenuController() -> ref<ComputerMenuWidgetController> {
    return this.m_mailsMenu.GetController() as ComputerMenuWidgetController;
  }

  public final func GetMailThumbnailController(adress: SDocumentAdress) -> ref<ComputerDocumentThumbnailWidgetController> {
    return this.GetMailMenuController().GetThumbnailController(adress);
  }

  protected final func GetNewsFeedController() -> ref<NewsFeedMenuWidgetController> {
    return this.m_newsFeedMenu.GetController() as NewsFeedMenuWidgetController;
  }

  protected final func GetMainMenuController() -> ref<ComputerMainMenuWidgetController> {
    return this.m_mainMenu.GetController() as ComputerMainMenuWidgetController;
  }

  protected final func GetInternetController() -> ref<BrowserController> {
    return this.m_internetData.GetController() as BrowserController;
  }

  public final func InitializeMails(gameController: ref<ComputerInkGameController>, widgetsData: array<SDocumentWidgetPackage>) -> Void {
    this.GetMailMenuController().InitializeFiles(gameController, widgetsData);
  }

  public final func InitializeFiles(gameController: ref<ComputerInkGameController>, widgetsData: array<SDocumentWidgetPackage>) -> Void {
    this.GetFileMenuController().InitializeFiles(gameController, widgetsData);
  }

  public final func InitializeMailsThumbnails(gameController: ref<ComputerInkGameController>, widgetsData: array<SDocumentThumbnailWidgetPackage>) -> Void {
    this.GetMailMenuController().InitializeFilesThumbnails(gameController, widgetsData);
  }

  public final func InitializeFilesThumbnails(gameController: ref<ComputerInkGameController>, widgetsData: array<SDocumentThumbnailWidgetPackage>) -> Void {
    this.GetFileMenuController().InitializeFilesThumbnails(gameController, widgetsData);
  }

  public final func InitializeBanners(gameController: ref<ComputerInkGameController>, widgetsData: array<SBannerWidgetPackage>) -> Void {
    this.GetNewsFeedController().InitializeBanners(gameController, widgetsData);
  }

  public final func InitializeMainMenuButtons(gameController: ref<ComputerInkGameController>, widgetsData: array<SComputerMenuButtonWidgetPackage>) -> Void {
    this.GetMainMenuController().InitializeMenuButtons(gameController, widgetsData);
  }

  public final func ShowFullBanner(gameController: ref<ComputerInkGameController>, widgetData: SBannerWidgetPackage) -> Void {
    this.GetNewsFeedController().ShowFullBanner(gameController, widgetData);
  }

  public final func HideNewsFeed() -> Void {
    this.HideBanners();
    this.HideFullBanner();
  }

  public final func HideFullBanner() -> Void {
    this.GetNewsFeedController().HideFullBanner();
  }

  public final func HideBanners() -> Void {
    this.GetNewsFeedController().HideBannerWidgets();
  }

  public final func HideMails() -> Void {
    this.GetMailMenuController().HideFileWidgets();
  }

  public final func MarkMailThumbnailAsSelected(controller: ref<ComputerDocumentThumbnailWidgetController>) -> Void {
    this.GetMailMenuController().MarkThumbnailAsSelected(controller);
  }

  public final func MarkMailThumbnailAsSelected(adress: SDocumentAdress) -> Void {
    this.GetMailMenuController().MarkThumbnailAsSelected(adress);
  }

  public final func HideFiles() -> Void {
    this.GetFileMenuController().HideFileWidgets();
  }

  public final func MarkFileThumbnailAsSelected(controller: ref<ComputerDocumentThumbnailWidgetController>) -> Void {
    this.GetFileMenuController().MarkThumbnailAsSelected(controller);
  }

  public final func HideDevices() -> Void {
    this.m_devicesMenu.SetVisible(false);
  }

  public final func HideMainMenu() -> Void {
    this.m_mainMenu.SetVisible(false);
  }

  public final func HideInternet() -> Void {
    this.m_internetData.SetVisible(false);
  }

  public final func CreateMenuButtonWidget(gameController: ref<ComputerInkGameController>, parentWidget: wref<inkWidget>, widgetData: SComputerMenuButtonWidgetPackage) -> wref<inkWidget> {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    let widget: ref<inkWidget> = gameController.FindWidgetInLibrary(parentWidget, TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style, widgetData.libraryID, widgetData.libraryPath);
    if IsDefined(parentWidget as inkHorizontalPanel) {
      widget.SetHAlign(inkEHorizontalAlign.Left);
    } else {
      if IsDefined(parentWidget as inkVerticalPanel) {
        widget.SetVAlign(inkEVerticalAlign.Top);
      };
    };
    widget.SetSizeRule(inkESizeRule.Fixed);
    return widget;
  }

  protected final func InitializeMenuButtonWidget(gameController: ref<ComputerInkGameController>, widget: ref<inkWidget>, widgetData: SComputerMenuButtonWidgetPackage) -> Void {
    let controller: ref<ComputerMenuButtonController> = widget.GetController() as ComputerMenuButtonController;
    if controller != null {
      controller.Initialize(gameController, widgetData);
    };
    widget.SetVisible(true);
  }

  protected final func GetMenuButtonWidget(widgetData: SComputerMenuButtonWidgetPackage, gameController: ref<ComputerInkGameController>) -> wref<inkWidget> {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    widgetData.libraryID = gameController.GetCurrentFullLibraryID(TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style);
    let i: Int32 = 0;
    while i < ArraySize(this.m_computerMenuButtonWidgetsData) {
      if Equals(this.m_computerMenuButtonWidgetsData[i].ownerID, widgetData.ownerID) && Equals(this.m_computerMenuButtonWidgetsData[i].widgetName, widgetData.widgetName) && this.m_computerMenuButtonWidgetsData[i].widgetTweakDBID == widgetData.widgetTweakDBID && Equals(this.m_computerMenuButtonWidgetsData[i].libraryPath, widgetData.libraryPath) && Equals(this.m_computerMenuButtonWidgetsData[i].libraryID, widgetData.libraryID) {
        return this.m_computerMenuButtonWidgetsData[i].widget;
      };
      i += 1;
    };
    return null;
  }

  protected final func AddMenuButtonWidget(widget: ref<inkWidget>, widgetData: SComputerMenuButtonWidgetPackage, gameController: ref<ComputerInkGameController>) -> wref<inkWidget> {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    widgetData.libraryID = gameController.GetCurrentFullLibraryID(TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style);
    widgetData.widget = widget;
    ArrayPush(this.m_computerMenuButtonWidgetsData, widgetData);
    return widgetData.widget;
  }

  protected final func HideMenuButtonWidgets() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_computerMenuButtonWidgetsData) {
      if this.m_computerMenuButtonWidgetsData[i].widget != null {
        this.m_computerMenuButtonWidgetsData[i].widget.SetVisible(false);
      };
      i += 1;
    };
  }
}
