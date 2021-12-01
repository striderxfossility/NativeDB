
public class TVController extends MediaDeviceController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class TVControllerPS extends MediaDeviceControllerPS {

  protected persistent let m_tvSetup: TVSetup;

  @attrib(category, "Glitch")
  protected let m_defaultGlitchVideoPath: ResRef;

  @attrib(category, "Glitch")
  protected let m_broadcastGlitchVideoPath: ResRef;

  private let m_globalTVInitialized: Bool;

  private let m_backupCustomChannels: array<STvChannel>;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "Gameplay-Devices-DisplayNames-TV";
    };
  }

  protected func GameAttached() -> Void {
    this.InitializeTv();
  }

  private final func InitializeTv() -> Void {
    if !this.IsGlobalTvOnly() && this.HasBackupedCustomChannels() {
      this.m_tvSetup.m_channels = this.m_backupCustomChannels;
    };
    this.InitializeGlobalTV();
    this.m_amountOfStations = ArraySize(this.m_tvSetup.m_channels);
    this.m_activeChannelName = this.m_tvSetup.m_channels[this.GetActiveStationIndex()].channelName;
    this.m_isInteractive = this.m_tvSetup.m_isInteractive;
  }

  public final const func IsInterfaceMuted() -> Bool {
    return this.m_tvSetup.m_muteInterface;
  }

  public final func SetInterfaceMuted(mute: Bool) -> Void {
    this.m_tvSetup.m_muteInterface = mute;
  }

  public final func SetIsInteractive(isInteractive: Bool) -> Void {
    this.m_tvSetup.m_isInteractive = isInteractive;
  }

  public final const func GetDefaultGlitchVideoPath() -> ResRef {
    if ResRef.IsValid(this.m_defaultGlitchVideoPath) {
      return this.m_defaultGlitchVideoPath;
    };
    return r"base\\movies\\misc\\generic_noise_white.bk2";
  }

  public final const func GetBroadcastGlitchVideoPath() -> ResRef {
    if ResRef.IsValid(this.m_broadcastGlitchVideoPath) {
      return this.m_broadcastGlitchVideoPath;
    };
    return r"base\\movies\\misc\\distraction_generic.bk2";
  }

  public final const func HasCustomChannels() -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_tvSetup.m_channels) {
      if !TDBID.IsValid(this.m_tvSetup.m_channels[i].channelTweakID) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func SetIsGlobalTvOnly(isGlobalTv: Bool) -> Void {
    if NotEquals(isGlobalTv, this.m_tvSetup.m_isGlobalTvOnly) {
      this.m_tvSetup.m_isGlobalTvOnly = isGlobalTv;
      this.m_globalTVInitialized = false;
      this.m_dataInitialized = false;
      this.InitializeTv();
    };
  }

  public final const func IsGlobalTvOnly() -> Bool {
    return this.m_tvSetup.m_isGlobalTvOnly;
  }

  public final const func GetGlobalTVChannels() -> array<wref<ChannelData_Record>> {
    let channels: array<wref<ChannelData_Record>>;
    let tvRecord: wref<TVBase_Record> = TweakDBInterface.GetTVBaseRecord(this.m_tweakDBRecord);
    if IsDefined(tvRecord) {
      tvRecord.Channels(channels);
    };
    return channels;
  }

  public final const func GetAmmountOfGlobalTVChannels() -> Int32 {
    let channels: array<wref<ChannelData_Record>> = this.GetGlobalTVChannels();
    return ArraySize(channels);
  }

  private final func InitializeGlobalTV() -> Int32 {
    let channelData: STvChannel;
    let channels: array<wref<ChannelData_Record>>;
    let i: Int32;
    if this.IsGlobalTvOnly() {
      this.BackupCustomChannels();
      ArrayClear(this.m_tvSetup.m_channels);
    };
    if !TDBID.IsValid(this.m_tweakDBRecord) {
      this.InitializeRPGParams();
    };
    channels = this.GetGlobalTVChannels();
    if this.m_globalTVInitialized {
      return ArraySize(channels);
    };
    i = 0;
    while i < ArraySize(channels) {
      channelData.channelName = channels[i].LocalizedName();
      channelData.channelTweakID = channels[i].GetID();
      ArrayPush(this.m_tvSetup.m_channels, channelData);
      i += 1;
    };
    this.m_globalTVInitialized = true;
    return ArraySize(channels);
  }

  private final func BackupCustomChannels() -> Void {
    let currentChannel: STvChannel;
    let i: Int32 = 0;
    while i < ArraySize(this.m_tvSetup.m_channels) {
      if !TDBID.IsValid(this.m_tvSetup.m_channels[i].channelTweakID) {
        currentChannel = this.m_tvSetup.m_channels[i];
        ArrayPush(this.m_backupCustomChannels, currentChannel);
      };
      i += 1;
    };
  }

  private final const func HasBackupedCustomChannels() -> Bool {
    return ArraySize(this.m_backupCustomChannels) > 0;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionGlitchScreen(t"DeviceAction.GlitchScreenSuicide", t"QuickHack.DeviceSuicideHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    ArrayPush(outActions, currentAction);
    currentAction = this.ActionGlitchScreen(t"DeviceAction.GlitchScreenBlind", t"QuickHack.BlindHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    ArrayPush(outActions, currentAction);
    currentAction = this.ActionGlitchScreen(t"DeviceAction.GlitchScreenHeartAttack", t"QuickHack.HeartAttackHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    ArrayPush(outActions, currentAction);
    currentAction = this.ActionGlitchScreen(t"DeviceAction.GlitchScreenGrenade", t"QuickHack.GrenadeHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    ArrayPush(outActions, currentAction);
    if !GlitchScreen.IsDefaultConditionMet(this, context) {
      ScriptableDeviceComponentPS.SetActionsInactiveAll(outActions, "LocKey#7003");
    };
    currentAction = this.ActionQuickHackDistraction();
    currentAction.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    currentAction.SetInactiveWithReason(ScriptableDeviceAction.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(outActions, currentAction);
    if this.IsGlitching() || this.IsDistracting() {
      ScriptableDeviceComponentPS.SetActionsInactiveAll(outActions, "LocKey#7004");
    };
    this.FinalizeGetQuickHackActions(outActions, context);
  }

  public func GetQuestActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(outActions, context);
    ArrayPush(outActions, this.ActionQuestMuteSounds(true));
    ArrayPush(outActions, this.ActionQuestMuteSounds(false));
    ArrayPush(outActions, this.ActionQuestToggleInteractivity(true));
    ArrayPush(outActions, this.ActionQuestToggleInteractivity(false));
  }

  public func GetActiveStationIndex() -> Int32 {
    if !this.m_dataInitialized {
      this.m_dataInitialized = true;
      this.m_previousStation = -1;
      this.m_activeStation = this.EstablishInitialActiveChannelIndex();
    };
    return this.m_activeStation;
  }

  private final func EstablishInitialActiveChannelIndex() -> Int32 {
    let globalTVChannelsCount: Int32;
    let idx: Int32;
    if !this.m_globalTVInitialized {
      this.InitializeGlobalTV();
    };
    if TDBID.IsValid(this.m_tvSetup.m_initialGlobalTvChannel) {
      idx = this.GetGlobalTVChannelIDX(this.m_tvSetup.m_initialGlobalTvChannel);
    } else {
      if this.HasCustomChannels() {
        idx = this.m_tvSetup.m_initialChannel;
      } else {
        globalTVChannelsCount = this.GetAmmountOfGlobalTVChannels();
        if globalTVChannelsCount > 0 {
          idx = RandRange(0, globalTVChannelsCount);
        };
      };
    };
    return idx;
  }

  public final const func GetGlobalTVChannelIDX(id: TweakDBID) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_tvSetup.m_channels) {
      if this.m_tvSetup.m_channels[i].channelTweakID == id {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final const func GetActiveChannelVideoPath() -> ResRef {
    let channelData: STvChannel = this.GetChannelData(this.m_activeStation);
    return channelData.videoPath;
  }

  private final const func GetActiveChannelTweakDBID() -> TweakDBID {
    let channelData: STvChannel = this.GetChannelData(this.m_activeStation);
    return channelData.channelTweakID;
  }

  private final const func GlobalTVChannelIDToEnum(id: TweakDBID) -> ETVChannel {
    let channel: ETVChannel;
    switch id {
      case t"Channels.CH1":
        channel = ETVChannel.CH1;
        break;
      case t"Channels.CH2":
        channel = ETVChannel.CH2;
        break;
      case t"Channels.CH3":
        channel = ETVChannel.CH3;
        break;
      case t"Channels.CH4":
        channel = ETVChannel.CH4;
        break;
      case t"Channels.CH5":
        channel = ETVChannel.CH5;
        break;
      default:
        channel = ETVChannel.INVALID;
    };
    return channel;
  }

  private final const func GlobalTVChannelIDToInt(id: TweakDBID) -> Int32 {
    let channel: Int32;
    switch id {
      case t"Channels.CH1":
        channel = 1;
        break;
      case t"Channels.CH2":
        channel = 2;
        break;
      case t"Channels.CH3":
        channel = 3;
        break;
      case t"Channels.CH4":
        channel = 4;
        break;
      case t"Channels.CH5":
        channel = 5;
        break;
      default:
        channel = -1;
    };
    return channel;
  }

  public final const func GetChannelName(index: Int32) -> String {
    if index < 0 {
      return "";
    };
    return this.m_tvSetup.m_channels[index].channelName;
  }

  public final const func GetChannelID(channelName: String) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_tvSetup.m_channels) {
      if Equals(this.m_tvSetup.m_channels[i].channelName, channelName) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  public final const func GetChannelData(channelIndex: Int32) -> STvChannel {
    let invalidChannel: STvChannel;
    if channelIndex < 0 || channelIndex > ArraySize(this.m_tvSetup.m_channels) - 1 {
      return invalidChannel;
    };
    return this.m_tvSetup.m_channels[channelIndex];
  }

  protected func DetermineGameplayViability(context: GetActionsContext, hasActiveActions: Bool) -> Bool {
    return TVViabilityInterpreter.Evaluate(this, hasActiveActions);
  }

  public func GetDeviceIconPath() -> String {
    return "base/gameplay/gui/brushes/devices/icon_tv.widgetbrush";
  }

  protected func GetInkWidgetTweakDBID(context: GetActionsContext) -> TweakDBID {
    if !this.IsUserAuthorized(context.processInitiatorObject.GetEntityID()) && !context.ignoresAuthorization {
      return this.GetInkWidgetTweakDBID(context);
    };
    return t"DevicesUIDefinitions.TvDeviceWidget";
  }

  public func GetDeviceWidget(context: GetActionsContext) -> SDeviceWidgetPackage {
    let channel: STvChannel;
    let customData: ref<TvDeviceWidgetCustomData>;
    let widgetData: SDeviceWidgetPackage = this.GetDeviceWidget(context);
    if this.IsON() {
      channel = this.GetChannelData(this.m_activeStation);
      customData = new TvDeviceWidgetCustomData();
      customData.videoPath = this.GetActiveChannelVideoPath();
      customData.channelID = this.GetActiveChannelTweakDBID();
      customData.looped = channel.looped;
      customData.messageRecordID = channel.m_messageRecordID;
      widgetData.customData = customData;
      widgetData.textData = this.GetDeviceStatusTextData();
      widgetData.deviceStatus = "LocKey#42211";
    };
    return widgetData;
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return GetAllBlackboardDefs().TVDeviceBlackboard;
  }

  public const func IsInteractive() -> Bool {
    return this.m_tvSetup.m_isInteractive && this.IsInteractive();
  }

  public final func PushResaveData(data: TVResaveData) -> Void;

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.ScreenDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.ScreenDeviceBackground";
  }

  protected final func ActionQuestMuteSounds(mute: Bool) -> ref<QuestMuteSounds> {
    let action: ref<QuestMuteSounds> = new QuestMuteSounds();
    action.SetUp(this);
    action.SetProperties(mute);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func OnQuestMuteSounds(evt: ref<QuestMuteSounds>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    this.SetInterfaceMuted(FromVariant(evt.prop.first));
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestToggleInteractivity(enable: Bool) -> ref<QuestToggleInteractivity> {
    let action: ref<QuestToggleInteractivity> = new QuestToggleInteractivity();
    action.SetUp(this);
    action.SetProperties(enable);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func OnQuestToggleInteractivity(evt: ref<QuestToggleInteractivity>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    this.SetIsInteractive(FromVariant(evt.prop.first));
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final const quest func IsGlobalTVChannelActive(channel: Int32) -> Bool {
    let activeChannel: Int32;
    let channelID: TweakDBID = this.GetActiveChannelTweakDBID();
    if !TDBID.IsValid(channelID) {
      return false;
    };
    activeChannel = this.GlobalTVChannelIDToInt(channelID);
    return activeChannel == channel;
  }
}
