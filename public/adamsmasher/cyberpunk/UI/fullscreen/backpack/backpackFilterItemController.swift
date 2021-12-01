
public class BackpackFilterButtonController extends inkLogicController {

  protected edit let m_icon: inkImageRef;

  protected edit let m_text: inkTextRef;

  private let m_filterType: ItemFilterCategory;

  private let m_active: Bool;

  private let m_hovered: Bool;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
  }

  protected cb func OnHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    this.m_hovered = true;
    if !this.m_active {
      this.GetRootWidget().SetState(n"Hover");
    };
  }

  protected cb func OnHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.m_hovered = false;
    if !this.m_active {
      this.GetRootWidget().SetState(n"Default");
    };
  }

  public final func Setup(filterType: ItemFilterCategory) -> Void {
    this.m_filterType = filterType;
    InkImageUtils.RequestSetImage(this, this.m_icon, BackpackFilterButtonController.GetIcon(this.m_filterType));
  }

  public final func GetFilterType() -> ItemFilterCategory {
    return this.m_filterType;
  }

  public final func SetActive(value: Bool) -> Void {
    this.m_active = value;
    this.GetRootWidget().SetState(value ? n"Active" : n"Default");
    if !value && this.m_hovered {
      this.GetRootWidget().SetState(n"Hover");
    };
  }

  public final func GetLabelKey() -> CName {
    return BackpackFilterButtonController.GetLabelKey(this.m_filterType);
  }

  public final static func GetLabelKey(filterType: ItemFilterCategory) -> CName {
    return ItemFilterCategories.GetLabelKey(filterType);
  }

  private final static func GetIcon(filterType: ItemFilterCategory) -> String {
    return ItemFilterCategories.GetIcon(filterType);
  }
}

public abstract final class ItemFilterCategories extends IScriptable {

  public final static func GetLabelKey(filterType: Int32) -> CName {
    return ItemFilterCategories.GetLabelKey(IntEnum(filterType));
  }

  public final static func GetLabelKey(filterType: ItemFilterCategory) -> CName {
    switch filterType {
      case ItemFilterCategory.RangedWeapons:
        return n"UI-Filters-RangedWeapons";
      case ItemFilterCategory.MeleeWeapons:
        return n"UI-Filters-MeleeWeapons";
      case ItemFilterCategory.Clothes:
        return n"UI-Filters-Clothes";
      case ItemFilterCategory.Consumables:
        return n"UI-Filters-Consumables";
      case ItemFilterCategory.Grenades:
        return n"UI-Filters-Grenades";
      case ItemFilterCategory.SoftwareMods:
        return n"UI-Filters-Mods";
      case ItemFilterCategory.Attachments:
        return n"UI-Filters-Attachments";
      case ItemFilterCategory.Programs:
        return n"UI-Filters-Hacks";
      case ItemFilterCategory.Cyberware:
        return n"Lockey#45229";
      case ItemFilterCategory.Junk:
        return n"UI-Filters-Junk";
      case ItemFilterCategory.Quest:
        return n"UI-Filters-QuestItems";
      case ItemFilterCategory.Buyback:
        return n"UI-Filters-Buyback";
      case ItemFilterCategory.AllItems:
        return n"UI-Filters-AllItems";
    };
    return n"UI-Filters-AllItems";
  }

  public final static func GetIcon(filterType: Int32) -> String {
    return ItemFilterCategories.GetIcon(IntEnum(filterType));
  }

  public final static func GetIcon(filterType: ItemFilterCategory) -> String {
    switch filterType {
      case ItemFilterCategory.RangedWeapons:
        return "UIIcon.Filter_RangedWeapons";
      case ItemFilterCategory.MeleeWeapons:
        return "UIIcon.Filter_MeleeWeapons";
      case ItemFilterCategory.Clothes:
        return "UIIcon.Filter_Clothes";
      case ItemFilterCategory.Consumables:
        return "UIIcon.Filter_Consumables";
      case ItemFilterCategory.Grenades:
        return "UIIcon.Filter_Grenades";
      case ItemFilterCategory.SoftwareMods:
        return "UIIcon.Filter_SoftwareMod";
      case ItemFilterCategory.Attachments:
        return "UIIcon.Filter_Attachments";
      case ItemFilterCategory.Programs:
        return "UIIcon.Filter_Hacks";
      case ItemFilterCategory.Cyberware:
        return "UIIcon.Filter_Cyberware";
      case ItemFilterCategory.Junk:
        return "UIIcon.Filter_Junk";
      case ItemFilterCategory.Quest:
        return "UIIcon.Filter_QuestItems";
      case ItemFilterCategory.Buyback:
        return "UIIcon.Filter_Buyback";
      case ItemFilterCategory.AllItems:
        return "UIIcon.Filter_AllItems";
    };
    return "UIIcon.Filter_AllItems";
  }
}

public abstract final class ItemFilters extends IScriptable {

  public final static func GetLabelKey(filterType: Int32) -> CName {
    return ItemFilters.GetLabelKey(IntEnum(filterType));
  }

