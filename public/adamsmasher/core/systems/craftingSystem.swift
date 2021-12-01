
public struct ItemAttachments {

  public let itemID: ItemID;

  public let attachmentSlotID: TweakDBID;

  public final static func Create(itemID: ItemID, attachmentSlotID: TweakDBID) -> ItemAttachments {
    let itemAttachment: ItemAttachments;
    itemAttachment.itemID = itemID;
    itemAttachment.attachmentSlotID = attachmentSlotID;
    return itemAttachment;
  }
}

public class CraftingSystem extends ScriptableSystem {

  private let m_lastActionStatus: Bool;

  private persistent let m_playerCraftBook: ref<CraftBook>;

  private let m_callback: ref<CraftingSystemInventoryCallback>;

  private let m_inventoryListener: ref<InventoryScriptListener>;

  private let m_itemIconGender: ItemIconGender;

  private func OnAttach() -> Void {
    if !IsDefined(this.m_playerCraftBook) {
      this.m_playerCraftBook = new CraftBook();
    };
  }

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(request.owner.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    this.m_itemIconGender = UIGenderHelper.GetIconGender(player);
    this.m_callback = new CraftingSystemInventoryCallback();
    this.m_callback.player = player;
    this.m_inventoryListener = GameInstance.GetTransactionSystem(player.GetGame()).RegisterInventoryListener(player, this.m_callback);
    if IsDefined(this.m_playerCraftBook) {
      this.m_playerCraftBook.InitializeCraftBookOwner(player);
    };
  }

  private final func OnPlayerDetach(request: ref<PlayerDetachRequest>) -> Void {
    let player: ref<PlayerPuppet> = request.owner as PlayerPuppet;
    GameInstance.GetTransactionSystem(player.GetGame()).UnregisterInventoryListener(player, this.m_inventoryListener);
    this.m_inventoryListener = null;
  }

