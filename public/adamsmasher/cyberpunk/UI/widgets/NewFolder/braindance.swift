
public class BraindanceGameController extends inkHUDGameController {

  private edit let m_currentTimerMarker: inkWidgetRef;

  private edit let m_currentTimerText: inkTextRef;

  private edit let m_activeLayer: inkTextRef;

  private edit let m_layerIcon: inkImageRef;

  private edit let m_layerThermalIcon: inkImageRef;

  private edit let m_layerVisualIcon: inkImageRef;

  private edit let m_layerAudioIcon: inkImageRef;

  private edit let m_cursorPoint: inkWidgetRef;

  private edit let m_buttonHintsManagerRef: inkWidgetRef;

  private edit const let m_clueHolder: array<inkCompoundRef>;

  private edit const let m_clueBarHolder: array<inkWidgetRef>;

  private edit const let m_speedIndicatorManagers: array<inkWidgetRef>;

  private let m_clueArray: array<wref<BraindanceClueLogicController>>;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_barSize: Float;

  private let m_braindanceDuration: Float;

  private let m_currentTime: Float;

  private let m_rootWidget: wref<inkWidget>;

  private let m_currentLayer: gameuiEBraindanceLayer;

  private let m_currentSpeed: scnPlaySpeed;

  private let m_currentDirection: scnPlayDirection;

  private let m_startingTimerTopMargin: Float;

  private let m_gameInstance: GameInstance;

  private let m_braindanceBB: wref<IBlackboard>;

  private let m_braindanceDef: ref<BraindanceBlackboardDef>;

  private let m_ClueBBID: ref<CallbackHandle>;

  private let m_VisionModeBBID: ref<CallbackHandle>;

  private let m_ProgressBBID: ref<CallbackHandle>;

  private let m_SectionTimeBBID: ref<CallbackHandle>;

  private let m_IsActiveBBID: ref<CallbackHandle>;

  private let m_EnableExitBBID: ref<CallbackHandle>;

  private let m_IsFPPBBID: ref<CallbackHandle>;

  private let m_PlaybackSpeedID: ref<CallbackHandle>;

  private let m_PlaybackDirectionID: ref<CallbackHandle>;

  private let m_isFPPMode: Bool;

  private let m_showTimelineAnimation: ref<inkAnimProxy>;

  private let m_hideTimelineAnimation: ref<inkAnimProxy>;

