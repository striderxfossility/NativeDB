
public abstract final class SortingDropdownData extends IScriptable {

  public final static func GetDropdownOption(options: array<ref<DropdownItemData>>, identifier: ItemSortMode) -> ref<DropdownItemData> {
    let i: Int32 = 0;
    while i < ArraySize(options) {
      if Equals(FromVariant(options[i].identifier), identifier) {
        return options[i];
      };
      i += 1;
    };
    return null;
  }

  private final static func GetDropdownItemData(identifier: Variant, labelKey: CName, direction: DropdownItemDirection) -> ref<DropdownItemData> {
    let itemData: ref<DropdownItemData> = new DropdownItemData();
    itemData.identifier = identifier;
    itemData.labelKey = labelKey;
    itemData.direction = direction;
    return itemData;
  }

  public final static func GetDefaultDropdownOptions() -> array<ref<DropdownItemData>> {
    let result: array<ref<DropdownItemData>>;
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.Default), n"UI-Sorting-Default", IntEnum(0l)));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.NewItems), n"UI-Sorting-NewItems", IntEnum(0l)));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.NameAsc), n"UI-Sorting-Name", DropdownItemDirection.Down));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.NameDesc), n"UI-Sorting-Name", DropdownItemDirection.Up));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.DpsDesc), n"UI-Sorting-DPS", DropdownItemDirection.Down));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.DpsAsc), n"UI-Sorting-DPS", DropdownItemDirection.Up));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.QualityAsc), n"UI-Sorting-Quality", DropdownItemDirection.Down));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.QualityDesc), n"UI-Sorting-Quality", DropdownItemDirection.Up));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.WeightDesc), n"UI-Sorting-Weight", DropdownItemDirection.Down));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.WeightAsc), n"UI-Sorting-Weight", DropdownItemDirection.Up));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.PriceDesc), n"UI-Sorting-Price", DropdownItemDirection.Down));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.PriceAsc), n"UI-Sorting-Price", DropdownItemDirection.Up));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.ItemType), n"UI-Sorting-ItemType", IntEnum(0l)));
    return result;
  }

  public final static func GetItemChooserWeaponDropdownOptions() -> array<ref<DropdownItemData>> {
    let result: array<ref<DropdownItemData>>;
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.Default), n"UI-Sorting-Default", IntEnum(0l)));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.NewItems), n"UI-Sorting-NewItems", IntEnum(0l)));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.NameAsc), n"UI-Sorting-Name", DropdownItemDirection.Down));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.NameDesc), n"UI-Sorting-Name", DropdownItemDirection.Up));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.DpsDesc), n"UI-Sorting-DPS", DropdownItemDirection.Down));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.DpsAsc), n"UI-Sorting-DPS", DropdownItemDirection.Up));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.QualityAsc), n"UI-Sorting-Quality", DropdownItemDirection.Down));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.QualityDesc), n"UI-Sorting-Quality", DropdownItemDirection.Up));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.WeightDesc), n"UI-Sorting-Weight", DropdownItemDirection.Down));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.WeightAsc), n"UI-Sorting-Weight", DropdownItemDirection.Up));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.PriceDesc), n"UI-Sorting-Price", DropdownItemDirection.Down));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.PriceAsc), n"UI-Sorting-Price", DropdownItemDirection.Up));
    ArrayPush(result, SortingDropdownData.GetDropdownItemData(ToVariant(ItemSortMode.ItemType), n"UI-Sorting-ItemType", IntEnum(0l)));
    return result;
  }

  public final static func GetContextDropdownOptions(context: DropdownDisplayContext) -> array<ref<DropdownItemData>> {
    switch context {
      case DropdownDisplayContext.Default:
        return SortingDropdownData.GetDefaultDropdownOptions();
      case DropdownDisplayContext.ItemChooserWeapon:
        return SortingDropdownData.GetItemChooserWeaponDropdownOptions();
    };
    return SortingDropdownData.GetDefaultDropdownOptions();
  }
}
