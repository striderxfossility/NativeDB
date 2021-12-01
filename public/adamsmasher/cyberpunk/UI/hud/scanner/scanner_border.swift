
public class scannerBorderLogicController extends inkLogicController {

  private edit const let m_braindanceSetVisible: array<inkWidgetRef>;

  private edit const let m_braindanceSetHidden: array<inkWidgetRef>;

  public final func SetBraindanceMode(isBraindance: Bool) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_braindanceSetVisible) {
      inkWidgetRef.SetVisible(this.m_braindanceSetVisible[i], isBraindance);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_braindanceSetHidden) {
      inkWidgetRef.SetVisible(this.m_braindanceSetHidden[i], !isBraindance);
      i += 1;
    };
  }
}

public class scannerBorderGameController extends inkProjectedHUDGameController {

  private edit let m_ZoomMovingContainer: inkCompoundRef;

  private edit let m_DistanceMovingContainer: inkCompoundRef;

  private edit let m_DistanceParentContainer: inkCompoundRef;

  private edit let m_CrosshairProjection: inkCompoundRef;

  private edit let m_loadingBarCanvas: inkCompoundRef;

  private edit let m_crosshairContainer: inkCompoundRef;

  private edit let m_ZoomNumber: inkTextRef;

  private edit let m_DistanceNumber: inkTextRef;

  private edit let m_DistanceImageRuler: inkImageRef;

  private edit let m_ZoomMoveBracketL: inkImageRef;

  private edit let m_ZoomMoveBracketR: inkImageRef;

  private edit let m_scannerBarWidget: inkCompoundRef;

  private edit let m_scannerBarFluffText: inkTextRef;

  private edit let m_scannerBarFill: inkImageRef;

  private edit const let m_deviceFluffs: array<inkWidgetRef>;

  private let m_LockOnAnimProxy: ref<inkAnimProxy>;

  private let m_IdleAnimProxy: ref<inkAnimProxy>;

  private let m_BracketsAppearAnimProxy: ref<inkAnimProxy>;

  private let lockOutAnimWasPlayed: Bool;

  private let m_root: wref<inkCompoundWidget>;

  private let m_currentTarget: EntityID;

  private let m_isTakeControllActive: Bool;

  private let m_ownerObject: wref<GameObject>;

  private let m_currentTargetBuffered: EntityID;

  private let m_scannerData: scannerDataStructure;

  private let m_shouldShowScanner: Bool;

  private let m_isFullyScanned: Bool;

  private let m_ProjectionLogicController: wref<ScannerCrosshairLogicController>;

  private let m_OriginalScannerBarFillSize: Vector2;

  private let zoomUpAnim: ref<inkAnimProxy>;

  private let animLockOn: ref<inkAnimProxy>;

  private let zoomDownAnim: ref<inkAnimProxy>;

  private let animLockOff: ref<inkAnimProxy>;

  private let m_exclusiveFocusAnim: ref<inkAnimProxy>;

  private let m_isExclusiveFocus: Bool;

  private let argZoomBuffered: Float;

  private let m_squares: array<wref<inkImage>>;

  private let m_squaresFilled: array<wref<inkImage>>;

  private let m_scanBlackboard: wref<IBlackboard>;

  private let m_psmBlackboard: wref<IBlackboard>;

  private let m_tcsBlackboard: wref<IBlackboard>;

  private let m_BBID_ScanObject: ref<CallbackHandle>;

  private let m_BBID_ScanObject_Data: ref<CallbackHandle>;

  private let m_BBID_ScanObject_Position: ref<CallbackHandle>;

  private let m_BBID_ScanState: ref<CallbackHandle>;

  private let m_BBID_ProgressNum: ref<CallbackHandle>;

  private let m_BBID_ProgressText: ref<CallbackHandle>;

  private let m_BBID_ExclusiveFocus: ref<CallbackHandle>;

  private let m_PSM_BBID: ref<CallbackHandle>;

  private let m_tcs_BBID: ref<CallbackHandle>;