  private func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void {
    let factVal: Int32;
    let warningMsg: SimpleScreenMessage;
    warningMsg.isShown = true;
    warningMsg.duration = 20.00;
    warningMsg.message = IntToString(saveVersion);
    GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(warningMsg), true);
    factVal = GetFact(this.GetGameInstance(), n"IconicItemsRevampCompleted");
    if factVal <= 0 && gameVersion >= 2 {
      this.ProcessIconicRevampRestoration();
      SetFactValue(this.GetGameInstance(), n"IconicItemsRevampCompleted", 1);
    };
    factVal = GetFact(this.GetGameInstance(), n"AmmoRecipesAdded");
    if factVal <= 0 && gameVersion >= 2 {
      this.AddAmmoRecipes();
      SetFactValue(this.GetGameInstance(), n"AmmoRecipesAdded", 1);
    };
    factVal = GetFact(this.GetGameInstance(), n"RecipesCraftedAmountRestored");
    if factVal <= 0 && gameVersion >= 2 {
      this.m_playerCraftBook.ResetRecipeCraftedAmount();
      SetFactValue(this.GetGameInstance(), n"RecipesCraftedAmountRestored", 1);
    };
    factVal = GetFact(this.GetGameInstance(), n"LegendaryLizzieFixed");
    if factVal <= 0 && gameVersion >= 2 {
      if GameInstance.GetTransactionSystem(this.GetGameInstance()).HasItem(this.m_playerCraftBook.GetOwner(), ItemID.CreateQuery(t"Items.Preset_Omaha_Suzie_Epic")) {
        this.m_playerCraftBook.AddRecipe(t"Items.Preset_Omaha_Suzie_Legendary");
        SetFactValue(this.GetGameInstance(), n"LegendaryLizzieFixed", 1);
      };
    };
    factVal = GetFact(this.GetGameInstance(), n"CraftedItemsPowerBoost_1");
    if factVal <= 0 && gameVersion >= 1200 {
      this.ProcessCraftedItemsPowerBoost();
      SetFactValue(this.GetGameInstance(), n"CraftedItemsPowerBoost_1", 1);
    };
    factVal = GetFact(this.GetGameInstance(), n"UncommonKnifeAdded");
    if factVal <= 0 && gameVersion >= 1300 {
      this.m_playerCraftBook.AddRecipe(t"Items.Craftable_Uncommon_Knife");
      SetFactValue(this.GetGameInstance(), n"UncommonKnifeAdded", 1);
    };
  }

  public final static func GetInstance(gameInstance: GameInstance) -> ref<CraftingSystem> {
    let cs: ref<CraftingSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"CraftingSystem") as CraftingSystem;
    return cs;
  }

  public final const func GetPlayerCraftBook() -> ref<CraftBook> {
    return this.m_playerCraftBook;
  }

  public final const func GetPlayerCraftableItems() -> array<wref<Item_Record>> {
    return this.m_playerCraftBook.GetCraftableItems();
  }

  public final const func GetItemFinalUpgradeCost(itemData: wref<gameItemData>) -> array<IngredientData> {
    let i: Int32;
    let ingredients: array<IngredientData>;
    let tempStat: Float;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGameInstance());
    let upgradeNumber: Float = itemData.GetStatValueByType(gamedataStatType.WasItemUpgraded);
    upgradeNumber += 1.00;
    ingredients = this.GetItemBaseUpgradeCost(itemData.GetItemType(), RPGManager.GetItemQuality(itemData));
    i = 0;
    while i < ArraySize(ingredients) {
      ingredients[i].quantity = ingredients[i].quantity * Cast(upgradeNumber);
      ingredients[i].baseQuantity = ingredients[i].quantity;
      i += 1;
    };
    tempStat = statsSystem.GetStatValue(Cast(this.m_playerCraftBook.GetOwner().GetEntityID()), gamedataStatType.UpgradingCostReduction);
    if tempStat > 0.00 {
      i = 0;
      while i < ArraySize(ingredients) {
        ingredients[i].quantity = Cast(Cast(ingredients[i].quantity) * (1.00 - tempStat));
        i += 1;
      };
    };
    return ingredients;
  }

  public final const func GetItemBaseUpgradeCost(itemType: gamedataItemType, quality: gamedataQuality) -> array<IngredientData> {
    let baseIngredients: array<IngredientData>;
    let i: Int32;
    let upgradeData: array<wref<RecipeElement_Record>>;
    let record: ref<UpgradingData_Record> = TweakDBInterface.GetUpgradingDataRecord(t"Upgrading." + TDBID.Create(EnumValueToString("gamedataItemType", Cast(EnumInt(itemType)))));
    record.Ingredients(upgradeData);
    i = 0;
    while i < ArraySize(upgradeData) {
      ArrayPush(baseIngredients, this.CreateIngredientData(upgradeData[i]));
      i += 1;
    };
    ArrayClear(upgradeData);
    record = TweakDBInterface.GetUpgradingDataRecord(t"Upgrading." + TDBID.Create(EnumValueToString("gamedataQuality", Cast(EnumInt(quality)))));
    record.Ingredients(upgradeData);
    i = 0;
    while i < ArraySize(upgradeData) {
      ArrayPush(baseIngredients, this.CreateIngredientData(upgradeData[i]));
      i += 1;
    };
    return baseIngredients;
  }

  public final const func GetItemCraftingCost(itemData: wref<gameItemData>) -> array<IngredientData> {
    let itemRecord: wref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemData.GetID()));
    let baseIngredients: array<IngredientData> = this.GetItemCraftingCost(itemRecord);
    return baseIngredients;
  }

  public final const func GetItemCraftingCost(itemRecord: wref<Item_Record>) -> array<IngredientData> {
    let baseIngredients: array<IngredientData>;
    let craftingData: array<wref<RecipeElement_Record>>;
    let record: wref<CraftingPackage_Record> = itemRecord.CraftingData();
    record.CraftingRecipe(craftingData);
    baseIngredients = this.GetItemCraftingCost(itemRecord, craftingData);
    return baseIngredients;
  }

  public final const func GetItemCraftingCost(record: wref<Item_Record>, craftingData: array<wref<RecipeElement_Record>>) -> array<IngredientData> {
    let baseIngredients: array<IngredientData>;
    let expectedQuality: gamedataQuality;
    let modifiedQuantity: Int32;
    let tempStat: Float;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGameInstance());
    let i: Int32 = 0;
    while i < ArraySize(craftingData) {
      ArrayPush(baseIngredients, this.CreateIngredientData(craftingData[i]));
      i += 1;
    };
    tempStat = statsSystem.GetStatValue(Cast(this.m_playerCraftBook.GetOwner().GetEntityID()), gamedataStatType.CraftingCostReduction);
    if tempStat > 0.00 {
      i = 0;
      while i < ArraySize(baseIngredients) {
        if baseIngredients[i].quantity > 1 {
          modifiedQuantity = CeilF(Cast(baseIngredients[i].quantity) * (1.00 - tempStat));
          baseIngredients[i].quantity = modifiedQuantity;
        };
        i += 1;
      };
    };
    if Equals(record.Quality().Type(), gamedataQuality.Random) {
      expectedQuality = IntEnum(Cast(EnumValueFromName(n"gamedataQuality", RPGManager.SetQualityBasedOnCraftingSkill(this.m_playerCraftBook.GetOwner()))));
      if expectedQuality >= gamedataQuality.Uncommon {
        ArrayPush(baseIngredients, this.CreateIngredientData(RPGManager.GetCraftingMaterialRecord(gamedataQuality.Uncommon, true), 8));
      };
      if expectedQuality >= gamedataQuality.Rare {
        ArrayPush(baseIngredients, this.CreateIngredientData(RPGManager.GetCraftingMaterialRecord(gamedataQuality.Rare, true), 5));
      };
      if expectedQuality >= gamedataQuality.Epic {
        ArrayPush(baseIngredients, this.CreateIngredientData(RPGManager.GetCraftingMaterialRecord(gamedataQuality.Epic, true), 3));
      };
      if expectedQuality >= gamedataQuality.Legendary {
        ArrayPush(baseIngredients, this.CreateIngredientData(RPGManager.GetCraftingMaterialRecord(gamedataQuality.Legendary, true), 2));
      };
    };
    return baseIngredients;
  }

  public final const func CanItemBeDisassembled(owner: wref<GameObject>, itemID: ItemID) -> Bool {
    let itemData: wref<gameItemData> = GameInstance.GetTransactionSystem(this.GetGameInstance()).GetItemData(owner, itemID);
    if RPGManager.IsItemEquipped(owner, itemID) {
      return false;
    };
    return this.CanItemBeDisassembled(itemData);
  }

  public final const func CanItemBeDisassembled(itemData: wref<gameItemData>) -> Bool {
    if IsDefined(itemData) {
      return !itemData.HasTag(n"Quest") && !itemData.HasTag(n"UnequipBlocked") && IsDefined(ItemActionsHelper.GetDisassembleAction(itemData.GetID()));
    };
    return false;
  }

  public final const func CanItemBeCrafted(itemData: wref<gameItemData>) -> Bool {
    let quality: gamedataQuality;
    let result: Bool;
    let requiredIngredients: array<IngredientData> = this.GetItemCraftingCost(itemData);
    if Equals(itemData.GetItemType(), gamedataItemType.Prt_Program) {
      result = this.HasIngredients(requiredIngredients);
    } else {
      result = this.HasIngredients(requiredIngredients) && this.CanCraftGivenQuality(itemData, quality);
    };
    return result;
  }

  public final const func CanItemBeCrafted(itemRecord: wref<Item_Record>) -> Bool {
    let quality: gamedataQuality;
    let result: Bool;
    let requiredIngredients: array<IngredientData> = this.GetItemCraftingCost(itemRecord);
    if Equals(itemRecord.ItemType().Type(), gamedataItemType.Prt_Program) {
      result = this.HasIngredients(requiredIngredients);
    } else {
      result = this.HasIngredients(requiredIngredients) && this.CanCraftGivenQuality(itemRecord, quality);
    };
    return result;
  }

  public final const func EnoughIngredientsForCrafting(itemData: wref<gameItemData>) -> Bool {
    let requiredIngredients: array<IngredientData> = this.GetItemCraftingCost(itemData);
    let result: Bool = this.HasIngredients(requiredIngredients);
    return result;
  }

  public final const func GetMaxCraftingAmount(itemData: wref<gameItemData>) -> Int32 {
    let currentQuantity: Int32;
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
    let requiredIngredients: array<IngredientData> = this.GetItemCraftingCost(itemData);
    let result: Int32 = 10000000;
    let i: Int32 = 0;
    while i < ArraySize(requiredIngredients) {
      currentQuantity = transactionSystem.GetItemQuantity(this.m_playerCraftBook.GetOwner(), ItemID.CreateQuery(requiredIngredients[i].id.GetID()));
      if currentQuantity > requiredIngredients[i].quantity {
        result = Min(result, currentQuantity / requiredIngredients[i].quantity);
      } else {
        return 0;
      };
      i += 1;
    };
    return result;
  }

  public final const func EnoughIngredientsForUpgrading(itemData: wref<gameItemData>) -> Bool {
    let requiredIngredients: array<IngredientData> = this.GetItemFinalUpgradeCost(itemData);
    let result: Bool = this.HasIngredients(requiredIngredients);
    return result;
  }

  public final const func CanItemBeUpgraded(itemData: wref<gameItemData>) -> Bool {
    let requiredIngredients: array<IngredientData>;
    let result: Bool;
    if RPGManager.IsItemMaxLevel(itemData) {
      return false;
    };
    requiredIngredients = this.GetItemFinalUpgradeCost(itemData);
    result = this.HasIngredients(requiredIngredients);
    return result;
  }

  public final const func HasIngredients(required: array<IngredientData>) -> Bool {
    let currentQuantity: Int32;
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
    let i: Int32 = 0;
    while i < ArraySize(required) {
      currentQuantity = transactionSystem.GetItemQuantity(this.m_playerCraftBook.GetOwner(), ItemID.CreateQuery(required[i].id.GetID()));
      if currentQuantity < required[i].quantity {
        return false;
      };
      i += 1;
    };
    return true;
  }

  public final const func CanCraftGivenQuality(itemData: wref<gameItemData>, out quality: gamedataQuality) -> Bool {
    let canCraft: Bool;
    let ss: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGameInstance());
    quality = RPGManager.GetItemQuality(itemData.GetStatValueByType(gamedataStatType.Quality));
    switch quality {
      case gamedataQuality.Rare:
        canCraft = ss.GetStatValue(Cast(this.m_playerCraftBook.GetOwner().GetEntityID()), gamedataStatType.CanCraftRareItems) > 0.00;
        break;
      case gamedataQuality.Epic:
        canCraft = ss.GetStatValue(Cast(this.m_playerCraftBook.GetOwner().GetEntityID()), gamedataStatType.CanCraftEpicItems) > 0.00;
        break;
      case gamedataQuality.Legendary:
        canCraft = ss.GetStatValue(Cast(this.m_playerCraftBook.GetOwner().GetEntityID()), gamedataStatType.CanCraftLegendaryItems) > 0.00;
        break;
      default:
        canCraft = true;
    };
    return canCraft;
  }

  public final const func CanCraftGivenQuality(itemRecord: wref<Item_Record>, out quality: gamedataQuality) -> Bool {
    let canCraft: Bool;
    let ss: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGameInstance());
    quality = itemRecord.Quality().Type();
    if Equals(quality, gamedataQuality.Random) {
      quality = UIItemsHelper.QualityNameToEnum(RPGManager.SetQualityBasedOnCraftingSkill(GetPlayer(this.GetGameInstance())));
    };
    switch quality {
      case gamedataQuality.Rare:
        canCraft = ss.GetStatValue(Cast(this.m_playerCraftBook.GetOwner().GetEntityID()), gamedataStatType.CanCraftRareItems) > 0.00;
        break;
      case gamedataQuality.Epic:
        canCraft = ss.GetStatValue(Cast(this.m_playerCraftBook.GetOwner().GetEntityID()), gamedataStatType.CanCraftEpicItems) > 0.00;
        break;
      case gamedataQuality.Legendary:
        canCraft = ss.GetStatValue(Cast(this.m_playerCraftBook.GetOwner().GetEntityID()), gamedataStatType.CanCraftLegendaryItems) > 0.00;
        break;
      default:
        canCraft = true;
    };
    return canCraft;
  }

  public final const func IsRecipeKnown(recipe: TweakDBID, playerCraftBook: ref<CraftBook>) -> Bool {
    if playerCraftBook.GetRecipeIndex(recipe) >= 0 {
      return true;
    };
    return false;
  }

  private final func OnCraftItemRequest(request: ref<CraftItemRequest>) -> Void {
    let craftedItem: wref<gameItemData> = this.CraftItem(request.target, request.itemRecord, request.amount, request.bulletAmount);
    this.UpdateBlackboard(CraftingCommands.CraftingFinished, craftedItem.GetID());
  }

  private final func OnDisassembleItemRequest(request: ref<DisassembleItemRequest>) -> Void {
    if this.CanItemBeDisassembled(GetPlayer(this.GetGameInstance()), request.itemID) {
      this.DisassembleItem(request.target, request.itemID, request.amount);
    };
  }

  private final func OnUpgradeItemRequest(request: ref<UpgradeItemRequest>) -> Void {
    this.UpgradeItem(request.owner, request.itemID);
    this.UpdateBlackboard(CraftingCommands.UpgradingFinished, request.itemID);
  }

  private final func OnAddRecipeRequest(request: ref<AddRecipeRequest>) -> Void {
    this.GetPlayerCraftBook().AddRecipe(request.recipe, request.hideOnItemsAdded, request.amount);
  }

  private final func OnHideRecipeRequest(request: ref<HideRecipeRequest>) -> Void {
    this.GetPlayerCraftBook().HideRecipe(request.recipe, true);
  }

  private final func OnShowRecipeRequest(request: ref<ShowRecipeRequest>) -> Void {
    this.GetPlayerCraftBook().HideRecipe(request.recipe, false);
  }

  public final const func GetLastActionStatus() -> Bool {
    return this.m_lastActionStatus;
  }

  private final func CraftItem(target: wref<GameObject>, itemRecord: ref<Item_Record>, amount: Int32, opt ammoBulletAmount: Int32) -> wref<gameItemData> {
    let craftedItemID: ItemID;
    let i: Int32;
    let ingredient: ItemID;
    let ingredientQuality: gamedataQuality;
    let ingredientRecords: array<wref<RecipeElement_Record>>;
    let isAmmo: Bool;
    let itemData: wref<gameItemData>;
    let j: Int32;
    let recipeXP: Int32;
    let requiredIngredients: array<IngredientData>;
    let savedAmount: Int32;
    let savedAmountLocked: Bool;
    let tempStat: Float;
    let xpID: TweakDBID;
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGameInstance());
    itemRecord.CraftingData().CraftingRecipe(ingredientRecords);
    requiredIngredients = this.GetItemCraftingCost(itemRecord);
    isAmmo = itemRecord.TagsContains(n"Ammo");
    i = 0;
    while i < ArraySize(requiredIngredients) {
      ingredient = ItemID.CreateQuery(requiredIngredients[i].id.GetID());
      if RPGManager.IsItemWeapon(ingredient) || RPGManager.IsItemClothing(ingredient) {
        itemData = transactionSystem.GetItemData(target, ingredient);
        if IsDefined(itemData) && itemData.HasTag(n"Quest") {
          itemData.RemoveDynamicTag(n"Quest");
        };
        this.ClearNonIconicSlots(itemData);
      } else {
        i += 1;
      };
    };
    tempStat = statsSystem.GetStatValue(Cast(target.GetEntityID()), gamedataStatType.CraftingMaterialRetrieveChance);
    savedAmount = 0;
    i = 0;
    while i < ArraySize(requiredIngredients) {
      ingredient = ItemID.CreateQuery(requiredIngredients[i].id.GetID());
      if RPGManager.IsItemWeapon(ingredient) || RPGManager.IsItemClothing(ingredient) {
      } else {
        if tempStat > 0.00 && !savedAmountLocked {
          j = 0;
          while j < amount {
            if RandF() < tempStat {
              savedAmount += 1;
            };
            j += 1;
          };
          savedAmountLocked = true;
        };
      };
      transactionSystem.RemoveItem(target, ingredient, requiredIngredients[i].quantity * (amount - savedAmount));
      ingredientQuality = RPGManager.GetItemQualityFromRecord(TweakDBInterface.GetItemRecord(requiredIngredients[i].id.GetID()));
      switch ingredientQuality {
        case gamedataQuality.Common:
          xpID = t"Constants.CraftingSystem.commonIngredientXP";
          break;
        case gamedataQuality.Uncommon:
          xpID = t"Constants.CraftingSystem.uncommonIngredientXP";
          break;
        case gamedataQuality.Rare:
          xpID = t"Constants.CraftingSystem.rareIngredientXP";
          break;
        case gamedataQuality.Epic:
          xpID = t"Constants.CraftingSystem.epicIngredientXP";
          break;
        case gamedataQuality.Legendary:
          xpID = t"Constants.CraftingSystem.legendaryIngredientXP";
          break;
        default:
      };
      recipeXP += TweakDBInterface.GetInt(xpID, 0) * requiredIngredients[i].baseQuantity * amount;
      i += 1;
    };
    craftedItemID = ItemID.FromTDBID(itemRecord.GetID());
    transactionSystem.GiveItem(target, craftedItemID, isAmmo ? amount * ammoBulletAmount : amount);
    itemData = transactionSystem.GetItemData(target, craftedItemID);
    this.ProcessCraftingPerksData(target, itemRecord, itemData);
    this.SetItemLevel(itemData);
    this.SetItemQualityBasedOnPlayerSkill(itemData);
    this.MarkItemAsCrafted(itemData);
    this.SendItemCraftedDataTrackingRequest(craftedItemID);
    this.ProcessCraftSkill(recipeXP, itemData.GetStatsObjectID());
    return itemData;
  }

  private final func MarkItemAsCrafted(itemData: wref<gameItemData>) -> Void {
    let statMod: ref<gameStatModifierData> = RPGManager.CreateStatModifier(gamedataStatType.IsItemCrafted, gameStatModifierType.Additive, 1.00);
    GameInstance.GetStatsSystem(this.GetGameInstance()).AddSavedModifier(itemData.GetStatsObjectID(), statMod);
  }

  private final func ClearNonIconicSlots(itemData: wref<gameItemData>) -> Void {
    let i: Int32;
    let removedMod: ItemID;
    let slots: array<TweakDBID>;
    let TS: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
    let player: wref<PlayerPuppet> = this.m_playerCraftBook.GetOwner() as PlayerPuppet;
    ArrayClear(slots);
    slots = RPGManager.GetModsSlotIDs(itemData.GetItemType());
    i = 0;
    while i < ArraySize(slots) {
      removedMod = TS.RemovePart(player, itemData.GetID(), slots[i]);
      if ItemID.IsValid(removedMod) && !TS.HasTag(player, n"DummyPart", removedMod) {
        TS.GiveItem(player, removedMod, 1);
      };
      i += 1;
    };
    ArrayClear(slots);
    slots = RPGManager.GetAttachmentSlotIDs();
    i = 0;
    while i < ArraySize(slots) {
      removedMod = TS.RemovePart(player, itemData.GetID(), slots[i]);
      if ItemID.IsValid(removedMod) {
        TS.GiveItem(player, removedMod, 1);
      };
      i += 1;
    };
  }

  public final static func MarkItemAsCrafted(target: wref<GameObject>, itemData: wref<gameItemData>) -> Void {
    let statMod: ref<gameStatModifierData>;
    if Equals(itemData.HasStatData(gamedataStatType.IsItemCrafted), false) {
      statMod = RPGManager.CreateStatModifier(gamedataStatType.IsItemCrafted, gameStatModifierType.Additive, 1.00);
      GameInstance.GetStatsSystem(target.GetGame()).AddSavedModifier(itemData.GetStatsObjectID(), statMod);
    };
  }

  private final func SetItemLevel(itemData: wref<gameItemData>) -> Void {
    let craftingLevelBoost: Float;
    let modifier: ref<gameConstantStatModifierData>;
    let playerPLValue: Float;
    let statMod: ref<gameStatModifierData>;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGameInstance());
    if Equals(ItemID.GetStructure(itemData.GetID()), gamedataItemStructure.Unique) {
      if !RPGManager.IsItemSingleInstance(itemData) {
        playerPLValue = statsSystem.GetStatValue(Cast(this.m_playerCraftBook.GetOwner().GetEntityID()), gamedataStatType.PowerLevel);
        craftingLevelBoost = this.CalculateCraftingLevelBoost();
        statsSystem.RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.PowerLevel, true);
        modifier = new gameConstantStatModifierData();
        modifier.modifierType = gameStatModifierType.Additive;
        modifier.statType = gamedataStatType.PowerLevel;
        modifier.value = playerPLValue;
        statsSystem.AddSavedModifier(itemData.GetStatsObjectID(), modifier);
        statsSystem.RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.ItemLevel, true);
        modifier = new gameConstantStatModifierData();
        modifier.modifierType = gameStatModifierType.Additive;
        modifier.statType = gamedataStatType.ItemLevel;
        modifier.value = playerPLValue * 10.00 - craftingLevelBoost;
        statsSystem.AddSavedModifier(itemData.GetStatsObjectID(), modifier);
        statMod = RPGManager.CreateCombinedStatModifier(gamedataStatType.ItemLevel, gameStatModifierType.Additive, gamedataStatType.WasItemUpgraded, gameCombinedStatOperation.Multiplication, 10.00, gameStatObjectsRelation.Self);
        statsSystem.AddSavedModifier(itemData.GetStatsObjectID(), statMod);
      };
    };
  }

  private final func SetItemQualityBasedOnPlayerSkill(itemData: wref<gameItemData>) -> Void {
    let modifier: ref<gameConstantStatModifierData>;
    let quality: CName;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGameInstance());
    if Equals(RPGManager.GetItemRecord(itemData.GetID()).Quality().Type(), gamedataQuality.Random) {
      statsSystem.RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.Quality, true);
      modifier = new gameConstantStatModifierData();
      modifier.modifierType = gameStatModifierType.Additive;
      modifier.statType = gamedataStatType.Quality;
      quality = RPGManager.SetQualityBasedOnCraftingSkill(this.m_playerCraftBook.GetOwner());
      modifier.value = RPGManager.ItemQualityNameToValue(quality);
      statsSystem.AddSavedModifier(itemData.GetStatsObjectID(), modifier);
    };
  }

  public final static func SetItemLevel(target: wref<GameObject>, itemData: wref<gameItemData>) -> Void {
    let craftingLevelBoost: Float;
    let modifier: ref<gameConstantStatModifierData>;
    let playerPLValue: Float;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(target.GetGame());
    if Equals(ItemID.GetStructure(itemData.GetID()), gamedataItemStructure.Unique) {
      if !RPGManager.IsItemSingleInstance(itemData) {
        playerPLValue = statsSystem.GetStatValue(Cast(target.GetEntityID()), gamedataStatType.PowerLevel);
        craftingLevelBoost = statsSystem.GetStatValue(Cast(target.GetEntityID()), gamedataStatType.CraftingItemLevelBoost);
        statsSystem.RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.PowerLevel, true);
        modifier = new gameConstantStatModifierData();
        modifier.modifierType = gameStatModifierType.Additive;
        modifier.statType = gamedataStatType.PowerLevel;
        modifier.value = playerPLValue;
        statsSystem.AddSavedModifier(itemData.GetStatsObjectID(), modifier);
        statsSystem.RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.ItemLevel, true);
        modifier = new gameConstantStatModifierData();
        modifier.modifierType = gameStatModifierType.Additive;
        modifier.statType = gamedataStatType.ItemLevel;
        modifier.value = playerPLValue * 10.00 - 5.00 - craftingLevelBoost;
        statsSystem.AddSavedModifier(itemData.GetStatsObjectID(), modifier);
      };
    };
  }

  private final func CalculateCraftingLevelBoost() -> Float {
    let reductionValue: Float = GameInstance.GetStatsSystem(this.GetGameInstance()).GetStatValue(Cast(this.m_playerCraftBook.GetOwner().GetEntityID()), gamedataStatType.CraftingItemLevelBoost);
    reductionValue = 5.00 - reductionValue;
    return reductionValue;
  }

  private final func ProcessProgramCrafting(itemTDBID: TweakDBID) -> Void {
    this.GetPlayerCraftBook().HideRecipe(itemTDBID, true);
  }

  public final const func GetDisassemblyResultItems(target: wref<GameObject>, itemID: ItemID, amount: Int32, out restoredAttachments: array<ItemAttachments>, opt calledFromUI: Bool) -> array<IngredientData> {
    let finalResult: array<IngredientData>;
    let i: Int32;
    let ingredients: array<wref<RecipeElement_Record>>;
    let itemData: wref<gameItemData>;
    let itemQual: gamedataQuality;
    let j: Int32;
    let newIngrData: IngredientData;
    let outResult: array<IngredientData>;
    let itemType: gamedataItemType = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID)).ItemType().Type();
    let dissResult: wref<DisassemblingResult_Record> = TweakDBInterface.GetDisassemblingResultRecord(t"Crafting." + TDBID.Create(EnumValueToString("gamedataItemType", Cast(EnumInt(itemType)))));
    dissResult.Ingredients(ingredients);
    itemData = GameInstance.GetTransactionSystem(this.GetGameInstance()).GetItemData(target, itemID);
    itemQual = RPGManager.GetItemQuality(itemData);
    i = 0;
    while i < amount {
      ArrayClear(outResult);
      j = 0;
      while j < ArraySize(ingredients) {
        newIngrData = this.CreateIngredientData(ingredients[j]);
        this.AddIngredientToResult(newIngrData, outResult);
        j += 1;
      };
      itemQual = RPGManager.GetItemQuality(itemData);
      if itemQual >= gamedataQuality.Uncommon {
        newIngrData = this.CreateIngredientData(RPGManager.GetCraftingMaterialRecord(gamedataQuality.Uncommon), 1);
        this.AddIngredientToResult(newIngrData, outResult);
      };
      if itemQual >= gamedataQuality.Rare {
        newIngrData = this.CreateIngredientData(RPGManager.GetCraftingMaterialRecord(gamedataQuality.Rare), 1);
        this.AddIngredientToResult(newIngrData, outResult);
        newIngrData = this.CreateIngredientData(RPGManager.GetCraftingMaterialRecord(gamedataQuality.Rare, true), 1);
        this.AddIngredientToResult(newIngrData, outResult);
      };
      if itemQual >= gamedataQuality.Epic {
        newIngrData = this.CreateIngredientData(RPGManager.GetCraftingMaterialRecord(gamedataQuality.Epic), 1);
        this.AddIngredientToResult(newIngrData, outResult);
        newIngrData = this.CreateIngredientData(RPGManager.GetCraftingMaterialRecord(gamedataQuality.Epic, true), 1);
        this.AddIngredientToResult(newIngrData, outResult);
      };
      if itemQual >= gamedataQuality.Legendary {
        newIngrData = this.CreateIngredientData(RPGManager.GetCraftingMaterialRecord(gamedataQuality.Legendary), 1);
        this.AddIngredientToResult(newIngrData, outResult);
        newIngrData = this.CreateIngredientData(RPGManager.GetCraftingMaterialRecord(gamedataQuality.Legendary, true), 1);
        this.AddIngredientToResult(newIngrData, outResult);
      };
      this.ProcessDisassemblingPerks(outResult, itemData, restoredAttachments, calledFromUI);
      this.MergeIngredients(outResult, finalResult);
      i += 1;
    };
    return finalResult;
  }

  private final const func AddIngredientToResult(ingredient: IngredientData, out outputResult: array<IngredientData>) -> Void {
    let quantityIncreased: Bool;
    let i: Int32 = 0;
    while i < ArraySize(outputResult) {
      if outputResult[i].id == ingredient.id {
        outputResult[i].quantity += ingredient.quantity;
        quantityIncreased = true;
      };
      i += 1;
    };
    if !quantityIncreased {
      ArrayPush(outputResult, ingredient);
    };
  }

  private final const func MergeIngredients(input: array<IngredientData>, out output: array<IngredientData>) -> Void {
    let j: Int32;
    let quantityIncreased: Bool;
    let i: Int32 = 0;
    while i < ArraySize(input) {
      quantityIncreased = false;
      j = 0;
      while j < ArraySize(output) {
        if output[i].id == input[j].id {
          output[i].quantity += input[j].quantity;
          quantityIncreased = true;
        };
        j += 1;
      };
      if !quantityIncreased {
        ArrayPush(output, input[j]);
      };
      i += 1;
    };
  }

  private final const func DisassembleItem(target: wref<GameObject>, itemID: ItemID, amount: Int32) -> Void {
    let restoredAttachments: array<ItemAttachments>;
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
    let listOfIngredients: array<IngredientData> = this.GetDisassemblyResultItems(target, itemID, amount, restoredAttachments);
    let i: Int32 = 0;
    while i < ArraySize(restoredAttachments) {
      transactionSystem.RemovePart(this.m_playerCraftBook.GetOwner(), itemID, restoredAttachments[i].attachmentSlotID);
      transactionSystem.GiveItem(this.m_playerCraftBook.GetOwner(), restoredAttachments[i].itemID, 1);
      i += 1;
    };
    GameInstance.GetTelemetrySystem(this.GetGameInstance()).LogItemDisassembled(ToTelemetryInventoryItem(target, itemID));
    transactionSystem.RemoveItem(target, itemID, amount);
    i = 0;
    while i < ArraySize(listOfIngredients) {
      transactionSystem.GiveItem(target, ItemID.FromTDBID(listOfIngredients[i].id.GetID()), listOfIngredients[i].quantity);
      i += 1;
    };
    this.UpdateBlackboard(CraftingCommands.DisassemblingFinished, itemID, listOfIngredients);
  }

  private final func UpgradeItem(owner: wref<GameObject>, itemID: ItemID) -> Void {
    let ingredientQuality: gamedataQuality;
    let mod: ref<gameStatModifierData>;
    let recipeXP: Int32;
    let xpID: TweakDBID;
    let randF: Float = RandF();
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGameInstance());
    let TS: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
    let itemData: wref<gameItemData> = TS.GetItemData(owner, itemID);
    let oldVal: Float = itemData.GetStatValueByType(gamedataStatType.WasItemUpgraded);
    let newVal: Float = oldVal + 1.00;
    let tempStat: Float = statsSystem.GetStatValue(Cast(owner.GetEntityID()), gamedataStatType.UpgradingMaterialRetrieveChance);
    let ingredients: array<IngredientData> = this.GetItemFinalUpgradeCost(itemData);
    let i: Int32 = 0;
    while i < ArraySize(ingredients) {
      if randF >= tempStat {
        TS.RemoveItem(owner, ItemID.CreateQuery(ingredients[i].id.GetID()), ingredients[i].quantity);
      };
      ingredientQuality = RPGManager.GetItemQualityFromRecord(TweakDBInterface.GetItemRecord(ingredients[i].id.GetID()));
      switch ingredientQuality {
        case gamedataQuality.Common:
          xpID = t"Constants.CraftingSystem.commonIngredientXP";
          break;
        case gamedataQuality.Uncommon:
          xpID = t"Constants.CraftingSystem.uncommonIngredientXP";
          break;
        case gamedataQuality.Rare:
          xpID = t"Constants.CraftingSystem.rareIngredientXP";
          break;
        case gamedataQuality.Epic:
          xpID = t"Constants.CraftingSystem.epicIngredientXP";
          break;
        case gamedataQuality.Legendary:
          xpID = t"Constants.CraftingSystem.legendaryIngredientXP";
          break;
        default:
      };
      recipeXP += TweakDBInterface.GetInt(xpID, 0) * ingredients[i].quantity;
      i += 1;
    };
    statsSystem.RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.WasItemUpgraded, true);
    mod = RPGManager.CreateStatModifier(gamedataStatType.WasItemUpgraded, gameStatModifierType.Additive, newVal);
    statsSystem.AddSavedModifier(itemData.GetStatsObjectID(), mod);
    this.ProcessCraftSkill(recipeXP, itemData.GetStatsObjectID());
  }

  private final func ProcessUpgradingPerksData(target: wref<GameObject>, itemRecord: ref<Item_Record>) -> Void {
    let randI: Int32;
    let recipe: array<wref<RecipeElement_Record>>;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGameInstance());
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
    let randF: Float = RandF();
    let tempStat: Float = statsSystem.GetStatValue(Cast(target.GetEntityID()), gamedataStatType.UpgradingMaterialRandomGrantChance);
    if randF <= tempStat {
      randI = RandRange(0, ArraySize(recipe) - 1);
      transactionSystem.GiveItemByTDBID(target, recipe[randI].Ingredient().GetID(), 1);
    };
  }

  private final func ProcessCraftingPerksData(target: wref<GameObject>, itemRecord: ref<Item_Record>, craftedItem: wref<gameItemData>) -> Void {
    let statMod: ref<gameStatModifierData>;
    let tempStat: Float;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGameInstance());
    if Equals(RPGManager.GetItemCategory(craftedItem.GetID()), gamedataItemCategory.Weapon) {
      tempStat = statsSystem.GetStatValue(Cast(target.GetEntityID()), gamedataStatType.CraftingBonusWeaponDamage);
      if tempStat > 0.00 {
        statMod = RPGManager.CreateStatModifier(gamedataStatType.CraftingBonusWeaponDamage, gameStatModifierType.Additive, tempStat);
        statsSystem.AddSavedModifier(craftedItem.GetStatsObjectID(), statMod);
      };
      tempStat = statsSystem.GetStatValue(Cast(target.GetEntityID()), gamedataStatType.CanLegendaryCraftedWeaponsBeBoosted);
      if tempStat > 0.00 {
        statMod = RPGManager.CreateStatModifier(gamedataStatType.CanLegendaryCraftedWeaponsBeBoosted, gameStatModifierType.Additive, tempStat);
        statsSystem.AddSavedModifier(craftedItem.GetStatsObjectID(), statMod);
      };
    };
    if Equals(RPGManager.GetItemCategory(craftedItem.GetID()), gamedataItemCategory.Clothing) {
      tempStat = statsSystem.GetStatValue(Cast(target.GetEntityID()), gamedataStatType.CraftingBonusArmorValue);
      if tempStat > 0.00 {
        statMod = RPGManager.CreateStatModifier(gamedataStatType.CraftingBonusArmorValue, gameStatModifierType.Additive, tempStat);
        statsSystem.AddSavedModifier(craftedItem.GetStatsObjectID(), statMod);
      };
    };
  }

  private final const func ProcessDisassemblingPerks(out disassembleResult: array<IngredientData>, itemData: wref<gameItemData>, out restoredAttachments: array<ItemAttachments>, opt calledFromUI: Bool) -> Void {
    let i: Int32;
    let innerPart: InnerItemData;
    let innerPartID: ItemID;
    let itemCategory: gamedataItemCategory;
    let matQuality: gamedataQuality;
    let newIngrData: IngredientData;
    let partTags: array<CName>;
    let rand: Float;
    let slotsToCheck: array<TweakDBID>;
    let tempArr: array<TweakDBID>;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGameInstance());
    let tempStat: Float = statsSystem.GetStatValue(Cast(this.m_playerCraftBook.GetOwner().GetEntityID()), gamedataStatType.DisassemblingIngredientsDoubleBonus);
    if tempStat > 0.00 {
      i = 0;
      while i < ArraySize(disassembleResult) {
        disassembleResult[i].quantity = Cast(Cast(disassembleResult[i].quantity) * 1.50);
        i += 1;
      };
    };
    if !calledFromUI {
      tempStat = statsSystem.GetStatValue(Cast(this.m_playerCraftBook.GetOwner().GetEntityID()), gamedataStatType.DisassemblingMaterialQualityObtainChance);
      rand = RandF();
      if rand < tempStat {
        matQuality = RPGManager.GetItemDataQuality(itemData);
        if NotEquals(matQuality, gamedataQuality.Invalid) {
          i = 0;
          while i < ArraySize(disassembleResult) {
            if Equals(matQuality, RPGManager.GetItemQualityFromRecord(disassembleResult[i].id)) {
              rand = RandF();
              if rand < 0.50 {
                newIngrData = this.CreateIngredientData(RPGManager.GetCraftingMaterialRecord(matQuality), 1);
                this.AddIngredientToResult(newIngrData, disassembleResult);
              } else {
                newIngrData = this.CreateIngredientData(RPGManager.GetCraftingMaterialRecord(matQuality, true), 1);
                this.AddIngredientToResult(newIngrData, disassembleResult);
              };
            };
            i += 1;
          };
        };
      };
      tempStat = statsSystem.GetStatValue(Cast(this.m_playerCraftBook.GetOwner().GetEntityID()), gamedataStatType.DisassemblingMaterialQualityObtainChance);
      rand = RandF();
      tempStat /= 4.00;
      if rand < tempStat {
        matQuality = RPGManager.GetItemDataQuality(itemData);
        if NotEquals(matQuality, gamedataQuality.Invalid) && matQuality <= gamedataQuality.Epic {
          matQuality = RPGManager.GetBumpedQuality(matQuality);
          rand = RandF();
          if rand < 0.50 {
            newIngrData = this.CreateIngredientData(RPGManager.GetCraftingMaterialRecord(matQuality), 1);
            this.AddIngredientToResult(newIngrData, disassembleResult);
          } else {
            newIngrData = this.CreateIngredientData(RPGManager.GetCraftingMaterialRecord(matQuality, true), 1);
            this.AddIngredientToResult(newIngrData, disassembleResult);
          };
        };
      };
    };
    itemCategory = RPGManager.GetItemCategory(itemData.GetID());
    if Equals(itemCategory, gamedataItemCategory.Weapon) || Equals(itemCategory, gamedataItemCategory.Clothing) {
      slotsToCheck = RPGManager.GetAttachmentSlotIDs();
      if statsSystem.GetStatValue(Cast(this.m_playerCraftBook.GetOwner().GetEntityID()), gamedataStatType.CanRetrieveModsFromDisassemble) > 0.00 {
        tempArr = RPGManager.GetModsSlotIDs(itemData.GetItemType());
        i = 0;
        while i < ArraySize(tempArr) {
          ArrayPush(slotsToCheck, tempArr[i]);
          i += 1;
        };
      };
      i = 0;
      while i < ArraySize(slotsToCheck) {
        itemData.GetItemPart(innerPart, slotsToCheck[i]);
        innerPartID = InnerItemData.GetItemID(innerPart);
        partTags = InnerItemData.GetStaticData(innerPart).Tags();
        if ItemID.IsValid(innerPartID) && !ArrayContains(partTags, n"DummyPart") {
          ArrayPush(restoredAttachments, ItemAttachments.Create(innerPartID, slotsToCheck[i]));
        };
        i += 1;
      };
    };
  }

  private final func ProcessCraftSkill(xpAmount: Int32, craftedItem: StatsObjectID) -> Void {
    let xpEvent: ref<ExperiencePointsEvent> = new ExperiencePointsEvent();
    xpEvent.amount = xpAmount;
    xpEvent.type = gamedataProficiencyType.Crafting;
    GetPlayer(this.GetGameInstance()).QueueEvent(xpEvent);
  }

  public final const func GetRecipeData(itemRecord: ref<Item_Record>) -> ref<RecipeData> {
    let i: Int32;
    let listOfIngredients: array<IngredientData>;
    let tempListOfIngredients: array<wref<RecipeElement_Record>>;
    let tempRecipeData: ItemRecipe = this.m_playerCraftBook.GetRecipeData(itemRecord.GetID());
    let tempItemCategory: ref<ItemCategory_Record> = itemRecord.ItemCategory();
    let newRecipeData: ref<RecipeData> = new RecipeData();
    newRecipeData.label = GetLocalizedItemNameByCName(itemRecord.DisplayName());
    newRecipeData.icon = itemRecord.IconPath();
    newRecipeData.iconGender = this.m_itemIconGender;
    newRecipeData.description = GetLocalizedItemNameByCName(itemRecord.LocalizedDescription());
    newRecipeData.type = LocKeyToString(tempItemCategory.LocalizedCategory());
    newRecipeData.id = itemRecord;
    newRecipeData.amount = tempRecipeData.amount;
    itemRecord.CraftingData().CraftingRecipe(tempListOfIngredients);
    i = 0;
    while i < ArraySize(tempListOfIngredients) {
      ArrayPush(listOfIngredients, this.CreateIngredientData(tempListOfIngredients[i]));
      i += 1;
    };
    newRecipeData.ingredients = listOfIngredients;
    return newRecipeData;
  }

  public final const func GetUpgradeRecipeData(itemID: ItemID) -> ref<RecipeData> {
    let itemdata: wref<gameItemData> = GameInstance.GetTransactionSystem(this.GetGameInstance()).GetItemData(GetPlayer(this.GetGameInstance()), itemID);
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
    let tempItemCategory: ref<ItemCategory_Record> = itemRecord.ItemCategory();
    let newRecipeData: ref<RecipeData> = new RecipeData();
    newRecipeData.label = GetLocalizedItemNameByCName(itemRecord.DisplayName());
    newRecipeData.icon = itemRecord.IconPath();
    newRecipeData.iconGender = this.m_itemIconGender;
    newRecipeData.description = GetLocalizedItemNameByCName(itemRecord.LocalizedDescription());
    newRecipeData.type = LocKeyToString(tempItemCategory.LocalizedCategory());
    newRecipeData.id = itemRecord;
    newRecipeData.ingredients = this.GetItemFinalUpgradeCost(itemdata);
    return newRecipeData;
  }

  private final const func GetIngredientQuality(data: IngredientData) -> gamedataQuality {
    let quality: gamedataQuality = RPGManager.GetItemQualityFromRecord(data.id);
    return quality;
  }

  private final const func CreateIngredientData(ingredientData: ref<RecipeElement_Record>) -> IngredientData {
    let newIngredientData: IngredientData;
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
    let itemRecord: wref<Item_Record> = ingredientData.Ingredient();
    newIngredientData.quantity = ingredientData.Amount();
    newIngredientData.baseQuantity = ingredientData.Amount();
    newIngredientData.label = itemRecord.FriendlyName();
    newIngredientData.inventoryQuantity = transactionSystem.GetItemQuantity(this.m_playerCraftBook.GetOwner(), ItemID.CreateQuery(itemRecord.GetID()));
    newIngredientData.id = itemRecord;
    newIngredientData.icon = itemRecord.IconPath();
    newIngredientData.iconGender = this.m_itemIconGender;
    return newIngredientData;
  }

  private final const func CreateIngredientData(item: ref<Item_Record>, amount: Int32) -> IngredientData {
    let newIngredientData: IngredientData;
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
    newIngredientData.quantity = amount;
    newIngredientData.label = item.FriendlyName();
    newIngredientData.inventoryQuantity = transactionSystem.GetItemQuantity(this.m_playerCraftBook.GetOwner(), ItemID.CreateQuery(item.GetID()));
    newIngredientData.id = item;
    newIngredientData.icon = item.IconPath();
    newIngredientData.iconGender = this.m_itemIconGender;
    return newIngredientData;
  }

  private final const func UpdateBlackboard(lastCommand: CraftingCommands, opt lastItem: ItemID, opt lastIngredients: array<IngredientData>) -> Void {
    let Blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_Crafting);
    if IsDefined(Blackboard) {
      Blackboard.SetVariant(GetAllBlackboardDefs().UI_Crafting.lastCommand, ToVariant(lastCommand), true);
      Blackboard.SetVariant(GetAllBlackboardDefs().UI_Crafting.lastItem, ToVariant(lastItem), true);
      if ArraySize(lastIngredients) > 0 {
        Blackboard.SetVariant(GetAllBlackboardDefs().UI_Crafting.lastIngredients, ToVariant(lastIngredients));
      };
    };
  }

  private final func SendItemCraftedDataTrackingRequest(targetItem: ItemID) -> Void {
    let request: ref<ItemCraftedDataTrackingRequest> = new ItemCraftedDataTrackingRequest();
    request.targetItem = targetItem;
    let dataTrackingSystem: ref<DataTrackingSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"DataTrackingSystem") as DataTrackingSystem;
    dataTrackingSystem.QueueRequest(request);
  }

  private final func ProcessIconicRevampRestoration() -> Void {
    let TS: ref<TransactionSystem>;
    let i: Int32;
    let itemList: array<wref<gameItemData>>;
    let player: wref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
    if IsDefined(player) {
      TS = GameInstance.GetTransactionSystem(this.GetGameInstance());
      TS.GetItemList(player, itemList);
    };
    i = 0;
    while i < ArraySize(itemList) {
      if RPGManager.IsItemIconic(itemList[i]) && RPGManager.IsItemWeapon(itemList[i].GetID()) {
        this.ClearNonIconicSlots(itemList[i]);
        RPGManager.ProcessOnLootedPackages(player, itemList[i].GetID());
      };
      i += 1;
    };
  }

  private final func ProcessCraftedItemsPowerBoost() -> Void {
    let i: Int32;
    let itemList: array<wref<gameItemData>>;
    let statMod: ref<gameStatModifierData>;
    let statsSystem: ref<StatsSystem>;
    let tempStat: Float;
    let transactionSystem: ref<TransactionSystem>;
    let player: wref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
    if IsDefined(player) {
      transactionSystem = GameInstance.GetTransactionSystem(this.GetGameInstance());
      statsSystem = GameInstance.GetStatsSystem(this.GetGameInstance());
      transactionSystem.GetItemList(player, itemList);
    };
    i = 0;
    while i < ArraySize(itemList) {
      if RPGManager.IsItemCrafted(itemList[i]) {
        if RPGManager.IsItemWeapon(itemList[i].GetID()) {
          tempStat = statsSystem.GetStatValue(Cast(player.GetEntityID()), gamedataStatType.CraftingBonusWeaponDamage);
          if tempStat > 0.00 {
            statMod = RPGManager.CreateStatModifier(gamedataStatType.CraftingBonusWeaponDamage, gameStatModifierType.Additive, tempStat);
            statsSystem.RemoveAllModifiers(itemList[i].GetStatsObjectID(), gamedataStatType.CraftingBonusWeaponDamage, true);
            statsSystem.AddSavedModifier(itemList[i].GetStatsObjectID(), statMod);
          };
        } else {
          if RPGManager.IsItemClothing(itemList[i].GetID()) {
            tempStat = statsSystem.GetStatValue(Cast(player.GetEntityID()), gamedataStatType.CraftingBonusArmorValue);
            if tempStat > 0.00 {
              statMod = RPGManager.CreateStatModifier(gamedataStatType.CraftingBonusArmorValue, gameStatModifierType.Additive, tempStat);
              statsSystem.RemoveAllModifiers(itemList[i].GetStatsObjectID(), gamedataStatType.CraftingBonusArmorValue, true);
              statsSystem.AddSavedModifier(itemList[i].GetStatsObjectID(), statMod);
            };
          };
        };
      };
      i += 1;
    };
  }

  private final func AddAmmoRecipes() -> Void {
    this.m_playerCraftBook.AddRecipe(t"Ammo.HandgunAmmo", CraftingSystem.GetAmmoBulletAmount(t"Ammo.HandgunAmmo"));
    this.m_playerCraftBook.AddRecipe(t"Ammo.ShotgunAmmo", CraftingSystem.GetAmmoBulletAmount(t"Ammo.ShotgunAmmo"));
    this.m_playerCraftBook.AddRecipe(t"Ammo.RifleAmmo", CraftingSystem.GetAmmoBulletAmount(t"Ammo.RifleAmmo"));
    this.m_playerCraftBook.AddRecipe(t"Ammo.SniperRifleAmmo", CraftingSystem.GetAmmoBulletAmount(t"Ammo.SniperRifleAmmo"));
  }

  public final static func GetAmmoBulletAmount(ammoId: TweakDBID) -> Int32 {
    let ammoRecipeId: TweakDBID;
    let amount: Int32;
    let craftingResult: wref<CraftingResult_Record>;
    let recipeRecord: wref<ItemRecipe_Record>;
    switch ammoId {
      case t"Ammo.HandgunAmmo":
        ammoRecipeId = t"Ammo.RecipeHandgunAmmo";
        break;
      case t"Ammo.ShotgunAmmo":
        ammoRecipeId = t"Ammo.RecipeShotgunAmmo";
        break;
      case t"Ammo.RifleAmmo":
        ammoRecipeId = t"Ammo.RecipeRifleAmmo";
        break;
      case t"Ammo.SniperRifleAmmo":
        ammoRecipeId = t"Ammo.RecipeSniperRifleAmmo";
    };
    recipeRecord = TweakDBInterface.GetItemRecipeRecord(ammoRecipeId);
    craftingResult = recipeRecord.CraftingResult();
    amount = craftingResult.Amount();
    return amount;
  }
}

