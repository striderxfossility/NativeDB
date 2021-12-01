
public class NewsFeedMenuWidgetController extends inkLogicController {

  @attrib(category, "OBSOLETE - Widget Paths")
  @default(NewsFeedMenuWidgetController, banners)
  protected edit let m_bannersListWidgetPath: CName;

  @attrib(category, "Widget Refs")
  protected edit let m_bannersListWidget: inkWidgetRef;

  protected let m_isInitialized: Bool;

  private let m_bannerWidgetsData: array<SBannerWidgetPackage>;

  protected let m_fullBannerWidgetData: SBannerWidgetPackage;

  protected cb func OnInitialize() -> Bool {
    this.m_fullBannerWidgetData.widgetTweakDBID = t"DevicesUIDefinitions.FullBannerWidget";
  }

  public func InitializeBanners(gameController: ref<ComputerInkGameController>, widgetsData: array<SBannerWidgetPackage>) -> Void {
    let i: Int32;
    let widget: ref<inkWidget>;
    this.HideBannerWidgets();
    i = 0;
    while i < ArraySize(widgetsData) {
      widget = this.GetBannerWidget(widgetsData[i], gameController);
      if widget == null {
        widget = this.CreateBannerWidget(gameController, inkWidgetRef.Get(this.m_bannersListWidget), widgetsData[i]);
        this.AddBannerWidget(widget, widgetsData[i], gameController);
      };
      this.InitializeBannerWidget(gameController, widget, widgetsData[i]);
      i += 1;
    };
    this.m_isInitialized = true;
  }

  public final func CreateBannerWidget(gameController: ref<ComputerInkGameController>, parentWidget: wref<inkWidget>, widgetData: SBannerWidgetPackage) -> wref<inkWidget> {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    let widget: ref<inkWidget> = gameController.FindWidgetInLibrary(parentWidget, TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style, widgetData.libraryID, widgetData.libraryPath);
    if widget != null {
      widget.SetSizeRule(inkESizeRule.Stretch);
    };
    return widget;
  }

  protected final func InitializeBannerWidget(gameController: ref<ComputerInkGameController>, widget: ref<inkWidget>, widgetData: SBannerWidgetPackage) -> Void {
    let controller: ref<ComputerBannerWidgetController> = widget.GetController() as ComputerBannerWidgetController;
    if controller != null {
      controller.Initialize(gameController, widgetData);
    };
    widget.SetVisible(true);
  }

  protected final func GetBannerWidget(widgetData: SBannerWidgetPackage, gameController: ref<ComputerInkGameController>) -> wref<inkWidget> {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    widgetData.libraryID = gameController.GetCurrentFullLibraryID(TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style);
    let i: Int32 = 0;
    while i < ArraySize(this.m_bannerWidgetsData) {
      if Equals(this.m_bannerWidgetsData[i].ownerID, widgetData.ownerID) && Equals(this.m_bannerWidgetsData[i].widgetName, widgetData.widgetName) && this.m_bannerWidgetsData[i].widgetTweakDBID == widgetData.widgetTweakDBID && Equals(this.m_bannerWidgetsData[i].libraryPath, widgetData.libraryPath) && Equals(this.m_bannerWidgetsData[i].libraryID, widgetData.libraryID) {
        return this.m_bannerWidgetsData[i].widget;
      };
      i += 1;
    };
    return null;
  }

  protected final func AddBannerWidget(widget: ref<inkWidget>, widgetData: SBannerWidgetPackage, gameController: ref<ComputerInkGameController>) -> wref<inkWidget> {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    widgetData.libraryID = gameController.GetCurrentFullLibraryID(TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style);
    widgetData.widget = widget;
    ArrayPush(this.m_bannerWidgetsData, widgetData);
    return widgetData.widget;
  }

  public final func HideBannerWidgets() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_bannerWidgetsData) {
      if this.m_bannerWidgetsData[i].widget != null {
        this.m_bannerWidgetsData[i].widget.SetVisible(false);
      };
      i += 1;
    };
  }

  public final func ShowFullBanner(gameController: ref<ComputerInkGameController>, widgetData: SBannerWidgetPackage) -> Void {
    let controller: ref<ComputerFullBannerWidgetController>;
    let libraryID: CName;
    let libraryPath: ResRef;
    let screenDef: ScreenDefinitionPackage;
    let widgetRecord: ref<WidgetDefinition_Record>;
    SWidgetPackageBase.ResolveWidgetTweakDBData(this.m_fullBannerWidgetData.widgetTweakDBID, libraryID, libraryPath);
    widgetRecord = TweakDBInterface.GetWidgetDefinitionRecord(this.m_fullBannerWidgetData.widgetTweakDBID);
    if this.m_fullBannerWidgetData.widget == null || NotEquals(this.m_fullBannerWidgetData.libraryID, libraryID) || NotEquals(this.m_fullBannerWidgetData.libraryPath, libraryPath) {
      if this.m_fullBannerWidgetData.widget != null {
        (gameController.GetMainLayoutController().GetMenuContainer() as inkCompoundWidget).RemoveChild(this.m_fullBannerWidgetData.widget);
      };
      screenDef = gameController.GetScreenDefinition();
      this.m_fullBannerWidgetData.widget = gameController.FindWidgetInLibrary(gameController.GetMainLayoutController().GetMenuContainer(), widgetRecord, screenDef.screenDefinition.ComputerScreenType(), screenDef.style, widgetData.libraryID, widgetData.libraryPath);
      this.m_fullBannerWidgetData.libraryPath = libraryPath;
      this.m_fullBannerWidgetData.libraryID = libraryID;
    };
    controller = this.m_fullBannerWidgetData.widget.GetController() as ComputerFullBannerWidgetController;
    if IsDefined(controller) {
      inkWidgetRef.SetVisible(this.m_bannersListWidget, false);
      this.m_fullBannerWidgetData.widget.SetVisible(true);
      controller.Initialize(gameController, widgetData);
    };
  }

  public final func HideFullBanner() -> Void {
    this.m_fullBannerWidgetData.widget.SetVisible(false);
    inkWidgetRef.SetVisible(this.m_bannersListWidget, true);
  }
}
