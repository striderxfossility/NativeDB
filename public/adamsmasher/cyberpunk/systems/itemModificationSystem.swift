
public class ItemModificationSystem extends ScriptableSystem {

  private let m_blackboard: wref<IBlackboard>;

  private func OnAttach() -> Void {
    this.m_blackboard = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_ItemModSystem);
  }

  private final func InstallItemPart(obj: ref<GameObject>, itemID: ItemID, partItemID: ItemID, opt slotID: TweakDBID) -> Bool {
    let defaultSlotID: TweakDBID;
    let partData: InnerItemData;
    let partInstallRequest: ref<PartInstallRequest>;
    let previousPartID: ItemID;
    let result: Bool;
    let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(obj.GetGame());
    let itemType: gamedataItemType = RPGManager.GetItemRecord(partItemID).ItemType().Type();
    let itemData: wref<gameItemData> = ts.GetItemData(obj, itemID);
    if IsDefined(TweakDBInterface.GetAttachmentSlotRecord(slotID)) {
      itemData.GetItemPart(partData, slotID);
      previousPartID = InnerItemData.GetItemID(partData);
      if ItemID.IsValid(previousPartID) {
        this.RemovePartEquipGLPs(obj, previousPartID);
      };
      result = ts.ForcePartInSlot(obj, itemID, partItemID, slotID);
      if Equals(itemType, gamedataItemType.Prt_Program) {
        this.RemoveLowerShards(obj, itemID, partItemID);
      };
      if ItemID.IsValid(previousPartID) && (Equals(RPGManager.GetItemType(previousPartID), gamedataItemType.Prt_Mod) || Equals(RPGManager.GetItemType(previousPartID), gamedataItemType.Prt_FabricEnhancer)) {
        ts.RemoveItem(obj, previousPartID, 1);
      };
    } else {
      defaultSlotID = EquipmentSystem.GetPlacementSlot(partItemID);
      result = ts.ForcePartInSlot(obj, itemID, partItemID, defaultSlotID);
      if Equals(itemType, gamedataItemType.Prt_Mod) || Equals(itemType, gamedataItemType.Prt_FabricEnhancer) {
        ts.RemoveItem(obj, partItemID, 1);
      };
    };
    if result {
      partInstallRequest = new PartInstallRequest();
      partInstallRequest.owner = obj;
      partInstallRequest.itemID = itemID;
      partInstallRequest.partID = partItemID;
      GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"EquipmentSystem").QueueRequest(partInstallRequest);
    };
    PlayerPuppet.ChacheQuickHackListCleanup(obj as PlayerPuppet);
    return result;
  }

  private final func RemoveItemPart(obj: ref<GameObject>, itemID: ItemID, slotID: TweakDBID, shouldUpdateEntity: Bool) -> ItemID {
    let emptyItem: ItemID;
    let partData: InnerItemData;
    let partUninstallRequest: ref<PartUninstallRequest>;
    let removedPartID: ItemID;
    let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(obj.GetGame());
    let itemData: wref<gameItemData> = ts.GetItemData(obj, itemID);
    if itemData.HasPartInSlot(slotID) {
      itemData.GetItemPart(partData, slotID);
      ts.RemovePart(obj, itemID, slotID, shouldUpdateEntity);
      removedPartID = InnerItemData.GetItemID(partData);
      partUninstallRequest = new PartUninstallRequest();
      partUninstallRequest.owner = obj;
      partUninstallRequest.itemID = itemID;
      partUninstallRequest.partID = removedPartID;
      GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"EquipmentSystem").QueueRequest(partUninstallRequest);
      this.SetPingTutorialFact(removedPartID, true, obj);
      PlayerPuppet.ChacheQuickHackListCleanup(obj as PlayerPuppet);
      return removedPartID;
    };
    PlayerPuppet.ChacheQuickHackListCleanup(obj as PlayerPuppet);
    emptyItem = ItemID.undefined();
    return emptyItem;
  }

  private final func RemoveLowerShards(obj: ref<GameObject>, item: ItemID, shardID: ItemID) -> Void {
    let deckData: ref<gameItemData>;
    let i: Int32;
    let instQuality: gamedataQuality;
    let partData: InnerItemData;
    let shardQuality: gamedataQuality;
    let usedSlots: array<TweakDBID>;
    let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(obj.GetGame());
    ts.GetUsedSlotsOnItem(obj, item, usedSlots);
    deckData = ts.GetItemData(obj, item);
    i = 0;
    while i < ArraySize(usedSlots) {
      deckData.GetItemPart(partData, usedSlots[i]);
      instQuality = RPGManager.GetItemRecord(InnerItemData.GetItemID(partData)).Quality().Type();
      shardQuality = RPGManager.GetItemRecord(shardID).Quality().Type();
      if Equals(TweakDBInterface.GetCName(ItemID.GetTDBID(InnerItemData.GetItemID(partData)) + t".shardType", n""), TweakDBInterface.GetCName(ItemID.GetTDBID(shardID) + t".shardType", n"")) && instQuality < shardQuality {
        this.RemoveItemPart(obj, item, usedSlots[i], false);
      };
      i += 1;
    };
  }

  private final func SetPingTutorialFact(itemID: ItemID, isUnequip: Bool, obj: ref<GameObject>) -> Void {
    let questSystem: ref<QuestsSystem>;
    let shard: CName = TweakDBInterface.GetCName(ItemID.GetTDBID(itemID) + t".shardType", n"");
    if Equals(shard, n"Ping") {
      questSystem = GameInstance.GetQuestsSystem(obj.GetGame());
      if isUnequip && questSystem.GetFact(n"ping_installed") == 1 {
        questSystem.SetFact(n"ping_installed", 0);
      } else {
        if questSystem.GetFact(n"ping_installed") == 0 {
          questSystem.SetFact(n"ping_installed", 1);
        };
      };
    };
  }

  private final func RemovePartEquipGLPs(obj: wref<GameObject>, itemID: ItemID) -> Void {
    let glpSys: ref<GameplayLogicPackageSystem>;
    let i: Int32;
    let packages: array<wref<GameplayLogicPackage_Record>>;
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
    itemRecord.OnEquip(packages);
    glpSys = GameInstance.GetGameplayLogicPackageSystem(obj.GetGame());
    i = 0;
    while i < ArraySize(packages) {
      glpSys.RemovePackage(obj, packages[i].GetID());
      i += 1;
    };
  }

  private final func SwapItemPart(obj: ref<GameObject>, itemID: ItemID, partItemID: ItemID, slotID: TweakDBID) -> Bool {
    if !ItemModificationSystem.IsBasePart(obj, itemID, slotID) {
      this.RemoveItemPart(obj, itemID, slotID, false);
    } else {
      return false;
    };
    return this.InstallItemPart(obj, itemID, partItemID, slotID);
  }

  public final static func IsBasePart(obj: ref<GameObject>, itemID: ItemID, slotID: TweakDBID) -> Bool {
    let i: Int32;
    let part: InnerItemData;
    let partRecord: ref<Item_Record>;
    let tags: array<CName>;
    let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(obj.GetGame());
    let itemData: wref<gameItemData> = ts.GetItemData(obj, itemID);
    itemData.GetItemPart(part, slotID);
    partRecord = InnerItemData.GetStaticData(part);
    tags = partRecord.Tags();
    i = 0;
    while i < ArraySize(tags) {
      if Equals(tags[i], n"parentPart") {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func IsItemSlotTaken(obj: ref<GameObject>, itemID: ItemID, slotID: TweakDBID) -> Bool {
    let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(obj.GetGame());
    let itemData: wref<gameItemData> = ts.GetItemData(obj, itemID);
    return itemData.HasPartInSlot(slotID);
  }

  public final static func GetAllSlots(obj: ref<GameObject>, item: ItemID) -> array<SPartSlots> {
    let allParts: array<SPartSlots>;
    let emptySlots: array<TweakDBID>;
    let i: Int32;
    let installableItems: array<ItemID>;
    let itemData: ref<gameItemData>;
    let part: SPartSlots;
    let partData: InnerItemData;
    let usedSlots: array<TweakDBID>;
    let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(obj.GetGame());
    ts.GetEmptySlotsOnItem(obj, item, emptySlots);
    ts.GetUsedSlotsOnItem(obj, item, usedSlots);
    itemData = ts.GetItemData(obj, item);
    ts.GetItemsInstallableInSlot(obj, item, t"AttachmentSlots.FabricEnhancer2", installableItems);
    i = 0;
    while i < ArraySize(usedSlots) {
      itemData.GetItemPart(partData, usedSlots[i]);
      part.status = ESlotState.Taken;
      part.slotID = usedSlots[i];
      part.installedPart = InnerItemData.GetItemID(partData);
      part.innerItemData = partData;
      ArrayPush(allParts, part);
      i += 1;
    };
    i = 0;
    while i < ArraySize(emptySlots) {
      part.status = ESlotState.Empty;
      part.slotID = emptySlots[i];
      part.installedPart = ItemID.undefined();
      ArrayPush(allParts, part);
      i += 1;
    };
    return allParts;
  }

  public final static func GetAllSlots(itemData: ref<gameItemData>) -> array<SPartSlots> {
    let allParts: array<SPartSlots>;
    let attachments: array<wref<AttachmentSlot_Record>>;
    let i: Int32;
    let part: SPartSlots;
    let partData: InnerItemData;
    let partDatas: array<InnerItemData>;
    let usedSlots: array<wref<SlotItemPartPreset_Record>>;
    RPGManager.GetItemRecord(itemData.GetID()).SlotPartListPreset(usedSlots);
    ItemModificationSystem.GetattachementFromBlueprint(RPGManager.GetItemRecord(itemData.GetID()).Blueprint().RootElement(), attachments);
    itemData.GetItemParts(partDatas);
    i = 0;
    while i < ArraySize(usedSlots) {
      itemData.GetItemPart(partData, usedSlots[i].Slot().GetID());
      part.status = ESlotState.Taken;
      part.slotID = usedSlots[i].Slot().GetID();
      part.installedPart = ItemID.FromTDBID(usedSlots[i].ItemPartPreset().GetID());
      part.innerItemData = partData;
      ArrayPush(allParts, part);
      i += 1;
    };
    i = 0;
    while i < ArraySize(attachments) {
      part.status = ESlotState.Empty;
      part.slotID = attachments[i].GetID();
      part.installedPart = ItemID.undefined();
      ArrayPush(allParts, part);
      i += 1;
    };
    return allParts;
  }

  private final static func GetattachementFromBlueprint(blueprintRecord: wref<ItemBlueprintElement_Record>, out attachments: array<wref<AttachmentSlot_Record>>) -> Void {
    let childElements: array<wref<ItemBlueprintElement_Record>>;
    let i: Int32;
    ArrayPush(attachments, blueprintRecord.Slot());
    blueprintRecord.ChildElements(childElements);
    i = 0;
    while i < ArraySize(childElements) {
      ItemModificationSystem.GetattachementFromBlueprint(childElements[i], attachments);
      i += 1;
    };
  }

  public final static func HasBetterShardInstalled(obj: ref<GameObject>, cyberdeckID: ItemID, shardID: ItemID) -> Bool {
    let deckData: ref<gameItemData>;
    let i: Int32;
    let instQuality: gamedataQuality;
    let partData: InnerItemData;
    let shardQuality: gamedataQuality;
    let shardType: CName;
    let usedSlots: array<TweakDBID>;
    let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(obj.GetGame());
    ts.GetUsedSlotsOnItem(obj, cyberdeckID, usedSlots);
    deckData = ts.GetItemData(obj, cyberdeckID);
    shardType = TweakDBInterface.GetCName(ItemID.GetTDBID(shardID) + t".shardType", n"");
    if NotEquals(shardType, n"") {
      i = 0;
      while i < ArraySize(usedSlots) {
        deckData.GetItemPart(partData, usedSlots[i]);
        instQuality = RPGManager.GetItemRecord(InnerItemData.GetItemID(partData)).Quality().Type();
        shardQuality = RPGManager.GetItemRecord(shardID).Quality().Type();
        if Equals(TweakDBInterface.GetCName(ItemID.GetTDBID(InnerItemData.GetItemID(partData)) + t".shardType", n""), shardType) && shardQuality <= instQuality {
          return true;
        };
        i += 1;
      };
    };
    return false;
  }

  private final func SendCallback() -> Void {
    this.m_blackboard.SetVariant(GetAllBlackboardDefs().UI_ItemModSystem.ItemModSystemUpdated, ToVariant(true));
    this.m_blackboard.SignalVariant(GetAllBlackboardDefs().UI_ItemModSystem.ItemModSystemUpdated);
  }

  private final func OnInstallItemPart(request: ref<InstallItemPart>) -> Void {
    this.InstallItemPart(request.obj, request.baseItem, request.partToInstall, request.slotID);
    this.SendCallback();
  }

  private final func OnRemoveItemPart(request: ref<RemoveItemPart>) -> Void {
    this.RemoveItemPart(request.obj, request.baseItem, request.slotToEmpty, true);
    this.SendCallback();
  }

  private final func OnSwapItemPart(request: ref<SwapItemPart>) -> Void {
    this.SwapItemPart(request.obj, request.baseItem, request.partToInstall, request.slotID);
    this.SendCallback();
  }
}
