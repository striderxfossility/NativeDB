
public native class scannerGameController extends inkHUDGameController {

  private let m_bbWeaponInfo: wref<IBlackboard>;

  private let m_BraindanceBB: wref<IBlackboard>;

  private let m_bbWeaponEventId: ref<CallbackHandle>;

  private let m_BBID_BraindanceActive: ref<CallbackHandle>;

  private let m_scannerscannerObjectStatsId: ref<CallbackHandle>;

  private let m_scannerScannablesId: ref<CallbackHandle>;

  private let m_scannerCurrentProgressId: ref<CallbackHandle>;

  private let m_scannerCurrentStateId: ref<CallbackHandle>;

  private let m_scannerScannedObjectId: ref<CallbackHandle>;

  private let scannerData: scannerDataStructure;

  private native let currentTarget: EntityID;

  private let curObj: GameObjectScanStats;

  private let m_scannerBorderMain: wref<inkCompoundWidget>;

  private let m_scannerBorderController: wref<scannerBorderLogicController>;

  private let m_scannerProgressMain: wref<inkCompoundWidget>;

  private let m_scannerFullScreenOverlay: wref<inkWidget>;

  private let m_center_frame: wref<inkImage>;

  private let m_squares: array<wref<inkImage>>;

  private let m_squaresFilled: array<wref<inkImage>>;

  private let m_isUnarmed: Bool;

  private native let scanLock: Bool;

  private let isEnabled: Bool;

  private let isFinish: Bool;

  private let isScanned: Bool;

  private native let percentValue: Float;

  private native let oldPercentValue: Float;

  private let m_isBraindanceActive: Bool;

  private let m_border_show: ref<inkAnimDef>;

  private let m_center_show: ref<inkAnimDef>;

  private let m_center_hide: ref<inkAnimDef>;

  private let m_dots_show: ref<inkAnimDef>;

  private let m_dots_hide: ref<inkAnimDef>;

  private let m_BorderAnimProxy: ref<inkAnimProxy>;

  @default(scannerGameController, ui_generic_set_11_navigation)
  private let soundFinishedOn: CName;

  @default(scannerGameController, ui_generic_set_10_navigation)
  private let soundFinishedOff: CName;

  private let m_playerSpawnedCallbackID: Uint32;

  private let m_BBID_IsEnabledChange: ref<CallbackHandle>;

  private let m_gameInstance: GameInstance;

  private let m_isShown: Bool;

  private let m_playerPuppet: wref<GameObject>;

  protected cb func OnInitialize() -> Bool {
    let uiBlackboard: ref<IBlackboard>;
    this.m_isUnarmed = true;
    let rootWidget: wref<inkCompoundWidget> = this.GetRootWidget() as inkCompoundWidget;
    this.AsyncSpawnFromExternal(rootWidget.GetWidget(n"border"), r"base\\gameplay\\gui\\widgets\\scanning\\scanner_hud.inkwidget", n"Root", this, n"OnScannerHudSpawned");
    this.CreateAnimationTemplates();
    uiBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Scanner);
    this.m_scannerscannerObjectStatsId = uiBlackboard.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_Scanner.scannerObjectStats, this, n"OnObjectData");
    this.m_scannerScannablesId = uiBlackboard.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_Scanner.Scannables, this, n"OnScannablesChange");
    this.m_scannerCurrentProgressId = uiBlackboard.RegisterDelayedListenerFloat(GetAllBlackboardDefs().UI_Scanner.CurrentProgress, this, n"OnProgressChange");
    this.m_scannerCurrentStateId = uiBlackboard.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_Scanner.CurrentState, this, n"OnStateChanged");
    this.m_scannerScannedObjectId = uiBlackboard.RegisterDelayedListenerEntityID(GetAllBlackboardDefs().UI_Scanner.ScannedObject, this, n"OnScannedObjectChanged");
    this.ConnectToPlayerRelatedBlackboards(this.GetPlayerControlledObject());
    this.m_bbWeaponInfo = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_ActiveWeaponData);
    this.m_bbWeaponEventId = this.m_bbWeaponInfo.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_ActiveWeaponData.WeaponRecordID, this, n"OnWeaponSwap");
    this.m_BraindanceBB = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().Braindance);
    if IsDefined(this.m_BraindanceBB) {
      this.m_BBID_BraindanceActive = this.m_BraindanceBB.RegisterDelayedListenerBool(GetAllBlackboardDefs().Braindance.IsActive, this, n"OnBraindanceToggle");
    };
    this.OnIsEnabledChange(EnumInt(gamePSMVision.Default));
    this.m_gameInstance = (this.GetOwnerEntity() as GameObject).GetGame();
  }

  protected cb func OnScannerHudSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let rootWidget: wref<inkCompoundWidget> = this.GetRootWidget() as inkCompoundWidget;
    this.m_scannerBorderMain = widget as inkCompoundWidget;
    this.m_scannerBorderController = this.m_scannerBorderMain.GetController() as scannerBorderLogicController;
    this.m_scannerFullScreenOverlay = this.m_scannerBorderMain.GetWidget(n"fullscreenHeavyOverlay");
    this.m_scannerProgressMain = rootWidget.GetWidget(n"module") as inkCompoundWidget;
    this.m_center_frame = this.m_scannerBorderMain.GetWidget(n"crosshair\\center_frame") as inkImage;
    let i: Int32 = 0;
    while i < 18 {
      ArrayPush(this.m_squares, this.m_scannerBorderMain.GetWidget(StringToName("crosshair\\dots_square\\square" + IntToString(i + 1))) as inkImage);
      ArrayPush(this.m_squaresFilled, this.m_scannerBorderMain.GetWidget(StringToName("crosshair\\dots_filled\\square" + IntToString(i + 1))) as inkImage);
      i += 1;
    };
  }

  protected cb func OnUnitialize() -> Bool {
    let uiBlackboard: ref<IBlackboard>;
    ArrayClear(this.m_squares);
    ArrayClear(this.m_squaresFilled);
    uiBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Scanner);
    uiBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_Scanner.scannerObjectStats, this.m_scannerscannerObjectStatsId);
    uiBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_Scanner.Scannables, this.m_scannerScannablesId);
    uiBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().UI_Scanner.CurrentProgress, this.m_scannerCurrentProgressId);
    uiBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_Scanner.CurrentState, this.m_scannerCurrentStateId);
    uiBlackboard.UnregisterListenerEntityID(GetAllBlackboardDefs().UI_Scanner.ScannedObject, this.m_scannerScannedObjectId);
    this.m_scannerBorderMain = null;
    this.m_scannerBorderController = null;
    this.m_scannerFullScreenOverlay = null;
    this.m_scannerProgressMain = null;
    this.m_center_frame = null;
    if IsDefined(this.m_bbWeaponInfo) {
      this.m_bbWeaponInfo.UnregisterListenerVariant(GetAllBlackboardDefs().UI_ActiveWeaponData.WeaponRecordID, this.m_bbWeaponEventId);
    };
    if IsDefined(this.m_BraindanceBB) {
      this.m_BraindanceBB.UnregisterDelayedListener(GetAllBlackboardDefs().Braindance.IsActive, this.m_BBID_BraindanceActive);
    };
    this.DisconnectFromPlayerRelatedBlackboards(this.GetPlayerControlledObject());
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    let isFocusModeActive: Bool;
    this.ConnectToPlayerRelatedBlackboards(playerPuppet);
    this.m_playerPuppet = this.GetPlayerControlledObject();
    isFocusModeActive = this.GetPSMBlackboard(playerPuppet).GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vision) == EnumInt(gamePSMVision.Focus);
    if isFocusModeActive {
      this.OnIsEnabledChange(EnumInt(gamePSMVision.Focus));
    };
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    if this.isEnabled {
      this.OnIsEnabledChange(EnumInt(gamePSMVision.Default));
    };
    this.DisconnectFromPlayerRelatedBlackboards(playerPuppet);
  }

  protected cb func OnBraindanceToggle(value: Bool) -> Bool {
    this.m_isBraindanceActive = value;
    if !value {
      this.ShowScanBorder(false);
    };
  }

  private final func ConnectToPlayerRelatedBlackboards(playerPuppet: ref<GameObject>) -> Void {
    this.DisconnectFromPlayerRelatedBlackboards(playerPuppet);
    if playerPuppet.IsControlledByLocalPeer() && !IsDefined(this.m_BBID_IsEnabledChange) {
      this.m_BBID_IsEnabledChange = this.GetPSMBlackboard(playerPuppet).RegisterDelayedListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Vision, this, n"OnIsEnabledChange");
    };
  }

  private final func DisconnectFromPlayerRelatedBlackboards(playerPuppet: ref<GameObject>) -> Void {
    if IsDefined(this.m_BBID_IsEnabledChange) {
      this.GetPSMBlackboard(playerPuppet).UnregisterDelayedListener(GetAllBlackboardDefs().PlayerStateMachine.Vision, this.m_BBID_IsEnabledChange);
    };
  }

  protected cb func OnWeaponSwap(value: Variant) -> Bool {
    this.m_isUnarmed = FromVariant(value) == TDBID.undefined();
  }

  private final func CreateAnimationTemplates() -> Void {
    this.m_border_show = new inkAnimDef();
    let alphaInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    alphaInterpolator.SetDuration(0.50);
    alphaInterpolator.SetStartTransparency(0.00);
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_border_show.AddInterpolator(alphaInterpolator);
    this.m_center_show = new inkAnimDef();
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetDuration(0.50);
    alphaInterpolator.SetStartTransparency(0.20);
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_center_show.AddInterpolator(alphaInterpolator);
    this.m_center_hide = new inkAnimDef();
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetDuration(0.50);
    alphaInterpolator.SetStartTransparency(1.00);
    alphaInterpolator.SetEndTransparency(0.20);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_center_hide.AddInterpolator(alphaInterpolator);
    this.m_dots_show = new inkAnimDef();
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetDuration(1.00);
    alphaInterpolator.SetStartTransparency(0.60);
    alphaInterpolator.SetEndTransparency(0.50);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_dots_show.AddInterpolator(alphaInterpolator);
    this.m_dots_hide = new inkAnimDef();
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetDuration(1.00);
    alphaInterpolator.SetStartTransparency(0.60);
    alphaInterpolator.SetEndTransparency(0.20);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_dots_hide.AddInterpolator(alphaInterpolator);
  }

  private final func ShowScanBorder(val: Bool) -> Void {
    this.m_scannerBorderMain.SetVisible(val);
    this.m_scannerBorderController.SetBraindanceMode(this.m_isBraindanceActive);
  }

  private final func PlaySound(SoundEffect: CName) -> Void {
    let audioEvent: ref<SoundPlayEvent> = new SoundPlayEvent();
    audioEvent.soundName = SoundEffect;
    let player: ref<PlayerPuppet> = this.GetPlayerControlledObject() as PlayerPuppet;
    player.QueueEvent(audioEvent);
  }

  private final func ShowScanner(show: Bool) -> Void {
    let uiBlackboard: ref<IBlackboard>;
    if NotEquals(this.m_isShown, show) {
      this.m_isShown = show;
      uiBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Scanner);
      uiBlackboard.SetBool(GetAllBlackboardDefs().UI_Scanner.UIVisible, show);
      if show {
        GameObjectEffectHelper.StartEffectEvent(this.m_playerPuppet, n"focus_mode");
        GameInstance.GetUISystem(this.m_gameInstance).RequestNewVisualState(n"inkScanningState");
      } else {
        GameObjectEffectHelper.BreakEffectLoopEvent(this.m_playerPuppet, n"focus_mode");
        GameInstance.GetUISystem(this.m_gameInstance).RestorePreviousVisualState(n"inkScanningState");
      };
    };
    this.m_scannerProgressMain.SetVisible(show);
    this.GetRootWidget().SetVisible(show);
  }

  protected cb func OnScannedObjectChanged(val: EntityID) -> Bool {
    let chunksBB: ref<IBlackboard>;
    let id: EntityID;
    if !this.scanLock {
      id = val;
      if this.currentTarget != id || !EntityID.IsDefined(id) {
        this.currentTarget = id;
        this.isFinish = false;
      };
      if !EntityID.IsDefined(id) {
        this.scannerData.entityName = "";
        ArrayClear(this.scannerData.questEntries);
        chunksBB = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_ScannerModules);
        if IsDefined(chunksBB) {
          chunksBB.ClearAllFields(true);
        };
      };
    };
  }

  protected cb func OnStateChanged(val: Variant) -> Bool {
    let state: gameScanningState = FromVariant(val);
    this.isScanned = Equals(state, gameScanningState.Complete) || Equals(state, gameScanningState.ShallowComplete);
  }

  protected cb func OnObjectData(val: Variant) -> Bool {
    let stats: GameObjectScanStats;
    if !this.scanLock {
      stats = FromVariant(val);
      this.curObj = stats;
    };
  }

  protected cb func OnIsEnabledChange(val: Int32) -> Bool {
    if val == EnumInt(gamePSMVision.Default) {
      this.ShowScanner(false);
      this.isEnabled = false;
      this.ShowScanBorder(false);
      this.m_scannerBorderMain.StopAllAnimations();
    } else {
      if val == EnumInt(gamePSMVision.Focus) {
        this.ShowScanBorder(true);
        this.ShowScanner(true);
        this.m_scannerBorderMain.PlayAnimation(this.m_border_show);
        this.isEnabled = true;
      };
    };
  }

  private final func AddQuestData(cat: CName, entry: CName, recordID: TweakDBID) -> Void {
    let questEntry: scannerQuestEntry;
    questEntry.categoryName = cat;
    questEntry.entryName = entry;
    questEntry.recordID = recordID;
    ArrayPush(this.scannerData.questEntries, questEntry);
  }

  private final func OnProgressChange(val: Float) -> Void {
    this.percentValue = val;
    this.scanLock = val > 0.00;
  }

  private final func OnScannablesChange(val: Variant) -> Void {
    let i: Int32;
    let scannables: array<ScanningTooltipElementData> = FromVariant(val);
    this.scannerData.entityName = this.curObj.scannerData.entityName;
    ArrayClear(this.scannerData.questEntries);
    i = 0;
    while i < ArraySize(scannables) {
      this.AddQuestData(scannables[i].localizedName, scannables[i].localizedDescription, scannables[i].recordID);
      i += 1;
    };
  }
}
