
public class VendorItemActionWidgetController extends DeviceActionWidgetControllerBase {

  @attrib(category, "Widget Refs")
  protected edit let m_priceWidget: inkTextRef;

  @attrib(category, "Widget Refs")
  protected edit let m_priceContainer: inkWidgetRef;

  @attrib(category, "Widget Refs")
  protected edit let m_moneyStatusContainer: inkWidgetRef;

  @attrib(category, "Widget Refs")
  protected edit let m_processingStatusContainer: inkWidgetRef;

  public func Initialize(gameController: ref<DeviceInkGameControllerBase>, widgetData: SActionWidgetPackage) -> Void {
    let action: ref<DispenceItemFromVendor>;
    let textParams: ref<inkTextParams>;
    this.Initialize(gameController, widgetData);
    action = widgetData.action as DispenceItemFromVendor;
    inkWidgetRef.SetVisible(this.m_moneyStatusContainer, false);
    inkWidgetRef.SetVisible(this.m_processingStatusContainer, false);
    if IsDefined(action) {
      textParams = new inkTextParams();
      textParams.AddNumber("COST", action.GetPrice());
      textParams.AddLocalizedString("ED", "LocKey#884");
      inkTextRef.SetLocalizedTextScript(this.m_priceWidget, "LocKey#45350", textParams);
    };
  }

  public func FinalizeActionExecution(executor: ref<GameObject>, action: ref<DeviceAction>) -> Void {
    let contextAction: ref<DispenceItemFromVendor> = action as DispenceItemFromVendor;
    if IsDefined(contextAction) {
      this.ProcessPayment(contextAction, executor);
    };
  }

  protected final func ProcessPayment(action: ref<DispenceItemFromVendor>, executor: ref<GameObject>) -> Void {
    if IsDefined(action) {
      this.m_targetWidget.SetInteractive(false);
      if action.CanPay(executor) {
        this.PlayLibraryAnimation(n"pay").RegisterToCallback(inkanimEventType.OnFinish, this, n"OnPaymentProcessed");
      } else {
        this.PlayLibraryAnimation(n"no_money").RegisterToCallback(inkanimEventType.OnFinish, this, n"OnNoMoneyShowed");
      };
    };
  }

  protected cb func OnPaymentProcessed(e: ref<inkAnimProxy>) -> Bool {
    e.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnPaymentProcessed");
    this.m_targetWidget.SetInteractive(true);
  }

  protected cb func OnNoMoneyShowed(e: ref<inkAnimProxy>) -> Bool {
    e.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnNoMoneyShowed");
    this.m_targetWidget.SetInteractive(true);
  }
}
