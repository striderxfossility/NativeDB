
public class InvisibleSceneStashController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class InvisibleSceneStashControllerPS extends ScriptableDeviceComponentPS {

  protected persistent let m_storedItems: array<ItemID>;

  public final func StoreItems(items: array<ItemID>) -> Void {
    let i: Int32;
    if ArraySize(this.m_storedItems) > 0 {
      i = 0;
      while i < ArraySize(items) {
        ArrayPush(this.m_storedItems, items[i]);
        i += 1;
      };
    } else {
      this.m_storedItems = items;
    };
  }

  public final const func GetItems() -> array<ItemID> {
    return this.m_storedItems;
  }

  public final func ClearStoredItems() -> Void {
    ArrayClear(this.m_storedItems);
  }
}
