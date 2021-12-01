
public class TvChannelSpawnData extends IScriptable {

  public let m_channelName: CName;

  public let m_localizedName: String;

  public let m_order: Int32;

  public final func Initialize(channelName: CName, localizedName: String, order: Int32) -> Void {
    this.m_channelName = channelName;
    this.m_localizedName = localizedName;
    this.m_order = order;
  }
}

public class TvInkGameController extends DeviceInkGameControllerBase {

  private let m_defaultUI: wref<inkCanvas>;

  private let m_securedUI: wref<inkCanvas>;

  private let m_channellTextWidget: wref<inkText>;

  private let m_securedTextWidget: wref<inkText>;

  protected let m_mainDisplayWidget: wref<inkVideo>;

  private let m_actionsList: wref<inkWidget>;

  @default(TvInkGameController, -1)
  private let m_activeChannelIDX: Int32;

  private let m_activeSequence: array<SequenceVideo>;

  @default(TvInkGameController, 0)
  private let m_activeSequenceVideo: Int32;

  private let m_globalTVChannels: array<wref<inkWidget>>;

  protected let m_messegeWidget: wref<inkText>;

  protected let m_backgroundWidget: wref<inkLeafWidget>;

  @default(TvInkGameController, -1)
  private let m_previousGlobalTVChannelID: Int32;

  @default(TvInkGameController, -1)
  private let m_globalTVchanellsCount: Int32;

  private let m_globalTVchanellsSpawned: Int32;

  private let m_globalTVslot: wref<inkWidget>;

  private let m_activeAudio: CName;

  private let m_activeMessage: wref<ScreenMessageData_Record>;

  private let m_onChangeChannelListener: ref<CallbackHandle>;

