
public class ComputerMainMenuWidgetController extends inkLogicController {

  @attrib(category, "Widget Refs")
  protected edit let m_menuButtonsListWidget: inkWidgetRef;

  protected let m_isInitialized: Bool;

  private let m_computerMenuButtonWidgetsData: array<SComputerMenuButtonWidgetPackage>;

  public func InitializeMenuButtons(gameController: ref<ComputerInkGameController>, widgetsData: array<SComputerMenuButtonWidgetPackage>) -> Void {
    let i: Int32;
    let widget: ref<inkWidget>;
    this.HideMenuButtonWidgets();
    i = 0;
    while i < ArraySize(widgetsData) {
      widget = this.GetMenuButtonWidget(widgetsData[i], gameController);
      if widget == null {
        widget = this.CreateMenuButtonWidget(gameController, inkWidgetRef.Get(this.m_menuButtonsListWidget), widgetsData[i]);
        this.AddMenuButtonWidget(widget, widgetsData[i], gameController);
      };
      this.InitializeMenuButtonWidget(gameController, widget, widgetsData[i]);
      i += 1;
    };
    this.m_isInitialized = true;
  }

  public final func CreateMenuButtonWidget(gameController: ref<ComputerInkGameController>, parentWidget: wref<inkWidget>, widgetData: SComputerMenuButtonWidgetPackage) -> wref<inkWidget> {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    let widget: ref<inkWidget> = gameController.FindWidgetInLibrary(parentWidget, TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style, widgetData.libraryID, widgetData.libraryPath);
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
