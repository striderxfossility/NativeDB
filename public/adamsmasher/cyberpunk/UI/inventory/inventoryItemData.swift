
public struct InventoryItemData {

  @default(InventoryItemData, true)
  private let Empty: Bool;

  private let ID: ItemID;

  private let SlotID: TweakDBID;

  private let Name: String;

  private let Quality: CName;

  private let Quantity: Int32;

  private let Ammo: Int32;

  private let Shape: EInventoryItemShape;

  private let ItemShape: EInventoryItemShape;

  private let IconPath: String;

  private let CategoryName: String;

  private let ItemType: gamedataItemType;

  private let LocalizedItemType: String;

  private let Description: String;

  private let AdditionalDescription: String;

  private let Price: Float;

  private let BuyPrice: Float;

  private let UnlockProgress: Float;

  private let RequiredLevel: Int32;

  private let ItemLevel: Int32;

  @default(InventoryItemData, gamedataDamageType.Invalid)
  private let DamageType: gamedataDamageType;

  @default(InventoryItemData, gamedataEquipmentArea.Invalid)
  private let EquipmentArea: gamedataEquipmentArea;

  @default(InventoryItemData, gamedataQuality.Invalid)
  private let ComparedQuality: gamedataQuality;

  @default(InventoryItemData, false)
  private let IsPart: Bool;

  @default(InventoryItemData, false)
  private let IsCraftingMaterial: Bool;

  @default(InventoryItemData, false)
  private let IsEquipped: Bool;

  @default(InventoryItemData, false)
  private let IsNew: Bool;

  @default(InventoryItemData, true)
  private let IsAvailable: Bool;

  @default(InventoryItemData, false)
  private let IsVendorItem: Bool;

  @default(InventoryItemData, false)
  private let IsBroken: Bool;

  private let SlotIndex: Int32;

  @default(InventoryItemData, 4294967295)
  private let PositionInBackpack: Uint32;

  @default(InventoryItemData, ItemIconGender.Female)
  private let IconGender: ItemIconGender;

  private let GameItemData: wref<gameItemData>;

  private let HasPlayerSmartGunLink: Bool;

  private let PlayerLevel: Int32;

  private let PlayerStrenght: Int32;

  private let PlayerReflexes: Int32;

  private let PlayerStreetCred: Int32;

  @default(InventoryItemData, true)
  private let IsRequirementMet: Bool;

  @default(InventoryItemData, true)
  private let IsEquippable: Bool;

  private let Requirement: SItemStackRequirementData;

  private let EquipRequirement: SItemStackRequirementData;

  private let LootItemType: LootItemType;

  private let Attachments: array<InventoryItemAttachments>;

  private let Abilities: array<InventoryItemAbility>;

  private let PlacementSlots: array<TweakDBID>;

  private let PrimaryStats: array<StatViewData>;

  private let SecondaryStats: array<StatViewData>;

  private let SortData: InventoryItemSortData;

  public final static func SetEmpty(out self: InventoryItemData, empty: Bool) -> Void {
    self.Empty = empty;
  }

  public final static func IsEmpty(self: InventoryItemData) -> Bool {
    return self.Empty;
  }

  public final static func SetID(out self: InventoryItemData, id: ItemID) -> Void {
    self.ID = id;
  }

  public final static func GetID(self: InventoryItemData) -> ItemID {
    return self.ID;
  }

  public final static func SetSlotID(out self: InventoryItemData, id: TweakDBID) -> Void {
    self.SlotID = id;
  }

  public final static func GetSlotID(self: InventoryItemData) -> TweakDBID {
    return self.SlotID;
  }

  public final static func SetName(out self: InventoryItemData, Name: String) -> Void {
    self.Name = Name;
  }

  public final static func GetName(self: InventoryItemData) -> String {
    return self.Name;
  }

  public final static func SetQuality(out self: InventoryItemData, quality: CName) -> Void {
    self.Quality = quality;
  }

  public final static func GetQuality(self: InventoryItemData) -> CName {
    return self.Quality;
  }

  public final static func SetQuantity(out self: InventoryItemData, quantity: Int32) -> Void {
    self.Quantity = quantity;
  }

  public final static func GetQuantity(self: InventoryItemData) -> Int32 {
    return self.Quantity;
  }

  public final static func SetAmmo(out self: InventoryItemData, ammo: Int32) -> Void {
    self.Ammo = ammo;
  }

