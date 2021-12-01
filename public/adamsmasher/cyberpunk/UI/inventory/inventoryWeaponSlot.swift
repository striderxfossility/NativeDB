
public class InventoryWeaponSlot extends InventoryEquipmentSlot {

  protected edit let m_DamageIndicatorRef: inkWidgetRef;

  protected edit let m_DPSRef: inkWidgetRef;

  protected edit let m_DPSValueLabel: inkTextRef;

  private let m_DamageTypeIndicator: wref<DamageTypeIndicator>;

  @default(InventoryWeaponSlot, false)
  private let m_IntroPlayed: Bool;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_DamageTypeIndicator = inkWidgetRef.GetControllerByType(this.m_DamageIndicatorRef, n"DamageTypeIndicator") as DamageTypeIndicator;
  }

  public func Setup(itemData: InventoryItemData, equipmentArea: gamedataEquipmentArea, opt slotName: String, opt slotIndex: Int32, opt ownerEntity: ref<Entity>) -> Void {
    let limit: Int32;
    let stats: array<StatViewData>;
    this.Setup(itemData, equipmentArea, slotName, slotIndex, ownerEntity);
    stats = InventoryItemData.GetPrimaryStats(itemData);
    limit = ArraySize(stats);
    if limit > 0 {
      inkTextRef.SetText(this.m_DPSValueLabel, IntToString(stats[0].value));
    };
    if IsDefined(this.m_DamageTypeIndicator) {
      this.m_DamageTypeIndicator.Setup(InventoryItemData.GetDamageType(itemData));
    };
    if InventoryItemData.IsEmpty(itemData) {
      inkWidgetRef.SetVisible(this.m_DPSRef, false);
      inkWidgetRef.SetVisible(this.m_DamageIndicatorRef, false);
    } else {
      inkWidgetRef.SetVisible(this.m_DPSRef, true);
      inkWidgetRef.SetVisible(this.m_DamageIndicatorRef, true);
    };
  }

  private final func PlayIntroAnimation(framesDelay: Int32) -> Void {
    let animaionDef: ref<inkAnimDef> = new inkAnimDef();
    let scaleInterp: ref<inkAnimScale> = new inkAnimScale();
    scaleInterp.SetStartScale(new Vector2(0.00, 0.00));
    scaleInterp.SetEndScale(new Vector2(1.00, 1.00));
    scaleInterp.SetMode(inkanimInterpolationMode.EasyInOut);
    scaleInterp.SetType(inkanimInterpolationType.Sinusoidal);
    scaleInterp.SetDirection(inkanimInterpolationDirection.FromTo);
    scaleInterp.SetDuration(0.25);
    scaleInterp.SetStartDelay(0.03 * Cast(framesDelay));
    animaionDef.AddInterpolator(scaleInterp);
    this.GetRootWidget().PlayAnimation(animaionDef);
  }

  private func RefreshUI() -> Void {
    this.RefreshUI();
  }
}
