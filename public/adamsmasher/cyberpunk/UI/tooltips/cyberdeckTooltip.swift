
public class CyberdeckTooltip extends AGenericTooltipController {

  protected edit let m_itemNameText: inkTextRef;

  protected edit let m_itemRarityText: inkTextRef;

  protected edit let m_rarityBars: inkWidgetRef;

  protected edit let m_categoriesWrapper: inkCompoundRef;

  protected edit let m_topContainer: inkCompoundRef;

  protected edit let m_headerContainer: inkCompoundRef;

  protected edit let m_statsContainer: inkCompoundRef;

  protected edit let m_descriptionContainer: inkCompoundRef;

  protected edit let m_bottomContainer: inkCompoundRef;

  protected edit let m_statsList: inkCompoundRef;

  protected edit let m_priceContainer: inkCompoundRef;

  protected edit let m_descriptionText: inkTextRef;

  protected edit let m_priceText: inkTextRef;

  protected edit let m_equipedWrapper: inkWidgetRef;

  protected edit let m_itemTypeText: inkTextRef;

  protected edit let m_itemWeightWrapper: inkWidgetRef;

  protected edit let m_itemWeightText: inkTextRef;

  protected edit let m_cybderdeckBaseMemoryValue: inkTextRef;

  protected edit let m_cybderdeckBufferValue: inkTextRef;

  protected edit let m_cybderdeckSlotsValue: inkTextRef;

  protected edit let m_deviceHacksGrid: inkCompoundRef;

  protected edit let m_itemIconImage: inkImageRef;

  protected edit let m_itemAttributeRequirements: inkWidgetRef;

  protected edit let m_itemAttributeRequirementsText: inkTextRef;

  protected edit let m_iconicLines: inkImageRef;

  protected let m_rarityBarsController: wref<LevelBarsController>;

  protected let m_data: ref<InventoryTooltipData>;

