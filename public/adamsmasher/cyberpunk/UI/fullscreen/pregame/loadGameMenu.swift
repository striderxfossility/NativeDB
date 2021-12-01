
public native class gameuiSaveHandlingController extends gameuiMenuGameController {

  public final native func DeleteSavedGame(saveId: Int32) -> Void;

  public final native func RequestSaveFailedNotification() -> Void;

  public final native func RequestGameSavedNotification() -> Void;

  public final native func IsSaveFailedNotificationActive() -> Bool;

  public final native func IsGameSavedNotificationActive() -> Bool;

  public final native func LoadSaveInGame(saveId: Int32) -> Void;

  public final native func OverrideSavedGame(saveId: Int32) -> Void;

  public final native func SetNextInitialLoadingScreen(tweakID: Uint64) -> Void;

  public final native func PreSpawnInitialLoadingScreen(tweakID: Uint64) -> Void;

  public final func ShowSavingLockedNotification(const locks: script_ref<array<gameSaveLock>>) -> Void {
    GameInstance.GetUISystem(this.GetPlayerControlledObject().GetGame()).QueueEvent(new UIInGameNotificationRemoveEvent());
    GameInstance.GetUISystem(this.GetPlayerControlledObject().GetGame()).QueueEvent(UIInGameNotificationEvent.CreateSavingLockedEvent(locks));
  }
}

public class LoadGameMenuGameController extends gameuiSaveHandlingController {

  private edit let m_list: inkCompoundRef;

  private edit let m_buttonHintsManagerRef: inkWidgetRef;

  private edit let m_transitToLoadingAnimName: CName;

  private edit let m_transitToLoadingSlotAnimName: CName;

  private edit let m_animDelayBetweenSlots: Float;

  private edit let m_animDelayForMainSlot: Float;

  private edit let m_enableLoadingTransition: Bool;

  private let m_eventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_loadComplete: Bool;

  private let m_saveInfo: ref<SaveMetadataInfo>;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_saveToLoadIndex: Int32;

  private let m_isInputDisabled: Bool;

