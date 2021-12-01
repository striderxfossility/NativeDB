
public abstract class BaseItemAction extends BaseScriptableAction {

  private let m_itemData: wref<gameItemData>;

  private let m_removeAfterUse: Bool;

  @default(BaseItemAction, 1)
  private let m_quantity: Int32;

  public final func ShouldRemoveAfterUse() -> Bool {
    return this.m_removeAfterUse;
  }

  public final func GetItemData() -> wref<gameItemData> {
    return this.m_itemData;
  }

  public final func SetRemoveAfterUse() -> Void {
    this.m_removeAfterUse = TweakDBInterface.GetBool(this.m_objectActionID + t".removeAfterUse", true);
  }

  public final func SetItemData(item: wref<gameItemData>) -> Void {
    this.m_itemData = item;
  }

  public final const func GetItemType() -> gamedataItemType {
    return this.m_itemData.GetItemType();
  }

  public final func SetRequestQuantity(quantity: Int32) -> Void {
    this.m_quantity = quantity;
  }

  public final func GetRequestQuantity() -> Int32 {
    return this.m_quantity;
  }
}
