
public class PaperDollSlotController extends inkButtonDpadSupportedController {

  protected let m_equipArea: gamedataEquipmentArea;

  protected let m_slotIndex: Int32;

  protected let m_areaTags: array<CName>;

  protected let m_itemID: ItemID;

  protected let m_slotName: String;

  protected let m_itemData: ref<gameItemData>;

  protected let m_locked: Bool;

  protected cb func OnInitialize() -> Bool {
    this.m_locked = false;
    super.OnInitialize();
  }

  public final func SetButtonDetails(argText: String, equipArea: gamedataEquipmentArea, slotIndex: Int32, areaTags: array<CName>) -> Void {
    let currListIcon: wref<inkImage>;
    this.m_rootWidget = this.GetRootWidget() as inkCanvas;
    this.m_areaTags = areaTags;
    this.m_equipArea = equipArea;
    this.m_slotIndex = slotIndex;
    let currListText: wref<inkText> = this.m_rootWidget.GetWidget(n"textLabel") as inkText;
    currListText.SetText(argText);
    this.m_slotName = argText;
    currListIcon = this.m_rootWidget.GetWidget(n"icon") as inkImage;
    currListIcon.SetVisible(false);
  }

  public final func SetItemInSlot(itemID: ItemID) -> Void {
    let color: CName;
    let currListIcon: wref<inkImage>;
    this.m_itemID = itemID;
    let currListText: wref<inkText> = this.m_rootWidget.GetWidget(n"itemName") as inkText;
    let qualityBg: wref<inkRectangle> = this.m_rootWidget.GetWidget(n"quality") as inkRectangle;
    let itemName: CName = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID)).DisplayName();
    let itemNameString: String = NameToString(itemName);
    currListText.SetText(itemNameString);
    color = StringToName(TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID)).Quality().Name());
    currListText.SetState(color);
    if NotEquals(color, n"Poor") && NotEquals(color, n"Common") {
      qualityBg.SetState(color);
      qualityBg.SetVisible(true);
    } else {
      qualityBg.SetVisible(false);
    };
    currListIcon = this.m_rootWidget.GetWidget(n"icon") as inkImage;
    if NotEquals(itemName, n"") {
      if currListIcon.IsTexturePartExist(itemName) {
        currListIcon.SetTexturePart(itemName);
        currListIcon.SetVisible(true);
      } else {
        currListIcon.SetTexturePart(n"none");
        currListIcon.SetVisible(true);
      };
    } else {
      currListIcon.SetTexturePart(n"none");
      currListText.SetText("");
      currListIcon.SetVisible(false);
    };
  }

  public final func SetSlotLocked(slotTweak: TweakDBID) -> Void {
    let currListIcon: wref<inkImage>;
    let currListText: wref<inkText>;
    let skillLevel: Int32;
    let skillName: String;
    let tweakID: TweakDBID = slotTweak;
    TDBID.Append(tweakID, t".skillName");
    skillName = TweakDBInterface.GetString(tweakID, "");
    tweakID = slotTweak;
    TDBID.Append(tweakID, t".skillLevel");
    skillLevel = TDB.GetInt(tweakID);
    currListText = this.m_rootWidget.GetWidget(n"itemName") as inkText;
    currListText.SetText("[LOCKED]\\n[" + skillName + "] : [" + ToString(skillLevel) + "]");
    currListIcon = this.m_rootWidget.GetWidget(n"icon") as inkImage;
    currListIcon.SetTexturePart(n"none");
    currListIcon.SetVisible(true);
    this.m_locked = true;
  }

  public final func IsLocked() -> Bool {
    return this.m_locked;
  }

  public final func GetItem() -> ItemID {
    return this.m_itemID;
  }

  public final func GetItemData() -> ref<gameItemData> {
    return this.m_itemData;
  }

  public final func GetAreaTags() -> array<CName> {
    return this.m_areaTags;
  }

  public final func GetEquipArea() -> gamedataEquipmentArea {
    return this.m_equipArea;
  }

  public final func GetSlotIndex() -> Int32 {
    return this.m_slotIndex;
  }

  public final func GetSlotName() -> String {
    return this.m_slotName;
  }
}

public class ArmorEquipInventoryItemController extends inkButtonDpadSupportedController {

  protected let m_itemID: ItemID;

  protected let m_itemData: ref<gameItemData>;

  protected let m_empty: Bool;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
  }

  public final func ClearButton() -> Void {
    this.m_rootWidget = this.GetRootWidget() as inkCanvas;
    let displayName: wref<inkText> = this.m_rootWidget.GetWidget(n"textLabel") as inkText;
    let quality: wref<inkText> = this.m_rootWidget.GetWidget(n"rarityLabel") as inkText;
    let statValue: wref<inkText> = this.m_rootWidget.GetWidget(n"summaryLabel") as inkText;
    let statName: wref<inkText> = this.m_rootWidget.GetWidget(n"summarySubText") as inkText;
    let quantity: wref<inkText> = this.m_rootWidget.GetWidget(n"txtQuantity") as inkText;
    let currListIcon: wref<inkImage> = this.m_rootWidget.GetWidget(n"icon") as inkImage;
    let qualityBg: wref<inkRectangle> = this.m_rootWidget.GetWidget(n"quality") as inkRectangle;
    qualityBg.SetVisible(false);
    displayName.SetText("");
    quality.SetText("");
    statValue.SetText("");
    statName.SetText("");
    quantity.SetText("");
    currListIcon.SetTexturePart(n"none");
    currListIcon.SetVisible(false);
    this.m_empty = true;
  }

  public final func SetButtonDetails(itemData: ref<gameItemData>, itemQuantity: Int32, disassemblable: Bool) -> Void {
    let color: CName;
    let diss: String;
    this.m_rootWidget = this.GetRootWidget() as inkCanvas;
    let displayName: wref<inkText> = this.m_rootWidget.GetWidget(n"textLabel") as inkText;
    let quality: wref<inkText> = this.m_rootWidget.GetWidget(n"rarityLabel") as inkText;
    let statValue: wref<inkText> = this.m_rootWidget.GetWidget(n"summaryLabel") as inkText;
    let statName: wref<inkText> = this.m_rootWidget.GetWidget(n"summarySubText") as inkText;
    let currListIcon: wref<inkImage> = this.m_rootWidget.GetWidget(n"icon") as inkImage;
    let quantity: wref<inkText> = this.m_rootWidget.GetWidget(n"txtQuantity") as inkText;
    let qualityBg: wref<inkRectangle> = this.m_rootWidget.GetWidget(n"quality") as inkRectangle;
    this.m_itemData = itemData;
    this.m_itemID = itemData.GetID();
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(this.m_itemID));
    let itemName: CName = itemRecord.DisplayName();
    let itemNameString: String = NameToString(itemName);
    if disassemblable {
      diss = " [D]";
    } else {
      diss = "";
    };
    displayName.SetText(itemNameString + diss);
    quality.SetText(itemRecord.Quality().Name());
    statValue.SetText("");
    statName.SetText("");
    if itemQuantity > 1 {
      quantity.SetText(IntToString(itemQuantity));
    } else {
      quantity.SetText("");
    };
    itemName = itemRecord.DisplayName();
    currListIcon.SetVisible(false);
    this.m_empty = false;
    color = StringToName(itemRecord.Quality().Name());
    displayName.SetState(color);
    quality.SetState(color);
    quantity.SetState(color);
    if NotEquals(color, n"Poor") && NotEquals(color, n"Common") {
      qualityBg.SetState(color);
      qualityBg.SetVisible(true);
    };
    if currListIcon.IsTexturePartExist(itemName) {
      currListIcon.SetTexturePart(itemName);
      currListIcon.SetVisible(true);
    } else {
      currListIcon.SetTexturePart(n"none");
      currListIcon.SetVisible(true);
    };
    if Equals(itemName, n"") {
      currListIcon.SetTexturePart(n"undefined");
      quality.SetText("!Undefined item");
      displayName.SetText("!No name defined");
      currListIcon.SetVisible(true);
    };
  }

  public final func GetItemData() -> ref<gameItemData> {
    return this.m_itemData;
  }

  public final func GetItemID() -> ItemID {
    return this.m_itemID;
  }

  public final func GetIsEmpty() -> Bool {
    return this.m_empty;
  }
}

