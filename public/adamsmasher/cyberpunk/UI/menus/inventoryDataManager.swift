
public class InventoryDataManager extends IScriptable {

  private let m_gameInstance: GameInstance;

  private let m_player: wref<PlayerPuppet>;

  private let m_transactionSystem: wref<TransactionSystem>;

  private let m_equipmentSystem: wref<EquipmentSystem>;

  private let m_statsSystem: wref<StatsSystem>;

  private let m_locMgr: ref<UILocalizationMap>;

  public final func Initialize(player: ref<PlayerPuppet>) -> Void {
    this.m_player = player;
    this.m_gameInstance = this.m_player.GetGame();
    this.m_transactionSystem = GameInstance.GetTransactionSystem(this.m_gameInstance);
    this.m_statsSystem = GameInstance.GetStatsSystem(this.m_gameInstance);
    this.m_equipmentSystem = GameInstance.GetScriptableSystemsContainer(this.m_gameInstance).Get(n"EquipmentSystem") as EquipmentSystem;
    this.m_locMgr = new UILocalizationMap();
    this.m_locMgr.Init();
  }

  public final func GetPlayer() -> wref<PlayerPuppet> {
    return this.m_player;
  }

  public final func GetLastLootedItems(count: Int32, out itemsList: array<wref<gameItemData>>) -> Void {
    let maxIdx: Int32;
    let sourceList: array<wref<gameItemData>>;
    let tagsList: array<CName>;
    ArrayPush(tagsList, n"Weapon");
    ArrayPush(tagsList, n"Quest");
    this.m_transactionSystem.GetItemListByTags(this.m_player, tagsList, sourceList);
    maxIdx = Min(ArraySize(sourceList), count);
    while ArraySize(itemsList) < maxIdx {
      ArrayPush(itemsList, ArrayPop(sourceList));
    };
  }

  public final func GetItemsList(out itemsList: array<wref<gameItemData>>) -> Void {
    this.m_transactionSystem.GetItemList(this.m_player, itemsList);
  }

  public final func GetItemsListByTag(tag: CName, out itemsList: array<wref<gameItemData>>) -> Void {
    this.m_transactionSystem.GetItemListByTag(this.m_player, tag, itemsList);
  }

  public final func GetEquippedItemIdInArea(equipArea: gamedataEquipmentArea, opt slot: Int32) -> ItemID {
    return this.m_equipmentSystem.GetItemInEquipSlot(this.m_player, equipArea, slot);
  }

  public final const func GetItemEquipArea(itemId: ItemID) -> gamedataEquipmentArea {
    return EquipmentSystem.GetEquipAreaType(itemId);
  }

  public final func GetExternalItemData(ownerId: EntityID, externalItemId: ItemID) -> wref<gameItemData> {
    let itemData: wref<gameItemData>;
    if ItemID.IsValid(externalItemId) {
      itemData = this.m_transactionSystem.GetItemDataByOwnerEntityId(ownerId, externalItemId);
    };
    return itemData;
  }

  public final func GetPlayerItemData(externalItemId: ItemID) -> wref<gameItemData> {
    let itemData: wref<gameItemData>;
    if ItemID.IsValid(externalItemId) {
      itemData = this.m_transactionSystem.GetItemData(this.m_player, externalItemId);
    };
    return itemData;
  }

  public final func GetExternalItemStats(ownerId: EntityID, externalItemId: ItemID, opt compareItemId: ItemID) -> ItemViewData {
    let compareItemData: wref<gameItemData>;
    let itemData: wref<gameItemData>;
    if ItemID.IsValid(compareItemId) {
      compareItemData = this.m_transactionSystem.GetItemData(this.m_player, compareItemId);
    };
    itemData = this.m_transactionSystem.GetItemDataByOwnerEntityId(ownerId, externalItemId);
    return this.GetItemStatsByData(itemData, compareItemData);
  }

  public final func GetPlayerItemStats(itemId: ItemID, opt compareItemId: ItemID) -> ItemViewData {
    let compareItemData: wref<gameItemData>;
    let itemData: wref<gameItemData>;
    if ItemID.IsValid(compareItemId) {
      compareItemData = this.m_transactionSystem.GetItemData(this.m_player, compareItemId);
    };
    itemData = this.m_transactionSystem.GetItemData(this.m_player, itemId);
    return this.GetItemStatsByData(itemData, compareItemData);
  }

