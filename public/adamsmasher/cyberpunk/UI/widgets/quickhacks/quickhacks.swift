
public class QuickhacksListGameController extends inkHUDGameController {

  private edit let m_timeBetweenIntroAndIntroDescription: Float;

  private let m_timeBetweenIntroAndDescritpionDelayID: DelayID;

  private let m_timeBetweenIntroAndDescritpionCheck: Bool;

  private let m_introDescriptionAnimProxy: ref<inkAnimProxy>;

  private edit let m_middleDots: inkWidgetRef;

  private edit let m_memoryWidget: inkWidgetRef;

  private edit let m_avaliableMemory: inkTextRef;

  private edit let m_listWidget: inkWidgetRef;

  private edit let m_executeBtn: inkWidgetRef;

  private edit let m_executeAndCloseBtn: inkWidgetRef;

  private edit let m_rightPanel: inkWidgetRef;

  private edit let m_networkBreach: inkWidgetRef;

  private edit let m_costReductionPanel: inkWidgetRef;

  private edit let m_costReductionValue: inkTextRef;

  private edit let m_targetName: inkTextRef;

  private edit let m_icePanel: inkWidgetRef;

  private edit let m_iceValue: inkTextRef;

  private edit let m_vulnerabilitiesPanel: inkWidgetRef;

  private edit const let m_vulnerabilityFields: array<inkWidgetRef>;

  private edit let m_subHeader: inkTextRef;

  private edit let m_tier: inkTextRef;

  private edit let m_description: inkTextRef;

  private edit let m_recompileTimer: inkTextRef;

  private edit let m_damage: inkTextRef;

  private edit let m_duration: inkTextRef;

  private edit let m_cooldown: inkTextRef;

  private edit let m_uploadTime: inkTextRef;

  private edit let m_memoryCost: inkTextRef;

  private edit let m_memoryRawCost: inkTextRef;

  private edit let m_warningWidget: inkWidgetRef;

  private edit let m_warningText: inkTextRef;

  private edit let m_recompilePanel: inkWidgetRef;

  private edit let m_recompileText: inkTextRef;

  private let m_isUILocked: Bool;

  private let m_gameInstance: GameInstance;

  private let m_visionModeSystem: wref<VisionModeSystem>;

  private let m_scanningCtrl: wref<ScanningController>;

  private let m_uiSystem: ref<UISystem>;

  private let m_contextHelpOverlay: Bool;

  private let m_quickHackDescriptionVisibility: Uint32;

  private let m_buffListListener: ref<CallbackHandle>;

  private let m_memoryBoard: wref<IBlackboard>;

  private let m_memoryBoardDef: ref<UI_PlayerBioMonitorDef>;

  private let m_memoryPercentListener: ref<CallbackHandle>;

  private let m_quickhackBarArray: array<wref<inkCompoundWidget>>;

  private let m_maxQuickhackBars: Int32;

  private let m_listController: wref<ListController>;

  private let m_data: array<ref<QuickhackData>>;

  private let m_selectedData: ref<QuickhackData>;

  @default(QuickhacksListGameController, false)
  private let m_active: Bool;

  private let m_memorySpendAnimation: ref<inkAnimProxy>;

  @default(QuickhacksListGameController, -1)
  private let m_currentMemoryCellsActive: Int32;

  @default(QuickhacksListGameController, -1)
  private let m_desiredMemoryCellsActive: Int32;

  private let m_selectedMemoryLoop: array<ref<inkAnimProxy>>;

  private let inkIntroAnimProxy: ref<inkAnimProxy>;

  private let inkVulnerabilityAnimProxy: ref<inkAnimProxy>;

  private let inkWarningAnimProxy: ref<inkAnimProxy>;

  private let inkRecompileAnimProxy: ref<inkAnimProxy>;

  private let inkReductionAnimProxy: ref<inkAnimProxy>;

  private let HACK_wasPlayedOnTarget: Bool;

  private let inkMemoryWarningTransitionAnimProxy: ref<inkAnimProxy>;

  private let m_lastMemoryWarningTransitionAnimName: CName;

  private let m_hasActiveUpload: Bool;

  private let m_lastCompiledTarget: EntityID;

  private let m_statPoolListenersIndexes: array<Int32>;

  protected let m_chunkBlackboard: wref<IBlackboard>;

  private let m_nameCallbackID: ref<CallbackHandle>;

  private let m_lastFillCells: Int32;

  private let m_lastUsedCells: Int32;

  private let m_lastMaxCells: Int32;

  private let m_axisInputConsumed: Bool;

  public let m_playerObject: wref<GameObject>;

