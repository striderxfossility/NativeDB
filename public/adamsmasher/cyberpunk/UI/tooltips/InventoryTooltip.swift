
public class InventorySlotTooltip extends AGenericTooltipController {

  private edit let m_itemName: inkTextRef;

  private edit let m_itemCategory: inkTextRef;

  private edit let m_itemPrice: inkTextRef;

  private edit let m_descriptionText: inkTextRef;

  private edit let m_lockedText: inkTextRef;

  private edit let m_requiredLevelText: inkTextRef;

  private edit let m_additionalStatsTextRef: inkTextRef;

  private edit let m_equippedHeader: inkWidgetRef;

  private edit let m_primaryStatsList: inkWidgetRef;

  private edit let m_comparedStatsList: inkWidgetRef;

  private edit let m_additionalStatsList: inkWidgetRef;

  private edit let m_itemPriceGroup: inkWidgetRef;

  private edit let m_damageIndicator: inkWidgetRef;

  private edit let m_requiredLevelGroup: inkWidgetRef;

  private edit let m_damageIndicatorRef: inkWidgetRef;

  private edit let m_attachmentsListVertRef: inkWidgetRef;

  private edit let m_attachmentsCtrlHorRef: inkWidgetRef;

  private edit let m_specialAbilitiesListRef: inkWidgetRef;

  private edit let m_rarityBarRef: inkWidgetRef;

  private edit const let m_elementsToSetRarityState: array<inkWidgetRef>;

  private edit const let m_rarityElementsRefs: array<inkImageRef>;

  private edit let m_tooltipCycleIndicatorsContainer: inkCompoundRef;

  private edit let m_tooltipCycleHintContainer: inkCompoundRef;

  private let m_primaryStatsCtrl: wref<InventoryItemStatList>;

  private let m_comparedStatsCtrl: wref<InventoryItemStatList>;

  private let m_additionalStatsCtrl: wref<InventoryItemStatList>;

  private let m_attachmentsCtrlVert: wref<InventoryItemAttachmentsList>;

  private let m_attachmentsCtrlHor: wref<InventoryItemAttachmentsList>;

  private let m_damageTypeIndicator: wref<DamageTypeIndicator>;

  private let m_specialAbilitiesList: wref<TooltipSpecialAbilityList>;

  private let m_data: ref<InventoryTooltipData>;

  private let m_tooltipCycleHint: wref<ButtonHintListItem>;

