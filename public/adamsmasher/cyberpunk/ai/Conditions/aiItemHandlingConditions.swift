
public class CheckUnregisteredWeapon extends AIItemHandlingCondition {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let emptyTweakDBID: TweakDBID;
    let i: Int32;
    let itemInCurrentLeftSlotTweakDBID: TweakDBID;
    let itemInCurrentRightSlotTweakDBID: TweakDBID;
    let itemsCount: Int32;
    let primaryItemArrayRecord: array<wref<NPCEquipmentGroupEntry_Record>>;
    let primaryItemInRecord: wref<NPCEquipmentItem_Record>;
    let primaryItemInRecordItemID: ItemID;
    let primaryItemInRecordTweakDBID: TweakDBID;
    let secondaryItemArrayRecord: array<wref<NPCEquipmentGroupEntry_Record>>;
    let secondaryItemInRecord: wref<NPCEquipmentItem_Record>;
    let secondaryItemInRecordItemID: ItemID;
    let secondaryItemInRecordTweakDBID: TweakDBID;
    let characterRecord: wref<Character_Record> = TweakDBInterface.GetCharacterRecord(ScriptExecutionContext.GetOwner(context).GetRecordID());
    let primaryEquipmentGroup: wref<NPCEquipmentGroup_Record> = characterRecord.PrimaryEquipment();
    let secondaryEquipmentGroup: wref<NPCEquipmentGroup_Record> = characterRecord.SecondaryEquipment();
    let itemInCurrentLeftSlot: wref<ItemObject> = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetItemInSlot(ScriptExecutionContext.GetOwner(context), t"AttachmentSlots.WeaponLeft");
    let itemInCurrentRightSlot: wref<ItemObject> = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetItemInSlot(ScriptExecutionContext.GetOwner(context), t"AttachmentSlots.WeaponRight");
    if !IsDefined(itemInCurrentLeftSlot) && !IsDefined(itemInCurrentRightSlot) {
      return Cast(false);
    };
    primaryEquipmentGroup.EquipmentItems(primaryItemArrayRecord);
    itemsCount = ArraySize(primaryItemArrayRecord);
    if itemsCount > 0 {
      i = 0;
      while i < itemsCount {
        primaryItemInRecord = primaryEquipmentGroup.GetEquipmentItemsItem(i) as NPCEquipmentItem_Record;
        AIActionTransactionSystem.GetItemID(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, primaryItemInRecord.Item(), primaryItemInRecord.OnBodySlot().GetID(), primaryItemInRecordItemID);
        primaryItemInRecordTweakDBID = ItemID.GetTDBID(primaryItemInRecordItemID);
        if primaryItemInRecordTweakDBID == emptyTweakDBID {
          return Cast(false);
        };
        itemInCurrentLeftSlotTweakDBID = ItemID.GetTDBID(itemInCurrentLeftSlot.GetItemID());
        itemInCurrentRightSlotTweakDBID = ItemID.GetTDBID(itemInCurrentRightSlot.GetItemID());
        if itemInCurrentLeftSlotTweakDBID == primaryItemInRecordTweakDBID || itemInCurrentRightSlotTweakDBID == primaryItemInRecordTweakDBID {
          return Cast(false);
        };
        i += 1;
      };
    };
    secondaryEquipmentGroup.EquipmentItems(secondaryItemArrayRecord);
    itemsCount = ArraySize(secondaryItemArrayRecord);
    if itemsCount > 0 {
      i = 0;
      while i < itemsCount {
        secondaryItemInRecord = secondaryEquipmentGroup.GetEquipmentItemsItem(i) as NPCEquipmentItem_Record;
        AIActionTransactionSystem.GetItemID(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, secondaryItemInRecord.Item(), secondaryItemInRecord.OnBodySlot().GetID(), secondaryItemInRecordItemID);
        secondaryItemInRecordTweakDBID = ItemID.GetTDBID(secondaryItemInRecordItemID);
        if secondaryItemInRecordTweakDBID == emptyTweakDBID {
          return Cast(false);
        };
        itemInCurrentLeftSlotTweakDBID = ItemID.GetTDBID(itemInCurrentLeftSlot.GetItemID());
        itemInCurrentRightSlotTweakDBID = ItemID.GetTDBID(itemInCurrentRightSlot.GetItemID());
        if itemInCurrentLeftSlotTweakDBID == secondaryItemInRecordTweakDBID || itemInCurrentRightSlotTweakDBID == secondaryItemInRecordTweakDBID {
          return Cast(false);
        };
        i += 1;
      };
    };
    return Cast(true);
  }
}

public class CheckEquippedWeapon extends AIItemHandlingCondition {

  public inline edit let m_slotID: ref<AIArgumentMapping>;

  public inline edit let m_itemID: ref<AIArgumentMapping>;

  protected let m_slotIDName: TweakDBID;

  protected let m_itemIDName: TweakDBID;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let owner: ref<GameObject> = AIBehaviorScriptBase.GetPuppet(context);
    if IsDefined(owner) {
      if IsDefined(this.m_slotID) && !TDBID.IsValid(this.m_slotIDName) {
        this.m_slotIDName = ScriptExecutionContext.GetTweakDBIDMappingValue(context, this.m_slotID);
      };
      if IsDefined(this.m_itemID) && !TDBID.IsValid(this.m_itemIDName) {
        this.m_itemIDName = ScriptExecutionContext.GetTweakDBIDMappingValue(context, this.m_itemID);
      };
      ScriptExecutionContext.DebugLog(context, n"script", "SLOT ID: " + TDBID.ToStringDEBUG(this.m_slotIDName) + ",  ITEM ID: " + TDBID.ToStringDEBUG(this.m_itemIDName));
      return Cast(GameInstance.GetTransactionSystem(owner.GetGame()).HasItemInSlot(owner, this.m_slotIDName, ItemID.CreateQuery(this.m_itemIDName)));
    };
    return Cast(false);
  }
}

public class CheckEquippedWeaponType extends AIItemHandlingCondition {

  public edit let m_weaponTypeToCheck: CName;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let item: ref<ItemObject>;
    let itemTypeRecordData: CName;
    let owner: ref<GameObject> = AIBehaviorScriptBase.GetPuppet(context);
    if IsDefined(owner) {
      item = GameInstance.GetTransactionSystem(owner.GetGame()).GetItemInSlot(owner, t"AttachmentSlots.WeaponRight");
      itemTypeRecordData = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item.GetItemID())).ItemType().Name();
      return Cast(Equals(this.m_weaponTypeToCheck, itemTypeRecordData));
    };
    return Cast(false);
  }
}