public class CraftBook extends IScriptable {

  protected persistent let m_knownRecipes: array<ItemRecipe>;

  public let m_newRecipes: array<TweakDBID>;

  public let m_owner: wref<GameObject>;

  public final func InitializeCraftBookOwner(owner: wref<GameObject>) -> Void {
    this.m_owner = owner;
    return;
  }

  public final func InitializeCraftBook(owner: wref<GameObject>, recipes: wref<Craftable_Record>) -> Void {
    let craftItems: array<wref<Item_Record>>;
    let i: Int32;
    recipes.CraftableItem(craftItems);
    i = 0;
    while i < ArraySize(craftItems) {
      if this.GetRecipeIndex(craftItems[i].GetID()) == -1 {
        this.AddRecipe(craftItems[i].GetID());
      };
      i += 1;
    };
    return;
  }

  public final const func GetCraftableItems() -> array<wref<Item_Record>> {
    let itemList: array<wref<Item_Record>>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_knownRecipes) {
      if !this.m_knownRecipes[i].isHidden {
        ArrayPush(itemList, TweakDBInterface.GetItemRecord(this.m_knownRecipes[i].targetItem));
      };
      i += 1;
    };
    return itemList;
  }

  public final const func GetRecipeData(Recipe: TweakDBID) -> ItemRecipe {
    let nullRecipe: ItemRecipe;
    let index: Int32 = this.GetRecipeIndex(Recipe);
    if index != -1 {
      return this.m_knownRecipes[index];
    };
    return nullRecipe;
  }

  public final const func GetRecipeIndex(recipe: TweakDBID) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_knownRecipes) {
      if this.m_knownRecipes[i].targetItem == recipe {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  public final func AddRecipe(targetItem: TweakDBID, opt hideOnItemsAdded: array<wref<Item_Record>>, opt amount: Int32) -> Void {
    let i: Int32;
    let itemID: ItemID;
    let itemRecipe: ItemRecipe;
    let transactionSystem: ref<TransactionSystem>;
    if !TDBID.IsValid(targetItem) {
      return;
    };
    itemRecipe.targetItem = targetItem;
    if amount > 0 && amount != 1 {
      itemRecipe.amount = amount;
    } else {
      itemRecipe.amount = 1;
    };
    if ArraySize(hideOnItemsAdded) > 0 {
      transactionSystem = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
      i = 0;
      while i < ArraySize(hideOnItemsAdded) {
        itemID = ItemID.CreateQuery(hideOnItemsAdded[i].GetID());
        if transactionSystem.HasItem(this.m_owner, itemID) {
          itemRecipe.isHidden = true;
        } else {
          i += 1;
        };
      };
    };
    i = this.GetRecipeIndex(targetItem);
    if i != -1 {
      this.m_knownRecipes[i] = itemRecipe;
      return;
    };
    ArrayPush(this.m_knownRecipes, itemRecipe);
    ArrayPush(this.m_newRecipes, itemRecipe.targetItem);
  }

  public final func SetRecipeInspected(itemID: TweakDBID) -> Void {
    if ArrayContains(this.m_newRecipes, itemID) {
      ArrayRemove(this.m_newRecipes, itemID);
    };
  }

  public final func IsRecipeNew(itemID: TweakDBID) -> Bool {
    return ArrayContains(this.m_newRecipes, itemID);
  }

  public final func HideRecipe(recipe: TweakDBID, shouldHide: Bool) -> Bool {
    let index: Int32 = this.GetRecipeIndex(recipe);
    if index != -1 {
      this.m_knownRecipes[index].isHidden = shouldHide;
      return true;
    };
    return false;
  }

  public final const func GetOwner() -> wref<GameObject> {
    return this.m_owner;
  }

  public final func ResetRecipeCraftedAmount() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_knownRecipes) {
      if this.m_knownRecipes[i].amount == 0 {
        this.m_knownRecipes[i].amount = 1;
      };
      i += 1;
    };
  }
}

