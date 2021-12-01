
public static exec func GiveItem(gi: GameInstance, itemName: String, opt amountStr: String) -> Void {
  let transSys: ref<TransactionSystem> = GameInstance.GetTransactionSystem(gi);
  let amount: Int32 = StringToInt(amountStr);
  if amount == 0 {
    amount = 1;
  };
  transSys.GiveItem(GetPlayer(gi), ItemID.FromTDBID(TDBID.Create(itemName)), amount);
}

public static exec func PrintItems(gi: GameInstance) -> Void {
  let i: Int32;
  let itemID: ItemID;
  let itemList: array<wref<gameItemData>>;
  let quantity: Int32;
  let str: String;
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  let trans: ref<TransactionSystem> = GameInstance.GetTransactionSystem(gi);
  trans.GetItemList(player, itemList);
  LogItems("");
  LogItems("--== Printing inventory contents of player:");
  i = 0;
  while i < ArraySize(itemList) {
    itemID = itemList[i].GetID();
    quantity = trans.GetItemQuantity(player, itemID);
    str = SpaceFill(IntToString(quantity), 6, ESpaceFillMode.JustifyRight) + "x " + TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID));
    LogItems(str);
    i += 1;
  };
  LogItems("--== End of inventory contents of player");
}

public static exec func PrintStatsItem(gi: GameInstance, itemName: String) -> Void {
  let i: Int32;
  let objectID: StatsObjectID;
  let stats: ref<StatsSystem>;
  let valF: Float;
  let itemTDBID: TweakDBID = TDBID.Create("Items." + itemName);
  let itemID: ItemID = ItemID.CreateQuery(itemTDBID);
  let transSys: ref<TransactionSystem> = GameInstance.GetTransactionSystem(gi);
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  let object: ref<GameObject> = transSys.GetItemInSlotByItemID(player, itemID);
  LogStats("");
  if !IsDefined(object) {
    LogStats("exec PrintStatsItem(): cannot find item object with specified ID \'" + Cast(TDBID.ToNumber(itemTDBID)) + "\'");
    return;
  };
  objectID = Cast(object.GetEntityID());
  stats = GameInstance.GetStatsSystem(gi);
  LogStats("---- stats of item \'" + Cast(TDBID.ToNumber(itemTDBID)) + "\' ----");
  i = 0;
  while i <= Cast(EnumGetMax(n"gamedataStatType")) {
    valF = stats.GetStatValue(objectID, IntEnum(i));
    if !FloatIsEqual(valF, 0.00) {
      LogStats(EnumValueToString("gamedataStatType", Cast(i)) + ": " + NoTrailZeros(valF));
    };
    i += 1;
  };
  LogStats("---- end of stats of item \'" + Cast(TDBID.ToNumber(itemTDBID)) + "\' ----");
}

public static exec func EquipItemOnPlayer(gi: GameInstance, item: String, slot: String) -> Void {
  GameInstance.GetTransactionSystem(gi).AddItemToSlot(GetPlayer(gi), TDBID.Create("AttachmentSlots." + slot), ItemID.FromTDBID(TDBID.Create(item)));
}

public static func PrintItemInSlot(gi: GameInstance, object: ref<GameObject>, slot: TweakDBID) -> Void {
  let slotName: String = TweakDBInterface.GetAttachmentSlotRecord(slot).EntitySlotName();
  let itemObj: ref<ItemObject> = GameInstance.GetTransactionSystem(gi).GetItemInSlot(object as PlayerPuppet, slot);
  if !IsDefined(itemObj) {
    LogItems("Item in slot: " + slotName + " NULL ");
    return;
  };
  LogItems("Item in slot: " + slotName + " : " + TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemObj.GetItemID())).FriendlyName());
}

public static exec func PrintItemsInSlots(gi: GameInstance) -> Void {
  let i: Int32;
  let slots: array<wref<AttachmentSlot_Record>>;
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  TweakDBInterface.GetCharacterRecord(player.GetRecordID()).AttachmentSlots(slots);
  i = 0;
  while i < ArraySize(slots) {
    PrintItemInSlot(gi, player, slots[i].GetID());
    i += 1;
  };
}

public static exec func PrintNPCItems(gi: GameInstance) -> Void {
  let i: Int32;
  let itemName: String;
  let items: array<wref<gameItemData>>;
  let target: ref<GameObject> = GameInstance.GetTargetingSystem(gi).GetLookAtObject(GetPlayer(gi));
  if !IsDefined(target) {
    Log("PrintNPCItems(): No valid target found!");
    return;
  };
  GameInstance.GetTransactionSystem(gi).GetItemList(target, items);
  i = 0;
  while i < ArraySize(items) {
    itemName = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(items[i].GetID())).FriendlyName();
    LogItems("Item name: " + itemName + ", Quantity: " + IntToString(items[i].GetQuantity()));
    i += 1;
  };
}

