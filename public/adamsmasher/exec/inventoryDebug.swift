
public static exec func EquipItem(inst: GameInstance, itemTDBIDStr: String) -> Void {
  let equipRequest: ref<GameplayEquipRequest>;
  let equipSys: ref<EquipmentSystem>;
  let placementSlots: array<wref<AttachmentSlot_Record>>;
  let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(inst).GetLocalPlayerControlledGameObject() as PlayerPuppet;
  let itemTDBID: TweakDBID = TDBID.Create(itemTDBIDStr);
  let itemID: ItemID = ItemID.FromTDBID(itemTDBID);
  TweakDBInterface.GetItemRecord(itemTDBID).PlacementSlots(placementSlots);
  equipRequest = new GameplayEquipRequest();
  equipRequest.itemID = itemID;
  equipRequest.owner = player;
  equipRequest.addToInventory = true;
  equipRequest.blockUpdateWeaponActiveSlots = true;
  equipSys = GameInstance.GetScriptableSystemsContainer(inst).Get(n"EquipmentSystem") as EquipmentSystem;
  equipSys.QueueRequest(equipRequest);
}

public static exec func EquipItemToHand(inst: GameInstance, itemTDBIDStr: String) -> Void {
  let drawItemRequest: ref<DrawItemRequest>;
  let equipRequest: ref<EquipRequest>;
  let equipSys: ref<EquipmentSystem>;
  let placementSlots: array<wref<AttachmentSlot_Record>>;
  let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(inst).GetLocalPlayerControlledGameObject() as PlayerPuppet;
  let itemTDBID: TweakDBID = TDBID.Create(itemTDBIDStr);
  let itemID: ItemID = ItemID.FromTDBID(itemTDBID);
  TweakDBInterface.GetItemRecord(itemTDBID).PlacementSlots(placementSlots);
  equipRequest = new EquipRequest();
  equipRequest.itemID = itemID;
  equipRequest.owner = player;
  equipRequest.addToInventory = true;
  equipSys = GameInstance.GetScriptableSystemsContainer(inst).Get(n"EquipmentSystem") as EquipmentSystem;
  equipSys.QueueRequest(equipRequest);
  drawItemRequest = new DrawItemRequest();
  drawItemRequest.owner = player;
  drawItemRequest.itemID = itemID;
  equipSys.QueueRequest(drawItemRequest);
}

public static exec func InstallProgram(inst: GameInstance, part: String, slot: String) -> Void {
  let itemModSys: ref<ItemModificationSystem> = GameInstance.GetScriptableSystemsContainer(inst).Get(n"ItemModificationSystem") as ItemModificationSystem;
  let installRequest: ref<SwapItemPart> = new SwapItemPart();
  let player: wref<GameObject> = GameInstance.GetPlayerSystem(inst).GetLocalPlayerMainGameObject();
  installRequest.obj = player;
  installRequest.baseItem = EquipmentSystem.GetData(player).GetActiveItem(gamedataEquipmentArea.SystemReplacementCW);
  installRequest.slotID = TDBID.Create(slot);
  let partID: ItemID = ItemID.FromTDBID(TDBID.Create(part));
  installRequest.partToInstall = partID;
  GameInstance.GetTransactionSystem(inst).GiveItem(player, partID, 1);
  itemModSys.QueueRequest(installRequest);
}

public static exec func GetItemInSlot(inst: GameInstance, slotString: String) -> Void {
  let slotID: TweakDBID = TDBID.Create(slotString);
  let item: ref<ItemObject> = GameInstance.GetTransactionSystem(inst).GetItemInSlot(GetPlayer(inst), slotID);
  Log(item.GetItemData().GetNameAsString());
}

public static exec func UnequipItem(inst: GameInstance, stringType: String, stringSlot: String) -> Void {
  let unequipRequest: ref<UnequipRequest> = new UnequipRequest();
  let areaType: gamedataEquipmentArea = IntEnum(Cast(EnumValueFromString("gamedataEquipmentArea", stringType)));
  unequipRequest.areaType = areaType;
  unequipRequest.slotIndex = StringToInt(stringSlot);
  unequipRequest.owner = GetPlayer(inst);
  GameInstance.GetScriptableSystemsContainer(inst).Get(n"EquipmentSystem").QueueRequest(unequipRequest);
}

public static exec func ClearEquipment(inst: GameInstance) -> Void {
  let clearRequest: ref<ClearEquipmentRequest> = new ClearEquipmentRequest();
  clearRequest.owner = GetPlayer(inst);
  GameInstance.GetScriptableSystemsContainer(inst).Get(n"EquipmentSystem").QueueRequest(clearRequest);
}

public static exec func SaveWeaponSet(inst: GameInstance, setName: String) -> Void {
  let saveSetRequest: ref<SaveEquipmentSetRequest> = new SaveEquipmentSetRequest();
  saveSetRequest.owner = GetPlayer(inst);
  saveSetRequest.setName = setName;
  saveSetRequest.setType = EEquipmentSetType.Offensive;
  GameInstance.GetScriptableSystemsContainer(inst).Get(n"EquipmentSystem").QueueRequest(saveSetRequest);
}

