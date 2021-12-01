
public abstract class AIActionTransactionSystem extends IScriptable {

  public final static func ChooseSingleItemsSetFromPool(powerLevel: Int32, seed: Uint32, itemPool: wref<NPCEquipmentItemPool_Record>) -> array<wref<NPCEquipmentItem_Record>> {
    let possibleItems: array<wref<NPCEquipmentItemsPoolEntry_Record>>;
    let randomVal: Float;
    let results: array<wref<NPCEquipmentItem_Record>>;
    let tempPoolEntry: wref<NPCEquipmentItemsPoolEntry_Record>;
    let weightSum: Float;
    let accumulator: Float = 0.00;
    let poolSize: Int32 = itemPool.GetPoolCount();
    let i: Int32 = 0;
    while i < poolSize {
      tempPoolEntry = itemPool.GetPoolItem(i);
      if powerLevel >= tempPoolEntry.MinLevel() {
        ArrayPush(possibleItems, tempPoolEntry);
        weightSum += tempPoolEntry.Weight();
      };
      i += 1;
    };
    randomVal = RandNoiseF(Cast(seed), 0.00, weightSum);
    i = 0;
    while i < ArraySize(possibleItems) {
      accumulator += possibleItems[i].Weight();
      if randomVal < accumulator {
        possibleItems[i].Items(results);
        return results;
      };
      i += 1;
    };
    return results;
  }

  public final static func CalculateEquipmentItems(const puppet: wref<ScriptedPuppet>, const equipmentGroupName: CName, out items: array<wref<NPCEquipmentItem_Record>>, opt powerLevel: Int32) -> Void {
    let equipmentGroupRecord: wref<NPCEquipmentGroup_Record>;
    let characterRecord: wref<Character_Record> = TweakDBInterface.GetCharacterRecord(puppet.GetRecordID());
    if !IsDefined(characterRecord) || !IsNameValid(equipmentGroupName) {
      return;
    };
    if Equals(equipmentGroupName, n"PrimaryEquipment") {
      equipmentGroupRecord = characterRecord.PrimaryEquipment();
    } else {
      if Equals(equipmentGroupName, n"SecondaryEquipment") {
        equipmentGroupRecord = characterRecord.SecondaryEquipment();
      };
    };
    if !IsDefined(equipmentGroupRecord) {
      return;
    };
    AIActionTransactionSystem.CalculateEquipmentItems(puppet, equipmentGroupRecord, items, powerLevel);
  }

  public final static func CalculateEquipmentItems(const puppet: wref<ScriptedPuppet>, equipmentGroupRecord: wref<NPCEquipmentGroup_Record>, out items: array<wref<NPCEquipmentItem_Record>>, powerLevel: Int32) -> Void {
    let entry: wref<NPCEquipmentGroupEntry_Record>;
    let groupID: Uint32;
    let i: Int32;
    let itemsCount: Int32;
    let itemsSet: array<wref<NPCEquipmentItem_Record>>;
    let seed: Uint32;
    let statSys: ref<StatsSystem>;
    let x: Int32;
    let id: EntityID = puppet.GetEntityID();
    let bitsMask: Uint64 = Cast(PowF(2.00, 32.00)) - 1u;
    if !IsDefined(equipmentGroupRecord) {
      return;
    };
    seed = EntityID.GetHash(id);
    groupID = Cast(TDBID.ToNumber(equipmentGroupRecord.GetID()) & bitsMask);
    seed = seed ^ groupID;
    if powerLevel < 0 {
      statSys = GameInstance.GetStatsSystem(puppet.GetGame());
      powerLevel = Cast(statSys.GetStatValue(Cast(puppet.GetEntityID()), gamedataStatType.PowerLevel));
    };
    itemsCount = equipmentGroupRecord.GetEquipmentItemsCount();
    i = 0;
    while i < itemsCount {
      entry = equipmentGroupRecord.GetEquipmentItemsItem(i);
      if IsDefined(entry as NPCEquipmentItem_Record) {
        ArrayPush(items, entry as NPCEquipmentItem_Record);
      } else {
        seed += 1u;
        itemsSet = AIActionTransactionSystem.ChooseSingleItemsSetFromPool(powerLevel, seed, entry as NPCEquipmentItemPool_Record);
        x = 0;
        while x < ArraySize(itemsSet) {
          ArrayPush(items, itemsSet[x]);
          x += 1;
        };
      };
      i += 1;
    };
  }

