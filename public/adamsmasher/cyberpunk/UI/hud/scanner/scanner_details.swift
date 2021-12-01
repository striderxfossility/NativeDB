
public class scannerDetailsGameController extends inkHUDGameController {

  private edit let m_scannerCountainer: inkCompoundRef;

  private edit let m_quickhackContainer: inkCompoundRef;

  private edit let m_cluesContainer: inkCompoundRef;

  private edit let m_bg: inkWidgetRef;

  private edit let m_toggleDescirptionHackPart: inkWidgetRef;

  private edit let m_toggleDescriptionScanIcon: inkWidgetRef;

  private edit let m_fitToContentBackground: inkWidgetRef;

  private edit let m_kiroshiLogo: inkWidgetRef;

  private let m_player: wref<GameObject>;

  private let m_gameInstance: GameInstance;

  private let m_objectTypeCallbackID: ref<CallbackHandle>;

  private let m_uiScannerChunkBlackboard: wref<IBlackboard>;

  private let m_scanningState: gameScanningState;

  private let m_scanStatusCallbackID: ref<CallbackHandle>;

  private let m_scanObjectCallbackID: ref<CallbackHandle>;

  private let m_uiBlackboard: wref<IBlackboard>;

  private let m_quickSlotsBoard: wref<IBlackboard>;

  private let m_quickSlotsCallbackID: ref<CallbackHandle>;

  private let m_quickhackStartedCallbackID: ref<CallbackHandle>;

  private let m_scannedObjectType: ScannerObjectType;

  private let m_showScanAnimProxy: ref<inkAnimProxy>;

  private let m_hideScanAnimProxy: ref<inkAnimProxy>;

  private let m_toggleScanDescriptionAnimProxy: ref<inkAnimProxy>;

  private let m_previousToggleAnimName: CName;

  private let m_hasHacks: Bool;

  private let m_lastScannedObject: EntityID;

  @default(scannerDetailsGameController, true)
  private let m_isDescriptionVisible: Bool;

  private let m_asyncSpawnRequests: array<wref<inkAsyncSpawnRequest>>;