  protected cb func OnInitialize() -> Bool {
    this.m_listController = inkWidgetRef.GetController(this.m_listWidget) as ListController;
    this.m_listController.RegisterToCallback(n"OnItemSelected", this, n"OnItemSelected");
    this.m_memoryBoardDef = GetAllBlackboardDefs().UI_PlayerBioMonitor;
    this.m_memoryBoard = this.GetBlackboardSystem().Get(this.m_memoryBoardDef);
    this.m_memoryPercentListener = this.m_memoryBoard.RegisterDelayedListenerFloat(this.m_memoryBoardDef.MemoryPercent, this, n"OnMemoryPercentUpdate");
    this.m_memoryBoard.Signal(this.m_memoryBoardDef.MemoryPercent);
    this.m_gameInstance = (this.GetOwnerEntity() as PlayerPuppet).GetGame();
    this.m_visionModeSystem = GameInstance.GetVisionModeSystem(this.m_gameInstance);
    this.m_scanningCtrl = this.m_visionModeSystem.GetScanningController();
    this.m_uiSystem = GameInstance.GetUISystem(this.m_gameInstance);
    this.m_chunkBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_ScannerModules);
    if IsDefined(this.m_chunkBlackboard) {
      this.m_nameCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerName, this, n"OnTargetDisplayNameChanged");
    };
    this.SetupQuickhacksMemoryBar();
    this.GetRootWidget().SetVisible(false);
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_memoryBoard) && IsDefined(this.m_memoryPercentListener) {
      this.m_memoryBoard.UnregisterDelayedListener(this.m_memoryBoardDef.MemoryPercent, this.m_memoryPercentListener);
    };
    if IsDefined(this.m_chunkBlackboard) && IsDefined(this.m_nameCallbackID) {
      this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerName, this.m_nameCallbackID);
    };
    this.SetVisibility(false);
  }

  protected cb func OnTargetDisplayNameChanged(value: Variant) -> Bool {
    let displayNmae: String;
    let nameData: ref<ScannerName> = FromVariant(value);
    if IsDefined(nameData) {
      displayNmae = nameData.GetDisplayName();
      if IsDefined(nameData.GetTextParams()) {
        inkTextRef.SetLocalizedTextScript(this.m_targetName, displayNmae, nameData.GetTextParams());
      } else {
        inkTextRef.SetText(this.m_targetName, displayNmae);
      };
    };
  }

  protected cb func OnQuickhackStarted(value: ref<RevealInteractionWheel>) -> Bool {
    if value.shouldReveal {
      this.m_data = value.commands;
      if !value.shouldReveal || NotEquals(this.GetPlayerControlledObject().GetHudManager().GetActiveMode(), ActiveMode.FOCUS) {
        return false;
      };
      if IsDefined(value.lookAtObject) {
        this.m_hasActiveUpload = value.lookAtObject.HasActiveQuickHackUpload();
      } else {
        this.m_hasActiveUpload = false;
      };
      this.PopulateData(this.m_data);
      this.SetVisibility(true);
      this.RegisterCooldownStatPoolUpdate();
    } else {
      this.SetVisibility(false);
    };
  }

  protected cb func OnItemSelected(index: Int32, itemController: ref<ListItemController>) -> Bool {
    this.SelectData(itemController.GetData() as QuickhackData);
    this.m_memoryBoard.Signal(this.m_memoryBoardDef.MemoryPercent);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    let actionName: CName;
    let isReleased: Bool = Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_PRESSED) || Equals(ListenerAction.GetType(action), gameinputActionType.AXIS_CHANGE);
    let isMinigameActive: Bool = this.GetPlayerControlledObject().GetHudManager().IsHackingMinigameActive();
    if isReleased && !isMinigameActive && !this.m_isUILocked {
      actionName = ListenerAction.GetName(action);
      switch actionName {
        case n"UI_MoveDown":
          this.m_listController.Next();
          break;
        case n"UI_MoveUp":
          this.m_listController.Prior();
          break;
        case n"context_help":
          this.ToggleTutorialOverlay();
          break;
        case n"UI_ApplyAndClose":
          this.ApplyQuickHack();
          break;
        default:
      };
    };
  }

  private final func ToggleTutorialOverlay() -> Void {
    if !this.m_contextHelpOverlay && !this.m_active {
      return;
    };
    this.m_contextHelpOverlay = !this.m_contextHelpOverlay;
    this.ShowTutorialOverlay(this.m_contextHelpOverlay);
  }

  private final func ShowTutorialOverlay(value: Bool) -> Void {
    let data: TutorialOverlayData;
    data.itemName = n"Root";
    data.widgetLibraryResource = r"base\\gameplay\\gui\\widgets\\tutorial\\vr_quickhacks_tutorial.inkwidget";
    this.m_contextHelpOverlay = value;
    if this.m_contextHelpOverlay {
      this.m_uiSystem.ShowTutorialOverlay(data);
    } else {
      this.m_uiSystem.HideTutorialOverlay(data);
    };
  }

  private final func SelectData(data: ref<QuickhackData>) -> Void {
    this.m_selectedData = data;
    let description: String = GetLocalizedText(this.m_selectedData.m_description);
    inkTextRef.SetText(this.m_subHeader, GetLocalizedText(this.m_selectedData.m_title));
    if this.m_selectedData.m_isLocked && this.m_selectedData.m_actionMatchesTarget && this.m_hasActiveUpload {
      inkWidgetRef.SetState(this.m_executeBtn, n"Disabled");
      inkWidgetRef.SetState(this.m_executeAndCloseBtn, n"Disabled");
      inkWidgetRef.SetState(this.m_description, n"Locked");
      inkWidgetRef.SetState(this.m_subHeader, n"Locked");
      if IsDefined(this.inkWarningAnimProxy) {
        this.inkWarningAnimProxy.Stop();
      };
      this.inkWarningAnimProxy = this.PlayLibraryAnimation(n"deviceOnly_hack", GetAnimOptionsInfiniteLoop(inkanimLoopType.Cycle));
      if NotEquals(this.m_lastMemoryWarningTransitionAnimName, n"memoryToWarning_transition") {
        if IsDefined(this.inkMemoryWarningTransitionAnimProxy) {
          this.inkMemoryWarningTransitionAnimProxy.Stop();
        };
        this.inkMemoryWarningTransitionAnimProxy = this.PlayLibraryAnimation(n"memoryToWarning_transition");
        this.m_lastMemoryWarningTransitionAnimName = n"memoryToWarning_transition";
      };
      this.ApplyQuickhackSelection();
      inkTextRef.SetText(this.m_warningText, GetLocalizedText(this.m_selectedData.m_inactiveReason));
    } else {
      if this.m_selectedData.m_isLocked {
        this.ResetQuickhackSelection();
        inkWidgetRef.SetState(this.m_executeBtn, n"Disabled");
        inkWidgetRef.SetState(this.m_executeAndCloseBtn, n"Disabled");
        inkWidgetRef.SetState(this.m_description, n"Locked");
        inkWidgetRef.SetState(this.m_subHeader, n"Locked");
        if IsDefined(this.inkWarningAnimProxy) {
          this.inkWarningAnimProxy.Stop();
        };
        this.inkWarningAnimProxy = this.PlayLibraryAnimation(n"deviceOnly_hack");
        if NotEquals(this.m_lastMemoryWarningTransitionAnimName, n"memoryToWarning_transition") {
          if IsDefined(this.inkMemoryWarningTransitionAnimProxy) {
            this.inkMemoryWarningTransitionAnimProxy.Stop();
          };
          this.inkMemoryWarningTransitionAnimProxy = this.PlayLibraryAnimation(n"memoryToWarning_transition");
          this.m_lastMemoryWarningTransitionAnimName = n"memoryToWarning_transition";
        };
        inkTextRef.SetText(this.m_warningText, GetLocalizedText(this.m_selectedData.m_inactiveReason));
      } else {
        inkWidgetRef.SetState(this.m_executeBtn, n"Default");
        inkWidgetRef.SetState(this.m_executeAndCloseBtn, n"Default");
        inkWidgetRef.SetState(this.m_description, n"Default");
        inkWidgetRef.SetState(this.m_subHeader, n"Default");
        this.ApplyQuickhackSelection();
        if IsDefined(this.inkWarningAnimProxy) {
          this.inkWarningAnimProxy.Stop();
        };
        this.inkWarningAnimProxy = this.PlayLibraryAnimation(n"warningOut");
        if NotEquals(this.m_lastMemoryWarningTransitionAnimName, n"warningToMemory_transition") {
          if IsDefined(this.inkMemoryWarningTransitionAnimProxy) {
            this.inkMemoryWarningTransitionAnimProxy.Stop();
          };
          this.inkMemoryWarningTransitionAnimProxy = this.PlayLibraryAnimation(n"warningToMemory_transition");
          this.m_lastMemoryWarningTransitionAnimName = n"warningToMemory_transition";
        };
      };
    };
    if !this.m_timeBetweenIntroAndDescritpionCheck {
    };
    inkTextRef.SetText(this.m_description, description);
    this.SetupTargetName();
    this.SetupTier();
    this.SetupVulnerabilities();
    this.SetupICE();
    this.SetupUploadTime();
    this.SetupDuration();
    this.SetupMaxCooldown();
    this.SetupMemoryCost();
    this.SetupMemoryCostDifferance();
    this.SetupNetworkBreach();
    if !this.IsCurrentSelectionOnStatPoolIndexes() {
      this.UpdateRecompileTime(false, 0.00);
    };
    GameInstance.GetBlackboardSystem(this.GetPlayerControlledObject().GetGame()).Get(GetAllBlackboardDefs().UI_QuickSlotsData).SetVariant(GetAllBlackboardDefs().UI_QuickSlotsData.quickHackDataSelected, ToVariant(this.m_selectedData), true);
  }

  private final func SetupTier() -> Void {
    let value: Int32 = this.m_selectedData.m_quality;
    let textParams: ref<inkTextParams> = new inkTextParams();
    textParams.AddNumber("VALUE", value);
    (inkWidgetRef.Get(this.m_tier) as inkText).SetLocalizedTextString("LocKey#40895", textParams);
  }

  private final func SetupMaxCooldown() -> Void {
    let value: Float = this.m_selectedData.m_cooldown;
    let textParams: ref<inkTextParams> = new inkTextParams();
    textParams.AddNumber("VALUE", value);
    textParams.AddLocalizedString("SEC", "LocKey#40730");
    (inkWidgetRef.Get(this.m_cooldown) as inkText).SetLocalizedTextString("LocKey#40729", textParams);
    if value == 0.00 {
      inkWidgetRef.SetState(this.m_cooldown, n"Locked");
    } else {
      inkWidgetRef.SetState(this.m_cooldown, n"Default");
    };
  }

  private final func SetupDuration() -> Void {
    let value: Float = this.m_selectedData.m_duration;
    let textParams: ref<inkTextParams> = new inkTextParams();
    textParams.AddNumber("VALUE", value);
    textParams.AddLocalizedString("SEC", "LocKey#40730");
    (inkWidgetRef.Get(this.m_duration) as inkText).SetLocalizedTextString("LocKey#40736", textParams);
    if value == 0.00 {
      inkWidgetRef.SetState(this.m_duration, n"Locked");
    } else {
      inkWidgetRef.SetState(this.m_duration, n"Default");
    };
  }

  private final func SetupUploadTime() -> Void {
    let value: Float = this.m_selectedData.m_uploadTime;
    let textParams: ref<inkTextParams> = new inkTextParams();
    textParams.AddNumber("VALUE", value);
    textParams.AddLocalizedString("SEC", "LocKey#40730");
    (inkWidgetRef.Get(this.m_uploadTime) as inkText).SetLocalizedTextString("LocKey#40737", textParams);
    if value == 0.00 {
      inkWidgetRef.SetState(this.m_uploadTime, n"Locked");
    } else {
      inkWidgetRef.SetState(this.m_uploadTime, n"Default");
    };
  }

  private final func SetupMemoryCost() -> Void {
    let textParams: ref<inkTextParams>;
    let value: Int32;
    inkTextRef.SetText(this.m_memoryCost, IntToString(this.m_selectedData.m_cost));
    value = this.m_selectedData.m_costRaw;
    textParams = new inkTextParams();
    textParams.AddNumber("VALUE", value);
    (inkWidgetRef.Get(this.m_memoryRawCost) as inkText).SetLocalizedTextString("LocKey#40804", textParams);
  }

  private final func SetupMemoryCostDifferance() -> Void {
    let reducedCost: Int32 = this.m_selectedData.m_costRaw - this.m_selectedData.m_cost;
    if reducedCost > 0 {
      inkTextRef.SetText(this.m_costReductionValue, IntToString(reducedCost));
      inkWidgetRef.SetVisible(this.m_costReductionPanel, true);
    } else {
      inkWidgetRef.SetVisible(this.m_costReductionPanel, false);
    };
  }

  private final func SetupNetworkBreach() -> Void {
    if this.m_selectedData.m_networkBreached {
      inkWidgetRef.SetVisible(this.m_networkBreach, true);
      if !this.HACK_wasPlayedOnTarget {
        if IsDefined(this.inkReductionAnimProxy) {
          this.inkReductionAnimProxy.Stop();
        };
        this.inkReductionAnimProxy = this.PlayLibraryAnimation(n"network_scan");
        this.HACK_wasPlayedOnTarget = true;
      };
    } else {
      inkWidgetRef.SetVisible(this.m_networkBreach, false);
      this.HACK_wasPlayedOnTarget = false;
    };
  }

  private final func SetupICE() -> Void {
    if this.m_selectedData.m_ICELevelVisible {
      inkTextRef.SetText(this.m_iceValue, IntToString(Cast(this.m_selectedData.m_ICELevel)));
    } else {
      inkTextRef.SetText(this.m_iceValue, "X");
    };
  }

  private final func SetupTargetName() -> Void {
    inkTextRef.SetText(this.m_targetName, ToString(this.m_selectedData.m_actionOwnerName));
  }

  private final func UpdateRecompileTime(isVisible: Bool, value: Float) -> Void {
    inkWidgetRef.SetVisible(this.m_recompilePanel, isVisible);
    inkTextRef.SetText(this.m_recompileText, FloatToString(value));
  }

  private final func SetupVulnerabilities() -> Void {
    let i: Int32;
    let vulnerabilityRecord: wref<ObjectActionGameplayCategory_Record>;
    if ArraySize(this.m_selectedData.m_vulnerabilities) == 0 {
      if inkWidgetRef.IsVisible(this.m_vulnerabilitiesPanel) && !this.IsIntroPlaying() {
        if IsDefined(this.inkVulnerabilityAnimProxy) {
          this.inkVulnerabilityAnimProxy.Stop();
        };
        this.inkVulnerabilityAnimProxy = this.PlayLibraryAnimation(n"vulnerabilityOut");
      };
      inkWidgetRef.SetVisible(this.m_vulnerabilitiesPanel, false);
      return;
    };
    if !inkWidgetRef.IsVisible(this.m_vulnerabilitiesPanel) && !this.IsIntroPlaying() {
      if IsDefined(this.inkVulnerabilityAnimProxy) {
        this.inkVulnerabilityAnimProxy.Stop();
      };
      this.inkVulnerabilityAnimProxy = this.PlayLibraryAnimation(n"vulnerabilityIn");
    };
    inkWidgetRef.SetVisible(this.m_vulnerabilitiesPanel, true);
    i = 0;
    while i < 4 {
      if i < ArraySize(this.m_selectedData.m_vulnerabilities) {
        vulnerabilityRecord = TweakDBInterface.GetObjectActionGameplayCategoryRecord(this.m_selectedData.m_vulnerabilities[i]);
        inkWidgetRef.SetVisible(this.m_vulnerabilityFields[i], true);
        (inkWidgetRef.GetController(this.m_vulnerabilityFields[i]) as QuickhacksVulnerabilityLogicController).SetText(vulnerabilityRecord.LocalizedDescription());
      } else {
        inkWidgetRef.SetVisible(this.m_vulnerabilityFields[i], false);
      };
      i += 1;
    };
  }

  private final func ApplyQuickHack() -> Bool {
    let cmd: ref<QuickSlotCommandUsed>;
    let hackUsed: ref<QhackExecuted>;
    this.PlayChoiceAnimation();
    if IsDefined(this.m_selectedData) && !this.m_selectedData.m_isLocked {
      cmd = new QuickSlotCommandUsed();
      cmd.action = this.m_selectedData.m_action;
      this.LogQuickHack();
      this.GetPlayerControlledObject().QueueEventForEntityID(this.m_selectedData.m_actionOwner, cmd);
      if this.GetPlayerControlledObject().GetTakeOverControlSystem().IsDeviceControlled() {
        hackUsed = new QhackExecuted();
        this.GetPlayerControlledObject().QueueEventForEntityID(this.GetPlayerControlledObject().GetTakeOverControlSystem().GetControlledObject().GetEntityID(), hackUsed);
      };
      return true;
    };
    return false;
  }

  private final func LogQuickHack() -> Void {
    let telemetryQuickHack: TelemetryQuickHack;
    let target: wref<GameObject> = GameInstance.FindEntityByID(this.m_gameInstance, this.m_selectedData.m_actionOwner) as GameObject;
    if !IsDefined(target) {
      return;
    };
    if target.IsPuppet() {
      telemetryQuickHack.targetType = "Puppet";
    } else {
      if target.IsSensor() {
        telemetryQuickHack.targetType = "Sensor";
      } else {
        if target.IsTurret() {
          telemetryQuickHack.targetType = "Turret";
        } else {
          if GameObject.IsVehicle(target) {
            telemetryQuickHack.targetType = "Vehicle";
          } else {
            telemetryQuickHack.targetType = "Other";
          };
        };
      };
    };
    telemetryQuickHack.actionName = this.m_selectedData.m_action.GetActionID();
    telemetryQuickHack.titleLocKey = this.m_selectedData.m_title;
    telemetryQuickHack.quickHackRecordID = this.m_selectedData.m_action.GetObjectActionID();
    telemetryQuickHack.quality = this.m_selectedData.m_quality;
    GameInstance.GetTelemetrySystem(this.m_gameInstance).LogQuickHack(telemetryQuickHack);
  }

  private final func PlayChoiceAnimation() -> Void {
    (this.m_listController.GetItemAt(this.m_listController.GetSelectedIndex()).GetController() as QuickhacksListItemController).PlayChoiceAcceptedAnimation();
  }

  private final func IsIntroPlaying() -> Bool {
    return this.inkIntroAnimProxy.IsPlaying();
  }

  private final func ApplyQuickhackSelection() -> Void {
    let itemChangedEvent: ref<QHackWheelItemChangedEvent>;
    if IsDefined(this.m_selectedData) {
      itemChangedEvent = new QHackWheelItemChangedEvent();
      itemChangedEvent.commandData = this.m_selectedData;
      itemChangedEvent.currentEmpty = false;
      this.GetOwnerEntity().QueueEventForEntityID(this.m_selectedData.m_actionOwner, itemChangedEvent);
    };
  }

  private final func ResetQuickhackSelection() -> Void {
    let itemChangedEvent: ref<QHackWheelItemChangedEvent>;
    if IsDefined(this.m_selectedData) {
      itemChangedEvent = new QHackWheelItemChangedEvent();
      itemChangedEvent.currentEmpty = true;
      this.GetOwnerEntity().QueueEventForEntityID(this.m_selectedData.m_actionOwner, itemChangedEvent);
    };
  }

  private final func SetVisibility(value: Bool) -> Void {
    let delayIntroDescritpio: ref<DelayedDescriptionIntro>;
    if value {
      if this.m_lastCompiledTarget != this.m_data[0].m_actionOwner {
        if EntityID.IsDefined(this.m_data[0].m_actionOwner) {
          this.m_lastCompiledTarget = this.m_data[0].m_actionOwner;
        };
      } else {
        return;
      };
      if !HUDManager.HasCurrentTarget(this.m_gameInstance) {
        return;
      };
      this.m_playerObject = this.GetPlayerControlledObject();
      if !IsDefined(this.m_playerObject) {
        return;
      };
      this.SetupQuickhacksMemoryBar();
      this.GetRootWidget().SetVisible(true);
      if IsDefined(this.inkIntroAnimProxy) && this.inkIntroAnimProxy.IsPlaying() {
        this.inkIntroAnimProxy.Stop();
      };
      this.inkIntroAnimProxy = this.PlayLibraryAnimation(n"intro");
      this.PlaySound(n"QuickHackMenu", n"OnOpen");
      if this.m_timeBetweenIntroAndDescritpionCheck {
        GameInstance.GetDelaySystem(this.m_playerObject.GetGame()).CancelDelay(this.m_timeBetweenIntroAndDescritpionDelayID);
      };
      if this.m_timeBetweenIntroAndIntroDescription != 0.00 {
        this.m_introDescriptionAnimProxy = this.PlayLibraryAnimation(n"outro_tooltip");
      };
      delayIntroDescritpio = new DelayedDescriptionIntro();
      this.m_timeBetweenIntroAndDescritpionDelayID = GameInstance.GetDelaySystem(this.m_playerObject.GetGame()).DelayEvent(this.m_playerObject, delayIntroDescritpio, this.m_timeBetweenIntroAndIntroDescription, false);
      this.m_timeBetweenIntroAndDescritpionCheck = true;
      if !this.m_active {
        this.m_playerObject.RegisterInputListener(this, n"UI_MoveDown");
        this.m_playerObject.RegisterInputListener(this, n"UI_MoveUp");
        this.m_playerObject.RegisterInputListener(this, n"context_help");
        this.m_playerObject.RegisterInputListener(this, n"UI_ApplyAndClose");
      };
      this.RequestTimeDilation(this.m_playerObject, n"quickHackScreen", true);
      this.m_memoryBoard.Signal(this.m_memoryBoardDef.MemoryPercent);
      this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_QuickSlotsData).SetBool(GetAllBlackboardDefs().UI_QuickSlotsData.quickhackPanelOpen, true);
      GameInstance.GetUISystem(this.m_gameInstance).RequestNewVisualState(n"inkQuickHackingState");
    } else {
      this.PlaySound(n"QuickHackMenu", n"OnClose");
      this.GetRootWidget().SetVisible(false);
      if IsDefined(this.m_playerObject) {
        GameInstance.GetTargetingSystem(this.m_playerObject.GetGame()).BreakLookAt(this.m_playerObject);
        if this.m_active {
          this.m_playerObject.UnregisterInputListener(this);
        };
        this.RequestTimeDilation(this.m_playerObject, n"quickHackScreen", false);
      };
      this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_QuickSlotsData).SetBool(GetAllBlackboardDefs().UI_QuickSlotsData.quickhackPanelOpen, false);
      this.m_playerObject = null;
      GameInstance.GetUISystem(this.m_gameInstance).RestorePreviousVisualState(n"inkQuickHackingState");
      this.ResetQuickhackSelection();
      if IsDefined(this.m_memorySpendAnimation) {
        this.m_memorySpendAnimation.UnregisterFromAllCallbacks(inkanimEventType.OnFinish);
      };
      this.m_currentMemoryCellsActive = -1;
      this.m_desiredMemoryCellsActive = -1;
      this.HACK_wasPlayedOnTarget = false;
      this.m_lastCompiledTarget = new EntityID();
      if this.m_contextHelpOverlay {
        this.ShowTutorialOverlay(false);
      };
    };
    this.m_active = value;
  }

  protected cb func OnDelayedDescriptionIntro(evt: ref<DelayedDescriptionIntro>) -> Bool {
    this.PlayDescritpionIntroAnimaton();
    this.m_timeBetweenIntroAndDescritpionCheck = false;
  }

  private final func PlayDescritpionIntroAnimaton() -> Void {
    if IsDefined(this.m_introDescriptionAnimProxy) && this.m_introDescriptionAnimProxy.IsPlaying() {
      this.m_introDescriptionAnimProxy.Stop();
    };
    this.m_introDescriptionAnimProxy = this.PlayLibraryAnimation(n"intro_tooltip");
  }

  private final func RequestTimeDilation(requester: wref<GameObject>, eventId: CName, val: Bool) -> Void {
    let psmEvent: ref<PSMPostponedParameterBool> = new PSMPostponedParameterBool();
    psmEvent.id = eventId;
    psmEvent.value = val;
    requester.QueueEvent(psmEvent);
  }

  private final func SetupQuickhacksMemoryBar() -> Void {
    (inkWidgetRef.Get(this.m_memoryWidget) as inkCompoundWidget).RemoveAllChildren();
    ArrayClear(this.m_quickhackBarArray);
    this.m_maxQuickhackBars = 0;
    this.UpdateQuickhacksMemoryBarSize(FloorF(GameInstance.GetStatsSystem(this.m_gameInstance).GetStatValue(Cast(this.GetPlayerControlledObject().GetEntityID()), gamedataStatType.Memory)));
    this.UpdateMemoryBar();
  }

  private final func UpdateQuickhacksMemoryBarSize(size: Int32) -> Void {
    let cell: wref<inkCompoundWidget>;
    let i: Int32;
    if size > this.m_maxQuickhackBars {
      i = this.m_maxQuickhackBars;
      while i < size {
        cell = this.SpawnFromLocal(inkWidgetRef.Get(this.m_memoryWidget) as inkCompoundWidget, n"memory_cell") as inkCompoundWidget;
        ArrayPush(this.m_quickhackBarArray, cell);
        i += 1;
      };
      this.m_maxQuickhackBars = size;
    };
  }

  protected cb func OnMemoryPercentUpdate(value: Float) -> Bool {
    let fillCells: Int32;
    let maxCells: Int32;
    let usedCells: Int32;
    if IsDefined(this.m_selectedData) {
      usedCells = this.m_selectedData.m_cost;
    };
    maxCells = FloorF(GameInstance.GetStatsSystem(this.m_gameInstance).GetStatValue(Cast(this.GetPlayerControlledObject().GetEntityID()), gamedataStatType.Memory));
    fillCells = FloorF(Cast(maxCells) * value * 0.01);
    if !this.GetRootWidget().IsVisible() || this.m_lastFillCells == fillCells && this.m_lastUsedCells == usedCells && this.m_lastMaxCells == maxCells {
      return false;
    };
    this.m_lastFillCells = fillCells;
    this.m_lastUsedCells = usedCells;
    this.m_lastMaxCells = maxCells;
    this.UpdateMemoryBar();
  }

  private final func UpdateMemoryBar() -> Void {
    let i: Int32;
    let textureWidget: wref<inkImage>;
    this.UpdateQuickhacksMemoryBarSize(this.m_lastMaxCells);
    inkTextRef.SetText(this.m_avaliableMemory, GetLocalizedText("UI-ResourceExports-CyberdeckMemory") + ": " + this.m_lastFillCells + "/" + this.m_lastMaxCells);
    i = 0;
    while i < ArraySize(this.m_selectedMemoryLoop) {
      this.m_selectedMemoryLoop[i].Stop();
      this.m_selectedMemoryLoop[i] = null;
      i += 1;
    };
    ArrayClear(this.m_selectedMemoryLoop);
    i = 0;
    while i < ArraySize(this.m_quickhackBarArray) {
      if i >= this.m_lastMaxCells {
        this.m_quickhackBarArray[i].SetVisible(false);
      } else {
        textureWidget = this.m_quickhackBarArray[i].GetWidgetByIndex(0) as inkImage;
        if i < this.m_lastFillCells {
          if i >= this.m_lastFillCells - this.m_lastUsedCells {
            this.m_quickhackBarArray[i].SetState(n"Used");
            this.PlayLibraryAnimationOnTargets(n"memorySelected_out", SelectWidgets(this.m_quickhackBarArray[i]));
            ArrayPush(this.m_selectedMemoryLoop, this.PlayLibraryAnimationOnTargets(n"memorySelected", SelectWidgets(this.m_quickhackBarArray[i]), GetAnimOptionsInfiniteLoop(inkanimLoopType.Cycle)));
          } else {
            this.m_quickhackBarArray[i].SetState(n"Default");
            this.PlayLibraryAnimationOnTargets(n"memorySelected_out", SelectWidgets(this.m_quickhackBarArray[i]));
          };
          textureWidget.SetTexturePart(n"charge_free");
        } else {
          textureWidget.SetTexturePart(n"charge_empty");
          this.m_quickhackBarArray[i].SetState(n"Empty");
          this.PlayLibraryAnimationOnTargets(n"memorySelected_out", SelectWidgets(this.m_quickhackBarArray[i]));
        };
        this.m_quickhackBarArray[i].SetVisible(true);
      };
      i += 1;
    };
    this.DeplenishMemoryCells(this.m_lastFillCells);
  }

  private final func DeplenishMemoryCells(currentMemory: Int32) -> Void {
    this.m_desiredMemoryCellsActive = currentMemory;
    if this.m_currentMemoryCellsActive < 0 {
      this.m_currentMemoryCellsActive = currentMemory;
      return;
    };
    this.OnDeplenishMemoryCells();
  }

  protected cb func OnDeplenishMemoryCells(opt e: ref<inkAnimProxy>) -> Bool {
    if IsDefined(this.m_memorySpendAnimation) {
      this.m_memorySpendAnimation.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnDeplenishMemoryCells");
      this.m_memorySpendAnimation = null;
    };
    if this.m_currentMemoryCellsActive > this.m_desiredMemoryCellsActive {
      this.m_memorySpendAnimation = this.PlayLibraryAnimationOnTargets(n"memorySpend", SelectWidgets(this.m_quickhackBarArray[this.m_currentMemoryCellsActive - 1]));
      this.m_memorySpendAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnDeplenishMemoryCells");
      this.m_currentMemoryCellsActive -= 1;
    };
  }

  private final func PopulateData(data: array<ref<QuickhackData>>) -> Void {
    let count: Int32;
    let i: Int32;
    this.m_lastMemoryWarningTransitionAnimName = n"";
    this.m_listController.Clear(false);
    count = ArraySize(data);
    i = 0;
    while i < count {
      data[i].m_maxListSize = count;
      this.m_listController.PushData(data[i], false);
      i += 1;
    };
    this.m_listController.Refresh();
    if this.m_lastCompiledTarget != this.m_data[0].m_actionOwner || !this.m_listController.HasValidSelection() {
      this.m_listController.SetSelectedIndex(0, true);
    } else {
      this.m_listController.SetSelectedIndex(this.m_listController.GetSelectedIndex(), true);
    };
    if count == 1 && Equals(data[0].m_actionState, EActionInactivityReson.Invalid) {
      inkWidgetRef.SetVisible(this.m_middleDots, true);
    } else {
      inkWidgetRef.SetVisible(this.m_middleDots, false);
    };
  }

  private final func RegisterCooldownStatPoolUpdate() -> Bool {
    let i: Int32;
    let i1: Int32;
    let buffList: array<BuffInfo> = FromVariant(this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_PlayerBioMonitor).GetVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.DebuffsList));
    ArrayClear(this.m_statPoolListenersIndexes);
    if ArraySize(buffList) == 0 {
      return false;
    };
    i = 0;
    while i < ArraySize(this.m_data) {
      i1 = 0;
      while i1 < ArraySize(buffList) {
        if !TDBID.IsValid(this.m_data[i].m_cooldownTweak) || !TDBID.IsValid(buffList[i1].buffID) {
        } else {
          if buffList[i1].buffID == this.m_data[i].m_cooldownTweak {
            if !ArrayContains(this.m_statPoolListenersIndexes, i) {
              ArrayPush(this.m_statPoolListenersIndexes, i);
            };
          } else {
            i1 += 1;
          };
        };
      };
      i += 1;
    };
    if ArraySize(this.m_statPoolListenersIndexes) == 0 {
      this.UnregisterCooldownStatPoolUpdate();
      return false;
    };
    if !IsDefined(this.m_buffListListener) {
      this.m_buffListListener = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_PlayerBioMonitor).RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.DebuffsList, this, n"OnCooldownStatPoolUpdate");
    };
    return true;
  }

  private final func UnregisterCooldownStatPoolUpdate() -> Void {
    let i: Int32;
    if IsDefined(this.m_buffListListener) {
      this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_PlayerBioMonitor).UnregisterDelayedListener(GetAllBlackboardDefs().UI_PlayerBioMonitor.DebuffsList, this.m_buffListListener);
      i = 0;
      while i < ArraySize(this.m_statPoolListenersIndexes) {
        (this.m_listController.GetItemAt(this.m_statPoolListenersIndexes[i]).GetController() as QuickhacksListItemController).SetCooldownVisibility(false);
        i += 1;
      };
      this.UpdateRecompileTime(false, 0.00);
    };
  }

  protected cb func OnCooldownStatPoolUpdate(value: Variant) -> Bool {
    let i: Int32;
    let i1: Int32;
    let wasMatched: Bool;
    let buffList: array<BuffInfo> = FromVariant(value);
    if ArraySize(buffList) == 0 {
      this.UnregisterCooldownStatPoolUpdate();
      QuickhackModule.RequestRefreshQuickhackMenu(this.GetPlayerControlledObject().GetGame(), this.m_data[0].m_actionOwner);
      return false;
    };
    i = ArraySize(this.m_statPoolListenersIndexes) - 1;
    while i >= 0 {
      wasMatched = false;
      i1 = 0;
      while i1 < ArraySize(buffList) {
        if buffList[i1].buffID == this.m_data[this.m_statPoolListenersIndexes[i]].m_cooldownTweak {
          (this.m_listController.GetItemAt(this.m_statPoolListenersIndexes[i]).GetController() as QuickhacksListItemController).UpdateCooldown(buffList[i1].timeRemaining);
          wasMatched = true;
          if this.IsCurrentSelectionOnStatPoolIndexes(i) {
            this.UpdateRecompileTime(true, buffList[i1].timeRemaining);
          };
        } else {
          i1 += 1;
        };
      };
      if !wasMatched {
        (this.m_listController.GetItemAt(this.m_statPoolListenersIndexes[i]).GetController() as QuickhacksListItemController).SetCooldownVisibility(false);
        if this.IsCurrentSelectionOnStatPoolIndexes(i) {
          this.UpdateRecompileTime(false, buffList[i1].timeRemaining);
        };
        ArrayErase(this.m_statPoolListenersIndexes, i);
        QuickhackModule.RequestRefreshQuickhackMenu(this.GetPlayerControlledObject().GetGame(), this.m_data[0].m_actionOwner);
      };
      i -= 1;
    };
  }

  private final func IsCurrentSelectionOnStatPoolIndexes() -> Bool {
    let i: Int32 = ArraySize(this.m_statPoolListenersIndexes) - 1;
    while i >= 0 {
      if this.m_data[this.m_statPoolListenersIndexes[i]].m_cooldownTweak == this.m_selectedData.m_cooldownTweak {
        return true;
      };
      i -= 1;
    };
    return false;
  }

  private final func IsCurrentSelectionOnStatPoolIndexes(index: Int32) -> Bool {
    return this.m_data[this.m_statPoolListenersIndexes[index]].m_cooldownTweak == this.m_selectedData.m_cooldownTweak;
  }

  public final static func EActionInactivityResonToLocalizationString(value: EActionInactivityReson) -> String {
    switch value {
      case EActionInactivityReson.Ready:
        return "LocKey#40763";
      case EActionInactivityReson.Locked:
        return "LocKey#40765";
      case EActionInactivityReson.Recompilation:
        return "LocKey#40766";
      case EActionInactivityReson.OutOfMemory:
        return "LocKey#40767";
      case EActionInactivityReson.Invalid:
        return "LocKey#40764";
    };
  }

  protected cb func OnQuickHackScreenOpen(evt: ref<QuickHackScreenOpen>) -> Bool {
    if evt.setToOpen {
      QuickhackModule.RequestCloseQuickhackMenu(this.GetPlayerControlledObject().GetGame(), this.GetPlayerControlledObject().GetEntityID());
    } else {
      this.SetVisibility(false);
    };
  }

  protected cb func OnQuickHackTimeDilationOverride(evt: ref<QuickHackTimeDilationOverride>) -> Bool {
    GameInstance.GetBlackboardSystem(this.m_playerObject.GetGame()).GetLocalInstanced(this.m_playerObject.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine).SetBool(GetAllBlackboardDefs().PlayerStateMachine.OverrideQuickHackPanelDilation, evt.overrideDilationToTutorialPreset);
  }

  protected cb func OnQuickHackLockHacks(evt: ref<QuickHackLockHacks>) -> Bool {
    this.m_isUILocked = evt.IsLocked;
    HUDManager.LockQHackInput(this.GetPlayerControlledObject().GetGame(), this.m_isUILocked);
  }
}

public class QuickHackScreenOpen extends Event {

  @attrib(tooltip, "Open or close Quick Hack menu. SetToOpen == true means open | SetToOpen == false means close")
  public edit let setToOpen: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Control QuickHack menu visibility";
  }
}

public class QuickHackTimeDilationOverride extends Event {

  @attrib(tooltip, "Time that will be set")
  public edit let overrideDilationToTutorialPreset: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Change time dilation when QuickHack menu is opened to tutorial preset";
  }
}

public class QuickHackLockHacks extends Event {

  @attrib(tooltip, "Is lock active")
  public edit let IsLocked: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Lock QHack menu that player cannot hack anything as long as lock is on";
  }
}

public class QuickhacksVulnerabilityLogicController extends inkLogicController {

  private edit let m_textField: inkTextRef;

  public final func SetText(locKey: CName) -> Void {
    inkTextRef.SetLocalizedTextScript(this.m_textField, locKey);
  }
}
