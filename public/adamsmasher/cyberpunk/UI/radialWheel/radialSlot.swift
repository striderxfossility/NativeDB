
public class RadialStatusEffectController extends inkLogicController {

  private edit let effectsContainerRef: inkCompoundRef;

  private edit let poolHolderRef: inkCompoundRef;

  private edit let effectTemplateRef: inkWidgetLibraryReference;

  @default(RadialStatusEffectController, 8)
  private edit let maxSize: Int32;

  private let effects: array<wref<SingleCooldownManager>>;

  protected cb func OnInitialize() -> Bool {
    let effect: ref<SingleCooldownManager>;
    let i: Int32 = 0;
    while i < this.maxSize {
      effect = this.SpawnFromLocal(inkWidgetRef.Get(this.poolHolderRef), this.effectTemplateRef.widgetItem).GetController() as SingleCooldownManager;
      effect.Init(this.poolHolderRef, this.effectsContainerRef);
      ArrayPush(this.effects, effect);
      i += 1;
    };
  }
}

public class PointerController extends inkLogicController {

  private edit const let m_connectors: array<inkWidgetRef>;

  private edit let m_pointer: inkWidgetRef;

  private edit let m_centerButtonSlot: inkWidgetRef;

  private edit let m_centerButton: wref<inkWidget>;

  @default(PointerController, -1)
  private let currentIndex: Int32;

  protected cb func OnInitialize() -> Bool {
    let inputKey: inkInputKeyData;
    let i: Int32 = 0;
    while i < ArraySize(this.m_connectors) {
      inkWidgetRef.Get(this.m_connectors[i]).SetVisible(false);
      i += 1;
    };
    inkWidgetRef.Get(this.m_pointer).SetVisible(false);
    if IsDefined(this.m_centerButton) {
      inkInputKeyData.SetInputKey(inputKey, EInputKey.IK_Pad_RightThumb);
      (this.m_centerButton.GetController() as inkInputDisplayController).SetInputKey(inputKey);
      this.m_centerButton.SetAnchor(inkEAnchor.Centered);
      this.m_centerButton.SetAnchorPoint(new Vector2(0.50, 0.50));
      this.m_centerButton.SetVisible(false);
    };
  }

  public final func Enable() -> Void {
    inkWidgetRef.Get(this.m_pointer).SetVisible(true);
  }

  public final func UpdateCenterPiece(rawInputAngle: Vector4) -> Void;

  public final func SetRotation(rawInputAngle: Vector4, angle: Float, activeIndex: Int32) -> Void {
    inkWidgetRef.Get(this.m_pointer).SetRotation(angle + 45.00);
    if activeIndex == this.currentIndex {
      return;
    };
    if this.currentIndex != -1 && IsDefined(inkWidgetRef.Get(this.m_connectors[this.currentIndex])) {
      inkWidgetRef.Get(this.m_connectors[this.currentIndex]).SetVisible(false);
    };
    if activeIndex != -1 && IsDefined(inkWidgetRef.Get(this.m_connectors[activeIndex])) {
      inkWidgetRef.Get(this.m_connectors[activeIndex]).SetVisible(true);
    };
    this.currentIndex = activeIndex;
  }
}

public class PointerSlot extends RadialSlot {

  public final const func GetController() -> ref<PointerController> {
    return this.GetWidget().GetController() as PointerController;
  }
}

public class StatusEffectSlot extends RadialSlot {

  public final const func GetController() -> ref<RadialStatusEffectController> {
    return this.GetWidget().GetController() as RadialStatusEffectController;
  }
}

public class WeaponRadialSlot extends RadialSlot {

  private edit let equipmentArea: gamedataEquipmentArea;

  private let index: Int32;

  public final const func GetController() -> ref<InventoryItemDisplayController> {
    return this.GetWidget().GetController() as InventoryItemDisplayController;
  }

  public final const func GetEquipmentArea() -> gamedataEquipmentArea {
    return this.equipmentArea;
  }

  public final const func GetIndex() -> Int32 {
    return this.index;
  }

  public final func SetIndex(i: Int32) -> Void {
    this.index = i;
  }

  public const func GetDebugInfo(out info: array<String>) -> Void {
    this.GetDebugInfo(info);
    ArrayPush(info, "Index: " + IntToString(this.index));
    ArrayPush(info, "Area: " + EnumValueToString("gamedataEquipmentArea", Cast(EnumInt(this.equipmentArea))));
    ArrayPush(info, "-" * 32);
  }
}

public class RadialSlot extends IScriptable {

  @attrib(tooltip, "Achnor at which provided library reference should be spawned into")
  public edit let slotAnchorRef: inkWidgetRef;

