
public class LcdScreenInkGameController extends DeviceInkGameControllerBase {

  protected let m_defaultUI: wref<inkCanvas>;

  protected let m_mainDisplayWidget: wref<inkVideo>;

  protected let m_messegeWidget: wref<inkText>;

  protected let m_backgroundWidget: wref<inkLeafWidget>;

  protected let m_messegeRecord: wref<ScreenMessageData_Record>;

  protected let m_replaceTextWithCustomNumber: Bool;

  protected let m_customNumber: Int32;

  private let m_onGlitchingStateChangedListener: ref<CallbackHandle>;

  private let m_onMessegeChangedListener: ref<CallbackHandle>;

  protected cb func OnFillStreetSignData(selector: ref<TweakDBIDSelector>) -> Bool {
    let fluffScreenSelector: ref<LCDScreenSelector>;
    let messageRecord: ref<ScreenMessageData_Record>;
    let screenRecord: ref<LCDScreen_Record>;
    if selector == null {
      return false;
    };
    screenRecord = TweakDBInterface.GetLCDScreenRecord(selector.GetRecordID());
    if IsDefined(screenRecord) {
      fluffScreenSelector = selector as LCDScreenSelector;
      if IsDefined(fluffScreenSelector) {
        this.InitializeCustomNumber(fluffScreenSelector.HasCustomNumber(), fluffScreenSelector.GetCustomNumber());
        messageRecord = TweakDBInterface.GetScreenMessageDataRecord(fluffScreenSelector.GetCustomMessageID());
      };
      if messageRecord == null {
        messageRecord = screenRecord.Message();
      };
      this.InitializeMessageRecord(messageRecord);
    } else {
      messageRecord = TweakDBInterface.GetScreenMessageDataRecord(selector.GetRecordID());
      if messageRecord != null {
        this.InitializeMessageRecord(messageRecord);
      };
    };
    this.Refresh(this.GetOwner().GetDeviceState());
  }

  protected func SetupWidgets() -> Void {
    if !this.m_isInitialized {
      this.m_defaultUI = this.GetWidget(n"default_ui") as inkCanvas;
      this.m_messegeWidget = this.GetWidget(n"default_ui/messege_text") as inkText;
      this.m_mainDisplayWidget = this.GetWidget(n"main_display") as inkVideo;
      this.m_backgroundWidget = this.GetWidget(n"default_ui/messege_background") as inkLeafWidget;
      this.m_rootWidget.SetAnchor(inkEAnchor.Fill);
    };
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
    this.StopVideo();
  }

  public func UpdateActionWidgets(widgetsData: array<SActionWidgetPackage>) -> Void;

  public func Refresh(state: EDeviceStatus) -> Void {
    this.SetupWidgets();
    switch state {
      case EDeviceStatus.ON:
        this.TurnOn();
        break;
      case EDeviceStatus.OFF:
        this.TurnOff();
        break;
      case EDeviceStatus.UNPOWERED:
        break;
      case EDeviceStatus.DISABLED:
        break;
      default:
    };
    this.Refresh(state);
  }

