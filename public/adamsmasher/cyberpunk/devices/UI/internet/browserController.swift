
public class BrowserGameController extends inkGameController {

  @attrib(category, "Widget Refs")
  public edit let m_logicControllerRef: inkWidgetRef;

  protected let m_journalManager: wref<JournalManager>;

  private let m_locationTags: array<CName>;

  protected cb func OnInitialize() -> Bool {
    let gameInstance: GameInstance;
    let locationManager: ref<LocationManager>;
    let logicScript: wref<BrowserController> = inkWidgetRef.GetController(this.m_logicControllerRef) as BrowserController;
    logicScript.Init(this);
    gameInstance = (this.GetOwnerEntity() as GameObject).GetGame();
    locationManager = GameInstance.GetLocationManager(gameInstance);
    locationManager.GetLocationTags(this.GetOwnerEntity().GetEntityID(), this.m_locationTags);
    this.PushWebsiteData();
    this.m_journalManager = GameInstance.GetJournalManager(gameInstance);
    this.m_journalManager.RegisterScriptCallback(this, n"OnJournalEntryStateChanged", gameJournalListenerType.State);
  }

  protected cb func OnJournalEntryStateChanged(entryHash: Uint32, className: CName, notifyOption: JournalNotifyOption, changeType: JournalChangeType) -> Bool {
    if Equals(className, n"gameJournalInternetPage") || Equals(className, n"gameJournalInternetSite") {
      this.PushWebsiteData();
    };
  }

  public final func PushWebsiteData() -> Void {
    let context: JournalRequestContext;
    let entries: array<wref<JournalEntry>>;
    let logicScript: wref<BrowserController>;
    context.stateFilter.active = true;
    if IsDefined(this.m_journalManager) {
      this.m_journalManager.GetInternetPages(context, entries);
    };
    logicScript = inkWidgetRef.GetController(this.m_logicControllerRef) as BrowserController;
    logicScript.SetWebsiteData(entries);
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_journalManager = GameInstance.GetJournalManager((this.GetOwnerEntity() as GameObject).GetGame());
    this.m_journalManager.UnregisterScriptCallback(this, n"OnJournalEntryStateChanged");
  }

  public final func GetJournalManager() -> ref<JournalManager> {
    return this.m_journalManager;
  }
}

public class BrowserController extends inkLogicController {

  protected edit let m_homeButton: inkWidgetRef;

  protected edit let m_homeButtonCoontroller: wref<LinkController>;

  protected edit let m_addressText: inkTextRef;

  protected edit let m_pageContentRoot: inkWidgetRef;

  protected edit let m_spinnerPath: ResRef;

  protected edit let m_webPageLibraryID: CName;

  protected edit let m_defaultDevicePage: String;

  private let m_gameController: wref<BrowserGameController>;

  private let m_websiteData: array<wref<JournalInternetPage>>;

  private let m_currentRequestedPage: wref<JournalInternetPage>;

  private let m_currentPage: wref<inkCompoundWidget>;

  private let m_spinner: wref<inkWidget>;

  public final func Init(gameController: ref<BrowserGameController>) -> Void {
    this.m_gameController = gameController;
    this.m_homeButtonCoontroller = inkWidgetRef.GetController(this.m_homeButton) as LinkController;
    if IsDefined(this.m_homeButtonCoontroller) {
      this.m_homeButtonCoontroller.RegisterToCallback(n"OnRelease", this, n"OnHomeButtonPressed");
    };
    this.AsyncSpawnFromExternal(inkWidgetRef.Get(this.m_pageContentRoot), this.m_spinnerPath, n"Root", this, n"OnSpinnerSpawned");
  }