  public final static func GetLabelKey(filterType: ItemFilterType) -> CName {
    switch filterType {
      case ItemFilterType.All:
        return n"UI-Filters-AllItems";
      case ItemFilterType.Weapons:
        return n"UI-Filters-Weapons";
      case ItemFilterType.Clothes:
        return n"UI-Filters-Clothes";
      case ItemFilterType.Consumables:
        return n"UI-Filters-Consumables";
      case ItemFilterType.Cyberware:
        return n"UI-Filters-Cyberware";
      case ItemFilterType.Attachments:
        return n"UI-Filters-Attachments";
      case ItemFilterType.Quest:
        return n"UI-Filters-QuestItems";
      case ItemFilterType.Buyback:
        return n"UI-Filters-Buyback";
      case ItemFilterType.LightWeapons:
        return n"UI-Filters-LightWeapons";
      case ItemFilterType.HeavyWeapons:
        return n"UI-Filters-HeavyWeapons";
      case ItemFilterType.MeleeWeapons:
        return n"UI-Filters-MeleeWeapons";
      case ItemFilterType.Hacks:
        return n"UI-Filters-Hacks";
    };
    return n"UI-Filters-AllItems";
  }

  public final static func GetIcon(filterType: Int32) -> String {
    return ItemFilters.GetIcon(IntEnum(filterType));
  }

  public final static func GetIcon(filterType: ItemFilterType) -> String {
    switch filterType {
      case ItemFilterType.All:
        return "UIIcon.Filter_AllItems";
      case ItemFilterType.Weapons:
        return "UIIcon.Filter_Weapons";
      case ItemFilterType.Clothes:
        return "UIIcon.Filter_Clothes";
      case ItemFilterType.Consumables:
        return "UIIcon.Filter_Consumables";
      case ItemFilterType.Cyberware:
        return "UIIcon.Filter_Cyberware";
      case ItemFilterType.Attachments:
        return "UIIcon.Filter_Attachments";
      case ItemFilterType.Quest:
        return "UIIcon.Filter_QuestItems";
      case ItemFilterType.Buyback:
        return "UIIcon.Filter_Buyback";
      case ItemFilterType.LightWeapons:
        return "UIIcon.Filter_LightWeapons";
      case ItemFilterType.HeavyWeapons:
        return "UIIcon.Filter_HeavyWeapons";
      case ItemFilterType.MeleeWeapons:
        return "UIIcon.Filter_MeleeWeapons";
      case ItemFilterType.Hacks:
        return "UIIcon.Filter_Hacks";
    };
    return "UIIcon.Filter_AllItems";
  }
}

public class ItemCategoryFliterManager extends IScriptable {

  private let m_filtersToCheck: array<ItemFilterCategory>;

  private let m_filters: array<ItemFilterCategory>;

  private let m_sharedFiltersToCheck: array<ItemFilterCategory>;

  private let m_isOrderDirty: Bool;

  public final static func Make(opt skipDefaultFilters: Bool) -> ref<ItemCategoryFliterManager> {
    let i: Int32;
    let instance: ref<ItemCategoryFliterManager> = new ItemCategoryFliterManager();
    ArrayClear(instance.m_filters);
    ArrayClear(instance.m_filtersToCheck);
    ArrayClear(instance.m_sharedFiltersToCheck);
    if !skipDefaultFilters {
      i = 0;
      while i < EnumInt(ItemFilterCategory.BaseCount) {
        ArrayPush(instance.m_filtersToCheck, IntEnum(i));
        i += 1;
      };
    };
    return instance;
  }

