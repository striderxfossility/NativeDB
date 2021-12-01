
public class RadialMenuGameController extends inkHUDGameController {

  private edit let m_containerRef: inkCompoundRef;

  private edit let m_highlightRef: inkWidgetRef;

  private edit const let m_itemListRef: array<inkWidgetRef>;

  private let m_quickSlotsBoard: wref<IBlackboard>;

  private let m_quickSlotsDef: ref<UI_QuickSlotsDataDef>;

  private let m_inputAxisCallbackId: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    this.m_quickSlotsDef = GetAllBlackboardDefs().UI_QuickSlotsData;
    this.m_quickSlotsBoard = this.GetBlackboardSystem().Get(this.m_quickSlotsDef);
    this.m_inputAxisCallbackId = this.m_quickSlotsBoard.RegisterDelayedListenerFloat(this.m_quickSlotsDef.UIRadialContextRightStickAngle, this, n"OnRadialAngleChanged");
    this.GetRootWidget().SetVisible(false);
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_quickSlotsBoard.UnregisterDelayedListener(this.m_quickSlotsDef.UIRadialContextRightStickAngle, this.m_inputAxisCallbackId);
  }

  protected cb func OnRadialAngleChanged(value: Float) -> Bool {
    let centerPos: Vector2;
    let containerPosition: Vector2;
    let containerSize: Vector2;
    let count: Int32;
    let curAngle: Float;
    let curItem: inkWidgetRef;
    let curPosition: Vector2;
    let curSize: Vector2;
    let i: Int32;
    let itemPos: Vector2;
    let minAngle: Float;
    let rootWidget: wref<inkCompoundWidget>;
    let tmpText: ref<inkText>;
    let tmpWdg: wref<inkCompoundWidget>;
    let highlightAngle: Float = value + 180.00;
    inkWidgetRef.SetRotation(this.m_highlightRef, highlightAngle);
    count = ArraySize(this.m_itemListRef);
    minAngle = -1.00;
    rootWidget = this.GetRootWidget() as inkCompoundWidget;
    containerSize = rootWidget.GetChildSize(inkWidgetRef.Get(this.m_containerRef));
    containerPosition = rootWidget.GetChildPosition(inkWidgetRef.Get(this.m_containerRef));
    centerPos = new Vector2(containerPosition.X + containerSize.X / 2.00, containerPosition.Y + containerSize.Y / 2.00);
    i = 0;
    while i < count {
      curItem = this.m_itemListRef[i];
      curPosition = inkCompoundRef.GetChildPosition(this.m_containerRef, inkWidgetRef.Get(curItem));
      curSize = inkCompoundRef.GetChildSize(this.m_containerRef, inkWidgetRef.Get(curItem));
      itemPos = new Vector2(curPosition.X + curSize.X / 2.00, curPosition.Y + curSize.Y / 2.00);
      curAngle = Rad2Deg(AtanF(itemPos.X - centerPos.X, itemPos.Y - centerPos.Y));
      if minAngle > curAngle {
        minAngle = curAngle;
      };
      tmpWdg = inkWidgetRef.Get(curItem) as inkCompoundWidget;
      tmpText = tmpWdg.GetWidget(n"debug") as inkText;
      tmpText.SetText(curAngle + " : " + value);
      i += 1;
    };
  }

  protected cb func OnOpenWheelRequest(evt: ref<QuickSlotButtonHoldStartEvent>) -> Bool {
    if Equals(evt.dPadItemDirection, EDPadSlot.WeaponsWheel) {
      this.PopulateData();
      this.SetVisible(true);
    };
  }

  protected cb func OnCloseWheelRequest(evt: ref<QuickSlotButtonHoldEndEvent>) -> Bool {
    if Equals(evt.dPadItemDirection, EDPadSlot.WeaponsWheel) {
      this.ApplySelection();
      this.SetVisible(false);
    };
  }

  protected final func PopulateData() -> Void;

  protected final func ApplySelection() -> Void;

  protected final func SetVisible(value: Bool) -> Void {
    this.GetRootWidget().SetVisible(value);
  }
}

public class RadialMenuHelper extends IScriptable {

  public final static func IsWeaponsBlocked(target: wref<GameObject>) -> Bool {
    return StatusEffectSystem.ObjectHasStatusEffectWithTag(target, n"VehicleScene") || StatusEffectSystem.ObjectHasStatusEffectWithTag(target, n"NoCombat") || StatusEffectSystem.ObjectHasStatusEffectWithTag(target, n"FirearmsNoUnequipNoSwitch");
  }

  public final static func IsCombatGadgetsBlocked(target: wref<GameObject>) -> Bool {
    return StatusEffectSystem.ObjectHasStatusEffectWithTag(target, n"Fists") || StatusEffectSystem.ObjectHasStatusEffectWithTag(target, n"Melee") || StatusEffectSystem.ObjectHasStatusEffectWithTag(target, n"Firearms");
  }
}