  public final static func GetAmmo(self: InventoryItemData) -> Int32 {
    return self.Ammo;
  }

  public final static func SetShape(out self: InventoryItemData, shape: EInventoryItemShape) -> Void {
    self.Shape = shape;
  }

  public final static func GetShape(self: InventoryItemData) -> EInventoryItemShape {
    return self.Shape;
  }

  public final static func SetItemShape(out self: InventoryItemData, shape: EInventoryItemShape) -> Void {
    self.ItemShape = shape;
  }

  public final static func GetItemShape(self: InventoryItemData) -> EInventoryItemShape {
    return self.ItemShape;
  }

  public final static func SetIconPath(out self: InventoryItemData, iconPath: String) -> Void {
    self.IconPath = iconPath;
  }

  public final static func GetIconPath(self: InventoryItemData) -> String {
    return self.IconPath;
  }

  public final static func SetCategoryName(out self: InventoryItemData, categoryName: String) -> Void {
    self.CategoryName = categoryName;
  }

  public final static func GetCategoryName(self: InventoryItemData) -> String {
    return self.CategoryName;
  }

  public final static func SetItemType(out self: InventoryItemData, itemType: gamedataItemType) -> Void {
    self.ItemType = itemType;
  }

  public final static func GetItemType(self: InventoryItemData) -> gamedataItemType {
    return self.ItemType;
  }

  public final static func SetLocalizedItemType(out self: InventoryItemData, localizedItemType: String) -> Void {
    self.LocalizedItemType = localizedItemType;
  }

  public final static func GetLocalizedItemType(self: InventoryItemData) -> String {
    return self.LocalizedItemType;
  }

  public final static func SetDescription(out self: InventoryItemData, description: String) -> Void {
    self.Description = description;
  }

  public final static func GetDescription(self: InventoryItemData) -> String {
    return self.Description;
  }

  public final static func SetAdditionalDescription(out self: InventoryItemData, description: String) -> Void {
    self.AdditionalDescription = description;
  }

  public final static func GetAdditionalDescription(self: InventoryItemData) -> String {
    return self.AdditionalDescription;
  }

  public final static func SetPrice(out self: InventoryItemData, price: Float) -> Void {
    self.Price = price;
  }

  public final static func GetPrice(self: InventoryItemData) -> Float {
    return self.Price;
  }

  public final static func SetBuyPrice(out self: InventoryItemData, price: Float) -> Void {
    self.BuyPrice = price;
  }

  public final static func GetBuyPrice(self: InventoryItemData) -> Float {
    return self.BuyPrice;
  }

  public final static func SetUnlockProgress(out self: InventoryItemData, unlockProgress: Float) -> Void {
    self.UnlockProgress = unlockProgress;
  }

  public final static func GetUnlockProgress(self: InventoryItemData) -> Float {
    return self.UnlockProgress;
  }

  public final static func SetRequiredLevel(out self: InventoryItemData, requiredLevel: Int32) -> Void {
    self.RequiredLevel = requiredLevel;
  }

  public final static func GetRequiredLevel(self: InventoryItemData) -> Int32 {
    return self.RequiredLevel;
  }

  public final static func SetItemLevel(out self: InventoryItemData, itemLevel: Int32) -> Void {
    self.ItemLevel = itemLevel;
  }

  public final static func GetItemLevel(self: InventoryItemData) -> Int32 {
    return self.ItemLevel;
  }

  public final static func SetDamageType(out self: InventoryItemData, damageType: gamedataDamageType) -> Void {
    self.DamageType = damageType;
  }

  public final static func GetDamageType(self: InventoryItemData) -> gamedataDamageType {
    return self.DamageType;
  }

  public final static func SetEquipmentArea(out self: InventoryItemData, equipmentArea: gamedataEquipmentArea) -> Void {
    self.EquipmentArea = equipmentArea;
  }

  public final static func GetEquipmentArea(self: InventoryItemData) -> gamedataEquipmentArea {
    return self.EquipmentArea;
  }

  public final static func SetComparedQuality(out self: InventoryItemData, comparedQuality: gamedataQuality) -> Void {
    self.ComparedQuality = comparedQuality;
  }

  public final static func GetComparedQuality(self: InventoryItemData) -> gamedataQuality {
    return self.ComparedQuality;
  }

  public final static func SetIsPart(out self: InventoryItemData, isPart: Bool) -> Void {
    self.IsPart = isPart;
  }