public class ArmorEquipGameController extends gameuiMenuGameController {

  protected let m_inventoryCanvas: wref<inkWidget>;

  protected let m_inventoryList: wref<inkVerticalPanel>;

  protected let m_inventory: array<wref<gameItemData>>;

  protected let player: wref<PlayerPuppet>;

  protected let m_equipmentSystem: wref<EquipmentSystem>;

  protected let m_subCharacterSystem: wref<SubCharacterSystem>;

  protected let m_transactionSystem: wref<TransactionSystem>;

  protected let m_craftingSystem: wref<CraftingSystem>;

  protected let buttonScrollUp: wref<inkCanvas>;

  protected let buttonScrollDn: wref<inkCanvas>;

  protected let buttonPlayer: wref<inkCanvas>;

  protected let buttonFlathead: wref<inkCanvas>;

  protected let buttonToolbox: wref<inkCanvas>;

  protected let panelPlayer: wref<inkCanvas>;

  protected let panelFlathead: wref<inkCanvas>;

  protected let panelToolbox: wref<inkCanvas>;

  protected let m_uiBB_Equipment: ref<UI_EquipmentDef>;

  protected let m_uiBB_EquipmentBlackboard: wref<IBlackboard>;

  protected let m_backgroundVideo: wref<inkVideo>;

  protected let m_paperdollVideo: wref<inkVideo>;

  protected let m_areaTags: array<CName>;

  protected let m_inventoryManager: ref<InventoryDataManager>;

  protected let m_equipArea: gamedataEquipmentArea;

  protected let m_slotIndex: Int32;

  protected let m_recipeItemList: array<TweakDBID>;

  protected let m_playerCraftBook: ref<CraftBook>;

  @default(ArmorEquipGameController, base/gameplay/gui/common/tooltip/tooltipslibrary.inkwidget)
  protected edit let m_tooltipsLibrary: ResRef;

  @default(ArmorEquipGameController, itemTooltip)
  protected edit let m_itemTooltipName: CName;

  @default(ArmorEquipGameController, base/gameplay/gui/common/tooltip/tooltip_menu.inkstyle)
  protected edit let m_tooltipStylePath: ResRef;

  protected let m_tooltipLeft: wref<InventorySlotTooltip>;

  protected let m_tooltipRight: wref<InventorySlotTooltip>;

  protected let m_tooltipContainer: wref<inkCompoundWidget>;

  protected let m_paperDollList: array<CName>;

  protected let scrollOffset: Int32;

  protected let faceTags: array<CName>;

  protected let headTags: array<CName>;

  protected let chestTags: array<CName>;

  protected let legTags: array<CName>;

  protected let weaponTags: array<CName>;

  protected let consumableTags: array<CName>;

  protected let modulesTags: array<CName>;

  protected let framesTags: array<CName>;

  protected let m_operationsMode: operationsMode;