  private let m_showWidgetAnimation: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    let barController: ref<BraindanceBarLogicController>;
    this.m_barSize = 2000.00;
    this.m_braindanceDuration = 100.00;
    this.m_isFPPMode = true;
    let timerPositionMargin: inkMargin = inkWidgetRef.GetMargin(this.m_currentTimerMarker);
    this.m_startingTimerTopMargin = timerPositionMargin.top;
    this.m_buttonHintsController = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsManagerRef), r"base\\gameplay\\gui\\common\\buttonhints_vertical.inkwidget", n"Root").GetController() as ButtonHints;
    this.m_rootWidget = this.GetRootWidget();
    this.m_rootWidget.SetVisible(false);
    if ArraySize(this.m_clueBarHolder) == 3 {
      barController = inkWidgetRef.GetController(this.m_clueBarHolder[0]) as BraindanceBarLogicController;
      barController.SetBarLayer(gameuiEBraindanceLayer.Visual, this.GetStateName(gameuiEBraindanceLayer.Visual));
      barController = inkWidgetRef.GetController(this.m_clueBarHolder[1]) as BraindanceBarLogicController;
      barController.SetBarLayer(gameuiEBraindanceLayer.Thermal, this.GetStateName(gameuiEBraindanceLayer.Thermal));
      barController = inkWidgetRef.GetController(this.m_clueBarHolder[2]) as BraindanceBarLogicController;
      barController.SetBarLayer(gameuiEBraindanceLayer.Audio, this.GetStateName(gameuiEBraindanceLayer.Audio));
    };
    this.SetupBB();
    this.SetBraindanceBaseInput();
  }

  protected cb func OnUnInitialize() -> Bool {
    this.UnregisterFromBB();
  }

  private final func SetupBB() -> Void {
    let bdEvent: ref<BraindanceInputChangeEvent>;
    let bdSystem: ref<BraindanceSystem>;
    this.m_braindanceDef = GetAllBlackboardDefs().Braindance;
    this.m_braindanceBB = this.GetBlackboardSystem().Get(this.m_braindanceDef);
    if IsDefined(this.m_braindanceBB) {
      this.m_ClueBBID = this.m_braindanceBB.RegisterDelayedListenerVariant(this.m_braindanceDef.Clue, this, n"OnClueDataUpdated");
      this.m_VisionModeBBID = this.m_braindanceBB.RegisterDelayedListenerInt(this.m_braindanceDef.activeBraindanceVisionMode, this, n"OnVisionModeUpdated");
      this.m_ProgressBBID = this.m_braindanceBB.RegisterDelayedListenerFloat(this.m_braindanceDef.Progress, this, n"OnProgressUpdated");
      this.m_SectionTimeBBID = this.m_braindanceBB.RegisterDelayedListenerFloat(this.m_braindanceDef.SectionTime, this, n"OnSectionTimeUpdated");
      this.m_IsActiveBBID = this.m_braindanceBB.RegisterDelayedListenerBool(this.m_braindanceDef.IsActive, this, n"OnIsActiveUpdated");
      this.m_EnableExitBBID = this.m_braindanceBB.RegisterDelayedListenerBool(this.m_braindanceDef.EnableExit, this, n"OnExitEnabled");
      this.m_IsFPPBBID = this.m_braindanceBB.RegisterDelayedListenerBool(this.m_braindanceDef.IsFPP, this, n"OnIsFPPUpdated");
      this.m_PlaybackSpeedID = this.m_braindanceBB.RegisterDelayedListenerVariant(this.m_braindanceDef.PlaybackSpeed, this, n"OnPlaybackSpeedUpdated");
      this.m_PlaybackDirectionID = this.m_braindanceBB.RegisterDelayedListenerVariant(this.m_braindanceDef.PlaybackDirection, this, n"OnPlaybackDirectionUpdated");
      if this.m_braindanceBB.GetBool(this.m_braindanceDef.IsActive) {
        this.OnIsActiveUpdated(true);
        this.OnSectionTimeUpdated(this.m_braindanceBB.GetFloat(this.m_braindanceDef.SectionTime));
        this.OnIsFPPUpdated(this.m_braindanceBB.GetBool(this.m_braindanceDef.IsFPP));
        this.OnVisionModeUpdated(this.m_braindanceBB.GetInt(this.m_braindanceDef.activeBraindanceVisionMode));
        bdSystem = GameInstance.GetScriptableSystemsContainer(this.GetPlayerControlledObject().GetGame()).Get(n"BraindanceSystem") as BraindanceSystem;
        bdEvent = new BraindanceInputChangeEvent();
        bdEvent.bdSystem = bdSystem;
        GameInstance.GetUISystem(this.GetPlayerControlledObject().GetGame()).QueueEvent(bdEvent);
        this.m_gameInstance = this.GetPlayerControlledObject().GetGame();
      };
    };
  }

  private final func UnregisterFromBB() -> Void {
    if IsDefined(this.m_braindanceBB) {
      this.m_braindanceBB.UnregisterDelayedListener(this.m_braindanceDef.Clue, this.m_ClueBBID);
      this.m_braindanceBB.UnregisterDelayedListener(this.m_braindanceDef.activeBraindanceVisionMode, this.m_VisionModeBBID);
      this.m_braindanceBB.UnregisterDelayedListener(this.m_braindanceDef.Progress, this.m_ProgressBBID);
      this.m_braindanceBB.UnregisterDelayedListener(this.m_braindanceDef.SectionTime, this.m_SectionTimeBBID);
      this.m_braindanceBB.UnregisterDelayedListener(this.m_braindanceDef.IsActive, this.m_IsActiveBBID);
      this.m_braindanceBB.UnregisterDelayedListener(this.m_braindanceDef.EnableExit, this.m_EnableExitBBID);
      this.m_braindanceBB.UnregisterDelayedListener(this.m_braindanceDef.IsFPP, this.m_IsFPPBBID);
      this.m_braindanceBB.UnregisterDelayedListener(this.m_braindanceDef.PlaybackSpeed, this.m_PlaybackSpeedID);
      this.m_braindanceBB.UnregisterDelayedListener(this.m_braindanceDef.PlaybackDirection, this.m_PlaybackDirectionID);
    };
    this.m_braindanceBB = null;
  }

  protected cb func OnBraindanceInputChangeEvent(evt: ref<BraindanceInputChangeEvent>) -> Bool {
    let inputMask: SBraindanceInputMask = evt.bdSystem.GetInputMask();
    this.m_buttonHintsController.ClearButtonHints();
    if inputMask.pauseAction {
      this.m_buttonHintsController.AddButtonHint(n"Pause", n"UI-ScriptExports-Play/Pause0");
    };
    if inputMask.playForwardAction {
      this.m_buttonHintsController.AddButtonHint(n"PlayForward", n"UI-ScriptExports-FastForward0", true);
    };
    if inputMask.playBackwardAction {
      this.m_buttonHintsController.AddButtonHint(n"PlayBackward", n"UI-ScriptExports-Rewind0", true);
    };
    if inputMask.restartAction {
      this.m_buttonHintsController.AddButtonHint(n"Restart", n"UI-ScriptExports-Restart0", true);
    };
    if inputMask.switchLayerAction && !this.m_isFPPMode {
      this.m_buttonHintsController.AddButtonHint(n"SwitchLayer", n"UI-ScriptExports-SwitchLayer0");
    };
    if inputMask.cameraToggleAction {
      this.m_buttonHintsController.AddButtonHint(n"BdCameraToggle", this.GetLeftShoulderLocKey());
    };
    this.OnExitEnabled(this.m_braindanceBB.GetBool(this.m_braindanceDef.EnableExit));
  }

  protected cb func OnClueDataUpdated(value: Variant) -> Bool {
    let clueData: BraindanceClueData;
    let clueIndex: Int32;
    let duplicatedClue: Bool;
    let clueDescriptor: gameuiBraindanceClueDescriptor = FromVariant(value);
    clueData.startTime = clueDescriptor.startTime;
    clueData.duration = clueDescriptor.endTime - clueDescriptor.startTime;
    switch clueDescriptor.mode {
      case gameuiEClueDescriptorMode.Add:
        clueData.state = ClueState.active;
        break;
      case gameuiEClueDescriptorMode.Finish:
        clueData.state = ClueState.complete;
    };
    clueData.layer = clueDescriptor.layer;
    clueData.id = clueDescriptor.clueName;
    clueIndex = 0;
    while !duplicatedClue && clueIndex < ArraySize(this.m_clueArray) {
      if Equals(this.m_clueArray[clueIndex].GetBraindanceClueId(), clueData.id) {
        duplicatedClue = true;
      } else {
        clueIndex += 1;
      };
    };
    if !duplicatedClue {
      this.AddClue(clueData);
      clueIndex = clueIndex + 1;
    };
    this.UpdateClues();
    if Equals(clueData.state, ClueState.complete) {
      this.m_clueArray[clueIndex].HideClue();
    };
  }

  protected cb func OnProgressUpdated(value: Float) -> Bool {
    this.m_currentTime = value;
    this.SetBraindanceProgress();
    this.UpdateClues();
  }

  protected cb func OnSectionTimeUpdated(value: Float) -> Bool {
    this.m_braindanceDuration = value;
  }

  protected cb func OnIsActiveUpdated(value: Bool) -> Bool {
    if !value {
      this.m_isFPPMode = true;
      this.SetBraindanceBaseInput();
      this.m_buttonHintsController.RemoveButtonHint(n"SwitchLayer");
    } else {
      this.m_buttonHintsController.AddButtonHint(n"SwitchLayer", n"UI-ScriptExports-SwitchLayer0");
    };
    this.UpdateBraindance(value);
  }

  protected cb func OnIsFPPUpdated(value: Bool) -> Bool {
    let bdSystem: ref<BraindanceSystem> = GameInstance.GetScriptableSystemsContainer(this.GetPlayerControlledObject().GetGame()).Get(n"BraindanceSystem") as BraindanceSystem;
    let inputMask: SBraindanceInputMask = bdSystem.GetInputMask();
    this.m_isFPPMode = value;
    this.m_buttonHintsController.AddButtonHint(n"BdCameraToggle", this.GetLeftShoulderLocKey());
    if inputMask.switchLayerAction && !this.m_isFPPMode {
      this.m_buttonHintsController.AddButtonHint(n"SwitchLayer", n"UI-ScriptExports-SwitchLayer0");
    } else {
      this.m_buttonHintsController.RemoveButtonHint(n"SwitchLayer");
    };
  }

  protected cb func OnPlaybackSpeedUpdated(value: Variant) -> Bool {
    this.m_currentSpeed = FromVariant(value);
    this.UpdateSpeedIndicators();
  }

  protected cb func OnPlaybackDirectionUpdated(value: Variant) -> Bool {
    this.m_currentDirection = FromVariant(value);
    this.UpdateSpeedIndicators();
  }

  private final func UpdateSpeedIndicators() -> Void {
    let speedIndicator: ref<SpeedIndicatorIconsManager>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_speedIndicatorManagers) {
      speedIndicator = inkWidgetRef.GetController(this.m_speedIndicatorManagers[i]) as SpeedIndicatorIconsManager;
      speedIndicator.SetBraindanceSpeed(this.m_currentSpeed, this.m_currentDirection);
      i += 1;
    };
  }

  protected cb func OnVisionModeUpdated(value: Int32) -> Bool {
    this.SetVisionMode(IntEnum(value));
    this.UpdateClues();
  }

  protected cb func OnExitEnabled(value: Bool) -> Bool {
    if value {
      this.m_buttonHintsController.AddButtonHint(n"ExitBraindance", n"UI-ScriptExports-Close");
    } else {
      this.m_buttonHintsController.RemoveButtonHint(n"ExitBraindance");
    };
  }

  public final func UpdateBraindance(active: Bool) -> Void {
    let i: Int32;
    if active {
      this.Intro();
      i = 0;
      while i < ArraySize(this.m_clueHolder) {
        inkCompoundRef.RemoveAllChildren(this.m_clueHolder[i]);
        i += 1;
      };
      ArrayClear(this.m_clueArray);
    } else {
      this.Outro();
    };
  }

  private final func SetBraindanceBaseInput() -> Void {
    this.m_buttonHintsController.ClearButtonHints();
    this.m_buttonHintsController.AddButtonHint(n"Pause", n"UI-ScriptExports-Play/Pause0");
    this.m_buttonHintsController.AddButtonHint(n"PlayForward", n"UI-ScriptExports-FastForward0", true);
    this.m_buttonHintsController.AddButtonHint(n"PlayBackward", n"UI-ScriptExports-Rewind0", true);
    this.m_buttonHintsController.AddButtonHint(n"Restart", n"UI-ScriptExports-Restart0", true);
    this.m_buttonHintsController.AddButtonHint(n"BdCameraToggle", this.GetLeftShoulderLocKey());
    this.OnExitEnabled(this.m_braindanceBB.GetBool(this.m_braindanceDef.EnableExit));
  }

  public final func SetBraindanceProgress() -> Void {
    let newPositionMargin: inkMargin;
    let currentPercent: Float = this.m_currentTime;
    let currentPosition: Float = currentPercent * this.m_barSize;
    newPositionMargin.left = currentPosition;
    inkWidgetRef.SetMargin(this.m_currentTimerMarker, newPositionMargin);
    inkTextRef.SetText(this.m_currentTimerText, this.GetTimeMS(this.m_braindanceDuration * currentPercent));
  }

  public final func AddClue(clueData: BraindanceClueData) -> Void {
    let clueMargin: inkMargin;
    let cluePercentage: Float;
    let cluePosition: Float;
    let clueSize: Float;
    let clueStartPercentage: Float;
    let controller: wref<BraindanceClueLogicController>;
    let holder: inkCompoundRef;
    let initialSize: Vector2;
    let widget: ref<inkWidget>;
    switch clueData.layer {
      case gameuiEBraindanceLayer.Visual:
        holder = this.m_clueHolder[0];
        break;
      case gameuiEBraindanceLayer.Thermal:
        holder = this.m_clueHolder[1];
        break;
      case gameuiEBraindanceLayer.Audio:
        holder = this.m_clueHolder[2];
        break;
      default:
        return;
    };
    widget = this.SpawnFromLocal(inkWidgetRef.Get(holder), n"Clue") as inkCanvas;
    controller = widget.GetController() as BraindanceClueLogicController;
    cluePercentage = clueData.duration / this.m_braindanceDuration;
    clueSize = cluePercentage * this.m_barSize;
    controller.SetupData(clueSize, clueData);
    clueStartPercentage = clueData.startTime / this.m_braindanceDuration;
    cluePosition = clueStartPercentage * this.m_barSize - 12.00;
    clueMargin.left = cluePosition;
    widget.SetMargin(clueMargin);
    widget.SetState(this.GetStateName(clueData.layer));
    widget.SetAnchorPoint(0.00, 0.50);
    widget.SetAnchor(inkEAnchor.CenterLeft);
    widget.SetVAlign(inkEVerticalAlign.Center);
    initialSize = widget.GetSize();
    initialSize.Y = 30.00;
    widget.SetSize(initialSize);
    ArrayPush(this.m_clueArray, controller);
  }

  private final func SetVisionMode(layer: gameuiEBraindanceLayer) -> Void {
    let barController: ref<BraindanceBarLogicController>;
    let cursorPointMargin: inkMargin;
    let i: Int32;
    let layerIconName: CName;
    let layerStateName: CName;
    let localizedLayerName: String;
    let clueBarOpacity: Float = 0.70;
    let clueBarScaleY: Float = 0.50;
    this.m_currentLayer = layer;
    switch this.m_currentLayer {
      case gameuiEBraindanceLayer.Visual:
        localizedLayerName = "LocKey#22109";
        layerIconName = n"braindance_visual_icon";
        cursorPointMargin.top = -45.00;
        inkWidgetRef.SetOpacity(this.m_clueHolder[0], 1.00);
        inkWidgetRef.SetScale(this.m_clueHolder[0], new Vector2(1.00, 1.00));
        inkWidgetRef.SetOpacity(this.m_clueHolder[1], clueBarOpacity);
        inkWidgetRef.SetScale(this.m_clueHolder[1], new Vector2(1.00, clueBarScaleY));
        inkWidgetRef.SetOpacity(this.m_clueHolder[2], clueBarOpacity);
        inkWidgetRef.SetScale(this.m_clueHolder[2], new Vector2(1.00, clueBarScaleY));
        break;
      case gameuiEBraindanceLayer.Thermal:
        localizedLayerName = "UI-ResourceExports-BraindanceThermalLayerName";
        layerIconName = n"braindance_thermal_icon";
        cursorPointMargin.top = -10.00;
        inkWidgetRef.SetOpacity(this.m_clueHolder[0], clueBarOpacity);
        inkWidgetRef.SetOpacity(this.m_clueHolder[1], 1.00);
        inkWidgetRef.SetOpacity(this.m_clueHolder[2], clueBarOpacity);
        inkWidgetRef.SetScale(this.m_clueHolder[0], new Vector2(1.00, clueBarScaleY));
        inkWidgetRef.SetScale(this.m_clueHolder[1], new Vector2(1.00, 1.00));
        inkWidgetRef.SetScale(this.m_clueHolder[2], new Vector2(1.00, clueBarScaleY));
        break;
      case gameuiEBraindanceLayer.Audio:
        localizedLayerName = "LocKey#23590";
        layerIconName = n"braindance_sound_icon";
        cursorPointMargin.top = 25.00;
        inkWidgetRef.SetOpacity(this.m_clueHolder[0], clueBarOpacity);
        inkWidgetRef.SetOpacity(this.m_clueHolder[1], clueBarOpacity);
        inkWidgetRef.SetOpacity(this.m_clueHolder[2], 1.00);
        inkWidgetRef.SetScale(this.m_clueHolder[0], new Vector2(1.00, clueBarScaleY));
        inkWidgetRef.SetScale(this.m_clueHolder[1], new Vector2(1.00, clueBarScaleY));
        inkWidgetRef.SetScale(this.m_clueHolder[2], new Vector2(1.00, 1.00));
    };
    localizedLayerName = GetLocalizedText(localizedLayerName);
    inkTextRef.SetLetterCase(this.m_activeLayer, textLetterCase.UpperCase);
    inkTextRef.SetText(this.m_activeLayer, localizedLayerName);
    inkImageRef.SetTexturePart(this.m_layerIcon, layerIconName);
    layerStateName = this.GetStateName(this.m_currentLayer);
    inkWidgetRef.SetState(this.m_layerIcon, layerStateName);
    inkWidgetRef.SetState(this.m_layerThermalIcon, layerStateName);
    inkWidgetRef.SetState(this.m_layerVisualIcon, layerStateName);
    inkWidgetRef.SetState(this.m_layerAudioIcon, layerStateName);
    inkWidgetRef.SetState(this.m_activeLayer, layerStateName);
    inkWidgetRef.SetState(this.m_currentTimerMarker, layerStateName);
    inkWidgetRef.SetMargin(this.m_cursorPoint, cursorPointMargin);
    i = 0;
    while i < ArraySize(this.m_clueBarHolder) {
      barController = inkWidgetRef.GetController(this.m_clueBarHolder[i]) as BraindanceBarLogicController;
      barController.UpdateActiveLayer(this.m_currentLayer);
      i += 1;
    };
  }

  private final func UpdateClues() -> Void {
    let controller: wref<BraindanceClueLogicController>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_clueArray) {
      controller = this.m_clueArray[i];
      controller.UpdateLayer(this.m_currentLayer);
      controller.UpdateTimeWindow(this.m_currentTime * this.m_braindanceDuration);
      i += 1;
    };
  }

  private final func GetStateName(stateEnum: gameuiEBraindanceLayer) -> CName {
    switch stateEnum {
      case gameuiEBraindanceLayer.Visual:
        return n"Visual";
      case gameuiEBraindanceLayer.Audio:
        return n"Audio";
      case gameuiEBraindanceLayer.Thermal:
        return n"Thermal";
    };
    return n"Default";
  }

  private final func GetLeftShoulderLocKey() -> CName {
    return this.m_isFPPMode ? n"UI-ScriptExports-EditorMode" : n"UI-ScriptExports-PlaybackMode";
  }

  private final func ShowInputHint(action: CName, label: CName) -> Void {
    let data: InputHintData;
    data.action = action;
    data.source = n"Braindance";
    data.localizedLabel = GetLocalizedTextByKey(label);
    let evt: ref<UpdateInputHintEvent> = new UpdateInputHintEvent();
    evt.data = data;
    evt.show = true;
    evt.targetHintContainer = n"GameplayInputHelper";
    GameInstance.GetUISystem(this.m_gameInstance).QueueEvent(evt);
  }

  private final func HideInputHint(action: CName) -> Void {
    let data: InputHintData;
    data.action = action;
    data.source = n"Braindance";
    let evt: ref<UpdateInputHintEvent> = new UpdateInputHintEvent();
    evt.data = data;
    evt.show = false;
    evt.targetHintContainer = n"GameplayInputHelper";
    GameInstance.GetUISystem(this.m_gameInstance).QueueEvent(evt);
  }

  private final func Intro() -> Void {
    this.m_rootWidget.SetVisible(true);
    this.m_showWidgetAnimation = this.PlayLibraryAnimation(n"SHOW");
  }

  private final func Outro() -> Void {
    this.Hide();
  }

  public final func Hide() -> Void {
    this.m_rootWidget.SetVisible(false);
  }

  private final func GetTimeMS(seconds: Float) -> String {
    let secondsLeft: Int32;
    let secondsString: String;
    let minutesLeft: Int32 = Cast(seconds) / 60;
    let minutesString: String = minutesLeft >= 10 ? "" : "0";
    minutesString += ToString(minutesLeft);
    secondsLeft = Cast(seconds) % 60;
    secondsString = secondsLeft >= 10 ? "" : "0";
    secondsString += ToString(secondsLeft);
    return minutesString + ":" + secondsString;
  }
}