  protected cb func OnSpinnerSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_spinner = widget;
    this.SetDefaultContent();
  }

  public final func SetWebsiteData(pageEntries: array<wref<JournalEntry>>) -> Void {
    let i: Int32;
    let pageEntry: wref<JournalInternetPage>;
    ArrayClear(this.m_websiteData);
    i = 0;
    while i < ArraySize(pageEntries) {
      pageEntry = pageEntries[i] as JournalInternetPage;
      ArrayPush(this.m_websiteData, pageEntry);
      i += 1;
    };
  }

  public final func SetDefaultPage(startingPage: String) -> Void {
    this.m_gameController.PushWebsiteData();
    this.m_defaultDevicePage = startingPage;
    this.SetDefaultContent();
  }

  public final const func GetDefaultpage() -> String {
    return this.m_defaultDevicePage;
  }

  private final func SetDefaultContent() -> Void {
    this.m_homeButtonCoontroller.SetLinkAddress(this.m_defaultDevicePage);
    this.m_homeButtonCoontroller.SetColors(new Color(255u, 255u, 255u, 255u), new Color(255u, 255u, 255u, 0u));
    this.LoadWebPage(this.m_defaultDevicePage);
  }

  private final func TryGetWebsiteData(address: String) -> wref<JournalInternetPage> {
    let i: Int32 = 0;
    while i < ArraySize(this.m_websiteData) {
      if Equals(this.m_websiteData[i].GetAddress(), address) {
        return this.m_websiteData[i];
      };
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_websiteData) {
      if Equals(this.m_websiteData[i].GetAddress(), "NETdir://page_not_found") {
        return this.m_websiteData[i];
      };
      i += 1;
    };
    return null;
  }

  protected cb func OnProcessLinkPressed(e: wref<inkWidget>) -> Bool {
    let page: ref<WebPage> = e.GetController() as WebPage;
    this.LoadWebPage(page.GetLastLinkClicked());
  }

  private final func OnHomeButtonPressed(e: ref<inkPointerEvent>) -> Void {
    let linkController: ref<LinkController>;
    if e.IsAction(n"click") {
      linkController = e.GetTarget().GetController() as LinkController;
      if IsDefined(linkController) {
        this.LoadWebPage(linkController.GetLinkAddress());
      };
    };
  }

  private final func LoadWebPage(address: String) -> Void {
    this.UnloadCurrentWebsite();
    this.m_currentRequestedPage = this.TryGetWebsiteData(address);
    if this.m_currentRequestedPage == null {
      if this.m_spinner != null {
        this.m_spinner.SetVisible(true);
      };
      return;
    };
    inkTextRef.SetText(this.m_addressText, this.m_currentRequestedPage.GetAddress());
    this.AsyncSpawnFromExternal(inkWidgetRef.Get(this.m_pageContentRoot), this.m_currentRequestedPage.GetWidgetPath(), this.m_webPageLibraryID, this, n"OnPageSpawned");
  }

  protected cb func OnPageSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let currentController: ref<WebPage>;
    let scale: Vector2;
    this.m_currentPage = widget as inkCompoundWidget;
    this.m_currentPage.SetAnchor(inkEAnchor.Fill);
    scale.X = this.m_currentRequestedPage.GetScale();
    scale.Y = this.m_currentRequestedPage.GetScale();
    this.m_currentPage.SetScale(scale);
    currentController = this.m_currentPage.GetController() as WebPage;
    if IsDefined(currentController) {
      currentController.FillPage(this.m_currentRequestedPage, this.m_gameController.GetJournalManager());
      currentController.RegisterToCallback(n"OnLinkPressed", this, n"OnProcessLinkPressed");
    };
    this.SetFacts(this.m_currentRequestedPage);
    if this.m_spinner != null {
      this.m_spinner.SetVisible(false);
    };
  }

  private final func SetFacts(page: wref<JournalInternetPage>) -> Void {
    let factsToSet: array<JournalFactNameValue> = page.GetFactsToSet();
    let i: Int32 = 0;
    while i < ArraySize(factsToSet) {
      if NotEquals(factsToSet[i].factName, n"") {
        SetFactValue(this.GetOwnerGameObject().GetGame(), factsToSet[i].factName, factsToSet[i].factValue);
      };
      i += 1;
    };
  }

  private final func UnloadCurrentWebsite() -> Void {
    let currentController: ref<WebPage>;
    if this.m_currentPage != null {
      currentController = this.m_currentPage.GetController() as WebPage;
      currentController.UnregisterFromCallback(n"OnLinkPressed", this, n"OnProcessLinkPressed");
      (inkWidgetRef.Get(this.m_pageContentRoot) as inkCompoundWidget).RemoveChild(this.m_currentPage);
    };
  }

  private final func GetOwnerGameObject() -> ref<Computer> {
    return this.m_gameController.GetOwnerEntity() as Computer;
  }
}

public class LinkController extends inkButtonController {

  private let m_linkAddress: String;

  private let m_defaultColor: HDRColor;

  private let m_hoverColor: HDRColor;

  private let IGNORED_COLOR: HDRColor;

