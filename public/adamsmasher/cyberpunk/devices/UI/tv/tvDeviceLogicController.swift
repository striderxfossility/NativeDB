
public class TvDeviceWidgetController extends DeviceWidgetControllerBase {

  @attrib(category, "Widget Refs")
  protected edit let m_videoWidget: inkVideoRef;

  @attrib(category, "Widget Refs")
  protected edit let m_globalTVChannelSlot: inkBasePanelRef;

  @attrib(category, "Widget Refs")
  protected edit let m_messegeWidget: inkTextRef;

  @attrib(category, "Widget Refs")
  protected edit let m_messageBackgroundWidget: inkLeafRef;

  private let m_globalTVChannel: wref<inkWidget>;

  private let m_activeVideo: ResRef;

  public func Initialize(gameController: ref<DeviceInkGameControllerBase>, widgetData: SDeviceWidgetPackage) -> Void {
    let customData: ref<TvDeviceWidgetCustomData>;
    this.HideGlobalTVChannel();
    customData = widgetData.customData as TvDeviceWidgetCustomData;
    if customData != null {
      this.ResolveChannelData(customData, widgetData, gameController);
    } else {
      this.ResolveMessegeRecord(null);
      if ResRef.IsValid(this.m_activeVideo) {
        this.StopVideo();
      };
    };
    this.Initialize(gameController, widgetData);
  }

  private final func ResolveChannelData(data: ref<TvDeviceWidgetCustomData>, widgetData: SDeviceWidgetPackage, gameController: ref<DeviceInkGameControllerBase>) -> Void {
    let channelRecord: wref<ChannelData_Record>;
    if TDBID.IsValid(data.channelID) {
      channelRecord = TweakDBInterface.GetChannelDataRecord(data.channelID);
    };
    this.ResolveMessegeRecord(this.GetMessageRecord(data.messageRecordID));
    if IsDefined(channelRecord) {
      this.StopVideo();
      inkWidgetRef.SetVisible(this.m_globalTVChannelSlot, true);
      if !IsDefined(this.m_globalTVChannel) || IsDefined(this.m_globalTVChannel) && NotEquals(this.m_globalTVChannel.GetName(), channelRecord.ChannelWidget()) {
        if this.m_globalTVChannel != null {
          this.RegisterTvChannel(-1, gameController);
          inkCompoundRef.RemoveChild(this.m_globalTVChannelSlot, this.m_globalTVChannel);
          this.m_globalTVChannel = null;
        };
        this.SpawnGlobalTVChannelWidget(gameController, channelRecord, widgetData.libraryPath);
      } else {
        if IsDefined(this.m_globalTVChannel) {
          this.RegisterTvChannel(channelRecord.OrderID(), gameController);
          this.ShowGlobalTVChannel();
        };
      };
      inkWidgetRef.SetVisible(this.m_videoWidget, false);
    } else {
      if NotEquals(this.m_activeVideo, data.videoPath) || NotEquals(widgetData.deviceState, EDeviceStatus.ON) || !ResRef.IsValid(data.videoPath) {
        this.StopVideo();
      };
      inkWidgetRef.SetVisible(this.m_globalTVChannelSlot, false);
      inkWidgetRef.SetVisible(this.m_videoWidget, true);
      this.m_activeVideo = data.videoPath;
      this.PlayVideo(data.videoPath, data.looped);
      this.RegisterTvChannel(-1, gameController);
    };
  }

  private final func SpawnGlobalTVChannelWidget(gameController: ref<DeviceInkGameControllerBase>, channelRecord: wref<ChannelData_Record>, opt libraryPath: ResRef) -> Void {
    let spawnData: ref<AsyncSpawnData>;
    let tvWidgetData: ref<TvChannelSpawnData> = new TvChannelSpawnData();
    tvWidgetData.Initialize(channelRecord.ChannelWidget(), channelRecord.LocalizedName(), channelRecord.OrderID());
    spawnData = new AsyncSpawnData();
    spawnData.Initialize(this, n"OnGLobalChannelSpawned", ToVariant(tvWidgetData), gameController);
    this.CreateWidgetAsync(inkWidgetRef.Get(this.m_globalTVChannelSlot), channelRecord.ChannelWidget(), libraryPath, spawnData);
  }