  protected cb func OnInitialize() -> Bool {
    let currButton: wref<inkCanvas>;
    let currWidget: wref<inkWidget>;
    this.m_equipArea = gamedataEquipmentArea.Invalid;
    this.m_operationsMode = operationsMode.PLAYER;
    this.m_inventoryList = this.GetWidget(n"InventoryCanvas/vertInventoryList") as inkVerticalPanel;
    this.m_inventoryCanvas = this.GetWidget(n"InventoryCanvas");
    this.panelPlayer = this.GetWidget(n"playerPuppet") as inkCanvas;
    this.panelFlathead = this.GetWidget(n"flatheadPuppet") as inkCanvas;
    this.panelToolbox = this.GetWidget(n"toolboxPuppet") as inkCanvas;
    this.panelPlayer.SetVisible(true);
    this.panelFlathead.SetVisible(false);
    this.panelToolbox.SetVisible(false);
    this.m_tooltipContainer = this.GetWidget(n"tooltipContainer") as inkCompoundWidget;
    this.m_paperdollVideo = this.GetWidget(n"playerPuppet/paperdollVideo") as inkVideo;
    this.m_backgroundVideo = this.GetWidget(n"backgroundVideo") as inkVideo;
    this.m_paperdollVideo.SetVideoPath(r"base\\gameplay\\gui\\widgets\\menus\\inventory\\assets\\v_weapon.bk2");
    this.m_paperdollVideo.Play();
    this.player = this.GetOwnerEntity() as PlayerPuppet;
    this.m_inventoryManager = new InventoryDataManager();
    this.m_inventoryManager.Initialize(this.player);
    this.m_uiBB_Equipment = GetAllBlackboardDefs().UI_Equipment;
    this.m_uiBB_EquipmentBlackboard = this.GetBlackboardSystem().Get(this.m_uiBB_Equipment);
    GameInstance.GetTransactionSystem(this.player.GetGame()).GetItemList(this.player, this.m_inventory);
    this.m_equipmentSystem = GameInstance.GetScriptableSystemsContainer(this.player.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    this.m_subCharacterSystem = GameInstance.GetScriptableSystemsContainer(this.player.GetGame()).Get(n"SubCharacterSystem") as SubCharacterSystem;
    this.m_transactionSystem = GameInstance.GetTransactionSystem(this.player.GetGame());
    this.m_craftingSystem = GameInstance.GetScriptableSystemsContainer(this.player.GetGame()).Get(n"CraftingSystem") as CraftingSystem;
    this.m_playerCraftBook = this.m_craftingSystem.GetPlayerCraftBook();
    ArrayPush(this.faceTags, n"FaceArmor");
    ArrayPush(this.headTags, n"HeadArmor");
    ArrayPush(this.chestTags, n"ChestArmor");
    ArrayPush(this.legTags, n"LegArmor");
    ArrayPush(this.weaponTags, n"Weapon");
    ArrayPush(this.weaponTags, WeaponObject.GetMeleeWeaponTag());
    ArrayPush(this.consumableTags, n"Drug");
    ArrayPush(this.consumableTags, n"Gadget");
    ArrayPush(this.consumableTags, n"Grenade");
    ArrayPush(this.modulesTags, n"SpiderBotModule");
    ArrayPush(this.modulesTags, n"CombatCore");
    ArrayPush(this.modulesTags, n"TacticalCore");
    ArrayPush(this.framesTags, n"Frame");
    currButton = this.GetWidget(n"playerPuppet/slotHead") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/slotHead");
    this.HelperAddPaperdollButton("HEAD", currButton, gamedataEquipmentArea.Head, 0, this.headTags);
    currButton = this.GetWidget(n"playerPuppet/slotFace") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/slotFace");
    this.HelperAddPaperdollButton("FACE", currButton, gamedataEquipmentArea.Face, 0, this.faceTags);
    currButton = this.GetWidget(n"playerPuppet/slotShirt") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/slotShirt");
    this.HelperAddPaperdollButton("SHIRT", currButton, gamedataEquipmentArea.InnerChest, 0, this.chestTags);
    currButton = this.GetWidget(n"playerPuppet/slotJacket") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/slotJacket");
    this.HelperAddPaperdollButton("JACKET", currButton, gamedataEquipmentArea.OuterChest, 0, this.chestTags);
    currButton = this.GetWidget(n"playerPuppet/slotPants") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/slotPants");
    this.HelperAddPaperdollButton("PANTS", currButton, gamedataEquipmentArea.Legs, 0, this.legTags);
    currButton = this.GetWidget(n"playerPuppet/slotBoots") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/slotBoots");
    this.HelperAddPaperdollButton("BOOTS", currButton, gamedataEquipmentArea.Feet, 0, this.legTags);
    currButton = this.GetWidget(n"playerPuppet/slotArmUpgrade1_1") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/slotArmUpgrade1_1");
    this.HelperAddPaperdollButton("MANTIS BLADE UPGRADES", currButton, gamedataEquipmentArea.Invalid, 0, this.faceTags);
    currButton = this.GetWidget(n"playerPuppet/slotArmUpgrade1_2") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/slotArmUpgrade1_2");
    this.HelperAddPaperdollButton("", currButton, gamedataEquipmentArea.Invalid, 0, this.faceTags);
    currButton = this.GetWidget(n"playerPuppet/slotArmUpgrade2_1") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/slotArmUpgrade2_1");
    this.HelperAddPaperdollButton("PROJECTILE LAUNCHER UPGRADES", currButton, gamedataEquipmentArea.Invalid, 0, this.faceTags);
    currButton = this.GetWidget(n"playerPuppet/slotArmUpgrade2_2") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/slotArmUpgrade2_2");
    this.HelperAddPaperdollButton("", currButton, gamedataEquipmentArea.Invalid, 0, this.faceTags);
    currButton = this.GetWidget(n"playerPuppet/slotProgram1") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/slotProgram1");
    this.HelperAddPaperdollButton("CYBERDECK PROGRAMS", currButton, gamedataEquipmentArea.Invalid, 0, this.faceTags);
    currButton = this.GetWidget(n"playerPuppet/slotProgram2") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/slotProgram2");
    this.HelperAddPaperdollButton("", currButton, gamedataEquipmentArea.Invalid, 1, this.faceTags);
    currButton = this.GetWidget(n"playerPuppet/slotProgram3") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/slotProgram3");
    this.HelperAddPaperdollButton("", currButton, gamedataEquipmentArea.Invalid, 2, this.faceTags);
    currButton = this.GetWidget(n"playerPuppet/quickSlot1") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/quickSlot1");
    this.HelperAddPaperdollButton("QUICK SLOT 1", currButton, gamedataEquipmentArea.QuickSlot, 0, this.consumableTags);
    currButton = this.GetWidget(n"playerPuppet/quickSlot2") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/quickSlot2");
    this.HelperAddPaperdollButton("QUICK SLOT 2", currButton, gamedataEquipmentArea.QuickSlot, 1, this.consumableTags);
    currButton = this.GetWidget(n"playerPuppet/quickSlot3") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/quickSlot3");
    this.HelperAddPaperdollButton("QUICK SLOT 3", currButton, gamedataEquipmentArea.QuickSlot, 2, this.consumableTags);
    currButton = this.GetWidget(n"playerPuppet/quickSlot4") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/quickSlot4");
    this.HelperAddPaperdollButton("QUICK SLOT 4", currButton, gamedataEquipmentArea.QuickSlot, 3, this.consumableTags);
    currButton = this.GetWidget(n"playerPuppet/quickSlot5") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/quickSlot5");
    this.HelperAddPaperdollButton("QUICK SLOT 5", currButton, gamedataEquipmentArea.QuickSlot, 4, this.consumableTags);
    currButton = this.GetWidget(n"playerPuppet/slotWeapon1") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/slotWeapon1");
    this.HelperAddPaperdollButton("WEAPON SLOT 1", currButton, gamedataEquipmentArea.Weapon, 0, this.weaponTags);
    currButton = this.GetWidget(n"playerPuppet/slotWeapon2") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/slotWeapon2");
    this.HelperAddPaperdollButton("WEAPON SLOT 2", currButton, gamedataEquipmentArea.Weapon, 1, this.weaponTags);
    currButton = this.GetWidget(n"playerPuppet/slotWeapon3") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"playerPuppet/slotWeapon3");
    this.HelperAddPaperdollButton("WEAPON SLOT 3", currButton, gamedataEquipmentArea.Weapon, 2, this.weaponTags);
    currButton = this.GetWidget(n"flatheadPuppet/slotFlatheadModule1") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"flatheadPuppet/slotFlatheadModule1");
    this.HelperAddPaperdollButton("FLATHEAD EXPANSION MODULE", currButton, gamedataEquipmentArea.BotMainModule, 0, this.headTags);
    currButton = this.GetWidget(n"flatheadPuppet/slotFlatheadModule2") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"flatheadPuppet/slotFlatheadModule2");
    this.HelperAddPaperdollButton("CPU UPGRADES", currButton, gamedataEquipmentArea.BotCPU, 0, this.headTags);
    currButton = this.GetWidget(n"flatheadPuppet/slotFlatheadModule3") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"flatheadPuppet/slotFlatheadModule3");
    this.HelperAddPaperdollButton("", currButton, gamedataEquipmentArea.BotCPU, 1, this.headTags);
    currButton = this.GetWidget(n"flatheadPuppet/slotFlatheadModule4") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"flatheadPuppet/slotFlatheadModule4");
    this.HelperAddPaperdollButton("", currButton, gamedataEquipmentArea.BotCPU, 2, this.headTags);
    currButton = this.GetWidget(n"flatheadPuppet/slotFlatheadSoftware1") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"flatheadPuppet/slotFlatheadSoftware1");
    this.HelperAddPaperdollButton("", currButton, gamedataEquipmentArea.BotSoftware, 0, this.headTags);
    currButton = this.GetWidget(n"flatheadPuppet/slotFlatheadSoftware2") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"flatheadPuppet/slotFlatheadSoftware2");
    this.HelperAddPaperdollButton("", currButton, gamedataEquipmentArea.BotSoftware, 1, this.headTags);
    currButton = this.GetWidget(n"flatheadPuppet/slotFlatheadSoftware3") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"flatheadPuppet/slotFlatheadSoftware3");
    this.HelperAddPaperdollButton("", currButton, gamedataEquipmentArea.BotSoftware, 2, this.headTags);
    currButton = this.GetWidget(n"flatheadPuppet/slotFlatheadSoftware4") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"flatheadPuppet/slotFlatheadSoftware4");
    this.HelperAddPaperdollButton("", currButton, gamedataEquipmentArea.BotSoftware, 3, this.headTags);
    currButton = this.GetWidget(n"flatheadPuppet/slotFlatheadSoftware5") as inkCanvas;
    ArrayPush(this.m_paperDollList, n"flatheadPuppet/slotFlatheadSoftware5");
    this.HelperAddPaperdollButton("SOFTWARE", currButton, gamedataEquipmentArea.BotSoftware, 4, this.headTags);
    (this.GetWidget(n"toolboxPuppet/matCorrosive") as inkText).SetText(GameInstance.GetTransactionSystem(this.player.GetGame()).GetItemQuantity(this.player, ItemID.CreateQuery(t"Items.corrosive")) + "x Corrosive materials");
    (this.GetWidget(n"toolboxPuppet/matExplosive") as inkText).SetText(GameInstance.GetTransactionSystem(this.player.GetGame()).GetItemQuantity(this.player, ItemID.CreateQuery(t"Items.explosive")) + "x Explosive materials");
    (this.GetWidget(n"toolboxPuppet/matMedical") as inkText).SetText(GameInstance.GetTransactionSystem(this.player.GetGame()).GetItemQuantity(this.player, ItemID.CreateQuery(t"Items.medical")) + "x Medical ingridients");
    (this.GetWidget(n"toolboxPuppet/matMetaplastic") as inkText).SetText(GameInstance.GetTransactionSystem(this.player.GetGame()).GetItemQuantity(this.player, ItemID.CreateQuery(t"Items.metaplastic")) + "x Metaplastic");
    (this.GetWidget(n"toolboxPuppet/matCybertextile") as inkText).SetText(GameInstance.GetTransactionSystem(this.player.GetGame()).GetItemQuantity(this.player, ItemID.CreateQuery(t"Items.cybertextile")) + "x Cybertextile");
    (this.GetWidget(n"toolboxPuppet/matCarbon") as inkText).SetText(GameInstance.GetTransactionSystem(this.player.GetGame()).GetItemQuantity(this.player, ItemID.CreateQuery(t"Items.carbon")) + "x Carbon fibers");
    (this.GetWidget(n"toolboxPuppet/matDetector") as inkText).SetText(GameInstance.GetTransactionSystem(this.player.GetGame()).GetItemQuantity(this.player, ItemID.CreateQuery(t"Items.detector")) + "x Detectors");
    (this.GetWidget(n"toolboxPuppet/matTrigger") as inkText).SetText(GameInstance.GetTransactionSystem(this.player.GetGame()).GetItemQuantity(this.player, ItemID.CreateQuery(t"Items.trigger")) + "x Triggers");
    (this.GetWidget(n"toolboxPuppet/matScraps") as inkText).SetText(GameInstance.GetTransactionSystem(this.player.GetGame()).GetItemQuantity(this.player, ItemID.CreateQuery(t"Items.parts")) + "x Scraps");
    this.buttonScrollUp = this.GetWidget(n"scrollUp") as inkCanvas;
    this.buttonScrollUp.RegisterToCallback(n"OnRelease", this, n"OnScrollUp");
    this.buttonScrollDn = this.GetWidget(n"scrollDn") as inkCanvas;
    this.buttonScrollDn.RegisterToCallback(n"OnRelease", this, n"OnScrollDn");
    this.buttonScrollUp.SetVisible(false);
    this.buttonPlayer = this.GetWidget(n"btnPlayer") as inkCanvas;
    this.buttonPlayer.RegisterToCallback(n"OnRelease", this, n"OnSelectPlayer");
    this.buttonFlathead = this.GetWidget(n"btnFlathead") as inkCanvas;
    this.buttonFlathead.RegisterToCallback(n"OnRelease", this, n"OnSelectFlathead");
    this.buttonToolbox = this.GetWidget(n"btnToolbox") as inkCanvas;
    this.buttonToolbox.RegisterToCallback(n"OnRelease", this, n"OnSelectToolbox");
    if this.m_transactionSystem.HasItem(this.player, ItemID.FromTDBID(t"Items.toolBox")) {
      this.buttonToolbox.SetVisible(true);
    } else {
      this.buttonToolbox.SetVisible(false);
    };
    this.RefreshEquipment();
    this.RefreshInventoryList();
    this.CreateTooltip(this.m_tooltipLeft);
    this.CreateTooltip(this.m_tooltipRight);
    this.SetCursorOverWidget(currWidget);
  }

  protected final func CreateTooltip(out tooltipController: wref<InventorySlotTooltip>) -> Void {
    let tooltip: wref<inkWidget>;
    if Equals(ResRef.IsValid(this.m_tooltipsLibrary), false) {
      this.m_tooltipsLibrary = r"base\\gameplay\\gui\\common\\tooltip\\tooltipslibrary.inkwidget";
    };
    tooltip = this.SpawnFromExternal(this.m_tooltipContainer, this.m_tooltipsLibrary, this.m_itemTooltipName);
    tooltipController = tooltip.GetController() as InventorySlotTooltip;
    if Equals(ResRef.IsValid(this.m_tooltipStylePath), false) {
      this.m_tooltipStylePath = r"base\\gameplay\\gui\\common\\tooltip\\tooltip_menu.inkstyle";
    };
    tooltipController.SetStyle(this.m_tooltipStylePath);
    tooltipController.Hide();
  }

  protected final func HelperAddPaperdollButton(argTitle: String, containerSlot: ref<inkCanvas>, equipArea: gamedataEquipmentArea, slotIndex: Int32, areaTags: array<CName>) -> Void {
    let currLogic: wref<PaperDollSlotController>;
    let currButton: wref<inkCanvas> = containerSlot;
    currButton.UnregisterFromCallback(n"OnRelease", this, n"OnPaperDollCursor");
    currButton.UnregisterFromCallback(n"OnEnter", this, n"OnPaperdollItemEnter");
    currButton.UnregisterFromCallback(n"OnLeave", this, n"OnPaperdollItemExit");
    currButton.RegisterToCallback(n"OnRelease", this, n"OnPaperDollCursor");
    currButton.RegisterToCallback(n"OnEnter", this, n"OnPaperdollItemEnter");
    currButton.RegisterToCallback(n"OnLeave", this, n"OnPaperdollItemExit");
    currLogic = currButton.GetController() as PaperDollSlotController;
    currLogic.SetButtonDetails(argTitle, equipArea, slotIndex, areaTags);
  }

  protected final func HelperAddInventoryButton(itemData: ref<gameItemData>, slotId: Int32) -> Void {
    let itemButton: wref<inkCompoundWidget>;
    let itemLogic: wref<ArmorEquipInventoryItemController>;
    let disassemblable: Bool = RPGManager.CanItemBeDisassembled(this.player.GetGame(), itemData.GetID());
    if slotId == 0 {
      itemButton = this.GetWidget(n"inventoryItem1") as inkCanvas;
    } else {
      if slotId == 1 {
        itemButton = this.GetWidget(n"inventoryItem2") as inkCanvas;
      } else {
        if slotId == 2 {
          itemButton = this.GetWidget(n"inventoryItem3") as inkCanvas;
        } else {
          if slotId == 3 {
            itemButton = this.GetWidget(n"inventoryItem4") as inkCanvas;
          } else {
            if slotId == 4 {
              itemButton = this.GetWidget(n"inventoryItem5") as inkCanvas;
            } else {
              if slotId == 5 {
                itemButton = this.GetWidget(n"inventoryItem6") as inkCanvas;
              } else {
                if slotId == 6 {
                  itemButton = this.GetWidget(n"inventoryItem7") as inkCanvas;
                } else {
                  if slotId == 7 {
                    itemButton = this.GetWidget(n"inventoryItem8") as inkCanvas;
                  } else {
                    if slotId == 8 {
                      itemButton = this.GetWidget(n"inventoryItem9") as inkCanvas;
                    } else {
                      if slotId == 9 {
                        itemButton = this.GetWidget(n"inventoryItem10") as inkCanvas;
                      } else {
                        if slotId == 10 {
                          itemButton = this.GetWidget(n"inventoryItem11") as inkCanvas;
                        } else {
                          if slotId == 11 {
                            itemButton = this.GetWidget(n"inventoryItem12") as inkCanvas;
                          } else {
                            if slotId == 12 {
                              itemButton = this.GetWidget(n"inventoryItem13") as inkCanvas;
                            } else {
                              if slotId == 13 {
                                itemButton = this.GetWidget(n"inventoryItem14") as inkCanvas;
                              } else {
                                if slotId == 14 {
                                  itemButton = this.GetWidget(n"inventoryItem15") as inkCanvas;
                                } else {
                                  if slotId == 15 {
                                    itemButton = this.GetWidget(n"inventoryItem16") as inkCanvas;
                                  } else {
                                    if slotId == 16 {
                                      itemButton = this.GetWidget(n"inventoryItem17") as inkCanvas;
                                    } else {
                                      if slotId == 17 {
                                        itemButton = this.GetWidget(n"inventoryItem18") as inkCanvas;
                                      } else {
                                        if slotId == 18 {
                                          itemButton = this.GetWidget(n"inventoryItem19") as inkCanvas;
                                        } else {
                                          if slotId == 19 {
                                            itemButton = this.GetWidget(n"inventoryItem20") as inkCanvas;
                                          } else {
                                            if slotId == 20 {
                                              itemButton = this.GetWidget(n"inventoryItem21") as inkCanvas;
                                            } else {
                                              if slotId == 21 {
                                                itemButton = this.GetWidget(n"inventoryItem22") as inkCanvas;
                                              } else {
                                                if slotId == 22 {
                                                  itemButton = this.GetWidget(n"inventoryItem23") as inkCanvas;
                                                } else {
                                                  if slotId == 23 {
                                                    itemButton = this.GetWidget(n"inventoryItem24") as inkCanvas;
                                                  } else {
                                                    if slotId == 24 {
                                                      itemButton = this.GetWidget(n"inventoryItem25") as inkCanvas;
                                                    } else {
                                                      if slotId == 25 {
                                                        itemButton = this.GetWidget(n"inventoryItem26") as inkCanvas;
                                                      } else {
                                                        if slotId == 26 {
                                                          itemButton = this.GetWidget(n"inventoryItem27") as inkCanvas;
                                                        } else {
                                                          if slotId == 27 {
                                                            itemButton = this.GetWidget(n"inventoryItem28") as inkCanvas;
                                                          } else {
                                                            if slotId == 28 {
                                                              itemButton = this.GetWidget(n"inventoryItem29") as inkCanvas;
                                                            } else {
                                                              if slotId == 29 {
                                                                itemButton = this.GetWidget(n"inventoryItem30") as inkCanvas;
                                                              } else {
                                                                return;
                                                              };
                                                            };
                                                          };
                                                        };
                                                      };
                                                    };
                                                  };
                                                };
                                              };
                                            };
                                          };
                                        };
                                      };
                                    };
                                  };
                                };
                              };
                            };
                          };
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
    itemButton.UnregisterFromCallback(n"OnRelease", this, n"OnInventoryItemPush");
    itemButton.UnregisterFromCallback(n"OnEnter", this, n"OnInventoryItemEnter");
    itemButton.UnregisterFromCallback(n"OnLeave", this, n"OnInventoryItemExit");
    itemButton.RegisterToCallback(n"OnRelease", this, n"OnInventoryItemPush");
    itemButton.RegisterToCallback(n"OnEnter", this, n"OnInventoryItemEnter");
    itemButton.RegisterToCallback(n"OnLeave", this, n"OnInventoryItemExit");
    itemLogic = itemButton.GetController() as ArmorEquipInventoryItemController;
    itemLogic.SetButtonDetails(itemData, this.m_transactionSystem.GetItemQuantity(this.player, itemData.GetID()), disassemblable);
  }

  protected final func HelperClearButton(slotId: Int32) -> Void {
    let itemButton: wref<inkCompoundWidget>;
    let itemLogic: wref<ArmorEquipInventoryItemController>;
    if slotId == 0 {
      itemButton = this.GetWidget(n"inventoryItem1") as inkCanvas;
    } else {
      if slotId == 1 {
        itemButton = this.GetWidget(n"inventoryItem2") as inkCanvas;
      } else {
        if slotId == 2 {
          itemButton = this.GetWidget(n"inventoryItem3") as inkCanvas;
        } else {
          if slotId == 3 {
            itemButton = this.GetWidget(n"inventoryItem4") as inkCanvas;
          } else {
            if slotId == 4 {
              itemButton = this.GetWidget(n"inventoryItem5") as inkCanvas;
            } else {
              if slotId == 5 {
                itemButton = this.GetWidget(n"inventoryItem6") as inkCanvas;
              } else {
                if slotId == 6 {
                  itemButton = this.GetWidget(n"inventoryItem7") as inkCanvas;
                } else {
                  if slotId == 7 {
                    itemButton = this.GetWidget(n"inventoryItem8") as inkCanvas;
                  } else {
                    if slotId == 8 {
                      itemButton = this.GetWidget(n"inventoryItem9") as inkCanvas;
                    } else {
                      if slotId == 9 {
                        itemButton = this.GetWidget(n"inventoryItem10") as inkCanvas;
                      } else {
                        if slotId == 10 {
                          itemButton = this.GetWidget(n"inventoryItem11") as inkCanvas;
                        } else {
                          if slotId == 11 {
                            itemButton = this.GetWidget(n"inventoryItem12") as inkCanvas;
                          } else {
                            if slotId == 12 {
                              itemButton = this.GetWidget(n"inventoryItem13") as inkCanvas;
                            } else {
                              if slotId == 13 {
                                itemButton = this.GetWidget(n"inventoryItem14") as inkCanvas;
                              } else {
                                if slotId == 14 {
                                  itemButton = this.GetWidget(n"inventoryItem15") as inkCanvas;
                                } else {
                                  if slotId == 15 {
                                    itemButton = this.GetWidget(n"inventoryItem16") as inkCanvas;
                                  } else {
                                    if slotId == 16 {
                                      itemButton = this.GetWidget(n"inventoryItem17") as inkCanvas;
                                    } else {
                                      if slotId == 17 {
                                        itemButton = this.GetWidget(n"inventoryItem18") as inkCanvas;
                                      } else {
                                        if slotId == 18 {
                                          itemButton = this.GetWidget(n"inventoryItem19") as inkCanvas;
                                        } else {
                                          if slotId == 19 {
                                            itemButton = this.GetWidget(n"inventoryItem20") as inkCanvas;
                                          } else {
                                            if slotId == 20 {
                                              itemButton = this.GetWidget(n"inventoryItem21") as inkCanvas;
                                            } else {
                                              if slotId == 21 {
                                                itemButton = this.GetWidget(n"inventoryItem22") as inkCanvas;
                                              } else {
                                                if slotId == 22 {
                                                  itemButton = this.GetWidget(n"inventoryItem23") as inkCanvas;
                                                } else {
                                                  if slotId == 23 {
                                                    itemButton = this.GetWidget(n"inventoryItem24") as inkCanvas;
                                                  } else {
                                                    if slotId == 24 {
                                                      itemButton = this.GetWidget(n"inventoryItem25") as inkCanvas;
                                                    } else {
                                                      if slotId == 25 {
                                                        itemButton = this.GetWidget(n"inventoryItem26") as inkCanvas;
                                                      } else {
                                                        if slotId == 26 {
                                                          itemButton = this.GetWidget(n"inventoryItem27") as inkCanvas;
                                                        } else {
                                                          if slotId == 27 {
                                                            itemButton = this.GetWidget(n"inventoryItem28") as inkCanvas;
                                                          } else {
                                                            if slotId == 28 {
                                                              itemButton = this.GetWidget(n"inventoryItem29") as inkCanvas;
                                                            } else {
                                                              if slotId == 29 {
                                                                itemButton = this.GetWidget(n"inventoryItem30") as inkCanvas;
                                                              } else {
                                                                return;
                                                              };
                                                            };
                                                          };
                                                        };
                                                      };
                                                    };
                                                  };
                                                };
                                              };
                                            };
                                          };
                                        };
                                      };
                                    };
                                  };
                                };
                              };
                            };
                          };
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
    itemButton.UnregisterFromCallback(n"OnRelease", this, n"OnInventoryItemPush");
    itemButton.UnregisterFromCallback(n"OnEnter", this, n"OnInventoryItemEnter");
    itemButton.UnregisterFromCallback(n"OnLeave", this, n"OnInventoryItemExit");
    itemLogic = itemButton.GetController() as ArmorEquipInventoryItemController;
    itemLogic.ClearButton();
  }

  protected final func OnInventoryChange(value: Variant) -> Void {
    this.m_inventory = FromVariant(value);
  }

  protected final func OnEquipmentChange(value: Variant) -> Void {
    this.RefreshEquipment();
    this.RefreshInventoryList();
  }

  protected final func RefreshEquipment() -> Void {
    switch this.m_operationsMode {
      case operationsMode.PLAYER:
        this.RefreshPlayerEquipment();
        break;
      case operationsMode.FLATHEAD:
        this.RefreshFlatheadEquipment();
        break;
      case operationsMode.TOOLBOX:
    };
  }

  protected final func RefreshFlatheadEquipment() -> Void {
    let paperDollButton: wref<inkCanvas>;
    let paperDollController: wref<PaperDollSlotController>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_paperDollList) {
      paperDollButton = this.GetWidget(this.m_paperDollList[i]) as inkCanvas;
      paperDollController = paperDollButton.GetController() as PaperDollSlotController;
      paperDollController.SetItemInSlot(this.m_subCharacterSystem.GetFlatheadEquipment().GetItemInEquipSlot(paperDollController.GetEquipArea(), paperDollController.GetSlotIndex()));
      i += 1;
    };
  }

  protected final func RefreshPlayerEquipment() -> Void {
    let paperDollButton: wref<inkCanvas>;
    let paperDollController: wref<PaperDollSlotController>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_paperDollList) {
      paperDollButton = this.GetWidget(this.m_paperDollList[i]) as inkCanvas;
      paperDollController = paperDollButton.GetController() as PaperDollSlotController;
      paperDollController.SetItemInSlot(this.m_equipmentSystem.GetItemInEquipSlot(this.player, paperDollController.GetEquipArea(), paperDollController.GetSlotIndex()));
      i += 1;
    };
  }

  protected final func RemovedCyberware(items: array<wref<gameItemData>>) -> array<wref<gameItemData>> {
    let validItems: array<wref<gameItemData>>;
    let i: Int32 = 0;
    while i < ArraySize(items) {
      if !this.m_transactionSystem.HasTag(this.player, n"Cyberware", items[i].GetID()) {
        ArrayPush(validItems, items[i]);
      };
      i += 1;
    };
    return validItems;
  }

  protected func RefreshInventoryList() -> Void {
    let i: Int32;
    let inventorySlotId: Int32;
    let validItems: array<wref<gameItemData>>;
    if Equals(this.m_equipArea, gamedataEquipmentArea.Invalid) {
      this.m_transactionSystem.GetItemList(this.player, validItems);
    } else {
      if Equals(this.m_equipArea, gamedataEquipmentArea.BotMainModule) {
        this.m_transactionSystem.GetItemListByTags(this.player, this.m_areaTags, validItems);
      };
    };
    validItems = this.RemovedCyberware(validItems);
    i = 0;
    while i < 30 {
      this.HelperClearButton(i);
      i += 1;
    };
    inventorySlotId = 0;
    if this.scrollOffset > ArraySize(validItems) {
      this.scrollOffset = ArraySize(validItems);
      this.buttonScrollDn.SetVisible(false);
    } else {
      this.buttonScrollDn.SetVisible(true);
    };
    i = this.scrollOffset;
    while i < this.scrollOffset + ArraySize(validItems) {
      if !this.m_equipmentSystem.IsEquipped(this.player, validItems[i].GetID()) && !this.m_subCharacterSystem.GetFlatheadEquipment().IsEquipped(validItems[i].GetID()) {
        this.HelperAddInventoryButton(validItems[i], inventorySlotId);
        inventorySlotId += 1;
      };
      i += 1;
    };
  }

  protected final func SetCraftList() -> Void {
    let PlayerCraftItems: array<wref<Item_Record>>;
    let i: Int32;
    ArrayClear(this.m_recipeItemList);
    PlayerCraftItems = this.m_playerCraftBook.GetCraftableItems();
    i = 0;
    while i < ArraySize(PlayerCraftItems) {
      ArrayPush(this.m_recipeItemList, PlayerCraftItems[i].GetID());
      i += 1;
    };
  }

  public final func OnPaperDollCursor(e: ref<inkPointerEvent>) -> Void {
    if e.IsAction(n"click") {
      switch this.m_operationsMode {
        case operationsMode.PLAYER:
          this.ProcessPaperDollPlayerClick(e);
          break;
        case operationsMode.FLATHEAD:
          this.ProcessPaperDollFlatheadClick(e);
      };
    };
    this.RefreshInventoryList();
    this.RefreshEquipment();
  }

  public final func OnInventoryItemPush(e: ref<inkPointerEvent>) -> Void {
    if e.IsAction(n"click") {
      switch this.m_operationsMode {
        case operationsMode.PLAYER:
          this.ProcessPlayerClick(e);
          break;
        case operationsMode.FLATHEAD:
          this.ProcessFlatheadClick(e);
          break;
        case operationsMode.TOOLBOX:
          this.ProcessToolboxClick(e);
      };
    };
    this.RefreshInventoryList();
    this.RefreshEquipment();
  }

  public func OnInventoryItemEnter(e: ref<inkPointerEvent>) -> Void {
    let button: wref<inkCompoundWidget>;
    let controller: wref<ArmorEquipInventoryItemController>;
    let equippedItem: ItemID;
    let inspectedItemData: ref<gameItemData>;
    let cursorPos: Vector2 = e.GetScreenSpacePosition();
    this.m_tooltipContainer.SetMargin(new inkMargin(cursorPos.X + 40.00, cursorPos.Y + 30.00, 0.00, 0.00));
    button = e.GetCurrentTarget() as inkCompoundWidget;
    controller = button.GetController() as ArmorEquipInventoryItemController;
    if !controller.GetIsEmpty() {
      inspectedItemData = controller.GetItemData();
      equippedItem = this.m_inventoryManager.GetEquippedItemIdInArea(this.m_inventoryManager.GetItemEquipArea(inspectedItemData.GetID()));
      this.RefreshTooltipsInventory(inspectedItemData, equippedItem);
    } else {
      this.HideTooltips();
    };
  }

  public func OnInventoryItemExit(e: ref<inkPointerEvent>) -> Void {
    this.HideTooltips();
  }

  public func OnPaperdollItemEnter(e: ref<inkPointerEvent>) -> Void {
    let button: wref<inkCompoundWidget>;
    let controller: wref<PaperDollSlotController>;
    let equippedItem: ItemID;
    let cursorPos: Vector2 = e.GetScreenSpacePosition();
    this.m_tooltipContainer.SetMargin(new inkMargin(cursorPos.X + 40.00, cursorPos.Y + 30.00, 0.00, 0.00));
    button = e.GetCurrentTarget() as inkCompoundWidget;
    controller = button.GetController() as PaperDollSlotController;
    equippedItem = this.m_equipmentSystem.GetItemInEquipSlot(this.player, controller.GetEquipArea(), controller.GetSlotIndex());
    if ItemID.IsValid(equippedItem) {
      this.RefreshTooltipsPaperdoll(this.m_inventoryManager.GetPlayerItemStats(equippedItem));
    };
  }

  public final func OnPaperdollItemExit(e: ref<inkPointerEvent>) -> Void {
    this.HideTooltips();
  }

  public final func OnScrollUp(e: ref<inkPointerEvent>) -> Void {
    this.scrollOffset -= 5;
    if this.scrollOffset < 0 {
      this.buttonScrollUp.SetVisible(false);
      this.scrollOffset = 0;
    } else {
      this.buttonScrollUp.SetVisible(true);
    };
    this.RefreshInventoryList();
  }

  public final func OnScrollDn(e: ref<inkPointerEvent>) -> Void {
    this.scrollOffset += 5;
    this.buttonScrollUp.SetVisible(true);
    this.RefreshInventoryList();
  }

  protected final func ProcessPaperDollPlayerClick(e: ref<inkPointerEvent>) -> Void {
    let button: wref<inkCanvas>;
    let controller: wref<PaperDollSlotController>;
    let unequipRequest: ref<UnequipRequest>;
    if e.IsAction(n"click") {
      button = e.GetCurrentTarget() as inkCanvas;
      controller = button.GetController() as PaperDollSlotController;
      button = e.GetCurrentTarget() as inkCanvas;
      controller = button.GetController() as PaperDollSlotController;
      unequipRequest = new UnequipRequest();
      unequipRequest.areaType = controller.GetEquipArea();
      unequipRequest.slotIndex = controller.GetSlotIndex();
      unequipRequest.owner = this.player;
      this.m_equipmentSystem.QueueRequest(unequipRequest);
      this.RefreshEquipment();
      this.RefreshInventoryList();
    };
  }

  protected final func ProcessPaperDollFlatheadClick(e: ref<inkPointerEvent>) -> Void {
    let button: wref<inkCanvas>;
    let controller: wref<PaperDollSlotController>;
    let unequipRequest: ref<SubCharUnequipRequest>;
    if e.IsAction(n"click") {
      button = e.GetCurrentTarget() as inkCanvas;
      controller = button.GetController() as PaperDollSlotController;
      button = e.GetCurrentTarget() as inkCanvas;
      controller = button.GetController() as PaperDollSlotController;
      unequipRequest = new SubCharUnequipRequest();
      unequipRequest.areaType = controller.GetEquipArea();
      unequipRequest.slotIndex = controller.GetSlotIndex();
      unequipRequest.subCharType = gamedataSubCharacter.Flathead;
      this.m_equipmentSystem.QueueRequest(unequipRequest);
      this.RefreshEquipment();
      this.RefreshInventoryList();
    };
  }

  protected final func ProcessPlayerClick(e: ref<inkPointerEvent>) -> Void {
    let equipRequest: ref<EquipRequest>;
    let button: wref<inkCompoundWidget> = e.GetCurrentTarget() as inkCompoundWidget;
    let controller: wref<ArmorEquipInventoryItemController> = button.GetController() as ArmorEquipInventoryItemController;
    if !controller.GetIsEmpty() && e.IsLeftControlDown() {
      this.DisassembleItem(controller.GetItemID(), 1);
      this.HideTooltips();
      this.RefreshInventoryList();
      return;
    };
    if !controller.GetIsEmpty() {
      equipRequest = new EquipRequest();
      equipRequest.itemID = controller.GetItemID();
      equipRequest.owner = this.player;
      this.m_equipmentSystem.QueueRequest(equipRequest);
    };
    this.RefreshEquipment();
    this.RefreshInventoryList();
    this.HideTooltips();
  }

  protected final func ProcessFlatheadClick(e: ref<inkPointerEvent>) -> Void {
    let button: wref<inkCompoundWidget> = e.GetCurrentTarget() as inkCompoundWidget;
    let controller: wref<ArmorEquipInventoryItemController> = button.GetController() as ArmorEquipInventoryItemController;
    let equipRequest: ref<SubCharEquipRequest> = new SubCharEquipRequest();
    equipRequest.itemID = controller.GetItemID();
    equipRequest.subCharType = gamedataSubCharacter.Flathead;
    this.m_subCharacterSystem.QueueRequest(equipRequest);
    this.RefreshEquipment();
    this.RefreshInventoryList();
    this.HideTooltips();
  }

  protected final func RefreshTooltipsInventory(tooltipItemData: ref<gameItemData>, equippedItemId: ItemID) -> Void {
    let inspectingEquippedItem: Bool;
    let tooltipData: ref<InventoryTooltipData>;
    this.HideTooltips();
    inspectingEquippedItem = equippedItemId == tooltipItemData.GetID();
    if ItemID.IsValid(equippedItemId) {
      if inspectingEquippedItem || this.m_inventoryManager.CanCompareItems(tooltipItemData.GetID(), equippedItemId) {
        tooltipData = InventoryTooltipData.FromItemViewData(this.m_inventoryManager.GetPlayerItemStats(equippedItemId));
        tooltipData.isEquipped = true;
        this.m_tooltipRight.Show(tooltipData);
      };
      if inspectingEquippedItem {
        return;
      };
    };
    tooltipData = InventoryTooltipData.FromItemViewData(this.m_inventoryManager.GetItemStatsByData(tooltipItemData, this.m_inventoryManager.GetPlayerItemData(equippedItemId)));
    this.m_tooltipLeft.Show(tooltipData);
  }

  protected final func RefreshTooltipsPaperdoll(tooltipItemData: ItemViewData) -> Void {
    let tooltipData: ref<InventoryTooltipData>;
    this.HideTooltips();
    tooltipData = InventoryTooltipData.FromItemViewData(tooltipItemData);
    tooltipData.isEquipped = true;
    this.m_tooltipLeft.Show(tooltipData);
  }

  protected func HideTooltips() -> Void {
    this.m_tooltipLeft.Hide();
    this.m_tooltipRight.Hide();
  }

  protected final func ProcessToolboxClick(e: ref<inkPointerEvent>) -> Void;

  protected final func DisassembleItem(itemID: ItemID, quantity: Int32) -> Void;

  public final func OnSelectPlayer(e: ref<inkPointerEvent>) -> Void {
    this.m_operationsMode = operationsMode.PLAYER;
    this.m_equipArea = gamedataEquipmentArea.Invalid;
    this.m_slotIndex = -1;
    this.panelPlayer.SetVisible(true);
    this.panelFlathead.SetVisible(false);
    this.panelToolbox.SetVisible(false);
    this.RefreshEquipment();
    this.RefreshInventoryList();
  }

  public final func OnSelectFlathead(e: ref<inkPointerEvent>) -> Void {
    this.m_operationsMode = operationsMode.FLATHEAD;
    this.m_equipArea = gamedataEquipmentArea.BotMainModule;
    this.m_slotIndex = 1;
    this.m_areaTags = this.modulesTags;
    this.panelPlayer.SetVisible(false);
    this.panelFlathead.SetVisible(true);
    this.panelToolbox.SetVisible(false);
    this.RefreshEquipment();
    this.RefreshInventoryList();
  }

  public final func OnSelectToolbox(e: ref<inkPointerEvent>) -> Void {
    this.m_operationsMode = operationsMode.TOOLBOX;
    this.m_equipArea = gamedataEquipmentArea.BotMainModule;
    this.m_slotIndex = 1;
    this.m_areaTags = this.framesTags;
    this.panelPlayer.SetVisible(false);
    this.panelFlathead.SetVisible(false);
    this.panelToolbox.SetVisible(true);
    this.RefreshInventoryList();
  }
}
