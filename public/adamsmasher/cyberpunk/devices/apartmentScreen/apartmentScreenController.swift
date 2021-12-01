
public class ApartmentScreenController extends LcdScreenController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class ApartmentScreenControllerPS extends LcdScreenControllerPS {

  @attrib(category, "UI")
  private let m_initialRentStatus: ERentStatus;

  @attrib(category, "UI")
  @attrib(customEditor, "TweakDBGroupInheritance;ScreenMessageData")
  private edit let m_overdueMessageRecordID: TweakDBID;

  @attrib(category, "UI")
  @attrib(customEditor, "TweakDBGroupInheritance;ScreenMessageData")
  private edit let m_paidMessageRecordID: TweakDBID;

  @attrib(category, "UI")
  @attrib(customEditor, "TweakDBGroupInheritance;ScreenMessageData")
  private edit let m_evictionMessageRecordID: TweakDBID;

  @attrib(category, "UI")
  @default(ApartmentScreenControllerPS, EPaymentSchedule.WEEKLY)
  private let m_paymentSchedule: EPaymentSchedule;

  @attrib(category, "UI")
  @default(ApartmentScreenControllerPS, true)
  private let m_randomizeInitialOverdue: Bool;

  @attrib(rangeMax, "90")
  @attrib(category, "UI")
  @attrib(rangeMin, "0")
  private let m_initialOverdue: Int32;

  @attrib(category, "UI")
  @default(ApartmentScreenControllerPS, true)
  private let m_allowAutomaticRentStatusChange: Bool;

  @default(ApartmentScreenControllerPS, 90)
  private const let m_maxDays: Int32;

  private persistent let m_currentOverdue: Int32;

  private persistent let m_isInitialRentStateSet: Bool;

  private persistent let m_currentRentStatus: ERentStatus;

  private persistent let m_lastStatusChangeDay: Int32;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "Gameplay-Devices-DisplayNames-Screen";
    };
  }

  protected func GameAttached() -> Void {
    this.UpdateRentState();
  }

  public func GetQuestActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(outActions, context);
  }

  public final func UpdateRentState() -> Void {
    if !this.m_isInitialRentStateSet {
      this.InitializeRentState();
    } else {
      if this.m_allowAutomaticRentStatusChange {
        this.ReEvaluateRentStatus();
      };
      if Equals(this.m_currentRentStatus, ERentStatus.OVERDUE) {
        this.UpdateCurrentOverdue();
      };
    };
    this.RefreshUI(this.GetBlackboard());
  }

  private final func InitializeRentState() -> Void {
    this.m_currentOverdue = this.GetInitialOverdueValue();
    if this.m_allowAutomaticRentStatusChange {
      if this.m_currentOverdue > 0 {
        this.SetCurrentRentStatus(ERentStatus.OVERDUE);
      } else {
        this.SetCurrentRentStatus(ERentStatus.PAID);
      };
    } else {
      this.SetCurrentRentStatus(this.m_initialRentStatus);
    };
    this.m_isInitialRentStateSet = true;
  }

  private final func GetInitialOverdueValue() -> Int32 {
    let returnValue: Int32;
    let randValue: Int32 = RandRange(0, 2);
    if this.m_randomizeInitialOverdue && randValue == 1 {
      returnValue = RandRange(0, this.m_maxDays);
    } else {
      if Equals(this.m_initialRentStatus, ERentStatus.OVERDUE) {
        this.m_initialOverdue = 1;
      };
      returnValue = this.m_initialOverdue;
    };
    return returnValue;
  }

  private final func SetCurrentRentStatus(status: ERentStatus) -> Void {
    let messageID: TweakDBID;
    this.m_currentRentStatus = status;
    this.m_lastStatusChangeDay = this.GetCurrentDay();
    if Equals(this.m_currentRentStatus, ERentStatus.PAID) {
      this.m_currentOverdue = 0;
      if TDBID.IsValid(this.m_paidMessageRecordID) {
        messageID = this.m_paidMessageRecordID;
      } else {
        messageID = t"screen_messages.RentPaid";
      };
    } else {
      if Equals(this.m_currentRentStatus, ERentStatus.OVERDUE) {
        if TDBID.IsValid(this.m_overdueMessageRecordID) {
          messageID = this.m_overdueMessageRecordID;
        } else {
          messageID = t"screen_messages.RentOverdue";
        };
      } else {
        if Equals(this.m_currentRentStatus, ERentStatus.EVICTED) {
          if TDBID.IsValid(this.m_evictionMessageRecordID) {
            messageID = this.m_evictionMessageRecordID;
          } else {
            messageID = t"screen_messages.EvictionNotice";
          };
        };
      };
    };
    this.SetMessageRecordID(messageID);
  }

  private final func UpdateCurrentOverdue() -> Void {
    this.m_currentOverdue += 1;
  }

  private final func GetGameTime() -> GameTime {
    return GameInstance.GetTimeSystem(this.GetGameInstance()).GetGameTime();
  }

  private final func GetCurrentDay() -> Int32 {
    return GameTime.Days(this.GetGameTime());
  }

  private final func GetDaysPassed() -> Int32 {
    return this.GetCurrentDay() - this.m_lastStatusChangeDay;
  }

  private final func ReEvaluateRentStatus() -> Void {
    let randValue: Int32;
    let stateChangeProbablity: Int32;
    if Equals(this.m_currentRentStatus, ERentStatus.PAID) && this.GetDaysPassed() < this.GetPaymentScheduleValue() {
      return;
    };
    stateChangeProbablity = this.GetStateChangeProbabilityValue();
    randValue = RandRange(0, 100);
    if randValue > stateChangeProbablity {
      return;
    };
    if Equals(this.m_currentRentStatus, ERentStatus.OVERDUE) {
      randValue = RandRange(0, 2);
      if randValue == 0 {
        this.SetCurrentRentStatus(ERentStatus.PAID);
      } else {
        this.SetCurrentRentStatus(ERentStatus.EVICTED);
      };
    } else {
      if Equals(this.m_currentRentStatus, ERentStatus.PAID) {
        this.SetCurrentRentStatus(ERentStatus.OVERDUE);
      } else {
        if Equals(this.m_currentRentStatus, ERentStatus.EVICTED) {
          this.SetCurrentRentStatus(ERentStatus.PAID);
        };
      };
    };
  }

  private final func GetStateChangeProbabilityValue() -> Int32 {
    let daysPassed: Float;
    let returnValue: Float;
    if Equals(this.m_currentRentStatus, ERentStatus.OVERDUE) {
      daysPassed = Cast(this.m_currentOverdue);
    } else {
      daysPassed = Cast(this.GetCurrentDay()) - Cast(this.m_lastStatusChangeDay);
    };
    if daysPassed > Cast(this.m_maxDays) {
      returnValue = 100.00;
    } else {
      returnValue = daysPassed / Cast(this.m_maxDays) * 100.00;
    };
    return Cast(returnValue);
  }

  public final const func GetCurrentRentStatus() -> ERentStatus {
    return this.m_currentRentStatus;
  }

  public final const func GetCurrentOverdueValue() -> Int32 {
    return this.m_currentOverdue;
  }

  public final const func GetPaymentScheduleValue() -> Int32 {
    let returnValue: Int32;
    if Equals(this.m_paymentSchedule, EPaymentSchedule.WEEKLY) {
      returnValue = 7;
    } else {
      if Equals(this.m_paymentSchedule, EPaymentSchedule.MONTHLY) {
        returnValue = 30;
      };
    };
    return returnValue;
  }
}