  protected let m_animProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_rarityBarsController = inkWidgetRef.GetController(this.m_rarityBars) as LevelBarsController;
  }

  public final func SetData(data: ItemViewData) -> Void {
    this.SetData(InventoryTooltipData.FromItemViewData(data));
  }

  public func SetData(tooltipData: ref<ATooltipData>) -> Void {
    this.m_data = tooltipData as InventoryTooltipData;
    this.UpdateLayout();
  }

  public func Show() -> Void {
    this.Show();
    if IsDefined(this.m_animProxy) {
      this.m_animProxy.Stop();
      this.m_animProxy = null;
    };
    this.m_animProxy = this.PlayLibraryAnimationOnAutoSelectedTargets(n"show_item_tooltip", this.GetRootWidget());
    this.m_animProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnShowAnimationFinished");
  }

  protected final func UpdateLayout() -> Void {
    this.UpdateName();
    this.UpdateRarity();
    this.UpdateCyberdeckStats();
    this.UpdateAbilities();
    this.SetupDeviceHacks();
    this.UpdateDescription();
    this.UpdatePrice();
    this.UpdateWeight();
    this.UpdateIcon();
    this.UpdateRequirements();
    inkWidgetRef.SetVisible(this.m_equipedWrapper, this.m_data.isEquipped);
    this.FixLines();
  }

  protected final func GetAbilities() -> array<InventoryItemAbility> {
    let GLPAbilities: array<wref<GameplayLogicPackage_Record>>;
    let abilities: array<InventoryItemAbility>;
    let ability: InventoryItemAbility;
    let i: Int32;
    let limit: Int32;
    let uiData: wref<GameplayLogicPackageUIData_Record>;
    let itemRecord: wref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(this.m_data.inventoryItemData)));
    itemRecord.OnAttach(GLPAbilities);
    i = 0;
    limit = ArraySize(GLPAbilities);
    while i < limit {
      if IsDefined(GLPAbilities[i]) {
        uiData = GLPAbilities[i].UIData();
        if IsDefined(uiData) {
          ability = new InventoryItemAbility(uiData.IconPath(), uiData.LocalizedName(), uiData.LocalizedDescription(), UILocalizationDataPackage.FromLogicUIDataPackage(uiData, InventoryItemData.GetGameItemData(this.m_data.inventoryItemData)));
          ArrayPush(abilities, ability);
        };
      };
      i += 1;
    };
    ArrayClear(GLPAbilities);
    itemRecord.OnEquip(GLPAbilities);
    i = 0;
    limit = ArraySize(GLPAbilities);
    while i < limit {
      if IsDefined(GLPAbilities[i]) {
        uiData = GLPAbilities[i].UIData();
        if IsDefined(uiData) {
          ability = new InventoryItemAbility(uiData.IconPath(), uiData.LocalizedName(), uiData.LocalizedDescription(), UILocalizationDataPackage.FromLogicUIDataPackage(uiData, InventoryItemData.GetGameItemData(this.m_data.inventoryItemData)));
          ArrayPush(abilities, ability);
        };
      };
      i += 1;
    };
    return abilities;
  }

  protected final func UpdateAbilities() -> Void {
    let controller: ref<CyberdeckStatController>;
    let i: Int32;
    let abilities: array<InventoryItemAbility> = this.GetAbilities();
    let abilitiesSize: Int32 = ArraySize(abilities);
    if abilitiesSize > 0 {
      while inkCompoundRef.GetNumChildren(this.m_statsList) > abilitiesSize {
        inkCompoundRef.RemoveChildByIndex(this.m_statsList, 0);
      };
      while inkCompoundRef.GetNumChildren(this.m_statsList) < abilitiesSize {
        this.SpawnFromLocal(inkWidgetRef.Get(this.m_statsList), n"cyberdeckStat");
      };
      i = 0;
      while i < abilitiesSize {
        controller = inkCompoundRef.GetWidgetByIndex(this.m_statsList, i).GetController() as CyberdeckStatController;
        controller.Setup(abilities[i]);
        i += 1;
      };
      inkWidgetRef.SetVisible(this.m_statsContainer, abilitiesSize > 0);
    } else {
      inkWidgetRef.SetVisible(this.m_statsContainer, false);
    };
  }

  protected final func UpdateCyberdeckStats() -> Void {
    let bufferValue: Float;
    let i: Int32;
    let j: Int32;
    let memoryValue: Float;
    let onEquipList: array<wref<GameplayLogicPackage_Record>>;
    let slots: Int32;
    let stat: wref<ConstantStatModifier_Record>;
    let statType: wref<Stat_Record>;
    let statsList: array<wref<StatModifier_Record>>;
    let tweakRecord: wref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(this.m_data.inventoryItemData)));
    tweakRecord.OnEquip(onEquipList);
    i = 0;
    while i < ArraySize(onEquipList) {
      onEquipList[i].Stats(statsList);
      j = 0;
      while j < ArraySize(statsList) {
        statType = statsList[j].StatType();
        stat = statsList[j] as ConstantStatModifier_Record;
        if IsDefined(stat) {
          if Equals(statType.StatType(), gamedataStatType.Memory) {
            memoryValue = stat.Value();
          } else {
            if Equals(statType.StatType(), gamedataStatType.BufferSize) {
              bufferValue = stat.Value();
            };
          };
        };
        j += 1;
      };
      i += 1;
    };
    slots = InventoryItemData.GetAttachmentsSize(this.m_data.inventoryItemData);
    inkTextRef.SetText(this.m_cybderdeckBaseMemoryValue, FloatToStringPrec(memoryValue, 0));
    inkTextRef.SetText(this.m_cybderdeckBufferValue, FloatToStringPrec(bufferValue, 0));
    inkTextRef.SetText(this.m_cybderdeckSlotsValue, IntToString(slots));
  }

  protected final func SetupDeviceHacks() -> Void {
    let controller: ref<CyberdeckDeviceHackIcon>;
    let i: Int32;
    let widget: wref<inkWidget>;
    let hacks: array<CyberdeckDeviceQuickhackData> = this.GetCyberdeckDeviceQuickhacks();
    inkCompoundRef.RemoveAllChildren(this.m_deviceHacksGrid);
    i = 0;
    while i < ArraySize(hacks) {
      widget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_deviceHacksGrid), n"deviceHackIcon");
      controller = widget.GetController() as CyberdeckDeviceHackIcon;
      controller.Setup(hacks[i]);
      i += 1;
    };
  }

  protected final func GetCyberdeckDeviceQuickhacks() -> array<CyberdeckDeviceQuickhackData> {
    let data: CyberdeckDeviceQuickhackData;
    let deviceHacks: array<wref<ObjectAction_Record>>;
    let i: Int32;
    let objectActionType: ref<ObjectActionType_Record>;
    let objectActions: array<wref<ObjectAction_Record>>;
    let result: array<CyberdeckDeviceQuickhackData>;
    let uiAction: wref<InteractionBase_Record>;
    let tweakRecord: wref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(this.m_data.inventoryItemData)));
    tweakRecord.ObjectActions(objectActions);
    i = 0;
    while i < ArraySize(objectActions) {
      objectActionType = objectActions[i].ObjectActionType();
      if IsDefined(objectActionType) {
        if Equals(objectActionType.Type(), gamedataObjectActionType.DeviceQuickHack) {
          ArrayPush(deviceHacks, objectActions[i]);
        };
      };
      i += 1;
    };
    i = 0;
    while i < ArraySize(deviceHacks) {
      uiAction = deviceHacks[i].ObjectActionUI();
      data.UIIcon = uiAction.CaptionIcon().TexturePartID();
      data.ObjectActionRecord = deviceHacks[i];
      ArrayPush(result, data);
      i += 1;
    };
    return result;
  }

  protected final func UpdateName() -> Void {
    let quantity: Int32 = InventoryItemData.GetQuantity(this.m_data.inventoryItemData);
    let finalItemName: String = UIItemsHelper.GetTooltipItemName(this.m_data);
    if quantity > 1 {
      finalItemName += " [" + IntToString(quantity) + "]";
    };
    inkTextRef.SetText(this.m_itemNameText, finalItemName);
  }

  protected final func UpdateRarity() -> Void {
    let iconicLabel: String;
    let isIconic: Bool;
    let quality: gamedataQuality;
    let rarityLabel: String;
    if this.m_data.overrideRarity {
      quality = UIItemsHelper.QualityNameToEnum(StringToName(this.m_data.quality));
    } else {
      quality = RPGManager.GetItemDataQuality(InventoryItemData.GetGameItemData(this.m_data.inventoryItemData));
    };
    iconicLabel = GetLocalizedText(UIItemsHelper.QualityToLocalizationKey(gamedataQuality.Iconic));
    rarityLabel = GetLocalizedText(UIItemsHelper.QualityToLocalizationKey(quality));
    isIconic = RPGManager.IsItemIconic(InventoryItemData.GetGameItemData(this.m_data.inventoryItemData));
    inkWidgetRef.SetState(this.m_itemNameText, UIItemsHelper.QualityEnumToName(quality));
    inkWidgetRef.SetState(this.m_itemRarityText, UIItemsHelper.QualityEnumToName(quality));
    inkTextRef.SetText(this.m_itemRarityText, isIconic ? rarityLabel + " / " + iconicLabel : rarityLabel);
    this.m_rarityBarsController.Update(UIItemsHelper.QualityToInt(quality));
    inkWidgetRef.SetVisible(this.m_iconicLines, isIconic);
  }

  protected final func UpdateDescription() -> Void {
    if NotEquals(this.m_data.description, "") {
      inkTextRef.SetText(this.m_descriptionText, this.m_data.description);
      inkWidgetRef.SetVisible(this.m_descriptionContainer, true);
    } else {
      inkWidgetRef.SetVisible(this.m_descriptionContainer, false);
    };
  }

  protected final func UpdateWeight() -> Void {
    let weight: Float = InventoryItemData.GetGameItemData(this.m_data.inventoryItemData).GetStatValueByType(gamedataStatType.Weight);
    inkTextRef.SetText(this.m_itemWeightText, FloatToStringPrec(weight, 2));
  }

  protected func UpdateIcon() -> Void {
    let emptyIcon: CName;
    let iconName: String;
    let iconsNameResolver: ref<IconsNameResolver> = IconsNameResolver.GetIconsNameResolver();
    if IsStringValid(InventoryItemData.GetIconPath(this.m_data.inventoryItemData)) {
      iconName = InventoryItemData.GetIconPath(this.m_data.inventoryItemData);
    } else {
      iconName = NameToString(iconsNameResolver.TranslateItemToIconName(ItemID.GetTDBID(InventoryItemData.GetID(this.m_data.inventoryItemData)), Equals(InventoryItemData.GetIconGender(this.m_data.inventoryItemData), ItemIconGender.Male)));
    };
    if NotEquals(iconName, "None") && NotEquals(iconName, "") {
      inkWidgetRef.SetScale(this.m_itemIconImage, Equals(InventoryItemData.GetEquipmentArea(this.m_data.inventoryItemData), gamedataEquipmentArea.Outfit) ? new Vector2(0.50, 0.50) : new Vector2(1.00, 1.00));
      InkImageUtils.RequestSetImage(this, this.m_itemIconImage, "UIIcon." + iconName, n"OnIconCallback");
    } else {
      emptyIcon = UIItemsHelper.GetSlotShadowIcon(TDBID.undefined(), InventoryItemData.GetItemType(this.m_data.inventoryItemData), InventoryItemData.GetEquipmentArea(this.m_data.inventoryItemData));
      InkImageUtils.RequestSetImage(this, this.m_itemIconImage, emptyIcon);
    };
  }

  protected final func UpdatePrice() -> Void {
    if this.m_data.isVendorItem {
      inkTextRef.SetText(this.m_priceText, FloatToStringPrec(this.m_data.buyPrice, 0));
    } else {
      inkTextRef.SetText(this.m_priceText, FloatToStringPrec(this.m_data.price, 0));
    };
    inkWidgetRef.SetVisible(this.m_priceContainer, true);
  }

  protected final func UpdateRequirements() -> Void {
    let requirement: SItemStackRequirementData;
    let statRecord: ref<Stat_Record>;
    let textParams: ref<inkTextParams>;
    inkWidgetRef.SetVisible(this.m_itemAttributeRequirements, false);
    if !InventoryItemData.IsEmpty(this.m_data.inventoryItemData) {
      requirement = InventoryItemData.GetRequirement(this.m_data.inventoryItemData);
      if NotEquals(requirement.statType, gamedataStatType.Invalid) && !InventoryItemData.IsRequirementMet(this.m_data.inventoryItemData) {
        inkWidgetRef.SetVisible(this.m_itemAttributeRequirements, true);
        textParams = new inkTextParams();
        textParams.AddNumber("value", RoundF(requirement.requiredValue));
        statRecord = RPGManager.GetStatRecord(requirement.statType);
        textParams.AddString("statName", GetLocalizedText(UILocalizationHelper.GetStatNameLockey(statRecord)));
        textParams.AddString("statColor", "StatTypeColor." + EnumValueToString("gamedataStatType", Cast(EnumInt(requirement.statType))));
        inkTextRef.SetLocalizedTextScript(this.m_itemAttributeRequirementsText, "LocKey#49215", textParams);
      };
      if !InventoryItemData.IsEquippable(this.m_data.inventoryItemData) {
        inkWidgetRef.SetVisible(this.m_itemAttributeRequirements, true);
        requirement = InventoryItemData.GetEquipRequirement(this.m_data.inventoryItemData);
        textParams = new inkTextParams();
        textParams.AddNumber("value", RoundF(requirement.requiredValue));
        statRecord = RPGManager.GetStatRecord(requirement.statType);
        textParams.AddString("statName", GetLocalizedText(UILocalizationHelper.GetStatNameLockey(statRecord)));
        textParams.AddString("statColor", "StatTypeColor." + EnumValueToString("gamedataStatType", Cast(EnumInt(requirement.statType))));
        inkTextRef.SetLocalizedTextScript(this.m_itemAttributeRequirementsText, "LocKey#77652", textParams);
      };
    };
  }

  protected final func FixLines() -> Void {
    let container: wref<inkCompoundWidget>;
    let lineWidget: wref<inkWidget>;
    let firstHidden: Bool = false;
    let i: Int32 = 0;
    while i < inkCompoundRef.GetNumChildren(this.m_categoriesWrapper) {
      container = inkCompoundRef.GetWidgetByIndex(this.m_categoriesWrapper, i) as inkCompoundWidget;
      if IsDefined(container) {
        if container.IsVisible() {
          lineWidget = container.GetWidgetByPath(inkWidgetPath.Build(n"line"));
          if IsDefined(lineWidget) {
            lineWidget.SetVisible(firstHidden);
            firstHidden = true;
          };
        };
      };
      i += 1;
    };
  }
}

public class CyberdeckDeviceHackIcon extends inkLogicController {

  protected edit let m_image: inkImageRef;

  public final func Setup(data: CyberdeckDeviceQuickhackData) -> Void {
    inkImageRef.SetAtlasResource(this.m_image, data.UIIcon.AtlasResourcePath());
    inkImageRef.SetTexturePart(this.m_image, data.UIIcon.AtlasPartName());
  }
}

public class CyberdeckStatController extends inkLogicController {

  protected edit let m_label: inkTextRef;

  public final func Setup(ability: InventoryItemAbility) -> Void {
    if NotEquals(ability.Description, "") {
      inkTextRef.SetText(this.m_label, ability.Description);
      if ability.LocalizationDataPackage.GetParamsCount() > 0 {
        inkTextRef.SetTextParameters(this.m_label, ability.LocalizationDataPackage.GetTextParams());
      };
    } else {
      inkTextRef.SetText(this.m_label, GetLocalizedText("UI-Labels-EmptySlot"));
    };
  }
}