  public final static func IsPart(self: InventoryItemData) -> Bool {
    return self.IsPart;
  }

  public final static func SetIsCraftingMaterial(out self: InventoryItemData, isCraftingMaterial: Bool) -> Void {
    self.IsCraftingMaterial = isCraftingMaterial;
  }

  public final static func IsCraftingMaterial(self: InventoryItemData) -> Bool {
    return self.IsCraftingMaterial;
  }

  public final static func SetIsEquipped(out self: InventoryItemData, isEquipped: Bool) -> Void {
    self.IsEquipped = isEquipped;
  }

  public final static func IsEquipped(self: InventoryItemData) -> Bool {
    return self.IsEquipped;
  }

  public final static func SetIsNew(out self: InventoryItemData, isNew: Bool) -> Void {
    self.IsNew = isNew;
  }

  public final static func IsNew(self: InventoryItemData) -> Bool {
    return self.IsNew;
  }

  public final static func SetIsAvailable(out self: InventoryItemData, isAvailable: Bool) -> Void {
    self.IsAvailable = isAvailable;
  }

  public final static func IsAvailable(self: InventoryItemData) -> Bool {
    return self.IsAvailable;
  }

  public final static func SetIsVendorItem(out self: InventoryItemData, isVendorItem: Bool) -> Void {
    self.IsVendorItem = isVendorItem;
  }

  public final static func IsVendorItem(self: InventoryItemData) -> Bool {
    return self.IsVendorItem;
  }

  public final static func SetIsBroken(out self: InventoryItemData, isBroken: Bool) -> Void {
    self.IsBroken = isBroken;
  }

  public final static func IsBroken(self: InventoryItemData) -> Bool {
    return self.IsBroken;
  }

  public final static func SetSlotIndex(out self: InventoryItemData, slotIndex: Int32) -> Void {
    self.SlotIndex = slotIndex;
  }

  public final static func GetSlotIndex(self: InventoryItemData) -> Int32 {
    return self.SlotIndex;
  }

  public final static func SetPositionInBackpack(out self: InventoryItemData, positionInBackpack: Uint32) -> Void {
    self.PositionInBackpack = positionInBackpack;
  }

  public final static func GetPositionInBackpack(self: InventoryItemData) -> Uint32 {
    return self.PositionInBackpack;
  }

  public final static func SetIconGender(out self: InventoryItemData, iconGender: ItemIconGender) -> Void {
    self.IconGender = iconGender;
  }

  public final static func GetIconGender(self: InventoryItemData) -> ItemIconGender {
    return self.IconGender;
  }

  public final static func SetGameItemData(out self: InventoryItemData, gameItemData: ref<gameItemData>) -> Void {
    self.GameItemData = gameItemData;
  }

  public final static func GetGameItemData(self: InventoryItemData) -> ref<gameItemData> {
    return self.GameItemData;
  }

  public final static func SetHasPlayerSmartGunLink(out self: InventoryItemData, hasPlayerSmartGunLink: Bool) -> Void {
    self.HasPlayerSmartGunLink = hasPlayerSmartGunLink;
  }

  public final static func HasPlayerSmartGunLink(self: InventoryItemData) -> Bool {
    return self.HasPlayerSmartGunLink;
  }

  public final static func SetPlayerLevel(out self: InventoryItemData, playerLevel: Int32) -> Void {
    self.PlayerLevel = playerLevel;
  }

  public final static func GetPlayerLevel(self: InventoryItemData) -> Int32 {
    return self.PlayerLevel;
  }

  public final static func SetPlayerStrenght(out self: InventoryItemData, playerStrenght: Int32) -> Void {
    self.PlayerStrenght = playerStrenght;
  }

  public final static func GetPlayerStrenght(self: InventoryItemData) -> Int32 {
    return self.PlayerStrenght;
  }

  public final static func SetPlayerReflexes(out self: InventoryItemData, playerReflexes: Int32) -> Void {
    self.PlayerReflexes = playerReflexes;
  }

  public final static func GetPlayerReflexes(self: InventoryItemData) -> Int32 {
    return self.PlayerReflexes;
  }

  public final static func SetPlayerStreetCred(out self: InventoryItemData, playerStreetCred: Int32) -> Void {
    self.PlayerStreetCred = playerStreetCred;
  }

  public final static func GetPlayerStreetCred(self: InventoryItemData) -> Int32 {
    return self.PlayerStreetCred;
  }