  protected cb func OnInitialize() -> Bool {
    this.IGNORED_COLOR = new HDRColor(1.00, 1.00, 1.00, 0.00);
    this.m_hoverColor = new HDRColor(1.00, 1.00, 1.00, 1.00);
  }

  protected cb func OnButtonStateChanged(controller: wref<inkButtonController>, oldState: inkEButtonState, newState: inkEButtonState) -> Bool {
    let widget: ref<inkWidget>;
    if StrLen(this.m_linkAddress) == 0 {
      return true;
    };
    if Equals(this.m_hoverColor, new HDRColor(1.00, 1.00, 1.00, 0.00)) {
      return true;
    };
    widget = this.GetRootWidget();
    if Equals(oldState, inkEButtonState.Normal) {
      this.m_defaultColor = widget.GetTintColor();
    };
    switch newState {
      case inkEButtonState.Normal:
        widget.SetTintColor(this.m_defaultColor);
        break;
      case inkEButtonState.Press:
      case inkEButtonState.Hover:
        widget.SetTintColor(this.m_hoverColor);
        break;
      case inkEButtonState.Disabled:
        widget.SetTintColor(this.m_defaultColor);
    };
  }

  public final func GetLinkAddress() -> String {
    return this.m_linkAddress;
  }

  public final func SetLinkAddress(link: String) -> Void {
    this.m_linkAddress = link;
  }

  public final func SetColors(color: Color, hoverColor: Color) -> Void {
    let widget: ref<inkWidget>;
    if Equals(Color.ToHDRColorDirect(color), this.IGNORED_COLOR) {
      widget = this.GetRootWidget();
      this.m_defaultColor = widget.GetTintColor();
    } else {
      this.m_defaultColor = Color.ToHDRColorDirect(color);
    };
    this.m_hoverColor = Color.ToHDRColorDirect(hoverColor);
  }
}

public class WebPage extends inkLogicController {

  protected edit const let m_textList: array<inkTextRef>;

  protected edit const let m_rectangleList: array<inkRectangleRef>;

  protected edit const let m_imageList: array<inkImageRef>;

  protected edit const let m_videoList: array<inkVideoRef>;

  private let m_lastClickedLinkAddress: String;

  @default(WebPage, ImageLink)
  private let HOME_IMAGE_NAME: String;

  @default(WebPage, TextLink)
  private let HOME_TEXT_NAME: String;

  public final func FillPage(page: wref<JournalInternetPage>, journalManager: ref<JournalManager>) -> Void {
    if page != null {
      this.FillPageFromJournal(page);
      if page.IsAdditionallyFilledFromScripts() {
        this.FillPageFromScripts(page.GetAddress(), journalManager);
      };
    };
  }

  private final func FillPageFromScripts(address: String, journalManager: ref<JournalManager>) -> Void {
    let context: JournalRequestContext;
    let entries: array<wref<JournalEntry>>;
    let i: Int32;
    let iconAtlasPath: ResRef;
    let iconTexturePart: CName;
    let pageAddress: String;
    let pageEntry: wref<JournalInternetPage>;
    let siteEntry: wref<JournalInternetSite>;
    let MAX_ICONS_COUNT: Int32 = 60;
    let slotNumber: Int32 = 1;
    while slotNumber <= MAX_ICONS_COUNT {
      if !this.ClearSlot(slotNumber) {
      } else {
        slotNumber += 1;
      };
    };
    if Equals(address, "NETdir://ncity.pub") {
      context.stateFilter.active = true;
      journalManager.GetInternetSites(context, entries);
      slotNumber = 1;
      i = 0;
      while i < Min(ArraySize(entries), MAX_ICONS_COUNT) {
        siteEntry = entries[i] as JournalInternetSite;
        if IsDefined(siteEntry) {
          if !siteEntry.IsIgnoredAtDesktop() {
            pageEntry = journalManager.GetMainInternetPage(siteEntry);
            if pageEntry != null {
              pageAddress = pageEntry.GetAddress();
            };
            iconAtlasPath = siteEntry.GetAtlasPath();
            iconTexturePart = siteEntry.GetTexturePart();
            this.SetSlot(slotNumber, siteEntry.GetShortName(), pageAddress, iconAtlasPath, iconTexturePart);
            slotNumber += 1;
          };
        };
        i += 1;
      };
    };
  }

