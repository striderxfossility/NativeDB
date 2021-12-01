
public class LcdScreenSignInkGameController extends DeviceInkGameControllerBase {

  protected let m_messegeRecord: wref<ScreenMessageData_Record>;

  protected let m_replaceTextWithCustomNumber: Bool;

  protected let m_customNumber: Int32;

  private let m_onGlitchingStateChangedListener: ref<CallbackHandle>;

  private let m_onMessegeChangedListener: ref<CallbackHandle>;

  protected func SetupWidgets() -> Void {
    if !this.m_isInitialized {
      this.m_rootWidget.SetAnchor(inkEAnchor.Fill);
    };
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
    this.Refresh(this.GetOwner().GetDeviceState());
  }

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

  protected final func GetMainLogicController() -> ref<LcdScreenILogicController> {
    return this.m_rootWidget.GetController() as LcdScreenILogicController;
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
      this.GetMainLogicController().StopVideo();
      this.GetMainLogicController().PlayVideo(r"base\\movies\\misc\\distraction_generic.bk2", true, n"");
    };
  }

  private func StopGlitchingScreen() -> Void {
    this.GetMainLogicController().StopVideo();
  }

  public final func TurnOff() -> Void {
    this.m_rootWidget.SetVisible(false);
    this.GetMainLogicController().TurnOff();
  }

  public final func TurnOn() -> Void {
    this.m_rootWidget.SetVisible(true);
    if this.m_messegeRecord == null {
      this.InitializeCustomNumber((this.GetOwner() as LcdScreen).HasCustomNumber(), (this.GetOwner() as LcdScreen).GetCustomNumber());
      this.InitializeMessageRecord((this.GetOwner() as LcdScreen).GetMessageRecord());
    };
    this.GetMainLogicController().TurnOn();
  }

  private final func InitializeCustomNumber(replaceTextWithCustomNumber: Bool, customNumber: Int32) -> Void {
    this.m_replaceTextWithCustomNumber = replaceTextWithCustomNumber;
    this.m_customNumber = customNumber;
    this.GetMainLogicController().InitializeCustomNumber(replaceTextWithCustomNumber, customNumber);
  }

  private final func InitializeMessageRecord(messageRecord: ref<ScreenMessageData_Record>) -> Void {
    this.GetMainLogicController().InitializeMessageRecord(messageRecord);
    this.m_messegeRecord = messageRecord;
  }

  protected func ResolveMessegeRecord(record: wref<ScreenMessageData_Record>) -> Void {
    this.GetMainLogicController().ResolveMessegeRecord(record);
  }
}
