
public class ComputerMenuWidgetController extends inkLogicController {

  @attrib(category, "Widget Refs")
  protected edit let m_thumbnailsListWidget: inkWidgetRef;

  @attrib(category, "Widget Refs")
  protected edit let m_contentWidget: inkWidgetRef;

  protected let m_isInitialized: Bool;

  private let m_fileWidgetsData: array<SDocumentWidgetPackage>;

  private let m_fileThumbnailWidgetsData: array<SDocumentThumbnailWidgetPackage>;

  public func InitializeFiles(gameController: ref<ComputerInkGameController>, widgetsData: array<SDocumentWidgetPackage>) -> Void {
    let i: Int32;
    let widget: ref<inkWidget>;
    this.HideFileWidgets();
    i = 0;
    while i < ArraySize(widgetsData) {
      widget = this.GetFileWidget(widgetsData[i], gameController);
      if widget == null {
        if Equals(widgetsData[i].placement, EWidgetPlacementType.FLOATING) {
          this.CreateDocumentWidgetAsync(gameController, gameController.GetMainLayoutController().GetMenuContainer(), widgetsData[i]);
        } else {
          this.CreateDocumentWidgetAsync(gameController, inkWidgetRef.Get(this.m_contentWidget), widgetsData[i]);
        };
      } else {
        this.InitializeDocumentWidget(gameController, widget, widgetsData[i]);
      };
      i += 1;
    };
    this.m_isInitialized = true;
  }

  public func InitializeFilesThumbnails(gameController: ref<ComputerInkGameController>, widgetsData: array<SDocumentThumbnailWidgetPackage>) -> Void {
    let i: Int32;
    let widget: ref<inkWidget>;
    this.HideFileThumbnailWidgets();
    i = 0;
    while i < ArraySize(widgetsData) {
      widget = this.GetFileThumbnailWidget(widgetsData[i], gameController);
      if widget == null {
        this.CreateDocumentThumbnailWidgetAsync(gameController, inkWidgetRef.Get(this.m_thumbnailsListWidget), widgetsData[i]);
      } else {
        this.InitializeDocumentThumbnailWidget(gameController, widget, widgetsData[i]);
      };
      i += 1;
    };
    this.m_isInitialized = true;
  }

  public final func CreateDocumentWidget(gameController: ref<ComputerInkGameController>, parentWidget: wref<inkWidget>, widgetData: SDocumentWidgetPackage) -> wref<inkWidget> {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    let widget: ref<inkWidget> = gameController.FindWidgetInLibrary(parentWidget, TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style, widgetData.libraryID, widgetData.libraryPath);
    if widget != null {
      widget.SetAnchor(inkEAnchor.Fill);
      widget.SetSizeRule(inkESizeRule.Stretch);
    };
    return widget;
  }

  protected final func CreateDocumentWidgetAsync(gameController: ref<ComputerInkGameController>, parentWidget: wref<inkWidget>, widgetData: SDocumentWidgetPackage) -> Void {
    let screenDef: ScreenDefinitionPackage;
    let spawnData: ref<AsyncSpawnData>;
    if this.HasFileWidgetData(widgetData, gameController) {
      return;
    };
    screenDef = gameController.GetScreenDefinition();
    spawnData = new AsyncSpawnData();
    spawnData.Initialize(this, n"OnDocumentWidgetSpawned", ToVariant(widgetData), gameController);
    widgetData.libraryID = gameController.RequestWidgetFromLibrary(parentWidget, TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style, widgetData.libraryID, widgetData.libraryPath, spawnData);
    this.AddFileWidgetData(widgetData, gameController);
  }

