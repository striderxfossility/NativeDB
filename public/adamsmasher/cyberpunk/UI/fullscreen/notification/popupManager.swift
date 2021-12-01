
public native class PopupsManager extends inkGameController {

  private let m_blackboard: wref<IBlackboard>;

  private let m_bbDefinition: ref<UIGameDataDef>;

  public let m_journalManager: wref<JournalManager>;

  private let m_uiSystemBB: wref<IBlackboard>;

  private let m_uiSystemBBDef: ref<UI_SystemDef>;

  private let m_uiSystemId: ref<CallbackHandle>;

  private let m_isShownBbId: ref<CallbackHandle>;

  private let m_dataBbId: ref<CallbackHandle>;

  private let m_tutorialOnHold: Bool;

  private let m_tutorialData: PopupData;

  private let m_tutorialSettings: PopupSettings;

  private let m_tutorialToken: ref<inkGameNotificationToken>;

  private let m_phoneMessageToken: ref<inkGameNotificationToken>;

  private let m_shardToken: ref<inkGameNotificationToken>;

  private let m_vehiclesManagerToken: ref<inkGameNotificationToken>;

  private let m_vehicleRadioToken: ref<inkGameNotificationToken>;

  private let m_codexToken: ref<inkGameNotificationToken>;

  private let m_ponrToken: ref<inkGameNotificationToken>;

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_blackboard = this.GetUIBlackboard();
    this.m_bbDefinition = GetAllBlackboardDefs().UIGameData;
    this.m_journalManager = GameInstance.GetJournalManager(playerPuppet.GetGame());
    this.m_uiSystemBB = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_System);
    this.m_uiSystemBBDef = GetAllBlackboardDefs().UI_System;
    this.m_uiSystemId = this.m_uiSystemBB.RegisterListenerBool(this.m_uiSystemBBDef.IsInMenu, this, n"OnMenuUpdate");
    this.m_isShownBbId = this.m_blackboard.RegisterDelayedListenerBool(this.m_bbDefinition.Popup_IsShown, this, n"OnUpdateVisibility");
    this.m_dataBbId = this.m_blackboard.RegisterDelayedListenerVariant(this.m_bbDefinition.Popup_Data, this, n"OnUpdateData");
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_blackboard.UnregisterDelayedListener(this.m_bbDefinition.Popup_IsShown, this.m_isShownBbId);
    this.m_blackboard.UnregisterDelayedListener(this.m_bbDefinition.Popup_Data, this.m_dataBbId);
  }

  protected cb func OnUpdateVisibility(value: Bool) -> Bool {
    if !value && IsDefined(this.m_tutorialToken) {
      this.m_tutorialToken.TriggerCallback(null);
    };
  }

  protected cb func OnMenuUpdate(value: Bool) -> Bool {
    if value {
      if this.m_tutorialToken != null && this.m_tutorialSettings.hideInMenu {
        this.m_tutorialOnHold = true;
        this.m_tutorialToken = null;
      };
      if IsDefined(this.m_vehicleRadioToken) {
        this.m_vehicleRadioToken.TriggerCallback(null);
      };
      if IsDefined(this.m_vehiclesManagerToken) {
        this.m_vehiclesManagerToken.TriggerCallback(null);
      };
    } else {
      if this.m_tutorialToken == null && this.m_tutorialOnHold {
        this.m_tutorialOnHold = false;
        this.ShowTutorial();
      };
    };
    this.ChangeTutorialOverlaysVisibility(value);
  }

  protected cb func OnUpdateData(value: Variant) -> Bool {
    this.m_tutorialOnHold = false;
    this.m_tutorialData = FromVariant(value);
    this.m_tutorialSettings = FromVariant(this.m_blackboard.GetVariant(this.m_bbDefinition.Popup_Settings));
    this.ShowTutorial();
  }

  protected cb func OnPopupCloseRequest(data: ref<inkGameNotificationData>) -> Bool {
    this.m_tutorialToken = null;
    this.m_blackboard.SetBool(this.m_bbDefinition.Popup_IsShown, false);
  }

  private final func ShowTutorial() -> Void {
    let notificationData: ref<TutorialPopupData> = new TutorialPopupData();
    notificationData.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\tutorial.inkwidget";
    notificationData.queueName = n"tutorial";
    notificationData.closeAtInput = this.m_tutorialSettings.closeAtInput;
    notificationData.pauseGame = this.m_tutorialSettings.pauseGame;
    notificationData.position = this.m_tutorialSettings.position;
    notificationData.isModal = this.m_tutorialSettings.fullscreen;
    notificationData.margin = this.m_tutorialSettings.margin;
    notificationData.title = this.m_tutorialData.title;
    notificationData.message = this.m_tutorialData.message;
    notificationData.imageId = this.m_tutorialData.iconID;
    notificationData.videoType = this.m_tutorialData.videoType;
    notificationData.video = PopupData.GetVideo(this.m_tutorialData);
    notificationData.isBlocking = this.m_tutorialSettings.closeAtInput;
    this.m_tutorialToken = this.ShowGameNotification(notificationData);
    this.m_tutorialToken.RegisterListener(this, n"OnPopupCloseRequest");
  }

  public final native func ChangeTutorialOverlaysVisibility(visible: Bool) -> Void;

  protected cb func OnCodexPopupRequest(evt: ref<OpenCodexPopupEvent>) -> Bool {
    let codexPopupData: ref<CodexPopupData> = new CodexPopupData();
    codexPopupData.m_entry = evt.m_entry;
    codexPopupData.isBlocking = true;
    codexPopupData.useCursor = true;
    codexPopupData.queueName = n"codex";
    codexPopupData.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\codex_popup.inkwidget";
    this.m_codexToken = this.ShowGameNotification(codexPopupData);
    this.m_codexToken.RegisterListener(this, n"OnCodexPopupCloseRequest");
  }

  protected cb func OnCodexPopupCloseRequest(data: ref<inkGameNotificationData>) -> Bool {
    this.m_codexToken = null;
  }

  protected cb func OnPhoneMessageShowRequest(evt: ref<PhoneMessagePopupEvent>) -> Bool {
    this.m_phoneMessageToken = this.ShowGameNotification(evt.m_data);
    this.m_phoneMessageToken.RegisterListener(this, n"OnMessagePopupUseCloseRequest");
  }

  protected cb func OnPhoneMessageHideRequest(evt: ref<PhoneMessageHidePopupEvent>) -> Bool {
    this.m_phoneMessageToken = null;
  }

  protected cb func OnMessagePopupUseCloseRequest(data: ref<inkGameNotificationData>) -> Bool {
    this.m_phoneMessageToken = null;
  }

  protected cb func OnShardRead(evt: ref<NotifyShardRead>) -> Bool {
    let notificationData: ref<ShardReadPopupData> = new ShardReadPopupData();
    notificationData.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\shard_notification.inkwidget";
    notificationData.queueName = n"shards";
    notificationData.isBlocking = true;
    notificationData.useCursor = false;
    notificationData.title = evt.title;
    notificationData.text = evt.text;
    notificationData.isCrypted = evt.isCrypted;
    notificationData.itemID = evt.itemID;
    this.m_journalManager.SetEntryVisited(evt.entry, true);
    this.m_shardToken = this.ShowGameNotification(notificationData);
    this.m_shardToken.RegisterListener(this, n"OnShardReadClosed");
    if notificationData.isCrypted {
      this.ProcessCrackableShardTutorial();
    };
  }

  public final func ProcessCrackableShardTutorial() -> Void {
    let questSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetPlayerControlledObject().GetGame());
    if questSystem.GetFact(n"encoded_shard_tutorial") == 0 && questSystem.GetFact(n"disable_tutorials") == 0 {
      questSystem.SetFact(n"encoded_shard_tutorial", 1);
    };
  }

  protected cb func OnShardReadClosed(data: ref<inkGameNotificationData>) -> Bool {
    this.m_shardToken = null;
    this.PlaySound(n"Button", n"OnPress");
  }

  protected cb func OnQuickSlotButtonHoldStartEvent(evt: ref<QuickSlotButtonHoldStartEvent>) -> Bool {
    switch evt.dPadItemDirection {
      case EDPadSlot.VehicleWheel:
        this.SpawnVehiclesManagerPopup();
        break;
      case EDPadSlot.VehicleInsideWheel:
        this.SpawnVehicleRadioPopup();
        break;
      default:
    };
  }

  private final func SpawnVehiclesManagerPopup() -> Void {
    let data: ref<inkGameNotificationData> = new inkGameNotificationData();
    data.notificationName = n"base\\gameplay\\gui\\widgets\\vehicle_control\\vehicles_manager.inkwidget";
    data.queueName = n"VehiclesManager";
    data.isBlocking = false;
    this.m_vehiclesManagerToken = this.ShowGameNotification(data);
    this.m_vehiclesManagerToken.RegisterListener(this, n"OnVehiclesManagerCloseRequest");
  }

  protected cb func OnVehiclesManagerCloseRequest(data: ref<inkGameNotificationData>) -> Bool {
    this.m_vehiclesManagerToken = null;
  }

  private final func SpawnVehicleRadioPopup() -> Void {
    let data: ref<inkGameNotificationData> = new inkGameNotificationData();
    data.notificationName = n"base\\gameplay\\gui\\widgets\\vehicle_control\\vehicles_radio.inkwidget";
    data.queueName = n"VehiclesRadio";
    data.isBlocking = false;
    this.m_vehicleRadioToken = this.ShowGameNotification(data);
    this.m_vehicleRadioToken.RegisterListener(this, n"OnVehicleRadioCloseRequest");
  }

  protected cb func OnVehicleRadioCloseRequest(data: ref<inkGameNotificationData>) -> Bool {
    this.m_vehicleRadioToken = null;
  }

  protected cb func OnSpawnPonRRewardsScreen(evt: ref<ShowPointOfNoReturnPromptEvent>) -> Bool {
    let notificationData: ref<inkGameNotificationData> = new inkGameNotificationData();
    notificationData.notificationName = n"base\\gameplay\\gui\\widgets\\ponr\\ponr_rewards.inkwidget";
    notificationData.queueName = n"PonR";
    notificationData.isBlocking = true;
    notificationData.useCursor = true;
    this.m_ponrToken = this.ShowGameNotification(notificationData);
    this.m_ponrToken.RegisterListener(this, n"OnClosePonRRewardsScreen");
  }

  protected cb func OnClosePonRRewardsScreen(data: ref<inkGameNotificationData>) -> Bool {
    this.m_ponrToken = null;
  }
}