  protected cb func OnInitialize() -> Bool {
    this.GetRootWidget().SetVisible(false);
    this.m_uiBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Scanner);
    this.m_uiScannerChunkBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_ScannerModules);
    this.m_quickSlotsBoard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    if IsDefined(this.m_uiBlackboard) {
      this.m_scanStatusCallbackID = this.m_uiBlackboard.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_Scanner.CurrentState, this, n"OnStateChanged");
      this.m_scanObjectCallbackID = this.m_uiBlackboard.RegisterDelayedListenerEntityID(GetAllBlackboardDefs().UI_Scanner.ScannedObject, this, n"OnScannedObjectChanged");
    };
    if IsDefined(this.m_uiScannerChunkBlackboard) {
      this.m_objectTypeCallbackID = this.m_uiScannerChunkBlackboard.RegisterDelayedListenerInt(GetAllBlackboardDefs().UI_ScannerModules.ObjectType, this, n"OnObjectTypeChanged");
    };
    if IsDefined(this.m_quickSlotsBoard) {
      this.m_quickSlotsCallbackID = this.m_quickSlotsBoard.RegisterDelayedListenerBool(GetAllBlackboardDefs().UI_QuickSlotsData.quickHackDescritpionVisible, this, n"OnQHDescriptionChanged");
      this.m_quickhackStartedCallbackID = this.m_quickSlotsBoard.RegisterDelayedListenerBool(GetAllBlackboardDefs().UI_QuickSlotsData.quickhackPanelOpen, this, n"OnQuickhackStarted");
    };
    this.AsyncSpawnFromLocal(inkWidgetRef.Get(this.m_cluesContainer), n"ScannerQuestEntries");
  }

  protected cb func OnUnitialize() -> Bool {
    this.GetRootWidget().SetVisible(false);
    if IsDefined(this.m_uiScannerChunkBlackboard) {
      this.m_uiScannerChunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ObjectType, this.m_objectTypeCallbackID);
    };
    if IsDefined(this.m_uiBlackboard) {
      this.m_uiBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_Scanner.CurrentState, this.m_scanStatusCallbackID);
      this.m_uiBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_Scanner.ScannedObject, this.m_scanObjectCallbackID);
    };
    if IsDefined(this.m_quickSlotsBoard) && IsDefined(this.m_quickSlotsCallbackID) {
      this.m_quickSlotsBoard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_QuickSlotsData.quickHackDescritpionVisible, this.m_quickSlotsCallbackID);
    };
    if IsDefined(this.m_quickSlotsBoard) && IsDefined(this.m_quickhackStartedCallbackID) {
      this.m_quickSlotsBoard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_QuickSlotsData.quickhackPanelOpen, this.m_quickhackStartedCallbackID);
    };
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_player = this.GetPlayerControlledObject();
    this.m_gameInstance = playerPuppet.GetGame();
  }

  protected cb func OnScannedObjectChanged(value: EntityID) -> Bool {
    let gameObject: ref<GameObject>;
    this.m_lastScannedObject = value;
    if EntityID.IsDefined(value) {
      gameObject = GameInstance.FindEntityByID(this.m_gameInstance, value) as GameObject;
      this.m_hasHacks = gameObject.IsQuickHackAble();
      inkWidgetRef.SetVisible(this.m_kiroshiLogo, GameInstance.GetStatsSystem(this.m_gameInstance).GetStatValue(Cast(this.m_player.GetEntityID()), gamedataStatType.HasLinkToBountySystem) > 0.00);
      this.SetupToggleVisibility();
    } else {
      this.m_hasHacks = false;
      this.m_scannedObjectType = ScannerObjectType.INVALID;
      this.PlayCloseScannerAnimation();
    };
  }

  protected cb func OnObjectTypeChanged(value: Int32) -> Bool {
    this.m_scannedObjectType = IntEnum(value);
    this.RefreshLayout();
  }

  protected cb func OnQHDescriptionChanged(value: Bool) -> Bool {
    this.ToggleDescriptionAnimation(value);
  }

  protected cb func OnStateChanged(val: Variant) -> Bool {
    let shouldRefresh: Bool;
    let state: gameScanningState = FromVariant(val);
    if Equals(this.m_scanningState, gameScanningState.Default) || Equals(state, gameScanningState.Stopped) {
      shouldRefresh = true;
    };
    this.m_scanningState = state;
    if shouldRefresh {
      this.RefreshLayout();
    };
  }

  public final func RefreshLayout() -> Void {
    let i: Int32;
    this.BreakAniamtions();
    if NotEquals(HUDManager.GetActiveMode(this.m_gameInstance), ActiveMode.FOCUS) {
      this.PlayCloseScannerAnimation();
    };
    if Equals(this.m_scanningState, gameScanningState.Complete) || Equals(this.m_scanningState, gameScanningState.ShallowComplete) || Equals(this.m_scanningState, gameScanningState.Started) {
      i = 0;
      while i < ArraySize(this.m_asyncSpawnRequests) {
        this.m_asyncSpawnRequests[i].Cancel();
        i += 1;
      };
      ArrayClear(this.m_asyncSpawnRequests);
      inkCompoundRef.RemoveAllChildren(this.m_scannerCountainer);
      inkCompoundRef.RemoveAllChildren(this.m_quickhackContainer);
      inkWidgetRef.SetVisible(this.m_bg, true);
      this.GetRootWidget().SetVisible(false);
      ArrayPush(this.m_asyncSpawnRequests, this.AsyncSpawnFromLocal(inkWidgetRef.Get(this.m_quickhackContainer), n"QuickHackDescription"));
      switch this.m_scannedObjectType {
        case ScannerObjectType.PUPPET:
          this.GetRootWidget().SetVisible(true);
          this.AsyncSpawnScannerModule(n"ScannerNPCHeaderWidget");
          this.AsyncSpawnScannerModule(n"ScannerNPCBodyWidget");
          this.AsyncSpawnScannerModule(n"ScannerBountySystemWidget");
          this.AsyncSpawnScannerModule(n"ScannerRequirementsWidget");
          this.AsyncSpawnScannerModule(n"ScannerAbilitiesWidget");
          this.AsyncSpawnScannerModule(n"ScannerResistancesWidget");
          this.AsyncSpawnScannerModule(n"ScannerDeviceDescriptionWidget");
          break;
        case ScannerObjectType.DEVICE:
          this.GetRootWidget().SetVisible(true);
          this.AsyncSpawnScannerModule(n"ScannerDeviceHeaderWidget");
          this.AsyncSpawnScannerModule(n"ScannerVulnerabilitiesWidget");
          this.AsyncSpawnScannerModule(n"ScannerRequirementsWidget");
          this.AsyncSpawnScannerModule(n"ScannerDeviceDescriptionWidget");
          break;
        case ScannerObjectType.VEHICLE:
          this.GetRootWidget().SetVisible(true);
          this.AsyncSpawnScannerModule(n"ScannerVehicleBody");
          this.AsyncSpawnScannerModule(n"ScannerDeviceDescriptionWidget");
          break;
        case ScannerObjectType.GENERIC:
          this.GetRootWidget().SetVisible(true);
          this.AsyncSpawnScannerModule(n"ScannerDeviceHeaderWidget");
          this.AsyncSpawnScannerModule(n"ScannerDeviceDescriptionWidget");
          inkWidgetRef.SetVisible(this.m_toggleDescirptionHackPart, false);
          break;
        default:
          return;
      };
      this.m_showScanAnimProxy = this.PlayLibraryAnimation(n"intro");
      this.m_showScanAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnScannerDetailsShown");
    };
    if Equals(this.m_scanningState, gameScanningState.Stopped) || Equals(this.m_scanningState, gameScanningState.Default) {
      this.PlayCloseScannerAnimation();
    };
  }

  private final func AsyncSpawnScannerModule(scannerWidgetLibraryName: CName) -> Void {
    ArrayPush(this.m_asyncSpawnRequests, this.AsyncSpawnFromLocal(inkWidgetRef.Get(this.m_scannerCountainer), scannerWidgetLibraryName));
  }

  private final func BreakAniamtions() -> Void {
    if this.m_showScanAnimProxy != null {
      this.m_showScanAnimProxy.Stop();
      this.m_showScanAnimProxy.UnregisterFromAllCallbacks(inkanimEventType.OnFinish);
      this.m_showScanAnimProxy = null;
    };
    if this.m_hideScanAnimProxy != null {
      this.m_hideScanAnimProxy.Stop();
      this.m_hideScanAnimProxy.UnregisterFromAllCallbacks(inkanimEventType.OnFinish);
      this.m_hideScanAnimProxy = null;
    };
  }

  private final func PlayCloseScannerAnimation() -> Void {
    this.BreakAniamtions();
    this.m_hideScanAnimProxy = this.PlayLibraryAnimation(n"outro");
    this.m_hideScanAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnScannerDetailsHidden");
  }

  private final func ToggleDescriptionAnimation(value: Bool) -> Void {
    if value {
      if !inkWidgetRef.IsVisible(this.m_quickhackContainer) {
        inkWidgetRef.SetVisible(this.m_quickhackContainer, true);
      };
      if NotEquals(this.m_previousToggleAnimName, n"scan_to_hack") {
        this.m_toggleScanDescriptionAnimProxy.Stop();
        this.m_toggleScanDescriptionAnimProxy = this.PlayLibraryAnimation(n"scan_to_hack");
        this.m_previousToggleAnimName = n"scan_to_hack";
      };
    } else {
      if NotEquals(this.m_previousToggleAnimName, n"hack_to_scan") {
        this.m_toggleScanDescriptionAnimProxy.Stop();
        this.m_toggleScanDescriptionAnimProxy = this.PlayLibraryAnimation(n"hack_to_scan");
        this.m_previousToggleAnimName = n"hack_to_scan";
      };
    };
    this.m_isDescriptionVisible = value;
  }

  private final func SetupToggleVisibility() -> Void {
    if this.m_hasHacks {
      if !inkWidgetRef.IsVisible(this.m_toggleDescirptionHackPart) {
        inkWidgetRef.SetVisible(this.m_toggleDescirptionHackPart, true);
        inkWidgetRef.SetVisible(this.m_toggleDescriptionScanIcon, true);
      };
    } else {
      if inkWidgetRef.IsVisible(this.m_toggleDescirptionHackPart) {
        inkWidgetRef.SetVisible(this.m_toggleDescirptionHackPart, false);
        inkWidgetRef.SetVisible(this.m_toggleDescriptionScanIcon, true);
      };
    };
  }

  protected cb func OnScannerDetailsHidden(animationProxy: ref<inkAnimProxy>) -> Bool {
    inkWidgetRef.SetVisible(this.m_bg, false);
    this.GetRootWidget().SetVisible(false);
    inkCompoundRef.RemoveAllChildren(this.m_scannerCountainer);
  }

  protected cb func OnScannerDetailsShown(animationProxy: ref<inkAnimProxy>) -> Bool {
    this.ToggleDescriptionAnimation(this.m_hasHacks && HUDManager.IsQuickHackDescriptionVisible(this.m_gameInstance));
  }

  protected cb func OnDescriptionTransitionFinish(animationProxy: ref<inkAnimProxy>) -> Bool {
    let evt: ref<FitToContetDelay> = new FitToContetDelay();
    inkWidgetRef.SetFitToContent(this.m_fitToContentBackground, false);
    GameInstance.GetDelaySystem(this.m_gameInstance).DelayEvent(this.m_player, evt, 0.01, false);
  }

  protected cb func OnFitToContentRest(evt: ref<FitToContetDelay>) -> Bool {
    inkWidgetRef.SetFitToContent(this.m_fitToContentBackground, true);
  }

  private final func ConvertActorTypeToObjectType(actorType: HUDActorType) -> ScannerObjectType {
    switch actorType {
      case HUDActorType.UNINITIALIZED:
        return ScannerObjectType.INVALID;
      case HUDActorType.GAME_OBJECT:
        return ScannerObjectType.GENERIC;
      case HUDActorType.VEHICLE:
        return ScannerObjectType.VEHICLE;
      case HUDActorType.DEVICE:
        return ScannerObjectType.DEVICE;
      case HUDActorType.BODY_DISPOSAL_DEVICE:
        return ScannerObjectType.DEVICE;
      case HUDActorType.PUPPET:
        return ScannerObjectType.PUPPET;
      case HUDActorType.ITEM:
        return ScannerObjectType.GENERIC;
    };
  }
}