  public final func AddItem(itemData: wref<gameItemData>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_sharedFiltersToCheck) {
      if ItemCategoryFliter.IsOfCategoryType(this.m_sharedFiltersToCheck[i], itemData) {
        ArrayPush(this.m_filters, this.m_sharedFiltersToCheck[i]);
        ArrayRemove(this.m_sharedFiltersToCheck, this.m_sharedFiltersToCheck[i]);
        this.m_isOrderDirty = true;
      };
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_filtersToCheck) {
      if ItemCategoryFliter.IsOfCategoryType(this.m_filtersToCheck[i], itemData) {
        ArrayPush(this.m_filters, this.m_filtersToCheck[i]);
        ArrayRemove(this.m_filtersToCheck, this.m_filtersToCheck[i]);
        this.m_isOrderDirty = true;
        return;
      };
      i += 1;
    };
  }

  public final func GetAt(index: Int32) -> ItemFilterCategory {
    if index >= 0 && index < ArraySize(this.m_filters) {
      return this.m_filters[index];
    };
    return ItemFilterCategory.Invalid;
  }

  public final func GetFiltersList() -> array<ItemFilterCategory> {
    let fallbackResult: array<ItemFilterCategory>;
    if ArraySize(this.m_filters) == 0 {
      ArrayPush(fallbackResult, ItemFilterCategory.AllItems);
      return fallbackResult;
    };
    return this.m_filters;
  }

  public final func SortFiltersList() -> Void {
    let i: Int32;
    let result: array<ItemFilterCategory>;
    if this.m_isOrderDirty {
      i = 0;
      while i < EnumInt(ItemFilterCategory.AllCount) {
        if ArrayContains(this.m_filters, IntEnum(i)) {
          ArrayPush(result, IntEnum(i));
        };
        i += 1;
      };
      this.m_filters = result;
      this.m_isOrderDirty = false;
    };
  }

  public final func GetSortedFiltersList() -> array<ItemFilterCategory> {
    this.SortFiltersList();
    return this.GetFiltersList();
  }

  public final func GetIntFiltersList() -> array<Int32> {
    let result: array<Int32>;
    let filters: array<ItemFilterCategory> = this.GetFiltersList();
    let i: Int32 = 0;
    while i < ArraySize(filters) {
      ArrayPush(result, EnumInt(filters[i]));
      i += 1;
    };
    return result;
  }

  public final func GetSortedIntFiltersList() -> array<Int32> {
    this.SortFiltersList();
    return this.GetIntFiltersList();
  }

  public final func InsertFilter(position: Int32, filter: ItemFilterCategory) -> Void {
    ArrayRemove(this.m_filters, filter);
    ArrayInsert(this.m_filters, position, filter);
  }

  public final func Clear(opt skipDefaultFilters: Bool) -> Void {
    let i: Int32;
    ArrayClear(this.m_filters);
    ArrayClear(this.m_sharedFiltersToCheck);
    ArrayClear(this.m_filtersToCheck);
    if !skipDefaultFilters {
      i = 0;
      while i < EnumInt(ItemFilterCategory.BaseCount) {
        ArrayPush(this.m_filtersToCheck, IntEnum(i));
        i += 1;
      };
    };
  }

  public final func AddFilter(filter: ItemFilterCategory) -> Void {
    if !ArrayContains(this.m_filters, filter) {
      ArrayPush(this.m_filters, filter);
      this.m_isOrderDirty = true;
    };
  }

  private final func IsSharedFilter(filter: ItemFilterCategory) -> Bool {
    return Equals(filter, ItemFilterCategory.Quest);
  }

  public final func AddFilterToCheck(filter: ItemFilterCategory) -> Void {
    if this.IsSharedFilter(filter) {
      ArrayPush(this.m_sharedFiltersToCheck, filter);
      return;
    };
    ArrayPush(this.m_filtersToCheck, filter);
  }

  public final func RemvoeFilterToCheck(filter: ItemFilterCategory) -> Void {
    if this.IsSharedFilter(filter) {
      ArrayRemove(this.m_sharedFiltersToCheck, filter);
      return;
    };
    ArrayRemove(this.m_filtersToCheck, filter);
  }
}

public abstract class ItemCategoryFliter extends IScriptable {

  public final static func FilterItem(filter: ItemFilterCategory, wrappedData: ref<WrappedInventoryItemData>) -> Bool {
    if Equals(filter, ItemFilterCategory.Invalid) {
      return true;
    };
    return ItemCategoryFliter.IsOfCategoryType(filter, InventoryItemData.GetGameItemData(wrappedData.ItemData));
  }

  public final static func IsOfCategoryType(filter: ItemFilterCategory, data: wref<gameItemData>) -> Bool {
    if !IsDefined(data) {
      return false;
    };
    switch filter {
      case ItemFilterCategory.RangedWeapons:
        return data.HasTag(WeaponObject.GetRangedWeaponTag());
      case ItemFilterCategory.MeleeWeapons:
        return data.HasTag(WeaponObject.GetMeleeWeaponTag());
      case ItemFilterCategory.Clothes:
        return data.HasTag(n"Clothing");
      case ItemFilterCategory.Consumables:
        return data.HasTag(n"Consumable");
      case ItemFilterCategory.Grenades:
        return data.HasTag(n"Grenade");
      case ItemFilterCategory.Attachments:
        return data.HasTag(n"itemPart") && !data.HasTag(n"Fragment") && !data.HasTag(n"SoftwareShard");
      case ItemFilterCategory.Programs:
        return data.HasTag(n"SoftwareShard");
      case ItemFilterCategory.Cyberware:
        return data.HasTag(n"Cyberware") || data.HasTag(n"Fragment");
      case ItemFilterCategory.Quest:
        return data.HasTag(n"Quest");
      case ItemFilterCategory.Junk:
        return data.HasTag(n"Junk");
      case ItemFilterCategory.AllItems:
        return true;
    };
    return false;
  }

  public final static func GetItemCategoryType(data: wref<gameItemData>) -> ItemFilterCategory {
    let i: Int32 = 0;
    while i < EnumInt(ItemFilterCategory.BaseCount) {
      if ItemCategoryFliter.IsOfCategoryType(IntEnum(i), data) {
        return IntEnum(i);
      };
      i += 1;
    };
    return ItemFilterCategory.Invalid;
  }
}
