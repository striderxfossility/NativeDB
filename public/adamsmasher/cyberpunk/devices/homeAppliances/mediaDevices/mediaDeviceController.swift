
public class MediaDeviceController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class MediaDeviceControllerPS extends ScriptableDeviceComponentPS {

  protected let m_previousStation: Int32;

  protected let m_activeChannelName: String;

  protected persistent let m_dataInitialized: Bool;

  protected persistent let m_amountOfStations: Int32;

  protected persistent let m_activeStation: Int32;

  protected final const func ActionMediaDeviceStatus() -> ref<MediaDeviceStatus> {
    let action: ref<MediaDeviceStatus> = new MediaDeviceStatus();
    action.clearanceLevel = DefaultActionsParametersHolder.GetStatusClearance();
    action.SetUp(this);
    action.SetProperties(this);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func ActionNextStation() -> ref<NextStation> {
    let action: ref<NextStation> = new NextStation();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    action.CreateInteraction();
    return action;
  }

  public func ActionPreviousStation() -> ref<PreviousStation> {
    let action: ref<PreviousStation> = new PreviousStation();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    action.CreateInteraction();
    return action;
  }

  protected final func ActionQuestSetChannel() -> ref<QuestSetChannel> {
    let action: ref<QuestSetChannel> = new QuestSetChannel();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties(this.m_activeStation);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(actions, context);
    if Equals(context.requestType, gamedeviceRequestType.Direct) && !this.IsInteractive() {
      return false;
    };
    if !this.IsUserAuthorized(context.processInitiatorObject.GetEntityID()) {
      return false;
    };
    if Equals(context.requestType, gamedeviceRequestType.Remote) {
      return false;
    };
    if ToggleON.IsDefaultConditionMet(this, context) {
      ArrayPush(actions, this.ActionToggleON());
    };
    if MediaDeviceStatus.IsDefaultConditionMet(this, context) && Equals(context.requestType, gamedeviceRequestType.External) {
      ArrayPush(actions, this.ActionMediaDeviceStatus());
    };
    if NextStation.IsDefaultConditionMet(this, context) {
      ArrayPush(actions, this.ActionPreviousStation());
      ArrayPush(actions, this.ActionNextStation());
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  public func GetQuestActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(outActions, context);
    ArrayPush(outActions, this.ActionQuestEnableInteraction());
    ArrayPush(outActions, this.ActionQuestDisableInteraction());
    if Clearance.IsInRange(context.clearance, this.ActionQuestForcePower().clearanceLevel) {
      ArrayPush(outActions, this.ActionQuestSetChannel());
    };
  }

  public func OnNextStation(evt: ref<NextStation>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    if this.IsUnpowered() || this.IsDisabled() || !this.IsON() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.m_previousStation = this.m_activeStation;
    if this.m_activeStation + 1 == this.m_amountOfStations {
      this.m_activeStation = 0;
    } else {
      this.m_activeStation += 1;
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnPreviousStation(evt: ref<PreviousStation>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    if this.IsUnpowered() || this.IsDisabled() || !this.IsON() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.m_previousStation = this.m_activeStation;
    if this.m_activeStation - 1 < 0 {
      this.m_activeStation = this.m_amountOfStations - 1;
    } else {
      this.m_activeStation -= 1;
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnQuestSetChannel(evt: ref<QuestSetChannel>) -> EntityNotificationType {
    let stationIDX: Int32;
    let prop: array<ref<DeviceActionProperty>> = evt.GetProperties();
    DeviceActionPropertyFunctions.GetProperty_Int(prop[0], stationIDX);
    this.SetActiveStationIndex(stationIDX);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestEnableInteraction() -> ref<QuestEnableInteraction> {
    let action: ref<QuestEnableInteraction> = new QuestEnableInteraction();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func OnQuestEnableInteraction(evt: ref<QuestEnableInteraction>) -> EntityNotificationType {
    this.m_isInteractive = true;
    this.UseNotifier(evt);
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  protected final func ActionQuestDisableInteraction() -> ref<QuestDisableInteraction> {
    let action: ref<QuestDisableInteraction> = new QuestDisableInteraction();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func OnQuestDisableInteraction(evt: ref<QuestDisableInteraction>) -> EntityNotificationType {
    this.m_isInteractive = false;
    this.UseNotifier(evt);
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  private final func GetQuickHackDistractionActions() -> Void;

  public const func GetDeviceStatusTextData() -> ref<inkTextParams> {
    let channelAsNumber: Int32;
    let channelName: String;
    let textData: ref<inkTextParams> = this.GetDeviceStatusTextData();
    if this.IsON() {
      channelName = this.GetActiveStationName();
      channelAsNumber = StringToInt(channelName);
      if IsDefined(textData) {
        if channelAsNumber > 0 {
          textData.AddString("TEXT_SECONDARY", channelName);
        } else {
          textData.AddLocalizedString("TEXT_SECONDARY", channelName);
        };
      };
    } else {
      if IsDefined(textData) {
        textData.AddString("TEXT_SECONDARY", "");
      };
    };
    return textData;
  }

  protected func ActionThumbnailUI() -> ref<ThumbnailUI> {
    let action: ref<ThumbnailUI> = this.ActionThumbnailUI();
    if this.IsON() {
      action.CreateThumbnailWidgetPackage("LocKey#42211");
    };
    return action;
  }

  public const func GetDeviceStatusAction() -> ref<BaseDeviceStatus> {
    return this.ActionMediaDeviceStatus();
  }

  public final const func GetPreviousStationIndex() -> Int32 {
    return this.m_previousStation;
  }

  public func GetActiveStationIndex() -> Int32 {
    return this.m_activeStation;
  }

  public final const func GetActiveStationName() -> String {
    return this.m_activeChannelName;
  }

  public final func SetActiveStationIndex(stationIDX: Int32) -> Void {
    this.m_previousStation = this.m_activeStation;
    this.m_activeStation = stationIDX;
  }

  public final func PassChannelName(channelName: String) -> Void {
    this.m_activeChannelName = channelName;
  }

  public final func PushPersistentData(data: MediaDeviceData) -> Void {
    if this.IsInitialized() {
      return;
    };
    this.m_previousStation = -1;
    this.m_activeStation = data.m_initialStation;
    this.m_amountOfStations = data.m_amountOfStations;
    this.m_activeChannelName = data.m_activeChannelName;
    this.m_isInteractive = data.m_isInteractive;
  }
}