public class BraindanceClueLogicController extends inkLogicController {

  private edit let bg: inkWidgetRef;

  private edit let m_timelineActiveAnimationName: CName;

  private edit let m_timelineDisabledAnimationName: CName;

  private let m_timelineActiveAnimation: ref<inkAnimProxy>;

  private let m_timelineDisabledAnimation: ref<inkAnimProxy>;

  private let m_state: ClueState;

  private let m_data: BraindanceClueData;

  private let m_isInLayer: Bool;

  private let m_isInTimeWindow: Bool;

  protected cb func OnInitialize() -> Bool;

  public final func SetupData(width: Float, data: BraindanceClueData) -> Void {
    let newSize: Vector2;
    this.m_data = data;
    let currentSize: Vector2 = inkWidgetRef.GetSize(this.bg);
    newSize.X = width;
    newSize.Y = currentSize.Y;
    inkWidgetRef.SetSize(this.bg, newSize);
    this.GetRootWidget().SetSize(newSize);
  }

  public final func UpdateLayer(layer: gameuiEBraindanceLayer) -> Void {
    this.m_isInLayer = Equals(this.m_data.layer, layer);
    this.UpdateOpacity();
  }

  public final func UpdateTimeWindow(currentTime: Float) -> Void {
    this.m_isInTimeWindow = this.m_data.startTime <= currentTime && currentTime <= this.m_data.startTime + this.m_data.duration;
    this.UpdateOpacity();
  }

