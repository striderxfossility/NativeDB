
public class CurrencyChangeInventoryCallback extends InventoryScriptCallback {

  public let m_notificationQueue: wref<ItemsNotificationQueue>;

  public func OnItemQuantityChanged(item: ItemID, diff: Int32, total: Uint32, flaggedAsSilent: Bool) -> Void {
    if ItemID.IsOfTDBID(item, t"Items.money") && !flaggedAsSilent {
      this.m_notificationQueue.PushCurrencyNotification(diff, total);
    };
  }
}

public native class CurrencyUpdateNotificationViewData extends GenericNotificationViewData {

  public native let diff: Int32;

  public native let total: Uint32;

  public func CanMerge(data: ref<GenericNotificationViewData>) -> Bool {
    let compareTo: ref<CurrencyUpdateNotificationViewData> = data as CurrencyUpdateNotificationViewData;
    if IsDefined(compareTo) {
      this.total = compareTo.total;
      this.diff = this.diff + compareTo.diff;
      return true;
    };
    return false;
  }
}

public class CurrencyNotification extends GenericNotificationController {

  private edit let m_CurrencyUpdateAnimation: CName;

  private edit let m_CurrencyDiff: inkTextRef;

  private edit let m_CurrencyTotal: inkTextRef;

  private edit let m_diff_animator: wref<inkTextValueProgressController>;

  private edit let m_total_animator: wref<inkTextValueProgressController>;

  private let m_currencyData: ref<CurrencyUpdateNotificationViewData>;

  private let m_animProxy: ref<inkAnimProxy>;

  private let blackboard: wref<IBlackboard>;

  private let uiSystemBB: ref<UI_SystemDef>;

  private let uiSystemId: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.blackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_System);
    this.uiSystemBB = GetAllBlackboardDefs().UI_System;
    this.uiSystemId = this.blackboard.RegisterListenerBool(this.uiSystemBB.IsInMenu, this, n"OnMenuUpdate");
    this.RegisterToCallback(n"OnItemChanged", this, n"OnDataUpdate");
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
    this.blackboard.UnregisterListenerBool(this.uiSystemBB.IsInMenu, this.uiSystemId);
  }

  protected cb func OnDataUpdate() -> Bool {
    this.UpdateData();
  }

  protected cb func OnMenuUpdate(value: Bool) -> Bool {
    this.UpdateData();
  }

  public func SetNotificationData(notificationData: ref<GenericNotificationViewData>) -> Void {
    this.m_currencyData = notificationData as CurrencyUpdateNotificationViewData;
    this.UpdateData();
    this.SetNotificationData(notificationData);
  }

  private final func UpdateData() -> Void {
    let optionIntro: inkAnimOptions;
    this.m_diff_animator = inkWidgetRef.GetController(this.m_CurrencyDiff) as inkTextValueProgressController;
    this.m_total_animator = inkWidgetRef.GetController(this.m_CurrencyTotal) as inkTextValueProgressController;
    inkTextRef.SetText(this.m_CurrencyDiff, ToString(this.m_currencyData.diff));
    inkTextRef.SetText(this.m_CurrencyTotal, ToString(this.m_currencyData.total));
    this.m_diff_animator.SetDelay(2.50);
    this.m_total_animator.SetDelay(2.50);
    this.m_diff_animator.SetDuration(1.00);
    this.m_total_animator.SetDuration(1.00);
    this.m_diff_animator.SetBaseValue(Cast(this.m_currencyData.diff));
    this.m_total_animator.SetBaseValue(Cast(this.m_currencyData.total) - Cast(this.m_currencyData.diff));
    this.m_diff_animator.SetTargetValue(0.00);
    this.m_total_animator.SetTargetValue(Cast(this.m_currencyData.total));
    this.m_diff_animator.PlaySetAnimation();
    this.m_total_animator.PlaySetAnimation().RegisterToCallback(inkanimEventType.OnFinish, this, n"OnIntroOver");
    if !IsDefined(this.m_animProxy) {
      optionIntro.toMarker = n">intro_end";
      this.m_animProxy = this.PlayLibraryAnimation(this.m_CurrencyUpdateAnimation, optionIntro);
    };
  }

  protected cb func OnIntroOver(e: ref<inkAnimProxy>) -> Bool {
    let optionOutro: inkAnimOptions;
    e.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnIntroOver");
    optionOutro.fromMarker = n"Outro_start";
    optionOutro.executionDelay = 0.50;
    this.PlayLibraryAnimation(this.m_CurrencyUpdateAnimation, optionOutro);
  }
}