  @attrib(tooltip, "Specify library item that you want to be spawned in this slot")
  public edit let libraryRef: inkWidgetLibraryReference;

  public edit let slotType: SlotType;

  protected edit let animData: RadialAnimData;

  private let widget: wref<inkWidget>;

  private let targetAngle: Float;

  @default(RadialSlot, Hover)
  private let active: String;

  @default(RadialSlot, Default)
  private let inactive: String;

  @default(RadialSlot, Blocked)
  private let blocked: String;

  public final func Construct(w: wref<inkWidget>) -> Void {
    this.widget = w;
  }

  public final const func GetWidget() -> wref<inkWidget> {
    return this.widget;
  }

  public const func IsCyclable() -> Bool {
    return false;
  }

  public const func CanCycle() -> Bool {
    return false;
  }

  public final const func GetAngle() -> Float {
    return this.targetAngle;
  }

  public const func GetDebugInfo(out info: array<String>) -> Void {
    ArrayPush(info, EnumValueToString("SlotType", Cast(EnumInt(this.slotType))));
    ArrayPush(info, FloatToString(this.targetAngle));
    ArrayPush(info, "-" * 32);
  }

  public final func Activate() -> Void {
    inkWidgetRef.Get(this.slotAnchorRef).SetState(StringToName(this.active));
    this.Activate(true);
  }

  public final func Deactivate() -> Void {
    inkWidgetRef.Get(this.slotAnchorRef).SetState(StringToName(this.inactive));
    this.Activate(false);
  }

  public final func SetTargetAngle(precalculatedAngle: Float) -> Void {
    this.targetAngle = precalculatedAngle;
  }

  protected func Activate(shouldActivate: Bool) -> Void {
    let controller: ref<inkLogicController> = this.GetWidget().GetController();
    if !IsDefined(controller) {
      return;
    };
    if shouldActivate {
      controller.PlayLibraryAnimation(this.animData.hover_in);
      controller.PlaySound(n"Button", n"OnHover");
    } else {
      controller.PlayLibraryAnimation(this.animData.hover_out);
    };
  }
}

public class CyclableRadialSlot extends WeaponRadialSlot {

  public edit let leftArrowEmpty: inkWidgetRef;

  public edit let leftArrowFull: inkWidgetRef;

  public edit let rightArrowEmpty: inkWidgetRef;

  public edit let rightArrowFull: inkWidgetRef;

  private let canCycle: Bool;

  public let isCycling: Bool;

  private let wasCyclingRight: Bool;

  private edit let hotkey: EHotkey;

  public const func IsCyclable() -> Bool {
    return true;
  }

  public const func CanCycle() -> Bool {
    return this.canCycle;
  }

  public final const func GetHotkey() -> EHotkey {
    return this.hotkey;
  }

  public const func GetDebugInfo(out info: array<String>) -> Void {
    this.GetDebugInfo(info);
    ArrayPush(info, "HOTKEY: " + EnumValueToString("EHotkey", Cast(EnumInt(this.hotkey))));
    ArrayPush(info, "Can Cycle: " + BoolToString(this.canCycle));
  }

  public final func SetCanCycle(_canCycle: Bool) -> Void {
    this.canCycle = _canCycle;
    inkWidgetRef.Get(this.leftArrowEmpty).SetVisible(this.canCycle);
    inkWidgetRef.Get(this.rightArrowEmpty).SetVisible(this.canCycle);
    if !this.canCycle {
      this.CycleStop();
    };
  }

  public final func CycleStart(right: Bool) -> Void {
    this.isCycling = true;
    if right {
      inkWidgetRef.Get(this.rightArrowFull).SetVisible(true);
      this.wasCyclingRight = true;
    } else {
      inkWidgetRef.Get(this.leftArrowFull).SetVisible(true);
      this.wasCyclingRight = false;
    };
  }

  public final func CycleStop() -> Void {
    this.isCycling = false;
    if this.wasCyclingRight {
      inkWidgetRef.Get(this.rightArrowFull).SetVisible(false);
    } else {
      inkWidgetRef.Get(this.leftArrowFull).SetVisible(false);
    };
  }

  protected func Activate(shouldActivate: Bool) -> Void {
    let showArrows: Bool = shouldActivate && this.canCycle;
    inkWidgetRef.Get(this.leftArrowEmpty).SetVisible(showArrows);
    inkWidgetRef.Get(this.rightArrowEmpty).SetVisible(showArrows);
    if !shouldActivate {
      this.CycleStop();
    };
    this.Activate(shouldActivate);
  }
}