  private final func UpdateOpacity() -> Void {
    let totalOpacity: Float = 0.60;
    if this.m_isInLayer {
      totalOpacity = 0.70;
      if this.m_isInTimeWindow {
        totalOpacity = 1.00;
      };
    };
    this.GetRootWidget().SetOpacity(totalOpacity);
  }

  public final func HideClue() -> Void {
    if this.GetRootWidget().IsVisible() {
      this.GetRootWidget().SetVisible(false);
    };
  }

  public final func GetBraindanceClueId() -> CName {
    return this.m_data.id;
  }

  public final func GetBraindanceClueState() -> ClueState {
    return this.m_data.state;
  }
}

public class SpeedIndicatorIconsManager extends inkLogicController {

  private edit let m_speedIndicator: inkImageRef;

  private edit let m_mirroredSpeedIndicator: inkImageRef;

  public final func SetBraindanceSpeed(currentSpeed: scnPlaySpeed, currentDirection: scnPlayDirection) -> Void {
    let hiddenInkWidget: inkImageRef;
    let newIconPart: CName;
    let selectedInkWidget: inkImageRef;
    let translationIntensity: Float;
    let translationSign: Int32;
    let speed: Int32 = EnumInt(currentSpeed);
    if Equals(currentSpeed, scnPlaySpeed.Pause) {
      newIconPart = n"pause";
      selectedInkWidget = this.m_speedIndicator;
      hiddenInkWidget = this.m_mirroredSpeedIndicator;
      translationSign = 1;
      translationIntensity = 0.00;
    } else {
      if NotEquals(currentDirection, scnPlayDirection.Forward) {
        selectedInkWidget = this.m_speedIndicator;
        hiddenInkWidget = this.m_mirroredSpeedIndicator;
        translationSign = -1;
      } else {
        selectedInkWidget = this.m_mirroredSpeedIndicator;
        hiddenInkWidget = this.m_speedIndicator;
        translationSign = 1;
      };
      switch speed {
        case 1:
          newIconPart = n"speed_1";
          translationIntensity = 0.00;
          break;
        case 2:
          newIconPart = n"speed_2";
          translationIntensity = 15.00;
          break;
        case 3:
          newIconPart = n"speed_3";
          translationIntensity = 30.00;
      };
    };
    inkImageRef.SetTexturePart(selectedInkWidget, newIconPart);
    inkWidgetRef.SetTranslation(selectedInkWidget, Cast(translationSign) * translationIntensity, 0.00);
    inkWidgetRef.SetVisible(selectedInkWidget, true);
    inkWidgetRef.SetVisible(hiddenInkWidget, false);
  }
}

