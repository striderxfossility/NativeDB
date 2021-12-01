
public class NetRunnerChargesGameController extends inkGameController {

  public edit let m_header: inkTextRef;

  public edit let m_list: inkCompoundRef;

  public edit let m_bar: inkWidgetRef;

  public edit let m_value: inkTextRef;

  private let m_blackboard: wref<IBlackboard>;

  private let m_bbDefinition: ref<UI_PlayerBioMonitorDef>;

  private let m_netrunnerCapacityId: Uint32;

  private let m_netrunnerCurrentId: ref<CallbackHandle>;

  private let m_currentCharges: Int32;

  private let m_maxCharges: Int32;

  private let m_chargesList: array<wref<NetRunnerListItem>>;

  private let m_root: wref<inkWidget>;

  protected cb func OnInitialize() -> Bool {
    this.m_root = this.GetRootWidget();
    inkCompoundRef.RemoveAllChildren(this.m_list);
    this.SetupBB();
  }

  protected cb func OnUnitialize() -> Bool {
    this.RemoveBB();
  }

  private final func SetupBB() -> Void {
    this.m_bbDefinition = GetAllBlackboardDefs().UI_PlayerBioMonitor;
    this.m_blackboard = this.GetBlackboardSystem().Get(this.m_bbDefinition);
    if IsDefined(this.m_blackboard) {
      this.m_netrunnerCurrentId = this.m_blackboard.RegisterDelayedListenerFloat(this.m_bbDefinition.MemoryPercent, this, n"OnNetrunnerChargesUpdated");
      this.OnNetrunnerChargesUpdated(this.m_blackboard.GetFloat(this.m_bbDefinition.MemoryPercent));
    };
  }

  private final func RemoveBB() -> Void {
    if IsDefined(this.m_blackboard) {
      this.m_blackboard.UnregisterDelayedListener(this.m_bbDefinition.MemoryPercent, this.m_netrunnerCurrentId);
    };
    this.m_blackboard = null;
  }

  protected cb func OnNetrunnerChargesUpdated(value: Float) -> Bool {
    let normalizedValue: Int32 = Cast(value);
    let scaledValue: Float = value / 100.00;
    inkTextRef.SetText(this.m_value, ToString(normalizedValue) + "%");
    inkWidgetRef.SetScale(this.m_bar, new Vector2(scaledValue, 1.00));
    if value >= 100.00 {
      this.Hide();
    } else {
      this.Show();
    };
  }

  public final func Show() -> Void {
    this.m_root.SetVisible(true);
  }

  public final func Hide() -> Void {
    this.m_root.SetVisible(false);
  }
}

public class NetRunnerListItem extends inkLogicController {

  public edit let m_highlight: inkWidgetRef;

  protected cb func OnInitialize() -> Bool;

  public final func ShowHighlight() -> Void {
    inkWidgetRef.SetVisible(this.m_highlight, true);
  }

  public final func HideHighlight() -> Void {
    inkWidgetRef.SetVisible(this.m_highlight, false);
  }
}
