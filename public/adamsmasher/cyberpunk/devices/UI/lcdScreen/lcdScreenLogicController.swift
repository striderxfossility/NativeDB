
public class LcdScreenILogicController extends inkLogicController {

  protected edit let m_defaultUI: inkWidgetRef;

  protected edit let m_mainDisplayWidget: inkVideoRef;

  protected edit let m_messegeWidget: inkTextRef;

  protected edit let m_backgroundWidget: inkImageRef;

  protected let m_messegeRecord: wref<ScreenMessageData_Record>;

  protected let m_replaceTextWithCustomNumber: Bool;

  protected let m_customNumber: Int32;

  protected cb func OnInitialize() -> Bool {
    this.GetRootWidget().SetAnchor(inkEAnchor.Fill);
  }

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
      this.ResolveMessegeRecord(this.m_messegeRecord);
    } else {
      messageRecord = TweakDBInterface.GetScreenMessageDataRecord(selector.GetRecordID());
      if messageRecord != null {
        this.InitializeMessageRecord(messageRecord);
      };
      this.InitializeMessageRecord(messageRecord);
      this.ResolveMessegeRecord(this.m_messegeRecord);
    };
  }

  public final func PlayVideo(videoPath: ResRef, looped: Bool, audioEvent: CName) -> Void {
    inkVideoRef.SetVideoPath(this.m_mainDisplayWidget, videoPath);
    inkVideoRef.SetLoop(this.m_mainDisplayWidget, looped);
    if IsNameValid(audioEvent) {
      (inkWidgetRef.Get(this.m_mainDisplayWidget) as inkVideo).SetAudioEvent(audioEvent);
    };
    inkVideoRef.Play(this.m_mainDisplayWidget);
  }

  public final func StopVideo() -> Void {
    inkVideoRef.Stop(this.m_mainDisplayWidget);
  }

  public final func TurnOff() -> Void {
    inkWidgetRef.UnregisterFromCallback(this.m_mainDisplayWidget, n"OnVideoFinished", this, n"OnVideoFinished");
  }

  public final func TurnOn() -> Void {
    this.ResolveMessegeRecord(this.m_messegeRecord);
  }

  public final func InitializeCustomNumber(replaceTextWithCustomNumber: Bool, customNumber: Int32) -> Void {
    this.m_replaceTextWithCustomNumber = replaceTextWithCustomNumber;
    this.m_customNumber = customNumber;
  }

  public final func InitializeMessageRecord(messageRecord: ref<ScreenMessageData_Record>) -> Void {
    let count: Int32;
    let groupRecord: wref<ScreenMessagesList_Record>;
    let rand: Int32;
    if messageRecord == this.m_messegeRecord {
      return;
    };
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

  public func ResolveMessegeRecord(record: wref<ScreenMessageData_Record>) -> Void {
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
      inkTextRef.EnableAutoScroll(this.m_messegeWidget, record.AutoScroll());
      inkTextRef.SetFontSize(this.m_messegeWidget, record.FontSize());
      if this.m_replaceTextWithCustomNumber {
        inkTextRef.SetText(this.m_messegeWidget, IntToString(this.m_customNumber));
      } else {
        inkTextRef.SetLocalizedTextScript(this.m_messegeWidget, record.LocalizedDescription());
      };
      inkWidgetRef.UpdateMargin(this.m_messegeWidget, record.LeftMargin(), record.TopMargin(), record.RightMargin(), record.BottomMargin());
      inkWidgetRef.SetTintColor(this.m_messegeWidget, this.GetColorFromArray(record.TextColor()));
      inkTextRef.SetScrollTextSpeed(this.m_messegeWidget, record.ScrollSpeed());
      inkWidgetRef.SetTintColor(this.m_backgroundWidget, this.GetColorFromArray(record.BackgroundColor()));
      inkWidgetRef.SetOpacity(this.m_backgroundWidget, record.BackgroundOpacity());
      this.SetTexture(this.m_backgroundWidget, record.BackgroundTextureID());
    };
  }

  private final func GetColorFromArray(calorArray: array<Int32>) -> Color {
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
}
