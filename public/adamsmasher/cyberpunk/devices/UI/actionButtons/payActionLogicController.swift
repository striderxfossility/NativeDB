
public class PayActionWidgetController extends DeviceActionWidgetControllerBase {

  @attrib(category, "Widget Refs")
  protected edit let m_priceContainer: inkWidgetRef;

  @attrib(category, "Widget Refs")
  protected edit let m_moneyStatusContainer: inkWidgetRef;

  @attrib(category, "Widget Refs")
  protected edit let m_processingStatusContainer: inkWidgetRef;

  @attrib(category, "Animations")
  @default(PayActionWidgetController, no_money)
  protected edit let m_moneyStatusAnimName: CName;

  @attrib(category, "Animations")
  @default(PayActionWidgetController, pay)
  protected edit let m_processingAnimName: CName;

  private let m_isProcessingPayment: Bool;

  public func Initialize(gameController: ref<DeviceInkGameControllerBase>, widgetData: SActionWidgetPackage) -> Void {
    let action: ref<Pay>;
    let textParams: ref<inkTextParams>;
    this.Initialize(gameController, widgetData);
    action = widgetData.action as Pay;
    inkWidgetRef.SetVisible(this.m_moneyStatusContainer, false);
    inkWidgetRef.SetVisible(this.m_processingStatusContainer, false);
    if IsDefined(action) {
      textParams = new inkTextParams();
      textParams.AddNumber("COST", action.GetCost());
      textParams.AddLocalizedString("ED", "LocKey#884");
      textParams.AddString("STATUS", "");
      inkTextRef.SetTextParameters(this.m_displayNameWidget, textParams);
    };
  }

  public func FinalizeActionExecution(executor: ref<GameObject>, action: ref<DeviceAction>) -> Void {
    let contextAction: ref<Pay> = action as Pay;
    if IsDefined(contextAction) {
      this.ProcessPayment(contextAction, executor);
    };
  }

  protected final func ProcessPayment(action: ref<Pay>, executor: ref<GameObject>) -> Void {
    if IsDefined(action) && !this.m_isProcessingPayment {
      this.m_isProcessingPayment = true;
      this.m_targetWidget.SetInteractive(false);
      if action.CanPayCost(executor) {
        this.PlayLibraryAnimation(this.m_processingAnimName).RegisterToCallback(inkanimEventType.OnFinish, this, n"OnPaymentProcessed");
      } else {
        this.PlayLibraryAnimation(this.m_moneyStatusAnimName).RegisterToCallback(inkanimEventType.OnFinish, this, n"OnNoMoneyShowed");
      };
    };
  }

  protected cb func OnPaymentProcessed(e: ref<inkAnimProxy>) -> Bool {
    e.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnPaymentProcessed");
    this.m_targetWidget.SetInteractive(true);
    this.m_isProcessingPayment = false;
  }

  protected cb func OnNoMoneyShowed(e: ref<inkAnimProxy>) -> Bool {
    e.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnNoMoneyShowed");
    this.m_targetWidget.SetInteractive(true);
    this.m_isProcessingPayment = false;
  }

  public const func CanExecuteAction() -> Bool {
    return this.CanExecuteAction() && !this.m_isProcessingPayment;
  }
}