  protected func RegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.RegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      this.m_onGlitchingStateChangedListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef().GlitchData, this, n"OnGlitchingStateChanged");
      this.m_onMessegeChangedListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef() as LcdScreenBlackBoardDef.MessegeData, this, n"OnMessegeChanged");
    };
  }

  protected func UnRegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.UnRegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef().GlitchData, this.m_onGlitchingStateChangedListener);
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef() as LcdScreenBlackBoardDef.MessegeData, this.m_onMessegeChangedListener);
    };
  }

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }

  protected cb func OnActionWidgetsUpdate(value: Variant) -> Bool {
    let widgets: array<SActionWidgetPackage> = FromVariant(value);
    this.UpdateActionWidgets(widgets);
  }

  protected cb func OnMessegeChanged(value: Variant) -> Bool {
    let record: ref<ScreenMessageData_Record>;
    let messageData: ref<ScreenMessageData> = FromVariant(value);
    if messageData == null {
      return false;
    };
    record = messageData.m_messageRecord;
    if record == null {
      return false;
    };
    this.InitializeCustomNumber(messageData.m_replaceTextWithCustomNumber, messageData.m_customNumber);
    this.InitializeMessageRecord(record);
    this.ResolveMessegeRecord(this.m_messegeRecord);
  }

  private func StartGlitchingScreen(glitchData: GlitchData) -> Void {
    if Equals(glitchData.state, EGlitchState.DEFAULT) {
    } else {
      this.StopVideo();
      this.PlayVideo(r"base\\movies\\misc\\distraction_generic.bk2", true, n"");
    };
  }

  private func StopGlitchingScreen() -> Void {
    this.StopVideo();
  }

  public final func PlayVideo(videoPath: ResRef, looped: Bool, audioEvent: CName) -> Void {
    this.m_mainDisplayWidget.SetVideoPath(videoPath);
    this.m_mainDisplayWidget.SetLoop(looped);
    if IsNameValid(audioEvent) {
      this.m_mainDisplayWidget.SetAudioEvent(audioEvent);
    };
    this.m_mainDisplayWidget.Play();
  }

  public final func StopVideo() -> Void {
    this.m_mainDisplayWidget.Stop();
  }

  public final func TurnOff() -> Void {
    this.m_rootWidget.SetVisible(false);
  }

  public final func TurnOn() -> Void {
    this.m_rootWidget.SetVisible(true);
    if this.m_messegeRecord == null {
      this.InitializeCustomNumber((this.GetOwner() as LcdScreen).HasCustomNumber(), (this.GetOwner() as LcdScreen).GetCustomNumber());
      this.InitializeMessageRecord((this.GetOwner() as LcdScreen).GetMessageRecord());
    };
    this.ResolveMessegeRecord(this.m_messegeRecord);
  }

  private final func InitializeCustomNumber(replaceTextWithCustomNumber: Bool, customNumber: Int32) -> Void {
    this.m_replaceTextWithCustomNumber = replaceTextWithCustomNumber;
    this.m_customNumber = customNumber;
  }

  private final func InitializeMessageRecord(messageRecord: ref<ScreenMessageData_Record>) -> Void {
    let count: Int32;
    let groupRecord: wref<ScreenMessagesList_Record>;
    let rand: Int32;
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
    this.m_messegeRecord = messageRecord;
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
      this.m_messegeWidget.EnableAutoScroll(record.AutoScroll());
      this.m_messegeWidget.SetFontSize(record.FontSize());
      if this.m_replaceTextWithCustomNumber {
        this.m_messegeWidget.SetText(IntToString(this.m_customNumber));
      } else {
        this.m_messegeWidget.SetLocalizedTextScript(record.LocalizedDescription());
      };
      this.m_messegeWidget.UpdateMargin(record.LeftMargin(), record.TopMargin(), record.RightMargin(), record.BottomMargin());
      this.m_messegeWidget.SetTintColor(this.GetColorFromArray(record.TextColor()));
      this.m_messegeWidget.SetScrollTextSpeed(record.ScrollSpeed());
      this.m_backgroundWidget.SetTintColor(this.GetColorFromArray(record.BackgroundColor()));
      this.m_backgroundWidget.SetOpacity(record.BackgroundOpacity());
      this.SetBackgroundTexture(this.m_backgroundWidget as inkImage, record.BackgroundTextureID());
    };
  }

  protected final func GetColorFromArray(calorArray: array<Int32>) -> Color {
    let color: Color;
    let i: Int32 = 0;
    while i < ArraySize(calorArray) {
      if i == 0 {
        color.Red = Cast(calorArray[i]);
      } else {
        if i == 1 {
          color.Green = Cast(calorArray[i]);
        } else {
          if i == 2 {
            color.Blue = Cast(calorArray[i]);
          } else {
            if i == 3 {
              color.Alpha = Cast(calorArray[i]);
            };
          };
        };
      };
      i += 1;
    };
    return color;
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
}