public static exec func SwapItemPart(gi: GameInstance) -> Void {
  let req: ref<SwapItemPart>;
  let weaponID: ItemID;
  let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(gi);
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  let partID: ItemID = ItemID.FromTDBID(t"Items.w_rifle_assault__nokota_copperhead__mag_std_maelstrom");
  ts.GiveItem(player, partID, 1);
  weaponID = ItemID.CreateQuery(t"Items.Base_Copperhead");
  req = new SwapItemPart();
  req.obj = player;
  req.baseItem = weaponID;
  req.partToInstall = partID;
  req.slotID = t"AttachmentSlots.Magazine";
  GameInstance.GetScriptableSystemsContainer(gi).Get(n"ItemModificationSystem").QueueRequest(req);
}

public static exec func ToggleFlashlight(gi: GameInstance, val: String) -> Void {
  let evt: ref<TogglePlayerFlashlightEvent> = new TogglePlayerFlashlightEvent();
  evt.enable = StringToBool(val);
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  player.QueueEvent(evt);
}

public static exec func Rev(gi: GameInstance) -> Void {
  let equipRequest: ref<EquipRequest>;
  let id: ItemID;
  let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(gi);
  let pl: ref<PlayerPuppet> = GetPlayer(gi);
  let equipSys: ref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(gi).Get(n"EquipmentSystem") as EquipmentSystem;
  ts.GiveItemByTDBID(pl, t"Items.Preset_Saratoga_Default", 1);
  ts.GiveItemByTDBID(pl, t"Items.Preset_Sidewinder_Default", 1);
  ts.GiveItemByTDBID(pl, t"Items.Preset_Zhuo_Default", 1);
  ts.GiveItemByTDBID(pl, t"Items.Preset_Ashura_Default", 1);
  ts.GiveItemByTDBID(pl, t"Items.Preset_Copperhead_Military1", 1);
  ts.GiveItemByTDBID(pl, t"Items.Preset_Burya_Default", 1);
  ts.GiveItemByTDBID(pl, t"Items.SuicideProgram", 1);
  ts.GiveItemByTDBID(pl, t"Items.MadnessProgram", 1);
  ts.GiveItemByTDBID(pl, t"Items.MalfunctionProgram", 1);
  ts.GiveItemByTDBID(pl, t"Items.TakeControlProgram", 1);
  ts.GiveItemByTDBID(pl, t"Items.SystemCollapseProgram", 1);
  ts.GiveItemByTDBID(pl, t"Items.CommsCallProgram", 1);
  ts.GiveItemByTDBID(pl, t"Items.w_att_scope_short_01", 1);
  ts.GiveItemByTDBID(pl, t"Items.w_att_scope_short_02", 1);
  ts.GiveItemByTDBID(pl, t"Items.w_att_scope_short_03", 1);
  ts.GiveItemByTDBID(pl, t"Items.w_att_scope_long_01", 1);
  ts.GiveItemByTDBID(pl, t"Items.w_att_scope_long_02", 1);
  ts.GiveItemByTDBID(pl, t"Items.w_att_scope_long_03", 1);
  ts.GiveItemByTDBID(pl, t"Items.w_silencer_01", 1);
  ts.GiveItemByTDBID(pl, t"Items.GrenadeFragRegular", 3);
  ts.GiveItemByTDBID(pl, t"Items.GrenadeFlashRegularV0", 3);
  ts.GiveItemByTDBID(pl, t"Items.GrenadeSonicBubbleSticky", 3);
  ts.GiveItemByTDBID(pl, t"Items.FirstAidWhiff", 3);
  id = ItemID.FromTDBID(t"Items.MilitechParaline");
  ts.GiveItem(pl, id, 1);
  equipRequest = new EquipRequest();
  equipRequest.itemID = id;
  equipRequest.owner = pl;
  equipSys.QueueRequest(equipRequest);
  id = ItemID.FromTDBID(t"Items.OpticalCamo");
  ts.GiveItem(pl, id, 1);
  equipRequest = new EquipRequest();
  equipRequest.itemID = id;
  equipRequest.owner = pl;
  equipSys.QueueRequest(equipRequest);
  id = ItemID.FromTDBID(t"Items.SmartLink");
  ts.GiveItem(pl, id, 1);
  equipRequest = new EquipRequest();
  equipRequest.itemID = id;
  equipRequest.owner = pl;
  equipSys.QueueRequest(equipRequest);
  id = ItemID.FromTDBID(t"Items.BoostedTendons");
  ts.GiveItem(pl, id, 1);
  equipRequest = new EquipRequest();
  equipRequest.itemID = id;
  equipRequest.owner = pl;
  equipSys.QueueRequest(equipRequest);
}