  private let m_onGlitchingStateChangedListener: ref<CallbackHandle>;

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
    if IsDefined(this.m_mainDisplayWidget) {
      this.m_mainDisplayWidget.Stop();
    };
  }

  protected func SetupWidgets() -> Void {
    if !this.m_isInitialized {
      this.m_rootWidget.SetVisible(false);
      this.m_defaultUI = this.GetWidget(n"default_ui") as inkCanvas;
      this.m_securedUI = this.GetWidget(n"secured_ui") as inkCanvas;
      this.m_channellTextWidget = this.GetWidget(n"default_ui/channel_text") as inkText;
      this.m_securedTextWidget = this.GetWidget(n"secured_ui/secured_text") as inkText;
      this.m_mainDisplayWidget = this.GetWidget(n"main_display") as inkVideo;
      this.m_actionsList = this.GetWidget(n"default_ui/actions_list_slot");
      this.m_messegeWidget = this.GetWidget(n"messege_text") as inkText;
      this.m_backgroundWidget = this.GetWidget(n"background") as inkLeafWidget;
      this.m_globalTVslot = this.GetWidget(n"global_tv_slot");
      if !(this.GetOwner() as TV).IsInteractive() {
        this.m_rootWidget.SetInteractive(false);
        this.m_defaultUI.SetInteractive(false);
        if IsDefined(this.m_actionsList) {
          this.m_actionsList.SetVisible(false);
        };
      };
    };
  }

  public func Refresh(state: EDeviceStatus) -> Void {
    this.SetupWidgets();
    if !this.IsGlobalTVInitialized() {
      if !this.WasGlobalTVinitalizationTrigered() {
        this.InitializeGlobalTV();
      };
      return;
    };
    switch state {
      case EDeviceStatus.ON:
        this.TurnOn();
        break;
      case EDeviceStatus.OFF:
        this.TurnOff();
        break;
      case EDeviceStatus.UNPOWERED:
        this.TurnOff();
        break;
      case EDeviceStatus.DISABLED:
        this.TurnOff();
        break;
      default:
    };
    this.Refresh(state);
  }

  protected func RegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.RegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      this.m_onChangeChannelListener = blackboard.RegisterListenerInt(this.GetOwner().GetBlackboardDef() as TVDeviceBlackboardDef.CurrentChannel, this, n"OnChangeChannel");
      this.m_onGlitchingStateChangedListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef().GlitchData, this, n"OnGlitchingStateChanged");
    };
  }

  protected func UnRegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.UnRegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef().GlitchData, this.m_onGlitchingStateChangedListener);
      blackboard.UnregisterListenerInt(this.GetOwner().GetBlackboardDef() as TVDeviceBlackboardDef.CurrentChannel, this.m_onChangeChannelListener);
    };
  }

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }

  protected cb func OnChangeChannel(value: Int32) -> Bool {
    if NotEquals(this.m_cashedState, EDeviceStatus.ON) {
      this.Refresh(this.GetOwner().GetDeviceState());
    } else {
      this.SelectChannel(value);
    };
  }

  private func StartGlitchingScreen(glitchData: GlitchData) -> Void {
    let glitchVideoPath: ResRef;
    this.StopVideo();
    this.HideAllGlobalTVChannels();
    if Equals(glitchData.state, EGlitchState.DEFAULT) {
      glitchVideoPath = (this.GetOwner() as TV).GetDefaultGlitchVideoPath();
    } else {
      glitchVideoPath = (this.GetOwner() as TV).GetBroadcastGlitchVideoPath();
    };
    if ResRef.IsValid(glitchVideoPath) {
      this.PlayVideo(glitchVideoPath, true, n"");
    };
  }

  private func StopGlitchingScreen() -> Void {
    this.StopVideo();
    this.SelectChannel(this.m_activeChannelIDX, true);
  }

  private final func SelectChannel(value: Int32, opt force: Bool) -> Void {
    let channel: STvChannel;
    if !this.m_isInitialized {
      return;
    };
    if value == this.m_activeChannelIDX && !force {
      return;
    };
    channel = (this.GetOwner() as TV).GetChannelData(value);
    this.m_activeSequence = channel.m_sequence;
    this.ResolveMessegeRecord(this.GetMessageRecord(channel.m_messageRecordID));
    if value != this.m_activeChannelIDX && this.m_activeChannelIDX != -1 {
      this.StopVideo();
      this.HideAllGlobalTVChannels();
      this.m_activeSequenceVideo = 0;
    };
    if this.IsGlobalTVChannel(channel) {
      if this.ShowGlobalTVChannel(channel.channelTweakID) {
        this.m_activeChannelIDX = value;
        this.SetChannellText("");
      };
    } else {
      this.m_activeChannelIDX = value;
      this.SetChannellText(channel.channelName);
      this.PlayVideo(channel.videoPath, channel.looped, channel.audioEvent);
    };
  }

  public final func PlayVideo(videoPath: ResRef, looped: Bool, audioEvent: CName) -> Void {
    this.RegisterTvChannel(-1);
    if this.m_mainDisplayWidget == null {
      return;
    };
    this.m_mainDisplayWidget.SetVideoPath(videoPath);
    this.m_mainDisplayWidget.SetLoop(looped);
    if IsNameValid(audioEvent) {
      this.m_mainDisplayWidget.SetAudioEvent(audioEvent);
    };
    if ResRef.IsValid(videoPath) {
      this.m_mainDisplayWidget.Play();
    };
  }

  public final func StopVideo() -> Void {
    if this.m_mainDisplayWidget == null {
      return;
    };
    GameObject.StopSound(this.GetOwner(), this.m_activeAudio);
    this.m_activeAudio = n"";
    this.m_mainDisplayWidget.Stop();
  }

  public final func SetChannellText(channelName: String) -> Void {
    if this.m_channellTextWidget != null {
      this.m_channellTextWidget.SetLocalizedTextScript(channelName);
    };
  }

  public final func SetSecuredText(text: String) -> Void {
    if this.m_securedTextWidget != null {
      this.m_securedTextWidget.SetText(text);
    };
  }

  public final func TurnOff() -> Void {
    this.m_rootWidget.SetVisible(false);
    if this.m_mainDisplayWidget != null && Equals(this.m_cashedState, EDeviceStatus.ON) {
      this.m_mainDisplayWidget.UnregisterFromCallback(n"OnVideoFinished", this, n"OnVideoFinished");
    };
    this.StopVideo();
    this.RegisterTvChannel(-1);
    this.m_activeSequenceVideo = 0;
    this.m_activeChannelIDX = -1;
    if IsNameValid(this.m_activeAudio) {
      GameObject.StopSound(this.GetOwner(), this.m_activeAudio);
    };
  }

  public func TurnOn() -> Void {
    this.m_rootWidget.SetVisible(true);
    this.m_defaultUI.SetVisible(true);
    if !this.GetOwner().IsDeviceSecured() {
      this.SelectChannel((this.GetOwner().GetDevicePS() as TVControllerPS).GetActiveStationIndex());
    };
    if this.m_mainDisplayWidget != null && NotEquals(this.m_cashedState, EDeviceStatus.ON) {
      this.m_mainDisplayWidget.RegisterToCallback(n"OnVideoFinished", this, n"OnVideoFinished");
    };
  }

  protected cb func OnVideoFinished(target: wref<inkVideo>) -> Bool {
    let index: Int32;
    if ArraySize(this.m_activeSequence) > 0 && this.m_activeSequenceVideo < ArraySize(this.m_activeSequence) {
      index = this.m_activeSequenceVideo;
      this.PlayVideo(this.m_activeSequence[index].videoPath, this.m_activeSequence[index].looped, this.m_activeSequence[index].audioEvent);
      this.m_activeSequenceVideo += 1;
    };
  }

  private final func RegisterTvChannel(id: Int32) -> Void {
    if id == this.m_previousGlobalTVChannelID {
      this.m_previousGlobalTVChannelID = -1;
    };
    GameInstance.GetGlobalTVSystem(this.GetOwner().GetGame()).RegisterTVChannelOnController(this, this.m_previousGlobalTVChannelID, id);
    this.m_previousGlobalTVChannelID = id;
  }

  private final func IsGlobalTVInitialized() -> Bool {
    return this.m_globalTVchanellsCount == this.m_globalTVchanellsSpawned;
  }

  private final func WasGlobalTVinitalizationTrigered() -> Bool {
    return this.m_globalTVchanellsCount > -1;
  }

  private final func InitializeGlobalTV() -> Void {
    let channels: array<wref<ChannelData_Record>>;
    let i: Int32;
    let spawnData: ref<AsyncSpawnData>;
    let tvWidgetData: ref<TvChannelSpawnData>;
    if this.m_globalTVchanellsCount > -1 {
      return;
    };
    channels = (this.GetOwner() as TV).GetGlobalTVChannels();
    this.m_globalTVchanellsCount = ArraySize(channels);
    i = 0;
    while i < ArraySize(channels) {
      tvWidgetData = new TvChannelSpawnData();
      tvWidgetData.Initialize(channels[i].ChannelWidget(), channels[i].LocalizedName(), channels[i].OrderID());
      spawnData = new AsyncSpawnData();
      spawnData.Initialize(this, n"OnGLobalChannelSpawned", ToVariant(tvWidgetData), this);
      if !this.CreateWidgetAsync(this.GetGlobalTVSlot(), channels[i].ChannelWidget(), spawnData) {
        this.m_globalTVchanellsSpawned += 1;
      };
      i += 1;
    };
    if this.IsGlobalTVInitialized() {
      this.Refresh(this.GetOwner().GetDeviceState());
    };
  }

  private final func GetGlobalTVSlot() -> wref<inkWidget> {
    if this.m_globalTVslot != null {
      return this.m_globalTVslot;
    };
    return this.GetRootWidget();
  }

  protected cb func OnGLobalChannelSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let tvWidgetData: ref<TvChannelSpawnData>;
    let spawnData: ref<AsyncSpawnData> = userData as AsyncSpawnData;
    if IsDefined(spawnData) {
      tvWidgetData = FromVariant(spawnData.m_widgetData);
    };
    if IsDefined(widget) {
      this.m_globalTVchanellsSpawned += 1;
      widget.SetAnchor(inkEAnchor.Fill);
      widget.SetVisible(false);
      if IsDefined(tvWidgetData) {
        widget.SetName(tvWidgetData.m_channelName);
      };
      ArrayPush(this.m_globalTVChannels, widget);
    };
    if this.IsGlobalTVInitialized() {
      this.Refresh(this.GetOwner().GetDeviceState());
    };
  }

  private final func HideAllGlobalTVChannels() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_globalTVChannels) {
      this.m_globalTVChannels[i].SetVisible(false);
      i += 1;
    };
    if IsNameValid(this.m_activeAudio) {
      GameObject.StopSound(this.GetOwner(), this.m_activeAudio);
    };
  }

  private final func ShowGlobalTVChannel(channelID: TweakDBID) -> Bool {
    let audioEvent: CName;
    let i: Int32;
    let realChannelID: Int32;
    let channelRecord: wref<ChannelData_Record> = TweakDBInterface.GetChannelDataRecord(channelID);
    if IsDefined(channelRecord) {
      realChannelID = channelRecord.OrderID();
      i = 0;
      while i < ArraySize(this.m_globalTVChannels) {
        if Equals(this.m_globalTVChannels[i].GetName(), channelRecord.ChannelWidget()) {
          audioEvent = channelRecord.AudioEvent();
          this.m_globalTVChannels[i].SetVisible(true);
          this.RegisterTvChannel(realChannelID);
          GameObject.PlaySound(this.GetOwner(), audioEvent);
          this.m_activeAudio = audioEvent;
          this.SetChannellText("");
          return true;
        };
        i += 1;
      };
    };
    return false;
  }

  private final func HideGlobalTVChannel(channelID: TweakDBID) -> Void {
    let audioEvent: CName;
    let i: Int32;
    let channelRecord: wref<ChannelData_Record> = TweakDBInterface.GetChannelDataRecord(channelID);
    if IsDefined(channelRecord) {
      i = 0;
      while i < ArraySize(this.m_globalTVChannels) {
        if Equals(this.m_globalTVChannels[i].GetName(), channelRecord.ChannelWidget()) {
          audioEvent = channelRecord.AudioEvent();
          GameObject.StopSound(this.GetOwner(), audioEvent);
          this.m_activeAudio = n"";
          this.m_globalTVChannels[i].SetVisible(false);
          this.SetChannellText("");
        };
        i += 1;
      };
    };
  }

  private final func IsGlobalTVChannel(channel: STvChannel) -> Bool {
    return TDBID.IsValid(channel.channelTweakID);
  }

  protected func ResolveMessegeRecord(record: wref<ScreenMessageData_Record>) -> Void {
    let fontPath: String;
    let fontstyle: CName;
    let horizontalAlignment: CName;
    let verticalAlignment: CName;
    if record != null {
      fontPath = record.FontPath();
      fontstyle = record.FontStyle();
      verticalAlignment = record.TextVerticalAlignment();
      horizontalAlignment = record.TextHorizontalAlignment();
      if IsStringValid(fontPath) {
        this.m_messegeWidget.SetFontFamily(fontPath, fontstyle);
      } else {
        if IsNameValid(fontstyle) {
          this.m_messegeWidget.SetFontStyle(fontstyle);
        };
      };
      if IsNameValid(verticalAlignment) {
        this.m_messegeWidget.SetVerticalAlignment(this.m_messegeWidget.GetVerticalAlignmentEnumValue(verticalAlignment));
      };
      if IsNameValid(horizontalAlignment) {
        this.m_messegeWidget.SetHorizontalAlignment(this.m_messegeWidget.GetHorizontalAlignmentEnumValue(horizontalAlignment));
      };
      this.m_messegeWidget.UpdateMargin(record.LeftMargin(), record.TopMargin(), record.RightMargin(), record.BottomMargin());
      this.m_messegeWidget.EnableAutoScroll(record.AutoScroll());
      this.m_messegeWidget.SetFontSize(record.FontSize());
      this.m_messegeWidget.SetLocalizedTextScript(record.LocalizedDescription());
      this.m_messegeWidget.SetTintColor(this.GetColorFromArray(record.TextColor()));
      this.m_messegeWidget.SetScrollTextSpeed(record.ScrollSpeed());
      this.m_backgroundWidget.SetTintColor(this.GetColorFromArray(record.BackgroundColor()));
      this.m_backgroundWidget.SetOpacity(record.BackgroundOpacity());
      this.SetBackgroundTexture(this.m_backgroundWidget as inkImage, record.BackgroundTextureID());
      this.m_activeMessage = record;
    } else {
      this.m_activeMessage = null;
      this.m_messegeWidget.SetText("");
      this.m_backgroundWidget.SetOpacity(0.00);
    };
  }

  private final func GetColorFromArray(colorArray: array<Int32>) -> Color {
    let color: Color;
    let i: Int32 = 0;
    while i < ArraySize(colorArray) {
      if i == 0 {
        color.Red = Cast(colorArray[i]);
      } else {
        if i == 1 {
          color.Green = Cast(colorArray[i]);
        } else {
          if i == 2 {
            color.Blue = Cast(colorArray[i]);
          } else {
            if i == 3 {
              color.Alpha = Cast(colorArray[i]);
            };
          };
        };
      };
      i += 1;
    };
    return color;
  }

  private final const func GetMessageRecord(messageID: TweakDBID) -> ref<ScreenMessageData_Record> {
    let count: Int32;
    let groupRecord: wref<ScreenMessagesList_Record>;
    let messageRecord: wref<ScreenMessageData_Record>;
    let rand: Int32;
    if !TDBID.IsValid(messageID) {
      return null;
    };
    messageRecord = TweakDBInterface.GetScreenMessageDataRecord(messageID);
    if messageRecord != null {
      groupRecord = messageRecord.MessageGroup();
      if groupRecord != null {
        count = groupRecord.GetMessagesCount();
        if count > 0 {
          rand = RandRange(0, count);
          messageRecord = groupRecord.GetMessagesItem(rand);
        };
      };
    };
    return messageRecord;
  }

  private final func SetBackgroundTexture(imageWidget: wref<inkImage>, textureID: TweakDBID) -> Void {
    if imageWidget != null && TDBID.IsValid(textureID) {
      InkImageUtils.RequestSetImage(this, imageWidget, textureID);
    };
  }

  private final func SetBackgroundTexture(imageWidget: wref<inkImage>, textureRecord: wref<UIIcon_Record>) -> Void {
    if imageWidget != null && textureRecord != null {
      imageWidget.SetAtlasResource(textureRecord.AtlasResourcePath());
      imageWidget.SetTexturePart(textureRecord.AtlasPartName());
    };
  }

  private final func SetBackgroundTexture(imageWidgetRef: inkImageRef, textureRecord: wref<UIIcon_Record>) -> Void {
    if inkWidgetRef.IsValid(imageWidgetRef) && textureRecord != null {
      inkImageRef.SetAtlasResource(imageWidgetRef, textureRecord.AtlasResourcePath());
      inkImageRef.SetTexturePart(imageWidgetRef, textureRecord.AtlasPartName());
    };
  }

  protected cb func OnMessageTextureCallback(e: ref<iconAtlasCallbackData>) -> Bool {
    switch e.loadResult {
      case inkIconResult.Success:
        Log("TEST SUCCESS");
        break;
      case inkIconResult.AtlasResourceNotFound:
        Log("TEST FAIL");
        break;
      case inkIconResult.UnknownIconTweak:
        Log("TEST FAIL");
        break;
      case inkIconResult.PartNotFoundInAtlas:
        Log("TEST FAIL");
    };
  }
}