public static exec func SaveArmorSet(inst: GameInstance, setName: String) -> Void {
  let saveSetRequest: ref<SaveEquipmentSetRequest> = new SaveEquipmentSetRequest();
  saveSetRequest.owner = GetPlayer(inst);
  saveSetRequest.setName = setName;
  saveSetRequest.setType = EEquipmentSetType.Defensive;
  GameInstance.GetScriptableSystemsContainer(inst).Get(n"EquipmentSystem").QueueRequest(saveSetRequest);
}

public static exec func LoadEquipmentSet(inst: GameInstance, setName: String) -> Void {
  let loadSetRequest: ref<LoadEquipmentSetRequest> = new LoadEquipmentSetRequest();
  loadSetRequest.owner = GetPlayer(inst);
  loadSetRequest.setName = setName;
  GameInstance.GetScriptableSystemsContainer(inst).Get(n"EquipmentSystem").QueueRequest(loadSetRequest);
}

public static exec func DeleteEquipmentSet(inst: GameInstance, setName: String) -> Void {
  let deleteSetRequest: ref<DeleteEquipmentSetRequest> = new DeleteEquipmentSetRequest();
  deleteSetRequest.owner = GetPlayer(inst);
  deleteSetRequest.setName = setName;
  GameInstance.GetScriptableSystemsContainer(inst).Get(n"EquipmentSystem").QueueRequest(deleteSetRequest);
}

public static exec func PrintEquipment(inst: GameInstance) -> Void {
  let equipmentSystem: ref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(inst).Get(n"EquipmentSystem") as EquipmentSystem;
  equipmentSystem.PrintEquipment();
}

public static exec func AddToInventory(inst: GameInstance, itemString: String, opt quantityString: String) -> Void {
  let equipmentUIBBRequest: ref<EquipmentUIBBRequest>;
  let itemID: ItemID;
  let quantity: Int32 = StringToInt(quantityString);
  if quantity <= 0 {
    quantity = 1;
  };
  itemID = ItemID.FromTDBID(TDBID.Create(itemString));
  GameInstance.GetTransactionSystem(inst).GiveItem(GetPlayer(inst), itemID, quantity);
  equipmentUIBBRequest = new EquipmentUIBBRequest();
  equipmentUIBBRequest.owner = GetPlayer(inst);
  GameInstance.GetScriptableSystemsContainer(inst).Get(n"EquipmentSystem").QueueRequest(equipmentUIBBRequest);
}

public static exec func AddItems(inst: GameInstance, type: String, opt amount: String) -> Void {
  let itemID: ItemID;
  let quantity: Int32 = StringToInt(amount, 1);
  let tweakPath: TweakDBID = TDBID.Create("Debug." + type + ".items");
  let itemsArray: array<String> = TDB.GetStringArray(tweakPath);
  let i: Int32 = 0;
  while i <= ArraySize(itemsArray) {
    itemID = ItemID.FromTDBID(TDBID.Create(itemsArray[i]));
    GameInstance.GetTransactionSystem(inst).GiveItem(GetPlayer(inst), itemID, quantity);
    i += 1;
  };
}

public static exec func AddRecord(inst: GameInstance, tweak: String) -> Void {
  let codexSystem: ref<CodexSystem> = GameInstance.GetScriptableSystemsContainer(inst).Get(n"CodexSystem") as CodexSystem;
  let addRecordRequest: ref<CodexAddRecordRequest> = new CodexAddRecordRequest();
  addRecordRequest.codexRecordID = TDBID.Create(tweak);
  codexSystem.QueueRequest(addRecordRequest);
}

public static exec func UnlockRecord(inst: GameInstance, tweak: String) -> Void {
  let codexSystem: ref<CodexSystem> = GameInstance.GetScriptableSystemsContainer(inst).Get(n"CodexSystem") as CodexSystem;
  let unlockRecordRequest: ref<CodexUnlockRecordRequest> = new CodexUnlockRecordRequest();
  unlockRecordRequest.codexRecordID = TDBID.Create(tweak);
  codexSystem.QueueRequest(unlockRecordRequest);
}

public static exec func PrintCodex(inst: GameInstance) -> Void {
  let codexSystem: ref<CodexSystem> = GameInstance.GetScriptableSystemsContainer(inst).Get(n"CodexSystem") as CodexSystem;
  let codexPrintRecordsRequest: ref<CodexPrintRecordsRequest> = new CodexPrintRecordsRequest();
  codexSystem.QueueRequest(codexPrintRecordsRequest);
}

public static exec func SM(gi: GameInstance) -> Void {
  let crack: ref<CrackAction> = new CrackAction();
  crack.CompleteAction(gi);
}
