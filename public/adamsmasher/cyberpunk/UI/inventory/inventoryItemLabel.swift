
public class ItemLabelContainerController extends inkLogicController {

  protected let m_items: array<wref<ItemLabelController>>;

  public final func Add(type: ItemLabelType, opt params: String) -> Void {
    let item: wref<ItemLabelController>;
    let widget: wref<inkWidget>;
    let root: wref<inkCompoundWidget> = this.GetRootCompoundWidget();
    let i: Int32 = 0;
    while i < ArraySize(this.m_items) {
      if Equals(this.m_items[i].GetType(), type) {
        return;
      };
      i += 1;
    };
    widget = this.SpawnFromLocal(root, n"itemLabel");
    item = widget.GetController() as ItemLabelController;
    widget.SetVAlign(inkEVerticalAlign.Top);
    widget.SetHAlign(inkEHorizontalAlign.Left);
    item.Setup(type, params);
    ArrayPush(this.m_items, item);
    this.Reorder();
  }

  public final func Remove(type: ItemLabelType) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_items) {
      if Equals(this.m_items[i].GetType(), type) {
        this.GetRootCompoundWidget().RemoveChild(this.m_items[i].GetRootWidget());
        return;
      };
      i += 1;
    };
  }

  public final func Has(type: ItemLabelType) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_items) {
      if Equals(this.m_items[i].GetType(), type) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func Clear() -> Void {
    ArrayClear(this.m_items);
    this.GetRootCompoundWidget().RemoveAllChildren();
  }

  protected final func Reorder() -> Void {
    let i: Int32;
    let sorted: Bool;
    let temp: wref<ItemLabelController>;
    let root: wref<inkCompoundWidget> = this.GetRootCompoundWidget();
    let size: Int32 = ArraySize(this.m_items);
    while !sorted {
      sorted = true;
      i = 0;
      while i < size - 1 {
        if EnumInt(this.m_items[i].GetType()) > EnumInt(this.m_items[(i + 1) % size].GetType()) {
          temp = this.m_items[i];
          this.m_items[i] = this.m_items[(i + 1) % size];
          this.m_items[(i + 1) % size] = temp;
          sorted = false;
        };
        i += 1;
      };
    };
    i = 0;
    while i < size {
      root.ReorderChild(this.m_items[i].GetRootWidget(), i);
      i += 1;
    };
  }
}

public class ItemLabelController extends inkLogicController {

  protected edit let m_label: inkTextRef;

  protected edit let m_moneyIcon: inkImageRef;

  protected let m_type: ItemLabelType;

  public final func Setup(type: ItemLabelType, opt params: String) -> Void {
    let labelKey: String;
    let labelText: String;
    inkWidgetRef.SetVisible(this.m_label, NotEquals(type, ItemLabelType.Money));
    inkWidgetRef.SetVisible(this.m_moneyIcon, Equals(type, ItemLabelType.Money));
    labelKey = ItemLabelController.GetLabelKey(type);
    this.m_type = type;
    labelText = GetLocalizedText(labelKey);
    if !IsStringValid(labelText) {
      labelText = labelKey;
    };
    this.GetRootWidget().SetState(ItemLabelController.GetState(type));
    inkTextRef.SetText(this.m_label, labelText + params);
  }

  public final func GetType() -> ItemLabelType {
    return this.m_type;
  }

  protected final static func GetLabelKey(type: ItemLabelType) -> String {
    switch type {
      case ItemLabelType.New:
        return "UI-ItemLabel-New";
      case ItemLabelType.Quest:
        return "UI-ItemLabel-Quest";
      case ItemLabelType.Money:
        return "UI-ItemLabel-Money";
      case ItemLabelType.Equipped:
        return "UI-ItemLabel-Equipped";
      case ItemLabelType.Owned:
        return "UI-ItemLabel-Owned";
      case ItemLabelType.Buyback:
        return "UI-ItemLabel-Buyback";
    };
    return "None";
  }

  protected final static func GetState(type: ItemLabelType) -> CName {
    switch type {
      case ItemLabelType.New:
        return n"New";
      case ItemLabelType.Quest:
        return n"Quest";
      case ItemLabelType.Money:
        return n"Money";
      case ItemLabelType.Equipped:
        return n"Equipped";
      case ItemLabelType.Owned:
        return n"Owned";
      case ItemLabelType.Buyback:
        return n"Buyback";
    };
    return n"";
  }
}