  private let anim: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_primaryStatsCtrl = inkWidgetRef.GetController(this.m_primaryStatsList) as InventoryItemStatList;
    if inkWidgetRef.IsValid(this.m_comparedStatsList) {
      this.m_comparedStatsCtrl = inkWidgetRef.GetController(this.m_comparedStatsList) as InventoryItemStatList;
    };
    if inkWidgetRef.IsValid(this.m_additionalStatsList) {
      this.m_additionalStatsCtrl = inkWidgetRef.GetController(this.m_additionalStatsList) as InventoryItemStatList;
    };
    if inkWidgetRef.IsValid(this.m_attachmentsListVertRef) {
      this.m_attachmentsCtrlVert = inkWidgetRef.GetController(this.m_attachmentsListVertRef) as InventoryItemAttachmentsList;
    };
    if inkWidgetRef.IsValid(this.m_attachmentsCtrlHorRef) {
      this.m_attachmentsCtrlHor = inkWidgetRef.GetController(this.m_attachmentsCtrlHorRef) as InventoryItemAttachmentsList;
    };
    this.m_damageTypeIndicator = inkWidgetRef.GetController(this.m_damageIndicatorRef) as DamageTypeIndicator;
    this.m_specialAbilitiesList = inkWidgetRef.GetController(this.m_specialAbilitiesListRef) as TooltipSpecialAbilityList;
  }

  public func SetStyle(styleResPath: ResRef) -> Void {
    this.m_Root.SetStyle(styleResPath);
    inkWidgetRef.SetStyle(this.m_primaryStatsList, styleResPath);
    if inkWidgetRef.IsValid(this.m_comparedStatsList) {
      inkWidgetRef.SetStyle(this.m_comparedStatsList, styleResPath);
    };
    if inkWidgetRef.IsValid(this.m_additionalStatsList) {
      inkWidgetRef.SetStyle(this.m_additionalStatsList, styleResPath);
    };
    if inkWidgetRef.IsValid(this.m_attachmentsListVertRef) {
      inkWidgetRef.SetStyle(this.m_attachmentsListVertRef, styleResPath);
    };
    if inkWidgetRef.IsValid(this.m_attachmentsCtrlHorRef) {
      inkWidgetRef.SetStyle(this.m_attachmentsCtrlHorRef, styleResPath);
    };
    inkWidgetRef.SetStyle(this.m_specialAbilitiesListRef, styleResPath);
  }

  public final func Show(data: ItemViewData) -> Void {
    this.Show(InventoryTooltipData.FromItemViewData(data));
  }

  public final func Show(data: ref<InventoryTooltipData>) -> Void {
    this.SetData(data);
    this.Show();
  }

  public final func SetData(data: ItemViewData) -> Void {
    this.SetData(InventoryTooltipData.FromItemViewData(data));
    this.UpdateLayout();
  }

  public func SetData(tooltipData: ref<ATooltipData>) -> Void {
    this.SetData(tooltipData as InventoryTooltipData);
  }

  public final func SetData(data: ref<InventoryTooltipData>) -> Void {
    if IsDefined(data) {
      this.m_data = data;
      this.UpdateLayout();
    };
  }

  private final func UpdateLayout() -> Void {
    let i: Int32;
    let limit: Int32;
    inkTextRef.SetLetterCase(this.m_itemName, textLetterCase.UpperCase);
    inkTextRef.SetText(this.m_itemName, GetLocalizedItemNameByString(StringToName(this.m_data.itemName)));
    this.anim.Stop();
    if inkWidgetRef.IsValid(this.m_itemCategory) {
      inkTextRef.SetLetterCase(this.m_itemCategory, textLetterCase.UpperCase);
      inkTextRef.SetText(this.m_itemCategory, this.m_data.category);
      if IsNameValid(this.m_data.qualityStateName) {
        inkTextRef.SetText(this.m_itemCategory, GetLocalizedText(this.m_data.quality) + " " + GetLocalizedText(this.m_data.category));
      };
    };
    if inkWidgetRef.IsValid(this.m_itemPriceGroup) {
      if this.m_data.price > 0.00 {
        if this.m_data.isVendorItem {
          inkTextRef.SetTextFromParts(this.m_itemPrice, FloatToStringPrec(this.m_data.buyPrice, 0), " ", "Common-Characters-EuroDollar");
        } else {
          inkTextRef.SetTextFromParts(this.m_itemPrice, FloatToStringPrec(this.m_data.price, 0), " ", "Common-Characters-EuroDollar");
        };
        inkWidgetRef.SetVisible(this.m_itemPriceGroup, true);
      } else {
        inkWidgetRef.SetVisible(this.m_itemPriceGroup, false);
      };
    };
    this.UpdateDescription();
    this.UpdateRarityBar();
    if this.m_data.isBroken {
      this.m_data.qualityStateName = n"Common";
    };
    i = 0;
    limit = ArraySize(this.m_elementsToSetRarityState);
    while i < limit {
      inkWidgetRef.SetState(this.m_elementsToSetRarityState[i], this.m_data.qualityStateName);
      i += 1;
    };
    if inkWidgetRef.IsValid(this.m_equippedHeader) {
      inkWidgetRef.SetVisible(this.m_equippedHeader, this.m_data.isEquipped);
    };
    if inkWidgetRef.IsValid(this.m_requiredLevelGroup) {
      inkTextRef.SetText(this.m_requiredLevelText, IntToString(this.m_data.levelRequired));
      inkWidgetRef.SetVisible(this.m_requiredLevelGroup, this.m_data.levelRequired > 0);
    };
    this.SetStats(this.m_primaryStatsCtrl, this.m_data.primaryStats);
    this.SetStats(this.m_comparedStatsCtrl, this.m_data.comparedStats);
    this.SetStats(this.m_additionalStatsCtrl, this.m_data.additionalStats);
    this.SetAdditionalStatsText();
    if !this.m_data.isBroken {
      if IsDefined(this.m_attachmentsCtrlVert) {
        this.m_attachmentsCtrlVert.SetData(this.m_data.attachments);
      };
      if IsDefined(this.m_attachmentsCtrlHor) {
        this.m_attachmentsCtrlHor.SetData(this.m_data.attachments);
      };
      this.m_damageTypeIndicator.Setup(this.m_data.damageType);
      this.m_specialAbilitiesList.SetData(this.m_data.qualityStateName, this.m_data.specialAbilities);
    } else {
      if IsDefined(this.m_attachmentsCtrlVert) {
        this.m_attachmentsCtrlVert.ClearData(0);
      };
      if IsDefined(this.m_attachmentsCtrlHor) {
        this.m_attachmentsCtrlHor.ClearData(0);
      };
      this.m_specialAbilitiesList.ClearData(0);
      this.m_damageTypeIndicator.Setup(gamedataDamageType.Invalid);
    };
    this.m_primaryStatsCtrl.UpdateVisibility(true);
    if IsDefined(this.m_attachmentsCtrlVert) {
      this.m_attachmentsCtrlVert.UpdateVisibility();
      this.m_attachmentsCtrlVert.UpdateVisibility(ArraySize(this.m_data.additionalStats) > 0);
    };
    if IsDefined(this.m_attachmentsCtrlHor) {
      this.m_attachmentsCtrlHor.UpdateVisibility();
      this.m_attachmentsCtrlHor.UpdateVisibility(ArraySize(this.m_data.additionalStats) == 0);
    };
    this.m_specialAbilitiesList.UpdateVisibility();
    this.UpdateCyclingDots();
    this.anim = this.PlayLibraryAnimation(n"intro");
  }

  private final func UpdateCyclingDots() -> Void {
    let dotController: ref<TooltipCycleDotController>;
    let i: Int32;
    inkWidgetRef.SetVisible(this.m_tooltipCycleIndicatorsContainer, this.m_data.showCyclingDots);
    inkWidgetRef.SetVisible(this.m_tooltipCycleHintContainer, this.m_data.showCyclingDots);
    if this.m_data.showCyclingDots {
      inkCompoundRef.RemoveAllChildren(this.m_tooltipCycleIndicatorsContainer);
      i = 0;
      while i < this.m_data.numberOfCyclingDots {
        dotController = this.SpawnFromLocal(inkWidgetRef.Get(this.m_tooltipCycleIndicatorsContainer), n"tooltipCycleDot").GetController() as TooltipCycleDotController;
        dotController.Toggle(i == this.m_data.selectedCyclingDot);
        i += 1;
      };
    };
  }

  private final func UpdateRarityBar() -> Void {
    let i: Int32;
    let limit: Int32;
    let numBars: Int32;
    if !inkWidgetRef.IsValid(this.m_rarityBarRef) {
      return;
    };
    if IsNameValid(this.m_data.qualityStateName) && !this.m_data.isBroken {
      switch this.m_data.qualityStateName {
        case n"Legendary":
          numBars = 5;
          break;
        case n"Epic":
          numBars = 4;
          break;
        case n"Rare":
          numBars = 3;
          break;
        case n"Uncommon":
          numBars = 2;
          break;
        default:
          numBars = 1;
      };
      i = 0;
      limit = ArraySize(this.m_rarityElementsRefs);
      while i < limit {
        if i < numBars {
          inkWidgetRef.SetOpacity(this.m_rarityElementsRefs[i], 1.00);
          inkWidgetRef.SetState(this.m_rarityElementsRefs[i], this.m_data.qualityStateName);
        } else {
          inkWidgetRef.SetOpacity(this.m_rarityElementsRefs[i], 0.30);
          inkWidgetRef.SetState(this.m_rarityElementsRefs[i], n"Common");
        };
        i += 1;
      };
      inkWidgetRef.SetVisible(this.m_rarityBarRef, true);
    } else {
      inkWidgetRef.SetVisible(this.m_rarityBarRef, false);
    };
  }

  private final func SetStats(statList: wref<InventoryItemStatList>, data: script_ref<array<InventoryTooltipData_StatData>>) -> Void {
    if IsDefined(statList) {
      if !this.m_data.isBroken {
        statList.SetData(Deref(data));
      } else {
        statList.ClearData(0);
      };
      statList.UpdateVisibility();
    };
  }

  private final func SetAdditionalStatsText() -> Void {
    let i: Int32;
    let limit: Int32;
    let outText: String = "";
    if inkWidgetRef.IsValid(this.m_additionalStatsTextRef) {
      i = 0;
      limit = ArraySize(this.m_data.additionalStats);
      while i < limit {
        if i > 0 {
          outText += ", ";
        };
        outText += this.m_data.additionalStats[i].statName;
        i += 1;
      };
      inkTextRef.SetText(this.m_additionalStatsTextRef, outText);
    };
  }

  private final func UpdateDescription() -> Void {
    let description: String;
    if this.m_data.isBroken {
      inkTextRef.SetText(this.m_descriptionText, GetLocalizedText("Gameplay-Scanning-Devices-Broken"));
      inkWidgetRef.SetVisible(this.m_descriptionText, true);
      return;
    };
    if inkWidgetRef.IsValid(this.m_descriptionText) {
      description = GetLocalizedText(this.m_data.description);
      if IsStringValid(this.m_data.additionalDescription) {
        if IsStringValid(description) {
          description += "\\n\\n";
        };
        description += GetLocalizedText(this.m_data.additionalDescription);
      };
      inkTextRef.SetText(this.m_descriptionText, description);
      inkWidgetRef.SetVisible(this.m_descriptionText, IsStringValid(description));
    };
  }
}
