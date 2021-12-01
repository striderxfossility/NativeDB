
public class SaveGameMenuGameController extends gameuiSaveHandlingController {

  private edit let m_list: inkCompoundRef;

  private edit let m_buttonHintsManagerRef: inkWidgetRef;

  private let m_eventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_loadComplete: Bool;

  private let m_handler: wref<inkISystemRequestsHandler>;

  private let m_saveInfo: ref<SaveMetadataInfo>;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_hasEmptySlot: Bool;

  private let m_saveInProgress: Bool;

  protected cb func OnInitialize() -> Bool {
    this.m_handler = this.GetSystemRequestsHandler();
    this.m_handler.RegisterToCallback(n"OnSavesReady", this, n"OnSavesReady");
    this.m_handler.RegisterToCallback(n"OnSaveMetadataReady", this, n"OnSaveMetadataReady");
    this.m_handler.RegisterToCallback(n"OnSaveDeleted", this, n"OnSaveDeleted");
    this.m_handler.RegisterToCallback(n"OnSavingComplete", this, n"OnSavingComplete");
    this.m_handler.RequestSavesForSave();
    inkCompoundRef.RemoveAllChildren(this.m_list);
    this.m_hasEmptySlot = false;
    this.PlayLibraryAnimation(n"intro");
    this.m_buttonHintsController = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsManagerRef), r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root").GetController() as ButtonHints;
    this.m_buttonHintsController.AddButtonHint(n"back", GetLocalizedText("Common-Access-Close"));
    this.m_buttonHintsController.AddButtonHint(n"delete_save", GetLocalizedText("UI-Menus-DeleteSave"));
    this.m_buttonHintsController.AddButtonHint(n"select", GetLocalizedText("UI-UserActions-Select"));
  }

  protected cb func OnUninitialize() -> Bool {
    this.GetSystemRequestsHandler().CancelSavedGameScreenshotRequests();
  }

  private final func TryToCreateEmptySlot() -> Void {
    let currButton: wref<inkCompoundWidget>;
    let currLogic: wref<LoadListItem>;
    if this.m_hasEmptySlot {
      return;
    };
    if !this.m_handler.HasFreeSaveSlot("ManualSave-") {
      return;
    };
    currButton = this.SpawnFromLocal(inkWidgetRef.Get(this.m_list), n"LoadListItem") as inkCompoundWidget;
    currButton.RegisterToCallback(n"OnRelease", this, n"OnSaveFile");
    inkCompoundRef.ReorderChild(this.m_list, currButton, 0);
    currLogic = currButton.GetController() as LoadListItem;
    currLogic.SetData(-1, true);
    this.m_hasEmptySlot = true;
  }

  private final func SetupLoadItems(saves: array<String>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(saves) {
      this.CreateLoadItem(i, saves[i]);
      i += 1;
    };
  }

  private final func CreateLoadItem(index: Int32, label: String) -> Void {
    let currLogic: wref<LoadListItem>;
    let currButton: wref<inkCompoundWidget> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_list), n"LoadListItem") as inkCompoundWidget;
    currButton.RegisterToCallback(n"OnRelease", this, n"OnSaveFile");
    currLogic = currButton.GetController() as LoadListItem;
    currLogic.SetData(index);
    this.GetSystemRequestsHandler().RequestSavedGameScreenshot(index, currLogic.GetPreviewImageWidget());
  }

  protected cb func OnSaveFile(e: ref<inkPointerEvent>) -> Bool {
    let button: wref<inkWidget>;
    let controller: wref<LoadListItem>;
    if !this.m_loadComplete || this.m_saveInProgress || this.IsSaveFailedNotificationActive() || this.IsGameSavedNotificationActive() {
      this.PlaySound(n"Button", n"OnPress");
      return false;
    };
    if e.IsAction(n"click") {
      button = e.GetCurrentTarget();
      controller = button.GetController() as LoadListItem;
      this.PlaySound(n"Button", n"OnPress");
      if controller.EmptySlot() {
        this.m_saveInProgress = true;
        this.GetSystemRequestsHandler().ManualSave("ManualSave-");
      } else {
        this.OverrideSavedGame(controller.Index());
      };
      return true;
    };
    if e.IsAction(n"delete_save") {
      button = e.GetCurrentTarget();
      controller = button.GetController() as LoadListItem;
      if !controller.EmptySlot() {
        this.PlaySound(n"SaveDeleteButton", n"OnPress");
        this.DeleteSavedGame(controller.Index());
      } else {
        this.PlaySound(n"SaveDeleteButton", n"OnPress");
      };
      return true;
    };
  }

  protected cb func OnSaveDeleted(result: Bool, idx: Int32) -> Bool {
    let button: wref<inkWidget>;
    let controller: wref<LoadListItem>;
    let i: Int32;
    if result {
      i = 0;
      while i < inkCompoundRef.GetNumChildren(this.m_list) {
        button = inkCompoundRef.GetWidgetByIndex(this.m_list, i);
        controller = button.GetController() as LoadListItem;
        if controller.Index() == idx {
          inkCompoundRef.RemoveChild(this.m_list, button);
        } else {
          i += 1;
        };
      };
      this.TryToCreateEmptySlot();
    };
  }

  protected cb func OnOverrideSaveAccepted() -> Bool {
    this.m_saveInProgress = true;
  }

  protected cb func OnSavingComplete(success: Bool, locks: array<gameSaveLock>) -> Bool {
    if success {
      this.m_handler.RequestSavesForSave();
      this.RequestGameSavedNotification();
    } else {
      this.ShowSavingLockedNotification(locks);
      this.RequestSaveFailedNotification();
    };
    this.m_saveInProgress = false;
  }

  protected cb func OnSavesReady(saves: array<String>) -> Bool {
    inkCompoundRef.RemoveAllChildren(this.m_list);
    this.m_hasEmptySlot = false;
    this.TryToCreateEmptySlot();
    this.SetupLoadItems(saves);
    this.m_loadComplete = true;
  }

  protected cb func OnSaveMetadataReady(info: ref<SaveMetadataInfo>) -> Bool {
    let button: wref<inkWidget>;
    let controller: wref<LoadListItem>;
    let i: Int32 = 0;
    while i < inkCompoundRef.GetNumChildren(this.m_list) {
      button = inkCompoundRef.GetWidgetByIndex(this.m_list, i);
      controller = button.GetController() as LoadListItem;
      if controller.Index() == info.saveIndex {
        if info.isValid {
          controller.SetMetadata(info);
        } else {
          controller.SetInvalid(info.internalName);
        };
      } else {
        i += 1;
      };
    };
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_eventDispatcher = menuEventDispatcher;
  }
}