  private final func SetSlot(number: Int32, shortName: String, pageAddress: String, iconAtlasPath: ResRef, iconTexturePart: CName) -> Void {
    let imageRef: inkImageRef;
    let textRef: inkTextRef = this.GetTextRef(this.GetRefName(this.HOME_TEXT_NAME, number));
    if inkWidgetRef.IsValid(textRef) {
      inkWidgetRef.SetVisible(textRef, true);
      inkTextRef.SetText(textRef, shortName);
      this.AddLink(textRef, pageAddress);
    };
    imageRef = this.GetImageRef(this.GetRefName(this.HOME_IMAGE_NAME, number));
    if inkWidgetRef.IsValid(imageRef) {
      inkWidgetRef.SetVisible(imageRef, true);
      inkImageRef.SetAtlasResource(imageRef, iconAtlasPath);
      inkImageRef.SetTexturePart(imageRef, iconTexturePart);
      this.AddLink(imageRef, pageAddress);
    };
  }

  private final func ClearSlot(number: Int32) -> Bool {
    let textRef: inkTextRef = this.GetTextRef(this.GetRefName(this.HOME_TEXT_NAME, number));
    let imageRef: inkImageRef = this.GetImageRef(this.GetRefName(this.HOME_IMAGE_NAME, number));
    if !inkWidgetRef.IsValid(textRef) && inkWidgetRef.IsValid(imageRef) {
      return false;
    };
    if inkWidgetRef.IsValid(textRef) {
      inkWidgetRef.SetVisible(textRef, false);
    };
    if inkWidgetRef.IsValid(imageRef) {
      inkWidgetRef.SetVisible(imageRef, false);
    };
    return true;
  }

  private final func GetRefName(prefix: String, number: Int32) -> CName {
    if number <= 9 {
      return StringToName(prefix + "0" + number);
    };
    return StringToName(prefix + number);
  }

  private final func GetTextRef(instanceName: CName) -> inkTextRef {
    let dummy: inkTextRef;
    let i: Int32 = 0;
    while i < ArraySize(this.m_textList) {
      if Equals(inkWidgetRef.GetName(this.m_textList[i]), instanceName) {
        return this.m_textList[i];
      };
      i += 1;
    };
    return dummy;
  }

  private final func GetImageRef(instanceName: CName) -> inkImageRef {
    let dummy: inkImageRef;
    let i: Int32 = 0;
    while i < ArraySize(this.m_imageList) {
      if Equals(inkWidgetRef.GetName(this.m_imageList[i]), instanceName) {
        return this.m_imageList[i];
      };
      i += 1;
    };
    return dummy;
  }

  private final func FillPageFromJournal(page: wref<JournalInternetPage>) -> Void {
    let images: array<ref<JournalInternetImage>>;
    let instanceName: CName;
    let rectangles: array<ref<JournalInternetRectangle>>;
    let t: Int32;
    let templateImageRef: inkImageRef;
    let templateRectangleRef: inkRectangleRef;
    let templateTextRef: inkTextRef;
    let templateVideoRef: inkVideoRef;
    let videos: array<ref<JournalInternetVideo>>;
    let IGNORED_COLOR: Color = new Color(255u, 255u, 255u, 0u);
    let texts: array<ref<JournalInternetText>> = page.GetTexts();
    let i: Int32 = 0;
    while i < ArraySize(texts) {
      instanceName = texts[i].GetName();
      t = 0;
      while t < ArraySize(this.m_textList) {
        templateTextRef = this.m_textList[t];
        if Equals(inkWidgetRef.GetName(templateTextRef), instanceName) {
          inkTextRef.SetText(templateTextRef, texts[i].GetText());
          if NotEquals(texts[i].GetColor(), IGNORED_COLOR) {
            inkWidgetRef.SetTintColor(templateTextRef, texts[i].GetColor());
          };
          this.AddLink(templateTextRef, texts[i]);
        } else {
          t += 1;
        };
      };
      i += 1;
    };
    rectangles = page.GetRectangles();
    i = 0;
    while i < ArraySize(rectangles) {
      instanceName = rectangles[i].GetName();
      t = 0;
      while t < ArraySize(this.m_rectangleList) {
        templateRectangleRef = this.m_rectangleList[t];
        if Equals(inkWidgetRef.GetName(templateRectangleRef), instanceName) {
          if NotEquals(rectangles[i].GetColor(), IGNORED_COLOR) {
            inkWidgetRef.SetTintColor(templateRectangleRef, rectangles[i].GetColor());
          };
          this.AddLink(templateRectangleRef, rectangles[i]);
        } else {
          t += 1;
        };
      };
      i += 1;
    };
    images = page.GetImages();
    i = 0;
    while i < ArraySize(images) {
      instanceName = images[i].GetName();
      t = 0;
      while t < ArraySize(this.m_imageList) {
        templateImageRef = this.m_imageList[t];
        if Equals(inkWidgetRef.GetName(templateImageRef), instanceName) {
          inkImageRef.SetAtlasResource(templateImageRef, images[i].GetAtlasPath());
          inkImageRef.SetTexturePart(templateImageRef, images[i].GetTexturePart());
          if NotEquals(rectangles[i].GetColor(), IGNORED_COLOR) {
            inkWidgetRef.SetTintColor(templateImageRef, images[i].GetColor());
          };
          this.AddLink(templateImageRef, images[i]);
        } else {
          t += 1;
        };
      };
      i += 1;
    };
    videos = page.GetVideos();
    i = 0;
    while i < ArraySize(videos) {
      instanceName = videos[i].GetName();
      t = 0;
      while t < ArraySize(this.m_videoList) {
        templateVideoRef = this.m_videoList[t];
        if Equals(inkWidgetRef.GetName(templateVideoRef), instanceName) {
          inkVideoRef.SetVideoPath(templateVideoRef, videos[i].GetVideoPath());
          inkVideoRef.Play(templateVideoRef);
          this.AddLink(templateVideoRef, videos[i]);
        } else {
          t += 1;
        };
      };
      i += 1;
    };
  }