  public final static func ShouldPerformEquipmentCheck(obj: wref<ScriptedPuppet>, const equipmentGroup: CName) -> Bool {
    let characterRecord: wref<Character_Record> = TweakDBInterface.GetCharacterRecord(obj.GetRecordID());
    if !IsDefined(characterRecord) {
      return false;
    };
    if !IsDefined(obj) || !IsNameValid(equipmentGroup) {
      return false;
    };
    if Equals(equipmentGroup, n"PrimaryEquipment") {
      if IsDefined(characterRecord.PrimaryEquipment()) {
        return true;
      };
    } else {
      if Equals(equipmentGroup, n"SecondaryEquipment") {
        if IsDefined(characterRecord.SecondaryEquipment()) {
          return true;
        };
      };
    };
    return false;
  }

  public final static func CheckEquipmentGroupForEquipment(const context: ScriptExecutionContext, condition: wref<AIItemCond_Record>) -> Bool {
    let a: Int32;
    let checkTag: Bool;
    let i: Int32;
    let item: ref<Item_Record>;
    let items: array<wref<NPCEquipmentItem_Record>>;
    let itemsCount: Int32;
    let tagCount: Int32;
    AIActionTransactionSystem.CalculateEquipmentItems(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, condition.EquipmentGroup(), items);
    itemsCount = ArraySize(items);
    if itemsCount > 0 && !condition.CheckAllItemsInEquipmentGroup() {
      itemsCount = 1;
    };
    i = 0;
    while i < itemsCount {
      item = items[i].Item();
      if !IsDefined(item) {
      } else {
        if IsDefined(condition.ItemType()) && NotEquals(condition.ItemType().Name(), n"") {
          if NotEquals(item.ItemType().Type(), condition.ItemType().Type()) {
          } else {
            if NotEquals(condition.ItemCategory().Name(), n"") {
              if item.ItemCategory() != condition.ItemCategory() {
              } else {
                if NotEquals(condition.ItemTag(), n"") {
                  tagCount = item.GetTagsCount();
                  a = 0;
                  while a < tagCount {
                    if Equals(item.GetTagsItem(a), condition.ItemTag()) {
                      checkTag = true;
                    } else {
                      a += 1;
                    };
                  };
                  if !checkTag {
                  } else {
                    return true;
                  };
                };
                return true;
              };
            };
            if NotEquals(condition.ItemTag(), n"") {
              tagCount = item.GetTagsCount();
              a = 0;
              while a < tagCount {
                if Equals(item.GetTagsItem(a), condition.ItemTag()) {
                  checkTag = true;
                } else {
                  a += 1;
                };
              };
              if !checkTag {
              } else {
                return true;
              };
            };
            return true;
          };
        };
        if NotEquals(condition.ItemCategory().Name(), n"") {
          if item.ItemCategory() != condition.ItemCategory() {
          } else {
            if NotEquals(condition.ItemTag(), n"") {
              tagCount = item.GetTagsCount();
              a = 0;
              while a < tagCount {
                if Equals(item.GetTagsItem(a), condition.ItemTag()) {
                  checkTag = true;
                } else {
                  a += 1;
                };
              };
              if !checkTag {
              } else {
                return true;
              };
            };
            return true;
          };
        };
        if NotEquals(condition.ItemTag(), n"") {
          tagCount = item.GetTagsCount();
          a = 0;
          while a < tagCount {
            if Equals(item.GetTagsItem(a), condition.ItemTag()) {
              checkTag = true;
            } else {
              a += 1;
            };
          };
          if !checkTag {
          } else {
            return true;
          };
        };
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func CheckSlotsForEquipment(const context: ScriptExecutionContext, const equipmentGroup: CName) -> Bool {
    let i: Int32;
    let itemsInSlots: Int32;
    let itemsToEquip: array<NPCItemToEquip>;
    switch equipmentGroup {
      case n"PrimaryEquipment":
        if !AIActionTransactionSystem.GetEquipment(context, true, itemsToEquip) {
          return false;
        };
        break;
      case n"SecondaryEquipment":
        if !AIActionTransactionSystem.GetEquipment(context, false, itemsToEquip) {
          return false;
        };
        break;
      default:
    };
    i = 0;
    while i < ArraySize(itemsToEquip) {
      if GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).HasItemInSlot(ScriptExecutionContext.GetOwner(context), itemsToEquip[i].slotID, itemsToEquip[i].itemID) {
        itemsInSlots += 1;
      };
      i += 1;
    };
    if itemsInSlots > 0 {
      return true;
    };
    return false;
  }

  public final static func GetEquipment(const context: ScriptExecutionContext, checkPrimaryEquipment: Bool, out itemsList: array<NPCItemToEquip>) -> Bool {
    let characterRecord: wref<Character_Record>;
    let equipmentGroup: wref<NPCEquipmentGroup_Record>;
    let i: Int32;
    let item: NPCItemToEquip;
    let itemCount: Int32;
    let itemID: ItemID;
    let itemRecord: ref<NPCEquipmentItem_Record>;
    let items: array<wref<NPCEquipmentItem_Record>>;
    let slotId: TweakDBID;
    let puppet: wref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return false;
    };
    characterRecord = TweakDBInterface.GetCharacterRecord(puppet.GetRecordID());
    if !IsDefined(characterRecord) {
      return false;
    };
    if checkPrimaryEquipment {
      equipmentGroup = characterRecord.PrimaryEquipment();
    } else {
      equipmentGroup = characterRecord.SecondaryEquipment();
    };
    AIActionTransactionSystem.CalculateEquipmentItems(puppet, equipmentGroup, items, -1);
    itemCount = ArraySize(items);
    i = 0;
    while i < itemCount {
      itemRecord = items[i];
      if IsDefined(itemRecord.OnBodySlot()) {
        slotId = itemRecord.OnBodySlot().GetID();
      };
      AIActionTransactionSystem.GetItemID(puppet, itemRecord.Item(), slotId, itemID);
      if GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).HasItem(ScriptExecutionContext.GetOwner(context), itemID) {
        item.itemID = itemID;
        item.slotID = itemRecord.EquipSlot().GetID();
        item.bodySlotID = slotId;
        ArrayPush(itemsList, item);
      };
      i += 1;
    };
    return ArraySize(itemsList) > 0;
  }