public class CraftingSystemInventoryCallback extends InventoryScriptCallback {

  public let player: wref<PlayerPuppet>;

  public func OnItemAdded(item: ItemID, itemData: wref<gameItemData>, flaggedAsSilent: Bool) -> Void {
    let addRecipeRequest: ref<AddRecipeRequest>;
    let craftingSystem: ref<CraftingSystem>;
    let itemToAdd: wref<CraftingResult_Record>;
    let recipeRecord: wref<ItemRecipe_Record>;
    let transactionSystem: ref<TransactionSystem>;
    if itemData.HasTag(n"Recipe") {
      transactionSystem = GameInstance.GetTransactionSystem(this.player.GetGame());
      craftingSystem = GameInstance.GetScriptableSystemsContainer(this.player.GetGame()).Get(n"CraftingSystem") as CraftingSystem;
      recipeRecord = TweakDBInterface.GetItemRecipeRecord(ItemID.GetTDBID(item));
      itemToAdd = recipeRecord.CraftingResult();
      addRecipeRequest = new AddRecipeRequest();
      addRecipeRequest.recipe = itemToAdd.Item().GetID();
      addRecipeRequest.amount = itemToAdd.Amount();
      if recipeRecord.GetHideOnItemsAddedCount() > 0 {
        recipeRecord.HideOnItemsAdded(addRecipeRequest.hideOnItemsAdded);
      };
      craftingSystem.QueueRequest(addRecipeRequest);
      transactionSystem.RemoveItem(this.player, item, transactionSystem.GetItemQuantity(this.player, item));
    };
  }
}