public class BraindanceBarLogicController extends inkLogicController {

  private let m_layer: gameuiEBraindanceLayer;

  private let m_isInLayer: Bool;

  private edit let m_timelineActiveAnimationName: CName;

  private edit let m_timelineDisabledAnimationName: CName;

  private let m_timelineActiveAnimation: ref<inkAnimProxy>;

  private let m_timelineDisabledAnimation: ref<inkAnimProxy>;

  public final func SetBarLayer(layer: gameuiEBraindanceLayer, stateLayerName: CName) -> Void {
    this.m_layer = layer;
    this.GetRootWidget().SetState(stateLayerName);
  }

  public final func UpdateActiveLayer(layer: gameuiEBraindanceLayer) -> Void {
    this.m_isInLayer = Equals(this.m_layer, layer);
    this.UpdateOpacity();
  }

  private final func UpdateOpacity() -> Void {
    let totalOpacity: Float = 0.30;
    if this.m_isInLayer {
      totalOpacity = 0.65;
      this.m_timelineActiveAnimation = this.PlayLibraryAnimation(this.m_timelineActiveAnimationName);
    } else {
      this.m_timelineDisabledAnimation = this.PlayLibraryAnimation(this.m_timelineDisabledAnimationName);
    };
    this.GetRootWidget().SetOpacity(totalOpacity);
  }
}
