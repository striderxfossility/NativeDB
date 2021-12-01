
public class CrafringMaterialItemController extends BaseButtonView {

  protected edit let m_nameText: inkTextRef;

  protected edit let m_quantityText: inkTextRef;

  protected edit let m_quantityChangeText: inkTextRef;

  protected edit let m_icon: inkImageRef;

  protected edit let m_frame: inkWidgetRef;

  protected edit let m_data: InventoryItemData;

  private let m_quantity: Int32;

  private let m_hovered: Bool;

  private let m_lastState: CrafringMaterialItemHighlight;

  private let m_shouldBeHighlighted: Bool;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    if IsDefined(this.m_ButtonController) {
      this.m_ButtonController.RegisterToCallback(n"OnButtonClick", this, n"OnButtonClick");
    };
    this.RegisterToCallback(n"OnHoverOver", this, n"OnCraftingMaterialHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnCraftingMaterialHoverOut");
  }

  protected cb func OnCraftingMaterialHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    this.m_hovered = true;
    this.SetHighlighted();
  }

  protected cb func OnCraftingMaterialHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.m_hovered = false;
    this.SetHighlighted();
  }

  public final func Setup(itemData: InventoryItemData) -> Void {
    this.m_data = itemData;
    this.RefreshUI();
    this.SetHighlighted(IntEnum(0l));
  }

  public final func RefreshUI() -> Void {
    inkTextRef.SetText(this.m_nameText, InventoryItemData.GetName(this.m_data));
    inkTextRef.SetText(this.m_quantityText, IntToString(InventoryItemData.GetQuantity(this.m_data)));
    this.m_quantity = InventoryItemData.GetQuantity(this.m_data);
    InkImageUtils.RequestSetImage(this, this.m_icon, "UIIcon." + InventoryItemData.GetIconPath(this.m_data));
    if InventoryItemData.GetQuantity(this.m_data) <= 0 {
      this.GetRootWidget().SetState(n"Empty");
    };
  }

  public final func SetHighlighted(type: CrafringMaterialItemHighlight, opt quantityChanged: Int32) -> Void {
    this.m_lastState = type;
    this.SetHighlighted(quantityChanged);
  }

  public final func SetHighlighted(opt quantityChanged: Int32) -> Void {
    inkWidgetRef.SetVisible(this.m_frame, NotEquals(this.m_lastState, IntEnum(0l)));
    this.m_shouldBeHighlighted = quantityChanged != 0;
    inkWidgetRef.SetVisible(this.m_quantityChangeText, this.m_shouldBeHighlighted);
    inkTextRef.SetText(this.m_quantityChangeText, "(+" + IntToString(quantityChanged) + ")");
    if quantityChanged == 0 {
      this.GetRootWidget().SetState(n"Default");
    } else {
      this.GetRootWidget().SetState(n"Hover");
    };
  }

  public final func GetItemID() -> ItemID {
    return InventoryItemData.GetID(this.m_data);
  }

  public final func GetQuantity() -> Int32 {
    return this.m_quantity;
  }

  public final func GetMateialDisplayName() -> String {
    return UIItemsHelper.GetItemName(this.m_data);
  }

  protected cb func OnCraftingMaterialAnimationCompleted(anim: ref<inkAnimProxy>) -> Bool {
    if this.m_shouldBeHighlighted {
      this.GetRootWidget().SetState(n"Default");
      this.GetRootWidget().SetState(n"Hover");
    } else {
      this.GetRootWidget().SetState(n"Hover");
      this.GetRootWidget().SetState(n"Default");
    };
  }

  public final func PlayAnimation() -> Void {
    let proxy: ref<inkAnimProxy> = this.PlayLibraryAnimationOnAutoSelectedTargets(n"craftingMaterial_animation", this.GetRootWidget());
    proxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnCraftingMaterialAnimationCompleted");
  }
}