  public final static func GetEquipmentWithCondition(const context: ScriptExecutionContext, checkPrimaryEquipment: Bool, checkForUnequip: Bool, out itemsList: array<NPCItemToEquip>) -> Bool {
    let BBoard: ref<IBlackboard>;
    let bodySlotId: TweakDBID;
    let characterRecord: wref<Character_Record>;
    let conditions: array<wref<AIActionCondition_Record>>;
    let currentItem: ref<NPCEquipmentItem_Record>;
    let defaultID: TweakDBID;
    let equipmentGroup: wref<NPCEquipmentGroup_Record>;
    let game: GameInstance;
    let i: Int32;
    let item: NPCItemToEquip;
    let itemID: ItemID;
    let items: array<wref<NPCEquipmentItem_Record>>;
    let itemsVariant: Variant;
    let k: Int32;
    let lastEquippedItems: array<ItemID>;
    let lastUnequipTimestamp: Float;
    let primaryConditions: array<wref<AIActionCondition_Record>>;
    let primaryItemID: ItemID;
    let primaryItems: array<wref<NPCEquipmentItem_Record>>;
    let primaryItemsToEquip: array<NPCItemToEquip>;
    let secondaryItemsToEquip: array<NPCItemToEquip>;
    let transactionSystem: ref<TransactionSystem>;
    let z: Int32;
    let puppet: wref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return false;
    };
    game = puppet.GetGame();
    characterRecord = TweakDBInterface.GetCharacterRecord(puppet.GetRecordID());
    if !IsDefined(characterRecord) {
      return false;
    };
    transactionSystem = GameInstance.GetTransactionSystem(game);
    if checkPrimaryEquipment {
      equipmentGroup = characterRecord.PrimaryEquipment();
    } else {
      equipmentGroup = characterRecord.SecondaryEquipment();
    };
    AIActionTransactionSystem.CalculateEquipmentItems(puppet, equipmentGroup, items, -1);
    i = 0;
    while i < ArraySize(items) {
      currentItem = items[i];
      if IsDefined(currentItem.OnBodySlot()) {
        bodySlotId = currentItem.OnBodySlot().GetID();
      };
      if IsDefined(currentItem.Item()) && IsDefined(currentItem.EquipSlot()) && AIActionTransactionSystem.GetItemID(puppet, currentItem.Item(), bodySlotId, itemID) {
        ArrayClear(conditions);
        if !checkForUnequip && !transactionSystem.HasItemInSlot(puppet, currentItem.EquipSlot().GetID(), itemID) && transactionSystem.HasItem(puppet, itemID) {
          currentItem.EquipCondition(conditions);
        } else {
          if checkForUnequip && (transactionSystem.HasItemInSlot(puppet, currentItem.EquipSlot().GetID(), itemID) || ItemID.GetTDBID(transactionSystem.GetItemInSlot(puppet, t"AttachmentSlots.WeaponRight").GetItemID()) == t"Items.Npc_fists_wounded") {
            currentItem.UnequipCondition(conditions);
          } else {
          };
        };
        if checkForUnequip && ArraySize(conditions) == 0 && checkPrimaryEquipment && ItemID.GetTDBID(transactionSystem.GetItemInSlot(puppet, t"AttachmentSlots.WeaponRight").GetItemID()) != t"Items.Npc_fists_wounded" {
        } else {
          if !checkForUnequip {
            BBoard = puppet.GetAIControllerComponent().GetActionBlackboard();
            if IsDefined(BBoard) {
              itemsVariant = BBoard.GetVariant(GetAllBlackboardDefs().AIAction.ownerLastEquippedItems);
              if VariantIsValid(itemsVariant) {
                lastEquippedItems = FromVariant(itemsVariant);
              };
              lastUnequipTimestamp = BBoard.GetFloat(GetAllBlackboardDefs().AIAction.ownerLastUnequipTimestamp);
            };
            if ArrayContains(lastEquippedItems, itemID) && EngineTime.ToFloat(GameInstance.GetSimTime(game)) < lastUnequipTimestamp + 3.00 {
            } else {
              if ArraySize(conditions) > 0 && !AICondition.CheckActionConditions(context, conditions) {
              } else {
                if !checkForUnequip && ArraySize(conditions) == 0 && ArraySize(itemsList) > 0 {
                  k = 0;
                  while k < ArraySize(itemsList) {
                    if itemsList[k].slotID == currentItem.EquipSlot().GetID() {
                    };
                    k += 1;
                  };
                };
                if !checkPrimaryEquipment && checkForUnequip {
                  AIActionTransactionSystem.GetEquipmentWithCondition(context, true, false, primaryItemsToEquip);
                  AIActionTransactionSystem.GetEquipmentWithCondition(context, false, false, secondaryItemsToEquip);
                  if ArraySize(primaryItemsToEquip) == 0 && ArraySize(secondaryItemsToEquip) == 0 {
                  } else {
                    if ArraySize(primaryItemsToEquip) > 0 && transactionSystem.HasItemInSlot(puppet, primaryItemsToEquip[0].slotID, primaryItemsToEquip[0].itemID) || ArraySize(secondaryItemsToEquip) > 0 && transactionSystem.HasItemInSlot(puppet, secondaryItemsToEquip[0].slotID, secondaryItemsToEquip[0].itemID) {
                    } else {
                      AIActionTransactionSystem.CalculateEquipmentItems(puppet, characterRecord.PrimaryEquipment(), primaryItems, -1);
                      z = 0;
                      while z < ArraySize(primaryItems) {
                        AIActionTransactionSystem.GetItemID(puppet, primaryItems[z].Item(), IsDefined(primaryItems[z].OnBodySlot()) ? primaryItems[z].OnBodySlot().GetID() : defaultID, primaryItemID);
                        if itemID == primaryItemID {
                          primaryItems[z].EquipCondition(primaryConditions);
                          if AICondition.CheckActionConditions(context, primaryConditions) {
                          };
                        };
                        z += 1;
                      };
                      item.itemID = itemID;
                      item.slotID = currentItem.EquipSlot().GetID();
                      item.bodySlotID = bodySlotId;
                      ArrayPush(itemsList, item);
                    };
                  };
                };
                item.itemID = itemID;
                item.slotID = currentItem.EquipSlot().GetID();
                item.bodySlotID = bodySlotId;
                ArrayPush(itemsList, item);
              };
            };
          };
          if ArraySize(conditions) > 0 && !AICondition.CheckActionConditions(context, conditions) {
          } else {
            if !checkForUnequip && ArraySize(conditions) == 0 && ArraySize(itemsList) > 0 {
              k = 0;
              while k < ArraySize(itemsList) {
                if itemsList[k].slotID == currentItem.EquipSlot().GetID() {
                };
                k += 1;
              };
            };
            if !checkPrimaryEquipment && checkForUnequip {
              AIActionTransactionSystem.GetEquipmentWithCondition(context, true, false, primaryItemsToEquip);
              AIActionTransactionSystem.GetEquipmentWithCondition(context, false, false, secondaryItemsToEquip);
              if ArraySize(primaryItemsToEquip) == 0 && ArraySize(secondaryItemsToEquip) == 0 {
              } else {
                if ArraySize(primaryItemsToEquip) > 0 && transactionSystem.HasItemInSlot(puppet, primaryItemsToEquip[0].slotID, primaryItemsToEquip[0].itemID) || ArraySize(secondaryItemsToEquip) > 0 && transactionSystem.HasItemInSlot(puppet, secondaryItemsToEquip[0].slotID, secondaryItemsToEquip[0].itemID) {
                } else {
                  AIActionTransactionSystem.CalculateEquipmentItems(puppet, characterRecord.PrimaryEquipment(), primaryItems, -1);
                  z = 0;
                  while z < ArraySize(primaryItems) {
                    AIActionTransactionSystem.GetItemID(puppet, primaryItems[z].Item(), IsDefined(primaryItems[z].OnBodySlot()) ? primaryItems[z].OnBodySlot().GetID() : defaultID, primaryItemID);
                    if itemID == primaryItemID {
                      primaryItems[z].EquipCondition(primaryConditions);
                      if AICondition.CheckActionConditions(context, primaryConditions) {
                      };
                    };
                    z += 1;
                  };
                  item.itemID = itemID;
                  item.slotID = currentItem.EquipSlot().GetID();
                  item.bodySlotID = bodySlotId;
                  ArrayPush(itemsList, item);
                };
              };
            };
            item.itemID = itemID;
            item.slotID = currentItem.EquipSlot().GetID();
            item.bodySlotID = bodySlotId;
            ArrayPush(itemsList, item);
          };
        };
      } else {
      };
      i += 1;
    };
    return ArraySize(itemsList) > 0;
  }

  public final static func GetDefaultEquipment(const context: ScriptExecutionContext, characterRecord: wref<Character_Record>, checkForUnequip: Bool, out itemsList: array<NPCItemToEquip>) -> Bool {
    let defaultItem: ref<NPCEquipmentItem_Record>;
    let i: Int32;
    let item: NPCItemToEquip;
    let itemID: ItemID;
    let items: array<wref<NPCEquipmentItem_Record>>;
    let onBodySlotID: TweakDBID;
    let primaryItemsToEquip: array<NPCItemToEquip>;
    let sendData: Bool;
    AIActionTransactionSystem.CalculateEquipmentItems(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, characterRecord.SecondaryEquipment(), items, -1);
    sendData = false;
    AIActionTransactionSystem.GetEquipmentWithCondition(context, true, false, primaryItemsToEquip);
    if checkForUnequip {
      if ArraySize(primaryItemsToEquip) > 0 && !GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).HasItemInSlot(ScriptExecutionContext.GetOwner(context), primaryItemsToEquip[0].slotID, primaryItemsToEquip[0].itemID) {
        if !GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).HasItemInSlot(ScriptExecutionContext.GetOwner(context), primaryItemsToEquip[0].slotID, primaryItemsToEquip[0].itemID) {
          sendData = true;
        };
      };
    };
    if sendData {
      i = ArraySize(items) - 1;
      if IsDefined(items[i].OnBodySlot()) {
        onBodySlotID = items[i].OnBodySlot().GetID();
      };
      AIActionTransactionSystem.GetItemID(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, items[i].Item(), onBodySlotID, itemID);
      if ArraySize(items) > 0 && GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).HasItem(ScriptExecutionContext.GetOwner(context), itemID) {
        item.itemID = itemID;
        item.slotID = items[i].EquipSlot().GetID();
      } else {
        defaultItem = characterRecord.DefaultEquipment();
        AIActionTransactionSystem.GetItemID(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, defaultItem.Item(), defaultItem.OnBodySlot().GetID(), itemID);
        if !GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).HasItem(ScriptExecutionContext.GetOwner(context), itemID) {
          GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GiveItem(ScriptExecutionContext.GetOwner(context), itemID, 1);
        };
        item.itemID = itemID;
        item.slotID = defaultItem.EquipSlot().GetID();
      };
      if !checkForUnequip || GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).HasItemInSlot(ScriptExecutionContext.GetOwner(context), item.slotID, item.itemID) {
        ArrayPush(itemsList, item);
        return true;
      };
    };
    return false;
  }

  public final static func GetOnBodyEquipment(obj: wref<ScriptedPuppet>, out itemsToEquip: array<NPCItemToEquip>) -> Bool {
    let characterRecord: wref<Character_Record>;
    let equipmentGroup: wref<NPCEquipmentGroup_Record>;
    let i: Int32;
    let itemID: ItemID;
    let itemToEquip: NPCItemToEquip;
    let items: array<wref<NPCEquipmentItem_Record>>;
    if !IsDefined(obj) {
      return false;
    };
    characterRecord = TweakDBInterface.GetCharacterRecord(obj.GetRecordID());
    if !IsDefined(characterRecord) {
      return false;
    };
    equipmentGroup = characterRecord.PrimaryEquipment();
    if !IsDefined(equipmentGroup) {
      return false;
    };
    AIActionTransactionSystem.CalculateEquipmentItems(obj, equipmentGroup, items, -1);
    i = 0;
    while i < ArraySize(items) {
      if IsDefined(items[i].Item()) && AIActionTransactionSystem.GetItemIDFromRecord(items[i].Item(), itemID) {
        itemToEquip.itemID = itemID;
        if IsDefined(items[i].OnBodySlot()) {
          itemToEquip.bodySlotID = items[i].OnBodySlot().GetID();
        };
        ArrayPush(itemsToEquip, itemToEquip);
      };
      i += 1;
    };
    equipmentGroup = characterRecord.SecondaryEquipment();
    ArrayClear(items);
    AIActionTransactionSystem.CalculateEquipmentItems(obj, equipmentGroup, items, -1);
    i = 0;
    while i < ArraySize(items) {
      if IsDefined(items[i].Item()) && AIActionTransactionSystem.GetItemIDFromRecord(items[i].Item(), itemID) {
        itemToEquip.itemID = itemID;
        if IsDefined(items[i].OnBodySlot()) {
          itemToEquip.bodySlotID = items[i].OnBodySlot().GetID();
        };
        ArrayPush(itemsToEquip, itemToEquip);
      };
      i += 1;
    };
    return ArraySize(itemsToEquip) > 0;
  }

  public final static func GetOnBodyEquipmentRecords(obj: wref<ScriptedPuppet>, out outEquipmentRecords: array<wref<NPCEquipmentItem_Record>>) -> Bool {
    let characterRecord: wref<Character_Record>;
    let equipmentGroup: wref<NPCEquipmentGroup_Record>;
    let i: Int32;
    let items: array<wref<NPCEquipmentItem_Record>>;
    if !IsDefined(obj) {
      return false;
    };
    characterRecord = TweakDBInterface.GetCharacterRecord(obj.GetRecordID());
    if !IsDefined(characterRecord) {
      return false;
    };
    equipmentGroup = characterRecord.PrimaryEquipment();
    if !IsDefined(equipmentGroup) {
      return false;
    };
    AIActionTransactionSystem.CalculateEquipmentItems(obj, equipmentGroup, items, -1);
    i = 0;
    while i < ArraySize(items) {
      if IsDefined(items[i].Item()) && IsDefined(items[i].OnBodySlot()) {
        ArrayPush(outEquipmentRecords, items[i]);
      };
      i += 1;
    };
    equipmentGroup = characterRecord.SecondaryEquipment();
    ArrayClear(items);
    AIActionTransactionSystem.CalculateEquipmentItems(obj, equipmentGroup, items, -1);
    i = 0;
    while i < ArraySize(items) {
      if IsDefined(items[i].Item()) && IsDefined(items[i].OnBodySlot()) {
        ArrayPush(outEquipmentRecords, items[i]);
      };
      i += 1;
    };
    return ArraySize(outEquipmentRecords) > 0;
  }

  public final static func GetItemsBodySlot(owner: wref<ScriptedPuppet>, const itemID: ItemID, out onBodySlotID: TweakDBID) -> Bool {
    let equipmentRecords: array<wref<NPCEquipmentItem_Record>>;
    let i: Int32;
    if !AIActionTransactionSystem.GetOnBodyEquipmentRecords(owner, equipmentRecords) {
      return false;
    };
    i = 0;
    while i < ArraySize(equipmentRecords) {
      if equipmentRecords[i].Item().GetID() == ItemID.GetTDBID(itemID) {
        onBodySlotID = equipmentRecords[i].OnBodySlot().GetID();
        return TDBID.IsValid(onBodySlotID);
      };
      i += 1;
    };
    return false;
  }

  public final static func GetItemID(obj: wref<ScriptedPuppet>, itemRecord: wref<Item_Record>, const onBodySlotID: TweakDBID, out itemID: ItemID) -> Bool {
    let itemObj: ref<ItemObject>;
    if !IsDefined(itemRecord) {
      return false;
    };
    if IsDefined(obj) && TDBID.IsValid(onBodySlotID) {
      itemObj = GameInstance.GetTransactionSystem(obj.GetGame()).GetItemInSlot(obj, onBodySlotID);
      if IsDefined(itemObj) {
        itemID = itemObj.GetItemID();
        if ItemID.GetTDBID(itemID) == itemRecord.GetID() {
          return true;
        };
      };
    };
    itemID = ItemID.CreateQuery(itemRecord.GetID());
    return ItemID.IsValid(itemID);
  }

  public final static func GetItemIDFromRecord(itemRecord: wref<Item_Record>, out itemID: ItemID) -> Bool {
    if !IsDefined(itemRecord) {
      return false;
    };
    itemID = ItemID.CreateQuery(itemRecord.GetID());
    return ItemID.IsValid(itemID);
  }

  public final static func GetFirstItemID(owner: wref<GameObject>, const itemTag: CName, out itemID: ItemID) -> Bool {
    let itemList: array<wref<gameItemData>>;
    if NotEquals(itemTag, n"") {
      GameInstance.GetTransactionSystem(owner.GetGame()).GetItemListByTag(owner, itemTag, itemList);
    } else {
      GameInstance.GetTransactionSystem(owner.GetGame()).GetItemList(owner, itemList);
    };
    if ArraySize(itemList) > 0 {
      itemID = itemList[0].GetID();
      return true;
    };
    return false;
  }

  public final static func GetFirstItemID(owner: wref<GameObject>, itemType: wref<ItemType_Record>, itemTag: CName, out itemID: ItemID) -> Bool {
    let i: Int32;
    let itemList: array<wref<gameItemData>>;
    if NotEquals(itemTag, n"") {
      GameInstance.GetTransactionSystem(owner.GetGame()).GetItemListByTag(owner, itemTag, itemList);
    } else {
      GameInstance.GetTransactionSystem(owner.GetGame()).GetItemList(owner, itemList);
    };
    i = 0;
    while i < ArraySize(itemList) {
      if TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemList[i].GetID())).ItemType() == itemType {
        itemID = itemList[i].GetID();
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func GetFirstItemID(owner: wref<GameObject>, itemCategory: wref<ItemCategory_Record>, itemTag: CName, out itemID: ItemID) -> Bool {
    let i: Int32;
    let itemList: array<wref<gameItemData>>;
    if NotEquals(itemTag, n"") {
      GameInstance.GetTransactionSystem(owner.GetGame()).GetItemListByTag(owner, itemTag, itemList);
    } else {
      GameInstance.GetTransactionSystem(owner.GetGame()).GetItemList(owner, itemList);
    };
    i = 0;
    while i < ArraySize(itemList) {
      if TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemList[i].GetID())).ItemCategory() == itemCategory {
        itemID = itemList[i].GetID();
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func IsSlotEmptySpawningItem(owner: wref<GameObject>, slotID: TweakDBID) -> Bool {
    if !IsDefined(owner) {
      return false;
    };
    if !TDBID.IsValid(slotID) {
      return false;
    };
    return GameInstance.GetTransactionSystem(owner.GetGame()).IsSlotEmptySpawningItem(owner, slotID);
  }

  public final static func DoesItemMeetRequirements(const weaponItemID: ItemID, condition: ref<AIItemCond_Record>, evolution: wref<WeaponEvolution_Record>) -> Bool {
    let weaponRecord: wref<WeaponItem_Record>;
    let triggerModeCount: Int32 = condition.GetTriggerModesCount();
    if !IsDefined(evolution) && triggerModeCount == 0 {
      return true;
    };
    weaponRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(weaponItemID)) as WeaponItem_Record;
    if IsDefined(weaponRecord) {
      if IsDefined(evolution) && weaponRecord.Evolution() != evolution {
        return false;
      };
      if triggerModeCount > 0 {
        if !IsDefined(weaponRecord.PrimaryTriggerMode()) || !condition.TriggerModesContains(weaponRecord.PrimaryTriggerMode()) {
          return false;
        };
      };
      return true;
    };
    return false;
  }
}
