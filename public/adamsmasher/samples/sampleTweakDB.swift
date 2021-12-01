
public static exec func TweakDBTest() -> Void {
  let itemRecord: ref<Item_Record>;
  let lootItemList: array<wref<LootItem_Record>>;
  let lootItemRecord: ref<LootItem_Record>;
  let lootTableRecord: ref<LootTable_Record>;
  Log(FloatToString(TDB.GetFloat(t"Scripts.Item.A")));
  Log(FloatToString(TweakDBInterface.GetFloat(t"Scripts.Item.C", 10.00)));
  Log(IntToString(TDB.GetInt(t"Scripts.Item.Int")));
  Log(IntToString(TweakDBInterface.GetInt(t"Scripts.Item.In2t", 1999)));
  Log(TDB.GetString(t"Scripts.Item.String"));
  Log(TweakDBInterface.GetString(t"Scripts.Item.Stng", "DefaultValue"));
  lootTableRecord = TweakDBInterface.GetLootTableRecord(t"LootTables.testSingleItem");
  lootTableRecord.LootItems(lootItemList);
  lootItemRecord = lootItemList[0];
  itemRecord = lootItemRecord.ItemID();
  Log(itemRecord.FriendlyName());
}