  public final static func SetIsRequirementMet(out self: InventoryItemData, isRequirementMet: Bool) -> Void {
    self.IsRequirementMet = isRequirementMet;
  }

  public final static func IsRequirementMet(self: InventoryItemData) -> Bool {
    return self.IsRequirementMet;
  }

  public final static func SetRequirement(out self: InventoryItemData, requirement: SItemStackRequirementData) -> Void {
    self.Requirement = requirement;
  }

  public final static func GetRequirement(self: InventoryItemData) -> SItemStackRequirementData {
    return self.Requirement;
  }

  public final static func SetIsEquippable(out self: InventoryItemData, isEquippable: Bool) -> Void {
    self.IsEquippable = isEquippable;
  }

  public final static func IsEquippable(self: InventoryItemData) -> Bool {
    return self.IsEquippable;
  }

  public final static func SetEquipRequirement(out self: InventoryItemData, requirement: SItemStackRequirementData) -> Void {
    self.EquipRequirement = requirement;
  }

  public final static func GetEquipRequirement(self: InventoryItemData) -> SItemStackRequirementData {
    return self.EquipRequirement;
  }

  public final static func SetLootItemType(out self: InventoryItemData, lootItemType: LootItemType) -> Void {
    self.LootItemType = lootItemType;
  }

  public final static func GetLootItemType(self: InventoryItemData) -> LootItemType {
    return self.LootItemType;
  }

  public final static func GetAttachmentsSize(self: InventoryItemData) -> Int32 {
    return ArraySize(self.Attachments);
  }

  public final static func GetAttachments(self: InventoryItemData) -> array<InventoryItemAttachments> {
    return self.Attachments;
  }

  public final static func GetAttachment(self: InventoryItemData, index: Int32) -> InventoryItemAttachments {
    return self.Attachments[index];
  }

  public final static func SetAttachments(out self: InventoryItemData, attachments: array<InventoryItemAttachments>) -> Void {
    self.Attachments = attachments;
  }

  public final static func GetAbilitiesSize(self: InventoryItemData) -> Int32 {
    return ArraySize(self.Abilities);
  }

  public final static func GetAbilities(self: InventoryItemData) -> array<InventoryItemAbility> {
    return self.Abilities;
  }

  public final static func GetAbility(self: InventoryItemData, index: Int32) -> InventoryItemAbility {
    return self.Abilities[index];
  }

  public final static func SetAbilities(out self: InventoryItemData, abilities: array<InventoryItemAbility>) -> Void {
    self.Abilities = abilities;
  }

  public final static func PlacementSlotsContains(self: InventoryItemData, slot: TweakDBID) -> Bool {
    return ArrayContains(self.PlacementSlots, slot);
  }

  public final static func AddPlacementSlot(out self: InventoryItemData, slot: TweakDBID) -> Void {
    return ArrayPush(self.PlacementSlots, slot);
  }

  public final static func GetPrimaryStatsSize(self: InventoryItemData) -> Int32 {
    return ArraySize(self.PrimaryStats);
  }

  public final static func GetPrimaryStats(self: InventoryItemData) -> array<StatViewData> {
    return self.PrimaryStats;
  }

  public final static func GetPrimaryStat(self: InventoryItemData, index: Int32) -> StatViewData {
    return self.PrimaryStats[index];
  }

  public final static func SetPrimaryStats(out self: InventoryItemData, primaryStats: array<StatViewData>) -> Void {
    self.PrimaryStats = primaryStats;
  }

  public final static func GetSecondaryStatsSize(self: InventoryItemData) -> Int32 {
    return ArraySize(self.SecondaryStats);
  }

  public final static func GetSecondaryStats(self: InventoryItemData) -> array<StatViewData> {
    return self.SecondaryStats;
  }

  public final static func GetSecondaryStat(self: InventoryItemData, index: Int32) -> StatViewData {
    return self.SecondaryStats[index];
  }

  public final static func SetSecondaryStats(out self: InventoryItemData, secondaryStats: array<StatViewData>) -> Void {
    self.SecondaryStats = secondaryStats;
  }

  public final static func GetDPS(self: InventoryItemData) -> Int32 {
    let i: Int32;
    let limit: Int32;
    if !self.Empty {
      i = 0;
      limit = ArraySize(self.PrimaryStats);
      while i < limit {
        if Equals(self.PrimaryStats[i].type, gamedataStatType.EffectiveDPS) {
          return self.PrimaryStats[i].value;
        };
        i += 1;
      };
    };
    return 0;
  }