  protected cb func OnDocumentWidgetSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let deviceGameController: ref<ComputerInkGameController>;
    let spawnData: ref<AsyncSpawnData>;
    let widgetData: SDocumentWidgetPackage;
    if widget != null {
      widget.SetAnchor(inkEAnchor.Fill);
      widget.SetSizeRule(inkESizeRule.Stretch);
    };
    spawnData = userData as AsyncSpawnData;
    if spawnData != null {
      deviceGameController = spawnData.m_controller as ComputerInkGameController;
      widgetData = FromVariant(spawnData.m_widgetData);
      if deviceGameController != null {
        widgetData.widget = widget;
        widgetData.libraryID = spawnData.m_libraryID;
        this.UpdateFileWidgetData(widgetData, this.GetFileWidgetDataIndex(widgetData, deviceGameController));
        this.InitializeDocumentWidget(deviceGameController, widget, widgetData);
      };
    };
  }

  protected final func AddFileWidgetData(widgetData: SDocumentWidgetPackage, gameController: ref<DeviceInkGameControllerBase>) -> Void {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    widgetData.libraryID = gameController.GetCurrentFullLibraryID(TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style);
    ArrayPush(this.m_fileWidgetsData, widgetData);
  }

  protected final func UpdateFileWidgetData(widgetData: SDocumentWidgetPackage, index: Int32) -> Void {
    if index >= 0 && index < ArraySize(this.m_fileWidgetsData) {
      this.m_fileWidgetsData[index] = widgetData;
    };
  }

  protected final func InitializeDocumentWidget(gameController: ref<ComputerInkGameController>, widget: ref<inkWidget>, widgetData: SDocumentWidgetPackage) -> Void {
    let controller: ref<ComputerDocumentWidgetController> = widget.GetController() as ComputerDocumentWidgetController;
    if controller != null {
      controller.Initialize(gameController, widgetData);
    };
    widget.SetVisible(true);
  }

  protected final func GetFileWidgetDataIndex(widgetData: SDocumentWidgetPackage, gameController: ref<DeviceInkGameControllerBase>) -> Int32 {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    widgetData.libraryID = gameController.GetCurrentFullLibraryID(TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style);
    let i: Int32 = 0;
    while i < ArraySize(this.m_fileWidgetsData) {
      if Equals(this.m_fileWidgetsData[i].ownerID, widgetData.ownerID) && Equals(this.m_fileWidgetsData[i].widgetName, widgetData.widgetName) && this.m_fileWidgetsData[i].widgetTweakDBID == widgetData.widgetTweakDBID && Equals(this.m_fileWidgetsData[i].libraryPath, widgetData.libraryPath) && Equals(this.m_fileWidgetsData[i].libraryID, widgetData.libraryID) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  protected final func HasFileWidgetData(widgetData: SDocumentWidgetPackage, gameController: ref<DeviceInkGameControllerBase>) -> Bool {
    return this.GetFileWidgetDataIndex(widgetData, gameController) >= 0;
  }

  protected final func GetFileWidget(widgetData: SDocumentWidgetPackage, gameController: ref<ComputerInkGameController>) -> wref<inkWidget> {
    let index: Int32 = this.GetFileWidgetDataIndex(widgetData, gameController);
    if index >= 0 && index < ArraySize(this.m_fileWidgetsData) {
      return this.m_fileWidgetsData[index].widget;
    };
    return null;
  }

  protected final func AddFileWidget(widget: ref<inkWidget>, widgetData: SDocumentWidgetPackage, gameController: ref<ComputerInkGameController>) -> wref<inkWidget> {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    widgetData.libraryID = gameController.GetCurrentFullLibraryID(TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style);
    widgetData.widget = widget;
    ArrayPush(this.m_fileWidgetsData, widgetData);
    return widgetData.widget;
  }

  public final func HideFileWidgets() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_fileWidgetsData) {
      if this.m_fileWidgetsData[i].widget != null {
        this.m_fileWidgetsData[i].widget.SetVisible(false);
      };
      i += 1;
    };
  }

  public final func CreateDocumentThumbnailWidget(gameController: ref<ComputerInkGameController>, parentWidget: wref<inkWidget>, widgetData: SDocumentThumbnailWidgetPackage) -> wref<inkWidget> {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    let widget: ref<inkWidget> = gameController.FindWidgetInLibrary(parentWidget, TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style, widgetData.libraryID, widgetData.libraryPath);
    return widget;
  }

  protected final func CreateDocumentThumbnailWidgetAsync(gameController: ref<ComputerInkGameController>, parentWidget: wref<inkWidget>, widgetData: SDocumentThumbnailWidgetPackage) -> Void {
    let screenDef: ScreenDefinitionPackage;
    let spawnData: ref<AsyncSpawnData>;
    if this.HasFileThumbnailWidgetData(widgetData, gameController) {
      return;
    };
    screenDef = gameController.GetScreenDefinition();
    spawnData = new AsyncSpawnData();
    spawnData.Initialize(this, n"OnDocumentThumbnailWidgetSpawned", ToVariant(widgetData), gameController);
    widgetData.libraryID = gameController.RequestWidgetFromLibrary(parentWidget, TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style, widgetData.libraryID, widgetData.libraryPath, spawnData);
    this.AddFileThumbnailWidgetData(widgetData, gameController);
  }

  protected cb func OnDocumentThumbnailWidgetSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let deviceGameController: ref<ComputerInkGameController>;
    let spawnData: ref<AsyncSpawnData>;
    let widgetData: SDocumentThumbnailWidgetPackage;
    if widget != null {
      widget.SetHAlign(inkEHorizontalAlign.Fill);
    };
    spawnData = userData as AsyncSpawnData;
    if spawnData != null {
      deviceGameController = spawnData.m_controller as ComputerInkGameController;
      widgetData = FromVariant(spawnData.m_widgetData);
      if deviceGameController != null {
        widgetData.widget = widget;
        widgetData.libraryID = spawnData.m_libraryID;
        this.UpdateFileThumbnailWidgetData(widgetData, this.GetFileThumbnailWidgetDataIndex(widgetData, deviceGameController));
        this.InitializeDocumentThumbnailWidget(deviceGameController, widget, widgetData);
      };
    };
  }

  protected final func AddFileThumbnailWidgetData(widgetData: SDocumentThumbnailWidgetPackage, gameController: ref<DeviceInkGameControllerBase>) -> Void {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    widgetData.libraryID = gameController.GetCurrentFullLibraryID(TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style);
    ArrayPush(this.m_fileThumbnailWidgetsData, widgetData);
  }

  protected final func UpdateFileThumbnailWidgetData(widgetData: SDocumentThumbnailWidgetPackage, index: Int32) -> Void {
    if index >= 0 && index < ArraySize(this.m_fileThumbnailWidgetsData) {
      this.m_fileThumbnailWidgetsData[index] = widgetData;
    };
  }

  protected final func InitializeDocumentThumbnailWidget(gameController: ref<ComputerInkGameController>, widget: ref<inkWidget>, widgetData: SDocumentThumbnailWidgetPackage) -> Void {
    let controller: ref<ComputerDocumentThumbnailWidgetController> = widget.GetController() as ComputerDocumentThumbnailWidgetController;
    if controller != null {
      controller.Initialize(gameController, widgetData);
      controller.ToggleSelection(widgetData.isOpened);
      if widgetData.isOpened {
        if Equals(widgetData.documentType, EDocumentType.MAIL) {
          gameController.RequestMailWidgetUpdate(widgetData.documentAdress);
        } else {
          if Equals(widgetData.documentType, EDocumentType.FILE) {
            gameController.RequestFileWidgetUpdate(widgetData.documentAdress);
          };
        };
      };
    };
    widget.SetVisible(true);
  }

  protected final func HasFileThumbnailWidgetData(widgetData: SDocumentThumbnailWidgetPackage, gameController: ref<DeviceInkGameControllerBase>) -> Bool {
    return this.GetFileThumbnailWidgetDataIndex(widgetData, gameController) >= 0;
  }

  protected final func GetFileThumbnailWidgetDataIndex(widgetData: SDocumentThumbnailWidgetPackage, gameController: ref<DeviceInkGameControllerBase>) -> Int32 {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    widgetData.libraryID = gameController.GetCurrentFullLibraryID(TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style);
    let i: Int32 = 0;
    while i < ArraySize(this.m_fileThumbnailWidgetsData) {
      if Equals(this.m_fileThumbnailWidgetsData[i].ownerID, widgetData.ownerID) && Equals(this.m_fileThumbnailWidgetsData[i].widgetName, widgetData.widgetName) && this.m_fileThumbnailWidgetsData[i].widgetTweakDBID == widgetData.widgetTweakDBID && Equals(this.m_fileThumbnailWidgetsData[i].libraryPath, widgetData.libraryPath) && Equals(this.m_fileThumbnailWidgetsData[i].libraryID, widgetData.libraryID) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  protected final func GetFileThumbnailWidget(widgetData: SDocumentThumbnailWidgetPackage, gameController: ref<ComputerInkGameController>) -> wref<inkWidget> {
    let index: Int32 = this.GetFileThumbnailWidgetDataIndex(widgetData, gameController);
    if index >= 0 && index < ArraySize(this.m_fileThumbnailWidgetsData) {
      return this.m_fileThumbnailWidgetsData[index].widget;
    };
    return null;
  }

  protected final func AddFileThumbnailWidget(widget: ref<inkWidget>, widgetData: SDocumentThumbnailWidgetPackage, gameController: ref<ComputerInkGameController>) -> wref<inkWidget> {
    let screenDef: ScreenDefinitionPackage = gameController.GetScreenDefinition();
    widgetData.libraryID = gameController.GetCurrentFullLibraryID(TweakDBInterface.GetWidgetDefinitionRecord(widgetData.widgetTweakDBID), screenDef.screenDefinition.ComputerScreenType(), screenDef.style);
    widgetData.widget = widget;
    ArrayPush(this.m_fileThumbnailWidgetsData, widgetData);
    return widgetData.widget;
  }

  public final func HideFileThumbnailWidgets() -> Void {
    let currentController: ref<ComputerDocumentThumbnailWidgetController>;
    let i: Int32;
    this.HideFileWidgets();
    i = 0;
    while i < ArraySize(this.m_fileThumbnailWidgetsData) {
      if this.m_fileThumbnailWidgetsData[i].widget != null {
        currentController = this.m_fileThumbnailWidgetsData[i].widget.GetController() as ComputerDocumentThumbnailWidgetController;
        this.m_fileThumbnailWidgetsData[i].widget.SetVisible(false);
        if IsDefined(currentController) {
          currentController.ToggleSelection(false);
        };
      };
      i += 1;
    };
  }

  public final func GetThumbnailController(adress: SDocumentAdress) -> ref<ComputerDocumentThumbnailWidgetController> {
    let currentAdress: SDocumentAdress;
    let currentController: ref<ComputerDocumentThumbnailWidgetController>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_fileThumbnailWidgetsData) {
      if this.m_fileThumbnailWidgetsData[i].widget != null {
        currentController = this.m_fileThumbnailWidgetsData[i].widget.GetController() as ComputerDocumentThumbnailWidgetController;
        currentAdress = currentController.GetDocumentAdress();
        if IsDefined(currentController) && currentAdress == adress {
        } else {
          currentController = null;
          i += 1;
        };
      } else {
      };
      i += 1;
    };
    return currentController;
  }

  public final func MarkThumbnailAsSelected(adress: SDocumentAdress) -> Void {
    let currentAdress: SDocumentAdress;
    let currentController: ref<ComputerDocumentThumbnailWidgetController>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_fileThumbnailWidgetsData) {
      if this.m_fileThumbnailWidgetsData[i].widget != null {
        currentController = this.m_fileThumbnailWidgetsData[i].widget.GetController() as ComputerDocumentThumbnailWidgetController;
        currentAdress = currentController.GetDocumentAdress();
        if IsDefined(currentController) && currentAdress == adress {
          currentController.ToggleSelection(true);
        } else {
          currentController.ToggleSelection(false);
        };
      };
      i += 1;
    };
  }

  public final func MarkThumbnailAsSelected(controller: ref<ComputerDocumentThumbnailWidgetController>) -> Void {
    let currentController: ref<ComputerDocumentThumbnailWidgetController>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_fileThumbnailWidgetsData) {
      if this.m_fileThumbnailWidgetsData[i].widget != null {
        currentController = this.m_fileThumbnailWidgetsData[i].widget.GetController() as ComputerDocumentThumbnailWidgetController;
        if IsDefined(currentController) && currentController == controller {
          currentController.ToggleSelection(true);
        } else {
          currentController.ToggleSelection(false);
        };
      };
      i += 1;
    };
  }
}