  protected cb func OnGLobalChannelSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let gameController: ref<DeviceInkGameControllerBase>;
    let tvWidgetData: ref<TvChannelSpawnData>;
    let spawnData: ref<AsyncSpawnData> = userData as AsyncSpawnData;
    if IsDefined(spawnData) {
      tvWidgetData = FromVariant(spawnData.m_widgetData);
    };
    if IsDefined(widget) {
      widget.SetAnchor(inkEAnchor.Fill);
      widget.SetSizeRule(inkESizeRule.Stretch);
      widget.SetVisible(false);
      if IsDefined(tvWidgetData) {
        widget.SetName(tvWidgetData.m_channelName);
      };
      gameController = spawnData.m_controller as DeviceInkGameControllerBase;
      if IsDefined(gameController) {
        this.m_globalTVChannel = widget;
        this.RegisterTvChannel(tvWidgetData.m_order, gameController);
        this.ShowGlobalTVChannel();
      };
    };
  }

  private final func HideGlobalTVChannel() -> Void {
    if IsDefined(this.m_globalTVChannel) {
      this.m_globalTVChannel.SetVisible(false);
    };
  }

  private final func ShowGlobalTVChannel() -> Void {
    if IsDefined(this.m_globalTVChannel) {
      this.m_globalTVChannel.SetVisible(true);
    };
  }

  private final func RegisterTvChannel(index: Int32, gameController: ref<DeviceInkGameControllerBase>) -> Void {
    let owner: ref<GameObject>;
    if IsDefined(gameController) {
      owner = gameController.GetOwnerEntity() as GameObject;
    };
    if IsDefined(owner) && IsDefined(gameController) {
      GameInstance.GetGlobalTVSystem(owner.GetGame()).RegisterTVChannelOnController(gameController, -1, index);
    };
  }

  private final func StopVideo() -> Void {
    let invalidPath: ResRef;
    inkVideoRef.Stop(this.m_videoWidget);
    inkVideoRef.SetVideoPath(this.m_videoWidget, invalidPath);
  }

  private final func PlayVideo(videoPath: ResRef, looped: Bool) -> Void {
    inkVideoRef.SetVideoPath(this.m_videoWidget, videoPath);
    inkVideoRef.SetLoop(this.m_videoWidget, looped);
    inkVideoRef.Play(this.m_videoWidget);
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
        inkTextRef.SetFontFamily(this.m_messegeWidget, fontPath, fontstyle);
      } else {
        if IsNameValid(fontstyle) {
          inkTextRef.SetFontStyle(this.m_messegeWidget, fontstyle);
        };
      };
      if IsNameValid(verticalAlignment) {
        inkTextRef.SetVerticalAlignment(this.m_messegeWidget, inkTextRef.GetVerticalAlignmentEnumValue(this.m_messegeWidget, verticalAlignment));
      };
      if IsNameValid(horizontalAlignment) {
        inkTextRef.SetHorizontalAlignment(this.m_messegeWidget, inkTextRef.GetHorizontalAlignmentEnumValue(this.m_messegeWidget, horizontalAlignment));
      };
      inkWidgetRef.UpdateMargin(this.m_messegeWidget, record.LeftMargin(), record.TopMargin(), record.RightMargin(), record.BottomMargin());
      inkTextRef.EnableAutoScroll(this.m_messegeWidget, record.AutoScroll());
      inkTextRef.SetFontSize(this.m_messegeWidget, record.FontSize());
      (inkWidgetRef.Get(this.m_messegeWidget) as inkText).SetLocalizedTextScript(record.LocalizedDescription());
      inkTextRef.SetScrollTextSpeed(this.m_messegeWidget, record.ScrollSpeed());
      inkWidgetRef.SetTintColor(this.m_messegeWidget, this.GetColorFromArray(record.TextColor()));
      inkWidgetRef.SetTintColor(this.m_messageBackgroundWidget, this.GetColorFromArray(record.BackgroundColor()));
      inkWidgetRef.SetOpacity(this.m_messageBackgroundWidget, record.BackgroundOpacity());
      this.SetBackgroundTexture(inkWidgetRef.Get(this.m_messageBackgroundWidget) as inkImage, record.BackgroundTextureID());
    } else {
      inkTextRef.SetText(this.m_messegeWidget, "");
      inkWidgetRef.SetOpacity(this.m_messageBackgroundWidget, 0.00);
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
    if imageWidget != null {
      InkImageUtils.RequestSetImage(this, imageWidget, textureID);
      imageWidget.SetAnchor(inkEAnchor.Fill);
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
}