  public final static func GetDPSF(self: InventoryItemData) -> Float {
    let i: Int32;
    let limit: Int32;
    if !self.Empty {
      i = 0;
      limit = ArraySize(self.PrimaryStats);
      while i < limit {
        if Equals(self.PrimaryStats[i].type, gamedataStatType.EffectiveDPS) {
          return self.PrimaryStats[i].valueF;
        };
        i += 1;
      };
    };
    return 0.00;
  }

  public final static func GetArmorF(self: InventoryItemData) -> Float {
    let i: Int32;
    let limit: Int32;
    if !self.Empty {
      i = 0;
      limit = ArraySize(self.SecondaryStats);
      while i < limit {
        if Equals(self.SecondaryStats[i].type, gamedataStatType.Armor) {
          return self.SecondaryStats[i].valueF;
        };
        i += 1;
      };
    };
    return 0.00;
  }

  public final static func SetSortData(out self: InventoryItemData, sortData: InventoryItemSortData) -> Void {
    self.SortData = sortData;
  }

  public final static func GetSortData(self: InventoryItemData) -> InventoryItemSortData {
    return self.SortData;
  }

  public final static func IsWeapon(self: InventoryItemData) -> Bool {
    return Equals(self.EquipmentArea, gamedataEquipmentArea.Weapon) || Equals(self.EquipmentArea, gamedataEquipmentArea.WeaponHeavy) || Equals(self.EquipmentArea, gamedataEquipmentArea.WeaponWheel) || Equals(self.EquipmentArea, gamedataEquipmentArea.WeaponLeft);
  }

  public final static func IsGarment(self: InventoryItemData) -> Bool {
    return Equals(self.EquipmentArea, gamedataEquipmentArea.Face) || Equals(self.EquipmentArea, gamedataEquipmentArea.Feet) || Equals(self.EquipmentArea, gamedataEquipmentArea.Head) || Equals(self.EquipmentArea, gamedataEquipmentArea.InnerChest) || Equals(self.EquipmentArea, gamedataEquipmentArea.Legs) || Equals(self.EquipmentArea, gamedataEquipmentArea.OuterChest) || Equals(self.EquipmentArea, gamedataEquipmentArea.Outfit) || Equals(self.EquipmentArea, gamedataEquipmentArea.UnderwearBottom) || Equals(self.EquipmentArea, gamedataEquipmentArea.UnderwearTop);
  }
}

public native class UILocalizationDataPackage extends IScriptable {

  public native let floatValues: array<Float>;

  public native let intValues: array<Int32>;

  public native let nameValues: array<CName>;

  public native let statValues: array<Float>;

  public native let statNames: array<CName>;

  private native let paramsCount: Int32;

  private native let textParams: ref<inkTextParams>;

  public final static native func FromLogicUIDataPackage(uiData: wref<GameplayLogicPackageUIData_Record>, opt item: wref<gameItemData>, opt partItemData: InnerItemData) -> ref<UILocalizationDataPackage>;

  public final static native func FromPerkUIDataPackage(uiData: wref<PerkLevelUIData_Record>) -> ref<UILocalizationDataPackage>;

  public final static native func FromPassiveUIDataPackage(uiData: wref<PassiveProficiencyBonusUIData_Record>) -> ref<UILocalizationDataPackage>;

  public final func InvalidateTextParams() -> Void {
    this.textParams = new inkTextParams();
    this.paramsCount = 0;
    let i: Int32 = 0;
    while i < ArraySize(this.floatValues) {
      this.textParams.AddNumber("float_" + IntToString(i), this.floatValues[i]);
      i += 1;
    };
    this.paramsCount += i;
    i = 0;
    while i < ArraySize(this.intValues) {
      this.textParams.AddNumber("int_" + IntToString(i), this.intValues[i]);
      i += 1;
    };
    this.paramsCount += i;
    i = 0;
    while i < ArraySize(this.nameValues) {
      this.textParams.AddString("name_" + IntToString(i), GetLocalizedText(NameToString(this.nameValues[i])));
      i += 1;
    };
    this.paramsCount += i;
    i = 0;
    while i < ArraySize(this.statValues) {
      this.textParams.AddNumber("stat_" + IntToString(i), this.statValues[i]);
      i += 1;
    };
    this.paramsCount += i;
    if ArraySize(this.statValues) == 0 && i >= 0 && i < ArraySize(this.statNames) {
      this.textParams.AddString("stat_" + IntToString(i), GetLocalizedText(NameToString(this.statNames[i])));
    };
    this.paramsCount += i;
  }

  public final func GetParamsCount() -> Int32 {
    if this.paramsCount == -1 {
      this.InvalidateTextParams();
    };
    return this.paramsCount;
  }

  public final func GetTextParams() -> ref<inkTextParams> {
    if this.paramsCount == -1 {
      this.InvalidateTextParams();
    };
    return this.textParams;
  }
}