  private final func AddLink(widget: inkWidgetRef, address: String) -> Void {
    let linkController: ref<LinkController>;
    if StrLen(address) > 0 {
      if !inkWidgetRef.IsInteractive(widget) {
        Log("Widget [" + NameToString(inkWidgetRef.GetName(widget)) + "] is not set as interactive, it cannot be clicked");
      };
      inkWidgetRef.RegisterToCallback(widget, n"OnRelease", this, n"OnLinkCallback");
      linkController = inkWidgetRef.GetController(widget) as LinkController;
      if IsDefined(linkController) {
        linkController.SetLinkAddress(address);
      } else {
        Log("Missing LinkController for a widget [" + NameToString(inkWidgetRef.GetName(widget)) + "]");
      };
    };
  }

  private final func AddLink(widget: inkWidgetRef, baseElement: ref<JournalInternetBase>) -> Void {
    let linkController: ref<LinkController>;
    let linkAddress: String = baseElement.GetLinkAddress();
    if StrLen(linkAddress) > 0 {
      if !inkWidgetRef.IsInteractive(widget) {
        Log("Widget [" + NameToString(inkWidgetRef.GetName(widget)) + "] is not set as interactive, it cannot be clicked");
      };
      inkWidgetRef.RegisterToCallback(widget, n"OnRelease", this, n"OnLinkCallback");
      linkController = inkWidgetRef.GetController(widget) as LinkController;
      if IsDefined(linkController) {
        linkController.SetLinkAddress(linkAddress);
        linkController.SetColors(baseElement.GetColor(), baseElement.GetHoverColor());
      } else {
        Log("Missing LinkController for a widget [" + NameToString(inkWidgetRef.GetName(widget)) + "]");
      };
    };
  }

  private final func OnLinkCallback(e: ref<inkPointerEvent>) -> Void {
    let linkController: ref<LinkController>;
    if e.IsAction(n"click") {
      linkController = e.GetTarget().GetController() as LinkController;
      if IsDefined(linkController) {
        this.m_lastClickedLinkAddress = linkController.GetLinkAddress();
        this.CallCustomCallback(n"OnLinkPressed");
      } else {
        Log("Missing link controller");
      };
    };
  }

  public final func GetLastLinkClicked() -> String {
    return this.m_lastClickedLinkAddress;
  }
}

public class WebsiteLoadingSpinner extends inkLogicController {

  protected cb func OnInitialize() -> Bool {
    let infiniteloop: inkAnimOptions;
    infiniteloop.loopType = inkanimLoopType.Cycle;
    infiniteloop.loopInfinite = true;
    this.PlayLibraryAnimation(n"loadingLoop", infiniteloop);
  }
}