  private final func QualityEnumToName(qualityStatValue: gamedataQuality) -> String {
    switch qualityStatValue {
      case gamedataQuality.Common:
        return "Common";
      case gamedataQuality.Uncommon:
        return "Uncommon";
      case gamedataQuality.Rare:
        return "Rare";
      case gamedataQuality.Epic:
        return "Epic";
      case gamedataQuality.Legendary:
        return "Legendary";
      default:
        return "Common";
    };
  }

  public final const func CanCompareItems(itemId: ItemID, compareItemId: ItemID) -> Bool {
    let compareItemRecord: ref<Item_Record>;
    let compareItemType: wref<ItemType_Record>;
    let stats: ref<UIStatsMap_Record>;
    let statsMapName: String;
    let typesToCompare: array<wref<ItemType_Record>>;
    if !ItemID.IsValid(itemId) || !ItemID.IsValid(compareItemId) {
      return false;
    };
    compareItemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(compareItemId));
    compareItemType = compareItemRecord.ItemType();
    statsMapName = this.GetStatsUIMapName(itemId);
    if !IsStringValid(statsMapName) {
      return false;
    };
    stats = TweakDBInterface.GetUIStatsMapRecord(TDBID.Create(statsMapName));
    stats.TypesToCompareWith(typesToCompare);
    return ArrayContains(typesToCompare, compareItemType);
  }

  public final func GetItemStatsByData(itemData: wref<gameItemData>, opt compareWithData: wref<gameItemData>) -> ItemViewData {
    let quality: gamedataQuality;
    let statsMapName: String;
    let viewData: ItemViewData;
    let itemId: ItemID = itemData.GetID();
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemId));
    let itemCategoryRecord: wref<ItemCategory_Record> = itemRecord.ItemCategory();
    viewData.id = itemId;
    viewData.itemName = LocKeyToString(itemRecord.DisplayName());
    viewData.categoryName = this.m_locMgr.Localize(itemCategoryRecord.Name());
    viewData.description = LocKeyToString(itemRecord.LocalizedDescription());
    if itemData.HasStatData(gamedataStatType.Quality) {
      quality = RPGManager.GetItemDataQuality(itemData);
      viewData.quality = this.QualityEnumToName(quality);
    } else {
      viewData.quality = itemRecord.Quality().Name();
    };
    statsMapName = this.GetStatsUIMapName(itemId);
    if IsStringValid(statsMapName) {
      this.GetStatsList(TDBID.Create(statsMapName), itemData, viewData.primaryStats, viewData.secondaryStats, compareWithData);
    };
    return viewData;
  }

  private final const func GetStatsUIMapName(itemData: wref<gameItemData>) -> String {
    let statsMapName: String;
    if IsDefined(itemData) {
      statsMapName = this.GetStatsUIMapName(itemData.GetID());
    };
    return statsMapName;
  }

  private final const func GetStatsUIMapName(itemId: ItemID) -> String {
    let itemRecord: ref<Item_Record>;
    let itemType: wref<ItemType_Record>;
    let statsMapName: String;
    if ItemID.IsValid(itemId) {
      itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemId));
      if IsDefined(itemRecord) {
        itemType = itemRecord.ItemType();
        statsMapName = "UIMaps." + EnumValueToString("gamedataItemType", Cast(EnumInt(itemType.Type())));
      };
    };
    return statsMapName;
  }

  private final const func GetStatsList(mapPath: TweakDBID, itemData: wref<gameItemData>, out primeStatsList: array<StatViewData>, out secondStatsList: array<StatViewData>, opt compareWithData: wref<gameItemData>) -> Void {
    let compareItemType: wref<ItemType_Record>;
    let compareStatRecords: array<wref<Stat_Record>>;
    let compareTypeList: array<wref<ItemType_Record>>;
    let statRecords: array<wref<Stat_Record>>;
    let stats: ref<UIStatsMap_Record> = TweakDBInterface.GetUIStatsMapRecord(mapPath);
    let canCompare: Bool = false;
    if compareWithData != null {
      compareItemType = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(compareWithData.GetID())).ItemType();
      stats.TypesToCompareWith(compareTypeList);
      canCompare = ArrayContains(compareTypeList, compareItemType);
    };
    stats.StatsToCompare(compareStatRecords);
    stats.PrimaryStats(statRecords);
    this.FillStatsList(itemData, statRecords, primeStatsList, canCompare, compareStatRecords, compareWithData);
    ArrayClear(statRecords);
    stats.SecondaryStats(statRecords);
    this.FillStatsList(itemData, statRecords, secondStatsList, canCompare, compareStatRecords, compareWithData);
  }

  private final const func FillStatsList(itemData: wref<gameItemData>, statRecords: array<wref<Stat_Record>>, out statList: array<StatViewData>, canCompare: Bool, compareStatRecords: array<wref<Stat_Record>>, opt compareWithData: wref<gameItemData>) -> Void {
    let compareValue: Int32;
    let compareValueF: Float;
    let currStatRecord: wref<Stat_Record>;
    let currentStatViewData: StatViewData;
    let currentType: gamedataStatType;
    let maxValue: Int32;
    let maxValueIdx: Int32;
    let count: Int32 = ArraySize(statRecords);
    let i: Int32 = 0;
    while i < count {
      currStatRecord = statRecords[i];
      currentType = currStatRecord.StatType();
      if itemData.HasStatData(currentType) {
        currentStatViewData.type = currentType;
        currentStatViewData.statName = this.m_locMgr.Localize(EnumValueToName(n"gamedataStatType", EnumInt(currentType)));
        currentStatViewData.value = RoundMath(itemData.GetStatValueByType(currentType));
        currentStatViewData.valueF = itemData.GetStatValueByType(currentType);
        if currentStatViewData.value <= 0 {
        } else {
          currentStatViewData.canBeCompared = ArrayContains(compareStatRecords, currStatRecord);
          currentStatViewData.isCompared = canCompare && currentStatViewData.canBeCompared && compareWithData.HasStatData(currentType);
          if currentStatViewData.isCompared {
            compareValue = RoundMath(compareWithData.GetStatValueByType(currentType));
            compareValueF = compareWithData.GetStatValueByType(currentType);
            currentStatViewData.diffValue = currentStatViewData.value - compareValue;
            currentStatViewData.diffValueF = currentStatViewData.valueF - compareValueF;
          } else {
            currentStatViewData.diffValue = 0;
            currentStatViewData.diffValueF = 0.00;
          };
          if currentStatViewData.value > maxValue {
            maxValue = currentStatViewData.value;
            maxValueIdx = i;
          };
          currentStatViewData.statMaxValue = RoundMath(currStatRecord.Max());
          currentStatViewData.statMinValue = RoundMath(currStatRecord.Min());
          currentStatViewData.statMaxValueF = currStatRecord.Max();
          currentStatViewData.statMinValueF = currStatRecord.Min();
          ArrayPush(statList, currentStatViewData);
        };
      };
      i += 1;
    };
    if ArraySize(statList) > 0 {
      statList[maxValueIdx].isMaxValue = true;
    };
  }

  public final func GetPlayerStats(out statsList: array<StatViewData>) -> Void {
    let count: Int32;
    let curData: StatViewData;
    let curRecords: wref<Stat_Record>;
    let i: Int32;
    let statRecords: array<wref<Stat_Record>>;
    let playerID: StatsObjectID = Cast(this.m_player.GetEntityID());
    let statMap: ref<UIStatsMap_Record> = TweakDBInterface.GetUIStatsMapRecord(t"UIMaps.Player");
    statMap.PrimaryStats(statRecords);
    count = ArraySize(statRecords);
    i = 0;
    while i < count {
      curRecords = statRecords[i];
      if IsDefined(curRecords) {
        curData.type = curRecords.StatType();
        curData.value = RoundMath(this.m_statsSystem.GetStatValue(playerID, curData.type));
        curData.statName = this.m_locMgr.Localize(EnumValueToName(n"gamedataStatType", EnumInt(curData.type)));
        ArrayPush(statsList, curData);
      };
      i += 1;
    };
  }
}