  private let m_VisionStateBlackboardId: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    let i: Int32;
    this.m_ownerObject = this.GetOwnerEntity() as GameObject;
    this.m_scanBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Scanner);
    if IsDefined(this.m_scanBlackboard) {
      this.m_BBID_ScanObject = this.m_scanBlackboard.RegisterDelayedListenerEntityID(GetAllBlackboardDefs().UI_Scanner.ScannedObject, this, n"OnScannedObject", true);
      this.m_BBID_ScanObject_Data = this.m_scanBlackboard.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_Scanner.scannerObjectStats, this, n"OnScannerObjectStats", true);
      this.m_BBID_ScanObject_Position = this.m_scanBlackboard.RegisterDelayedListenerFloat(GetAllBlackboardDefs().UI_Scanner.scannerObjectDistance, this, n"OnObjectPositionChange", true);
      this.m_BBID_ScanState = this.m_scanBlackboard.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_Scanner.CurrentState, this, n"OnStateChanged", true);
      this.m_BBID_ProgressNum = this.m_scanBlackboard.RegisterDelayedListenerFloat(GetAllBlackboardDefs().UI_Scanner.CurrentProgress, this, n"OnProgressChange", true);
      this.m_BBID_ProgressText = this.m_scanBlackboard.RegisterDelayedListenerString(GetAllBlackboardDefs().UI_Scanner.ProgressBarText, this, n"OnProgressBarFluffTextChange", true);
      this.m_BBID_ExclusiveFocus = this.m_scanBlackboard.RegisterDelayedListenerBool(GetAllBlackboardDefs().UI_Scanner.exclusiveFocusActive, this, n"OnExclusiveFocus", true);
    };
    this.m_tcsBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().DeviceTakeControl);
    if IsDefined(this.m_tcsBlackboard) {
      this.m_tcs_BBID = this.m_tcsBlackboard.RegisterDelayedListenerEntityID(GetAllBlackboardDefs().DeviceTakeControl.ActiveDevice, this, n"OnChangeControlledDevice");
      this.OnChangeControlledDevice(this.m_tcsBlackboard.GetEntityID(GetAllBlackboardDefs().DeviceTakeControl.ActiveDevice));
    };
    this.m_root = this.GetRootWidget() as inkCompoundWidget;
    inkWidgetRef.SetVisible(this.m_scannerBarWidget, false);
    if IsDefined(inkWidgetRef.Get(this.m_CrosshairProjection)) {
      this.m_ProjectionLogicController = inkWidgetRef.Get(this.m_CrosshairProjection).GetController() as ScannerCrosshairLogicController;
    };
    if IsDefined(this.m_ProjectionLogicController) {
      this.m_ProjectionLogicController.SetProjection(this.RegisterScreenProjection(this.m_ProjectionLogicController.CreateProjectionData()));
    };
    i = 0;
    while i < 14 {
      ArrayPush(this.m_squares, this.GetWidget(StringToName("scanner_overlay\\scannerDots\\dot" + IntToString(i + 1))) as inkImage);
      i += 1;
    };
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_scanBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_Scanner.ScannedObject, this.m_BBID_ScanObject);
    this.m_scanBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_Scanner.scannerObjectStats, this.m_BBID_ScanObject_Data);
    this.m_scanBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_Scanner.scannerObjectDistance, this.m_BBID_ScanObject_Position);
    this.m_scanBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_Scanner.CurrentState, this.m_BBID_ScanState);
    this.m_scanBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_Scanner.CurrentProgress, this.m_BBID_ProgressNum);
    this.m_scanBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_Scanner.ProgressBarText, this.m_BBID_ProgressText);
    if IsDefined(this.m_tcsBlackboard) {
      this.m_tcsBlackboard.UnregisterListenerEntityID(GetAllBlackboardDefs().DeviceTakeControl.ActiveDevice, this.m_tcs_BBID);
    };
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_psmBlackboard = this.GetPSMBlackboard(playerPuppet);
    if IsDefined(this.m_psmBlackboard) {
      this.m_PSM_BBID = this.m_psmBlackboard.RegisterDelayedListenerFloat(GetAllBlackboardDefs().PlayerStateMachine.ZoomLevel, this, n"OnScannerZoom");
      this.m_VisionStateBlackboardId = this.m_psmBlackboard.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Vision, this, n"OnPSMVisionStateChanged");
    };
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_psmBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().PlayerStateMachine.ZoomLevel, this.m_PSM_BBID);
    this.m_psmBlackboard.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Vision, this.m_VisionStateBlackboardId);
  }

  protected cb func OnChangeControlledDevice(value: EntityID) -> Bool {
    this.m_isTakeControllActive = EntityID.IsDefined(value);
    this.ResolveState();
  }

  private final func ResolveState() -> Void {
    let i: Int32;
    let stateName: CName;
    if this.m_isTakeControllActive {
      stateName = n"Device";
    } else {
      stateName = n"Default";
    };
    i = 0;
    while i < ArraySize(this.m_deviceFluffs) {
      inkWidgetRef.SetState(this.m_deviceFluffs[i], stateName);
      i += 1;
    };
  }

  public final func PlayLockAnimation(showAnim: Bool) -> Void {
    let idleAnimOptions: inkAnimOptions;
    if !this.m_isExclusiveFocus {
      idleAnimOptions.toMarker = n"stop";
      this.animLockOff.Stop();
      this.animLockOn.Stop();
      if showAnim {
        this.animLockOn = this.PlayLibraryAnimation(n"LockOnAnim", idleAnimOptions);
      };
      if !showAnim {
        this.animLockOff = this.PlayLibraryAnimation(n"LockOnAnimOff", idleAnimOptions);
      };
    };
  }

  private final func ComputeVisibility() -> Void {
    let currentTargetObject: wref<GameObject>;
    let owner: ref<GameObject>;
    if !EntityID.IsDefined(this.m_currentTarget) {
      this.m_ProjectionLogicController.SetEntity(null);
      inkWidgetRef.SetVisible(this.m_DistanceParentContainer, false);
      inkWidgetRef.SetVisible(this.m_CrosshairProjection, false);
      this.PlayLockAnimation(false);
      return;
    };
    owner = this.GetOwnerEntity() as GameObject;
    currentTargetObject = GameInstance.FindEntityByID(owner.GetGame(), this.m_currentTarget) as GameObject;
    if this.ShouldShowScanner(currentTargetObject) {
      this.m_ProjectionLogicController.SetEntity(currentTargetObject);
      inkWidgetRef.SetVisible(this.m_DistanceParentContainer, true);
      inkWidgetRef.SetVisible(this.m_CrosshairProjection, true);
      this.PlayLockAnimation(true);
    } else {
      this.m_ProjectionLogicController.SetEntity(null);
      inkWidgetRef.SetVisible(this.m_DistanceParentContainer, false);
      inkWidgetRef.SetVisible(this.m_CrosshairProjection, false);
      this.PlayLockAnimation(false);
    };
  }

  protected cb func OnScreenProjectionUpdate(projections: ref<gameuiScreenProjectionsData>) -> Bool {
    let currData: wref<ScannerCrosshairLogicController>;
    let i: Int32 = 0;
    while i < ArraySize(projections.data) {
      currData = projections.data[i].GetUserData() as ScannerCrosshairLogicController;
      if currData != null {
        currData.UpdateProjection();
      };
      i += 1;
    };
  }

  protected cb func OnObjectPositionChange(pos: Float) -> Bool {
    inkTextRef.SetText(this.m_DistanceNumber, FloatToStringPrec(pos, 1));
  }

  protected cb func OnPSMVisionStateChanged(value: Int32) -> Bool {
    let newState: gamePSMVision = IntEnum(value);
    if NotEquals(newState, gamePSMVision.Focus) {
      inkWidgetRef.SetVisible(this.m_loadingBarCanvas, false);
      inkWidgetRef.SetVisible(this.m_crosshairContainer, true);
    };
  }

  protected cb func OnExclusiveFocus(isExclusiveFocus: Bool) -> Bool {
    let animOption: inkAnimOptions;
    this.m_isExclusiveFocus = isExclusiveFocus;
    inkWidgetRef.SetVisible(this.m_loadingBarCanvas, this.m_isExclusiveFocus);
    inkWidgetRef.SetVisible(this.m_crosshairContainer, !this.m_isExclusiveFocus);
    if IsDefined(inkWidgetRef.Get(this.m_crosshairContainer)) {
      if this.m_isExclusiveFocus {
        inkWidgetRef.SetState(this.m_crosshairContainer, n"Animated");
      } else {
        inkWidgetRef.SetState(this.m_crosshairContainer, n"Default");
      };
    };
    if !this.m_isExclusiveFocus {
      if IsDefined(this.animLockOn) {
        this.animLockOn.Stop();
        this.animLockOn = null;
      };
      if IsDefined(this.animLockOff) {
        this.animLockOff.Stop();
        this.animLockOff = null;
      };
      if IsDefined(this.m_exclusiveFocusAnim) {
        this.m_exclusiveFocusAnim.Stop();
        this.m_exclusiveFocusAnim = null;
      };
    } else {
      if !IsDefined(this.m_exclusiveFocusAnim) {
        animOption.loopType = inkanimLoopType.PingPong;
        animOption.loopInfinite = true;
        this.m_exclusiveFocusAnim = this.PlayLibraryAnimation(n"loadingBar", animOption);
      };
    };
  }

  protected cb func OnScannerZoom(argZoom: Float) -> Bool {
    if argZoom * 2.00 > 2.00 {
      inkTextRef.SetText(this.m_ZoomNumber, FloatToStringPrec(MaxF(1.00, argZoom * 2.00), 1) + "x");
    } else {
      inkTextRef.SetText(this.m_ZoomNumber, FloatToStringPrec(MaxF(1.00, argZoom * 2.00 - 1.00), 1) + "x");
    };
    inkWidgetRef.SetMargin(this.m_ZoomMoveBracketL, new inkMargin(0.00, 0.00, 560.00 - argZoom * 60.00, 0.00));
    inkWidgetRef.SetMargin(this.m_ZoomMoveBracketR, new inkMargin(560.00 - argZoom * 60.00, 0.00, 0.00, 0.00));
    if argZoom < this.argZoomBuffered {
      if (!IsDefined(this.zoomDownAnim) || !this.zoomDownAnim.IsPlaying()) && (!IsDefined(this.zoomUpAnim) || !this.zoomUpAnim.IsPlaying()) {
        this.zoomDownAnim = this.PlayLibraryAnimation(n"zoomDown");
      };
    };
    if argZoom > this.argZoomBuffered {
      if (!IsDefined(this.zoomDownAnim) || !this.zoomDownAnim.IsPlaying()) && (!IsDefined(this.zoomUpAnim) || !this.zoomUpAnim.IsPlaying()) {
        this.zoomUpAnim = this.PlayLibraryAnimation(n"zoomUp");
      };
    };
    this.argZoomBuffered = argZoom;
  }

  protected cb func OnProgressChange(val: Float) -> Bool {
    let barActive: Bool = val > 0.00 && val < 1.00;
    let shouldShowScanner: Bool = this.ShouldShowScanner();
    if barActive && shouldShowScanner {
      inkWidgetRef.SetSize(this.m_scannerBarFill, new Vector2(val * 418.00, 15.00));
      if !this.m_BracketsAppearAnimProxy.IsPlaying() && val < 0.05 {
        this.m_BracketsAppearAnimProxy = this.PlayLibraryAnimation(n"BracketsAppearAnim");
      };
      if !this.m_LockOnAnimProxy.IsPlaying() && val > 0.95 {
        this.m_LockOnAnimProxy = this.PlayLibraryAnimation(n"BracketsAppearAnim");
      };
    };
    inkWidgetRef.SetVisible(this.m_scannerBarWidget, barActive && shouldShowScanner);
  }

  private final func ShouldShowScanner() -> Bool {
    let target: ref<GameObject>;
    if EntityID.IsDefined(this.m_currentTarget) {
      target = GameInstance.FindEntityByID(this.GetOwner().GetGame(), this.m_currentTarget) as GameObject;
      if IsDefined(target) {
        return target.ShouldShowScanner() && !target.IsScanned();
      };
      return false;
    };
    return false;
  }

  private final func GetOwner() -> wref<GameObject> {
    return this.GetOwnerEntity() as GameObject;
  }

  protected cb func OnProgressBarFluffTextChange(val: String) -> Bool {
    if !IsStringValid(val) {
      val = "SCANNING";
    };
    inkTextRef.SetLocalizedTextScript(this.m_scannerBarFluffText, val);
  }

  protected cb func OnStateChanged(val: Variant) -> Bool {
    let idleAnimOptions: inkAnimOptions;
    let state: gameScanningState = FromVariant(val);
    this.m_isFullyScanned = Equals(state, gameScanningState.Complete);
    this.ComputeVisibility();
    if !this.m_IdleAnimProxy.IsPlaying() {
      idleAnimOptions.loopInfinite = true;
      this.m_IdleAnimProxy = this.PlayLibraryAnimation(n"InfiniteIdleAnimation", idleAnimOptions);
    };
  }

  protected cb func OnScannedObject(val: EntityID) -> Bool {
    this.m_currentTargetBuffered = this.m_currentTarget;
    this.m_currentTarget = val;
    this.ComputeVisibility();
  }

  protected cb func OnScannerObjectStats(val: Variant) -> Bool {
    ArrayClear(this.m_scannerData.questEntries);
    this.m_scannerData = FromVariant(val);
    if !this.m_shouldShowScanner {
      return false;
    };
  }

  private final func ShouldShowScanner(currentTargetObject: wref<GameObject>) -> Bool {
    if EntityID.IsDefined(this.m_currentTarget) {
      return currentTargetObject.ShouldShowScanner();
    };
    return false;
  }

  private final func GetHudManager() -> ref<HUDManager> {
    return this.GetOwner().GetHudManager();
  }
}