public abstract class UIGenderHelper extends IScriptable {

  public final static func GetIconGender(playerPuppet: wref<PlayerPuppet>) -> ItemIconGender {
    if IsDefined(playerPuppet) {
      return Equals(playerPuppet.GetResolvedGenderName(), n"Male") ? ItemIconGender.Male : ItemIconGender.Female;
    };
    return ItemIconGender.Female;
  }
}

public abstract class InventoryGPRestrictionHelper extends IScriptable {

  public final static func CanUse(itemData: InventoryItemData, playerPuppet: wref<PlayerPuppet>) -> Bool {
    let bb: ref<IBlackboard>;
    let canUse: Bool = InventoryGPRestrictionHelper.CanInteractByEquipmentArea(itemData, playerPuppet);
    if Equals(InventoryItemData.GetItemType(itemData), gamedataItemType.Prt_Program) || Equals(InventoryItemData.GetEquipmentArea(itemData), gamedataEquipmentArea.Consumable) {
      bb = GameInstance.GetBlackboardSystem(playerPuppet.GetGame()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
      if bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat) == EnumInt(gamePSMCombat.InCombat) {
        canUse = false;
      };
    };
    return canUse;
  }

  public final static func CanEquip(itemData: InventoryItemData, playerPuppet: wref<PlayerPuppet>) -> Bool {
    let bb: ref<IBlackboard>;
    let canEquip: Bool = InventoryGPRestrictionHelper.CanInteractByEquipmentArea(itemData, playerPuppet);
    if Equals(InventoryItemData.GetItemType(itemData), gamedataItemType.Prt_Program) {
      bb = GameInstance.GetBlackboardSystem(playerPuppet.GetGame()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
      if bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat) == EnumInt(gamePSMCombat.InCombat) {
        canEquip = false;
      };
    };
    return canEquip;
  }

  public final static func CanDrop(itemData: InventoryItemData, playerPuppet: wref<PlayerPuppet>) -> Bool {
    let bb: ref<IBlackboard>;
    let canDrop: Bool = true;
    if Equals(InventoryItemData.GetEquipmentArea(itemData), gamedataEquipmentArea.Consumable) {
      bb = GameInstance.GetBlackboardSystem(playerPuppet.GetGame()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
      if bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat) == EnumInt(gamePSMCombat.InCombat) {
        canDrop = false;
      };
    };
    return canDrop;
  }

  private final static func CanInteractByEquipmentArea(itemData: InventoryItemData, playerPuppet: wref<PlayerPuppet>) -> Bool {
    let canInteract: Bool;
    let equipmentSystem: wref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(playerPuppet.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    switch InventoryItemData.GetEquipmentArea(itemData) {
      case gamedataEquipmentArea.Consumable:
        canInteract = !StatusEffectSystem.ObjectHasStatusEffectWithTag(playerPuppet, n"FistFight");
        break;
      case gamedataEquipmentArea.Weapon:
        canInteract = !(StatusEffectSystem.ObjectHasStatusEffectWithTag(playerPuppet, n"VehicleScene") || StatusEffectSystem.ObjectHasStatusEffectWithTag(playerPuppet, n"FirearmsNoSwitch") || InventoryGPRestrictionHelper.BlockedBySceneTier(playerPuppet) || !equipmentSystem.GetPlayerData(playerPuppet).IsEquippable(InventoryItemData.GetGameItemData(itemData)));
        break;
      default:
        canInteract = true;
    };
    return canInteract;
  }

  public final static func BlockedBySceneTier(playerPuppet: wref<PlayerPuppet>) -> Bool {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(playerPuppet.GetGame());
    let blackboard: ref<IBlackboard> = blackboardSystem.GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    let value: Int32 = blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel);
    return value > EnumInt(gamePSMHighLevel.SceneTier2) && value <= EnumInt(gamePSMHighLevel.SceneTier5);
  }
}
