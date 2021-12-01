
public class CraftingItemTemplateClassifier extends inkVirtualItemTemplateClassifier {

  public func ClassifyItem(data: Variant) -> Uint32 {
    if CraftingItemTemplateClassifier.IsSmall(data) {
      return 0u;
    };
    return 1u;
  }

  public final static func IsSmall(data: Variant) -> Bool {
    let inventoryItem: ref<ItemCraftingData>;
    let recipe: ref<RecipeData> = FromVariant(data) as RecipeData;
    if IsDefined(recipe) {
      return NotEquals(recipe.id.EquipArea().Type(), gamedataEquipmentArea.Weapon);
    };
    inventoryItem = FromVariant(data) as ItemCraftingData;
    if IsDefined(inventoryItem) {
      if Equals(InventoryItemData.GetEquipmentArea(inventoryItem.inventoryItem), gamedataEquipmentArea.Weapon) {
        return false;
      };
      return true;
    };
    return false;
  }

  public final static func GetIconPosition(data: Variant) -> ECraftingIconPositioning {
    let inventoryItem: ref<ItemCraftingData>;
    let recipe: ref<RecipeData> = FromVariant(data) as RecipeData;
    if IsDefined(recipe) {
      if Equals(recipe.id.EquipArea().Type(), gamedataEquipmentArea.Weapon) {
        return ECraftingIconPositioning.weaponBig;
      };
    };
    inventoryItem = FromVariant(data) as ItemCraftingData;
    if IsDefined(inventoryItem) {
      if Equals(InventoryItemData.GetEquipmentArea(inventoryItem.inventoryItem), gamedataEquipmentArea.Weapon) {
        if Equals(InventoryItemData.GetShape(inventoryItem.inventoryItem), EInventoryItemShape.DoubleSlot) {
          return ECraftingIconPositioning.weaponBig;
        };
        return ECraftingIconPositioning.weaponSmall;
      };
    };
    return ECraftingIconPositioning.generic;
  }
}

public class CraftingDataView extends ScriptableDataView {

  private let m_itemFilterType: ItemFilterCategory;

  private let m_itemSortMode: ItemSortMode;

  private let m_attachmentsList: array<gamedataItemType>;

  private let m_uiScriptableSystem: wref<UIScriptableSystem>;

  public final func BindUIScriptableSystem(uiScriptableSystem: wref<UIScriptableSystem>) -> Void {
    this.m_uiScriptableSystem = uiScriptableSystem;
  }

  public final func SetFilterType(type: ItemFilterCategory) -> Void {
    this.m_itemFilterType = type;
    this.Filter();
  }

  public final func GetFilterType() -> ItemFilterCategory {
    return this.m_itemFilterType;
  }

  public final func SetSortMode(mode: ItemSortMode) -> Void {
    this.m_itemSortMode = mode;
    this.Sort();
  }

  public final func GetSortMode() -> ItemSortMode {
    return this.m_itemSortMode;
  }

  protected func PreSortingInjection(builder: ref<ItemCompareBuilder>) -> ref<ItemCompareBuilder> {
    return builder;
  }

  public func SortItem(left: ref<IScriptable>, right: ref<IScriptable>) -> Bool {
    let leftItem: InventoryItemSortData;
    let rightItem: InventoryItemSortData;
    let itemDataLeft: ref<ItemCraftingData> = left as ItemCraftingData;
    let itemDataRight: ref<ItemCraftingData> = right as ItemCraftingData;
    let recipeDataLeft: ref<RecipeData> = left as RecipeData;
    let recipeDataRight: ref<RecipeData> = right as RecipeData;
    if IsDefined(itemDataLeft) && IsDefined(itemDataRight) {
      leftItem = InventoryItemData.GetSortData(itemDataLeft.inventoryItem);
      rightItem = InventoryItemData.GetSortData(itemDataRight.inventoryItem);
    } else {
      if IsDefined(recipeDataLeft) && IsDefined(recipeDataRight) {
        leftItem = InventoryItemData.GetSortData(recipeDataLeft.inventoryItem);
        rightItem = InventoryItemData.GetSortData(recipeDataRight.inventoryItem);
      };
    };
    switch this.m_itemSortMode {
      case ItemSortMode.NewItems:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).NewItem(this.m_uiScriptableSystem).QualityDesc().ItemType().NameAsc().GetBool();
      case ItemSortMode.NameAsc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).NameAsc().QualityDesc().GetBool();
      case ItemSortMode.NameDesc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).NameDesc().QualityDesc().GetBool();
      case ItemSortMode.QualityAsc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).QualityDesc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.QualityDesc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).QualityAsc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.WeightAsc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).WeightAsc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.WeightDesc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).WeightDesc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.PriceAsc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).PriceAsc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.PriceDesc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).PriceDesc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.ItemType:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).ItemType().NameAsc().QualityDesc().GetBool();
    };
    return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).QualityDesc().ItemType().NameAsc().GetBool();
  }

  public func FilterItem(item: ref<IScriptable>) -> Bool {
    let itemRecord: ref<Item_Record>;
    let itemData: ref<ItemCraftingData> = item as ItemCraftingData;
    let recipeData: ref<RecipeData> = item as RecipeData;
    if IsDefined(itemData) {
      itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(itemData.inventoryItem)));
    } else {
      if IsDefined(recipeData) {
        itemRecord = recipeData.id;
      };
    };
    switch this.m_itemFilterType {
      case ItemFilterCategory.RangedWeapons:
        return itemRecord.TagsContains(WeaponObject.GetRangedWeaponTag());
      case ItemFilterCategory.MeleeWeapons:
        return itemRecord.TagsContains(WeaponObject.GetMeleeWeaponTag());
      case ItemFilterCategory.Clothes:
        return itemRecord.TagsContains(n"Clothing");
      case ItemFilterCategory.Consumables:
        return itemRecord.TagsContains(n"Consumable") || itemRecord.TagsContains(n"Ammo");
      case ItemFilterCategory.Grenades:
        return itemRecord.TagsContains(n"Grenade");
      case ItemFilterCategory.Attachments:
        return itemRecord.TagsContains(n"itemPart") && !itemRecord.TagsContains(n"Fragment") && !itemRecord.TagsContains(n"SoftwareShard");
      case ItemFilterCategory.Programs:
        return itemRecord.TagsContains(n"SoftwareShard");
      case ItemFilterCategory.Cyberware:
        return itemRecord.TagsContains(n"Cyberware") || itemRecord.TagsContains(n"Fragment");
      case ItemFilterCategory.AllItems:
        return true;
    };
    return true;
  }
}