  protected cb func OnInitialize() -> Bool {
    let handler: wref<inkISystemRequestsHandler> = this.GetSystemRequestsHandler();
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
    handler.RegisterToCallback(n"OnSavesReady", this, n"OnSavesReady");
    handler.RegisterToCallback(n"OnSaveMetadataReady", this, n"OnSaveMetadataReady");
    handler.RegisterToCallback(n"OnSaveDeleted", this, n"OnSaveDeleted");
    handler.RequestSavesForLoad();
    inkCompoundRef.RemoveAllChildren(this.m_list);
    this.PlayLibraryAnimation(n"intro");
    this.m_buttonHintsController = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsManagerRef), r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root").GetController() as ButtonHints;
    this.m_buttonHintsController.AddButtonHint(n"back", GetLocalizedText("Common-Access-Close"));
    this.m_buttonHintsController.AddButtonHint(n"delete_save", GetLocalizedText("UI-Menus-DeleteSave"));
    this.m_buttonHintsController.AddButtonHint(n"select", GetLocalizedText("UI-UserActions-Select"));
    this.m_isInputDisabled = false;
  }

  protected cb func OnUninitialize() -> Bool {
    this.GetSystemRequestsHandler().CancelSavedGameScreenshotRequests();
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
  }

  protected cb func OnButtonRelease(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"back") {
      this.m_eventDispatcher.SpawnEvent(n"OnMainMenuBack");
    };
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
    currButton.RegisterToCallback(n"OnRelease", this, n"OnRelease");
    currLogic = currButton.GetController() as LoadListItem;
    currLogic.SetData(index);
    this.GetSystemRequestsHandler().RequestSavedGameScreenshot(index, currLogic.GetPreviewImageWidget());
  }

  protected cb func OnRelease(e: ref<inkPointerEvent>) -> Bool {
    let button: wref<inkWidget>;
    let controller: wref<LoadListItem>;
    if !this.m_isInputDisabled {
      if e.IsAction(n"click") && Equals(this.m_loadComplete, true) {
        button = e.GetCurrentTarget();
        controller = button.GetController() as LoadListItem;
        if controller.ValidSlot() {
          if this.GetSystemRequestsHandler().IsPreGame() {
            this.LoadGameMainMenu(controller);
          } else {
            this.LoadSaveInGame(controller.Index());
          };
        };
        this.PlaySound(n"Button", n"OnPress");
      };
      if e.IsAction(n"delete_save") && Equals(this.m_loadComplete, true) {
        button = e.GetCurrentTarget();
        controller = button.GetController() as LoadListItem;
        this.PlaySound(n"SaveDeleteButton", n"OnPress");
        this.DeleteSavedGame(controller.Index());
      };
    };
  }

  private final func LoadGameMainMenu(controller: ref<LoadListItem>) -> Void {
    let animOptions: inkAnimOptions;
    let animProxy: ref<inkAnimProxy>;
    this.PreSpawnInitialLoadingScreen(controller.GetInitialLoadingID());
    animProxy = this.PlayLibraryAnimation(this.m_transitToLoadingAnimName, animOptions);
    if this.m_enableLoadingTransition {
      this.PlayTransitionAnimOnButtons(controller.Index());
      animProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnTransitionFinished");
      this.m_saveToLoadIndex = controller.Index();
      this.m_isInputDisabled = true;
    } else {
      this.LoadSaveInGame(controller.Index());
    };
  }

  private final func PlayTransitionAnimOnButtons(sourceIndex: Int32) -> Void {
    let i: Int32 = 0;
    while i < sourceIndex {
      this.PlayTransitionAnimOnButton(i, sourceIndex - i);
      i += 1;
    };
    i = sourceIndex + 1;
    while i < inkCompoundRef.GetNumChildren(this.m_list) {
      this.PlayTransitionAnimOnButton(i, i - sourceIndex);
      i += 1;
    };
    this.PlayTransitionAnimOnButton(sourceIndex, this.m_animDelayForMainSlot);
  }

  private final func PlayTransitionAnimOnButton(index: Int32, distanceFromSource: Int32) -> Void {
    this.PlayTransitionAnimOnButton(index, this.m_animDelayBetweenSlots * Cast(distanceFromSource));
  }

  private final func PlayTransitionAnimOnButton(index: Int32, delay: Float) -> Void {
    let animOptions: inkAnimOptions;
    animOptions.executionDelay = delay;
    let targetWidget: wref<inkWidget> = inkCompoundRef.GetWidgetByIndex(this.m_list, index);
    targetWidget.GetController().PlayLibraryAnimation(this.m_transitToLoadingSlotAnimName, animOptions);
  }

  protected cb func OnTransitionFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.LoadSaveInGame(this.m_saveToLoadIndex);
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
    };
  }

  protected cb func OnSavesReady(saves: array<String>) -> Bool {
    let savesCount: Int32;
    this.SetupLoadItems(saves);
    savesCount = ArraySize(saves);
    if savesCount > 0 {
      this.m_loadComplete = true;
    };
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

public class LoadListItem extends AnimatedListItemController {

  private edit let m_imageReplacement: inkImageRef;

  private edit let m_label: inkTextRef;

  private edit let m_labelDate: inkTextRef;

  private edit let m_type: inkTextRef;

  private edit let m_quest: inkTextRef;

  private edit let m_level: inkTextRef;

  private edit let m_lifepath: inkImageRef;

  private edit let m_playTime: inkTextRef;

  private edit let m_characterLevel: inkTextRef;

  private edit let m_characterLevelLabel: inkTextRef;

  private edit let m_gameVersion: inkTextRef;

  private edit let m_emptySlotWrapper: inkWidgetRef;

  private edit let m_wrapper: inkWidgetRef;

  private let m_versionParams: ref<inkTextParams>;

  private let m_index: Int32;

  private let m_emptySlot: Bool;

  private let m_validSlot: Bool;

  private let m_initialLoadingID: Uint64;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
    super.OnInitialize();
    this.m_validSlot = true;
    inkWidgetRef.SetVisible(this.m_emptySlotWrapper, false);
    inkWidgetRef.SetVisible(this.m_wrapper, false);
    inkWidgetRef.SetVisible(this.m_label, false);
    inkWidgetRef.SetVisible(this.m_labelDate, false);
    inkWidgetRef.SetVisible(this.m_type, false);
    inkWidgetRef.SetVisible(this.m_playTime, false);
    inkWidgetRef.SetVisible(this.m_lifepath, false);
    inkWidgetRef.SetVisible(this.m_level, false);
    inkWidgetRef.SetVisible(this.m_quest, false);
    inkWidgetRef.SetVisible(this.m_characterLevel, false);
    inkWidgetRef.SetVisible(this.m_characterLevelLabel, false);
    inkWidgetRef.SetVisible(this.m_gameVersion, false);
    this.m_versionParams = new inkTextParams();
    this.m_versionParams.AddString("version_num", "--");
    inkTextRef.SetLocalizedText(this.m_gameVersion, n"UI-Settings-Audio-GameVersion", this.m_versionParams);
  }

  public final func SetMetadata(metadata: ref<SaveMetadataInfo>) -> Void {
    let hrs: Int32;
    let lvl: Int32;
    let mins: Int32;
    let playthroughTime: Float;
    let shrs: String;
    let smins: String;
    inkWidgetRef.SetVisible(this.m_wrapper, true);
    inkWidgetRef.SetVisible(this.m_label, true);
    inkWidgetRef.SetVisible(this.m_labelDate, true);
    inkWidgetRef.SetVisible(this.m_type, true);
    inkWidgetRef.SetVisible(this.m_playTime, true);
    inkWidgetRef.SetVisible(this.m_imageReplacement, true);
    inkWidgetRef.SetVisible(this.m_lifepath, true);
    inkWidgetRef.SetVisible(this.m_level, true);
    inkWidgetRef.SetVisible(this.m_quest, true);
    inkWidgetRef.SetVisible(this.m_characterLevel, true);
    inkWidgetRef.SetVisible(this.m_characterLevelLabel, true);
    inkWidgetRef.SetVisible(this.m_gameVersion, true);
    inkTextRef.SetText(this.m_label, metadata.trackedQuest);
    inkTextRef.SetText(this.m_quest, metadata.internalName);
    inkTextRef.SetText(this.m_type, metadata.locationName);
    this.m_versionParams.UpdateString("version_num", metadata.gameVersion);
    this.m_initialLoadingID = metadata.initialLoadingScreenID;
    playthroughTime = MaxF(Cast(metadata.playthroughTime), Cast(metadata.playTime));
    hrs = RoundF(playthroughTime / 3600.00);
    mins = RoundF((playthroughTime % 3600.00) / 60.00);
    if hrs > 9 {
      shrs = ToString(hrs);
    } else {
      shrs = "0" + ToString(hrs);
    };
    if mins > 9 {
      smins = ToString(mins);
    } else {
      smins = "0" + ToString(mins);
    };
    inkTextRef.SetText(this.m_playTime, shrs + ":" + smins);
    inkTextRef.SetDateTimeByTimestamp(this.m_labelDate, metadata.timestamp);
    lvl = RoundF(Cast(metadata.level));
    inkTextRef.SetText(this.m_characterLevel, ToString(lvl));
    if lvl == 0 {
      inkWidgetRef.SetVisible(this.m_characterLevel, false);
      inkWidgetRef.SetVisible(this.m_characterLevelLabel, false);
    };
    if Equals(metadata.lifePath, inkLifePath.Corporate) {
      inkImageRef.SetTexturePart(this.m_lifepath, n"LifepathCorpo1");
      inkTextRef.SetText(this.m_level, "Gameplay-LifePaths-Corporate");
    };
    if Equals(metadata.lifePath, inkLifePath.Nomad) {
      inkImageRef.SetTexturePart(this.m_lifepath, n"LifepathNomad1");
      inkTextRef.SetText(this.m_level, "Gameplay-LifePaths-Nomad");
    };
    if Equals(metadata.lifePath, inkLifePath.StreetKid) {
      inkImageRef.SetTexturePart(this.m_lifepath, n"LifepathStreetKid1");
      inkTextRef.SetText(this.m_level, "Gameplay-LifePaths-Streetkid");
    };
  }

  public final func SetInvalid(label: String) -> Void {
    this.m_validSlot = false;
    inkWidgetRef.SetVisible(this.m_wrapper, true);
    inkWidgetRef.SetVisible(this.m_label, true);
    inkWidgetRef.SetVisible(this.m_quest, true);
    inkTextRef.SetText(this.m_label, "UI-Menus-Saving-CorruptedSaveTitle");
    inkTextRef.SetText(this.m_quest, label);
  }

  public final func SetData(index: Int32, opt emptySlot: Bool) -> Void {
    this.m_index = index;
    if emptySlot {
      this.m_emptySlot = true;
      inkWidgetRef.SetVisible(this.m_wrapper, false);
      inkWidgetRef.SetVisible(this.m_emptySlotWrapper, true);
    } else {
      inkWidgetRef.SetVisible(this.m_wrapper, false);
      inkWidgetRef.SetVisible(this.m_emptySlotWrapper, false);
    };
  }

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    this.PlayLibraryAnimation(n"pause_button_hover_over_anim");
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    this.PlayLibraryAnimation(n"pause_button_hover_out_anim");
  }

  public final func Index() -> Int32 {
    return this.m_index;
  }

  public final func EmptySlot() -> Bool {
    return this.m_emptySlot;
  }

  public final func ValidSlot() -> Bool {
    return this.m_validSlot;
  }

  public final func GetInitialLoadingID() -> Uint64 {
    return this.m_initialLoadingID;
  }

  public final func GetPreviewImageWidget() -> wref<inkImage> {
    return inkWidgetRef.Get(this.m_imageReplacement) as inkImage;
  }
}
