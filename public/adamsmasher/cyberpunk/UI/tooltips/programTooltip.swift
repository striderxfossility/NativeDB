
public class ProgramTooltipController extends AGenericTooltipController {

  protected edit let m_backgroundContainer: inkCompoundRef;

  private edit let m_nameText: inkTextRef;

  private edit let m_tierText: inkTextRef;

  private edit let m_durationWidget: inkWidgetRef;

  private edit let m_uploadTimeWidget: inkWidgetRef;

  private edit let m_cooldownWidget: inkWidgetRef;

  private edit let m_memoryCostValueText: inkTextRef;

  private edit let m_damageWrapper: inkWidgetRef;

  private edit let m_damageLabel: inkTextRef;

  private edit let m_damageValue: inkTextRef;

  private edit let m_healthPercentageLabel: inkTextRef;

  private edit let m_priceContainer: inkWidgetRef;

  private edit let m_priceText: inkTextRef;

  private edit let m_descriptionWrapper: inkWidgetRef;

  private edit let m_descriptionText: inkTextRef;

  private edit let m_hackTypeWrapper: inkWidgetRef;

  private edit let m_hackTypeText: inkTextRef;

  private edit let m_effectsList: inkCompoundRef;

  private edit let DEBUG_iconErrorWrapper: inkWidgetRef;

  private edit let DEBUG_iconErrorText: inkTextRef;

  private let DEBUG_showAdditionalInfo: Bool;

  private let m_data: ref<InventoryTooltipData>;

  private let m_quickHackData: InventoryTooltipData_QuickhackData;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.RegisterToGlobalInputCallback(n"OnPostOnPress", this, n"OnGlobalPress");
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnGlobalRelease");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnPress", this, n"OnGlobalPress");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnGlobalRelease");
  }

  protected cb func OnGlobalPress(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsShiftDown() {
      this.DEBUG_showAdditionalInfo = true;
    } else {
      this.DEBUG_showAdditionalInfo = false;
    };
    this.DEBUG_UpdateIconErrorInfo();
  }

  protected cb func OnGlobalRelease(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsShiftDown() {
      this.DEBUG_showAdditionalInfo = false;
    };
    this.DEBUG_UpdateIconErrorInfo();
  }

  public func SetData(tooltipData: ref<ATooltipData>) -> Void {
    this.m_data = tooltipData as InventoryTooltipData;
    this.m_quickHackData = this.m_data.quickhackData;
    this.RefreshUI();
  }

  private func UpdateDetail(targetWidget: inkWidgetRef, key: String, value: Float, diff: Float) -> Void {
    let controller: ref<ProgramTooltipStatController> = inkWidgetRef.GetController(targetWidget) as ProgramTooltipStatController;
    controller.SetData(GetLocalizedText(key), value, diff);
  }

  private func UpdateDescription() -> Void {
    let description: String = this.m_data.description;
    if IsStringValid(description) {
      inkTextRef.SetText(this.m_descriptionText, description);
      inkWidgetRef.SetVisible(this.m_descriptionWrapper, true);
    } else {
      inkWidgetRef.SetVisible(this.m_descriptionWrapper, false);
    };
  }

  private func GetHackCategory() -> wref<HackCategory_Record> {
    let actionRecord: wref<ObjectAction_Record>;
    let actions: array<wref<ObjectAction_Record>>;
    let hackCategory: wref<HackCategory_Record>;
    let i: Int32;
    let tweakRecord: wref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(this.m_data.inventoryItemData)));
    tweakRecord.ObjectActions(actions);
    i = 0;
    while i < ArraySize(actions) {
      actionRecord = TweakDBInterface.GetObjectActionRecord(actions[i].GetID());
      hackCategory = actionRecord.HackCategory();
      if IsDefined(hackCategory) && NotEquals(hackCategory.EnumName(), n"NotAHack") {
        return hackCategory;
      };
      i += 1;
    };
    return null;
  }

  private func UpdateCategory() -> Void {
    let hackCategory: wref<HackCategory_Record> = this.GetHackCategory();
    if IsDefined(hackCategory) && NotEquals(hackCategory.EnumName(), n"NotAHack") {
      inkTextRef.SetText(this.m_hackTypeText, hackCategory.LocalizedDescription());
      inkWidgetRef.SetVisible(this.m_hackTypeWrapper, true);
    } else {
      inkWidgetRef.SetVisible(this.m_hackTypeWrapper, false);
    };
  }

  private final func UpdateRarity() -> Void {
    let quality: gamedataQuality;
    if this.m_data.overrideRarity {
      quality = UIItemsHelper.QualityNameToEnum(StringToName(this.m_data.quality));
    } else {
      quality = RPGManager.GetItemDataQuality(InventoryItemData.GetGameItemData(this.m_data.inventoryItemData));
    };
    inkWidgetRef.SetState(this.m_tierText, UIItemsHelper.QualityEnumToName(quality));
    inkWidgetRef.SetState(this.m_nameText, UIItemsHelper.QualityEnumToName(quality));
    (inkWidgetRef.Get(this.m_tierText) as inkText).SetText(GetLocalizedText(UIItemsHelper.QualityToLocalizationKey(quality)));
  }

  private func RefreshUI() -> Void {
    inkTextRef.SetText(this.m_nameText, this.m_data.itemName);
    inkWidgetRef.SetVisible(this.m_nameText, NotEquals(this.m_data.displayContext, InventoryTooltipDisplayContext.Crafting));
    inkTextRef.SetText(this.m_memoryCostValueText, IntToString(this.m_data.quickhackData.baseCost));
    this.UpdateDetail(this.m_durationWidget, "UI-Quickhacks-DetailsDuration", this.m_data.quickhackData.duration, this.m_data.quickhackData.durationDiff);
    this.UpdateDetail(this.m_uploadTimeWidget, "UI-Quickhacks-DetailsUploadTime", this.m_data.quickhackData.uploadTime, this.m_data.quickhackData.uploadTimeDiff);
    this.UpdateDetail(this.m_cooldownWidget, "UI-Quickhacks-DetailsCooldown", this.m_data.quickhackData.cooldown, this.m_data.quickhackData.cooldownDiff);
    inkWidgetRef.SetVisible(this.m_damageWrapper, false);
    this.UpdateDamage();
    this.UpdateMods();
    this.UpdatePrice();
    this.UpdateDescription();
    this.UpdateCategory();
    this.UpdateRarity();
    this.DEBUG_UpdateIconErrorInfo();
    inkWidgetRef.SetVisible(this.m_backgroundContainer, NotEquals(this.m_data.displayContext, InventoryTooltipDisplayContext.Crafting));
  }

  private final func DEBUG_UpdateIconErrorInfo() -> Void {
    let errorData: ref<DEBUG_IconErrorInfo>;
    let resultText: String;
    let iconsNameResolver: ref<IconsNameResolver> = IconsNameResolver.GetIconsNameResolver();
    if !iconsNameResolver.IsInDebugMode() {
      inkWidgetRef.SetVisible(this.DEBUG_iconErrorWrapper, false);
      return;
    };
    errorData = this.m_data.DEBUG_iconErrorInfo;
    inkWidgetRef.SetVisible(this.DEBUG_iconErrorWrapper, errorData != null || this.DEBUG_showAdditionalInfo);
    if this.DEBUG_showAdditionalInfo {
      resultText += " - itemID:\\n";
      resultText += TDBID.ToStringDEBUG(ItemID.GetTDBID(InventoryItemData.GetID(this.m_data.inventoryItemData)));
      inkTextRef.SetText(this.DEBUG_iconErrorText, resultText);
    } else {
      if errorData != null {
        resultText += "   ErrorType: " + EnumValueToString("inkIconResult", Cast(EnumInt(errorData.errorType))) + "\\n\\n";
        resultText += " - itemID:\\n";
        resultText += errorData.itemName;
        if errorData.isManuallySet {
          resultText += "\\n - resolved icon name (manually set):\\n";
        } else {
          resultText += "\\n - resolved icon name (auto generated):\\n";
        };
        resultText += errorData.resolvedIconName;
        resultText += "\\n - error message:\\n";
        resultText += errorData.errorMessage;
        inkTextRef.SetText(this.DEBUG_iconErrorText, resultText);
      };
    };
  }

  private final func IsDamageStat(targetStat: gamedataStatType, valueStat: gamedataStatType) -> Bool {
    if Equals(targetStat, gamedataStatType.Invalid) {
      switch valueStat {
        case gamedataStatType.ThermalDamage:
        case gamedataStatType.ElectricDamage:
        case gamedataStatType.ChemicalDamage:
        case gamedataStatType.PhysicalDamage:
        case gamedataStatType.BaseDamage:
          return true;
        default:
          return false;
      };
    } else {
      return Equals(targetStat, gamedataStatType.Health);
    };
    return false;
  }

  private final func UpdateDamage() -> Void {
    let effect: ref<DamageEffectUIEntry>;
    let isHealthPercentageStat: Bool;
    let valueToDisplay: String;
    let i: Int32 = 0;
    while i < ArraySize(this.m_data.quickhackData.attackEffects) {
      effect = this.m_data.quickhackData.attackEffects[i];
      if !this.IsDamageStat(effect.targetStat, effect.valueStat) {
      } else {
        isHealthPercentageStat = Equals(effect.targetStat, gamedataStatType.Health);
        inkWidgetRef.SetVisible(this.m_healthPercentageLabel, isHealthPercentageStat);
        if isHealthPercentageStat {
          valueToDisplay = "-";
        };
        valueToDisplay += IntToString(CeilF(effect.valueToDisplay));
        if isHealthPercentageStat {
          valueToDisplay += "%";
        };
        if effect.isContinuous {
          valueToDisplay += "/" + GetLocalizedText("UI-Quickhacks-Seconds");
        };
        inkTextRef.SetText(this.m_damageValue, valueToDisplay);
        inkTextRef.SetText(this.m_damageLabel, UILocalizationHelper.GetStatNameLockey(RPGManager.GetStatRecord(effect.valueStat)));
        inkWidgetRef.SetVisible(this.m_damageWrapper, true);
        goto 799;
      };
      i += 1;
    };
  }

  private final func UpdateMods() -> Void {
    let attachment: InventoryItemAttachments;
    let controller: ref<ItemTooltipModController>;
    let i: Int32;
    if ArraySize(this.m_data.itemAttachments) > 0 {
      while inkCompoundRef.GetNumChildren(this.m_effectsList) > 0 {
        inkCompoundRef.RemoveChildByIndex(this.m_effectsList, 0);
      };
      while inkCompoundRef.GetNumChildren(this.m_effectsList) < ArraySize(this.m_data.itemAttachments) {
        this.SpawnFromLocal(inkWidgetRef.Get(this.m_effectsList), n"programTooltipEffect");
      };
      i = 0;
      while i < ArraySize(this.m_data.itemAttachments) {
        attachment = this.m_data.itemAttachments[i];
        controller = inkCompoundRef.GetWidgetByIndex(this.m_effectsList, i).GetController() as ItemTooltipModController;
        controller.SetData(attachment);
        i += 1;
      };
    } else {
      if ArraySize(this.m_data.itemAttachments) == 0 && ArraySize(this.m_data.specialAbilities) > 0 {
        while inkCompoundRef.GetNumChildren(this.m_effectsList) > 0 {
          inkCompoundRef.RemoveChildByIndex(this.m_effectsList, 0);
        };
        while inkCompoundRef.GetNumChildren(this.m_effectsList) < ArraySize(this.m_data.specialAbilities) {
          this.SpawnFromLocal(inkWidgetRef.Get(this.m_effectsList), n"programTooltipEffect");
        };
        i = 0;
        while i < ArraySize(this.m_data.specialAbilities) {
          controller = inkCompoundRef.GetWidgetByIndex(this.m_effectsList, i).GetController() as ItemTooltipModController;
          controller.SetData(this.m_data.specialAbilities[i]);
          i += 1;
        };
      };
    };
  }

  private final func UpdatePrice() -> Void {
    if this.m_data.isVendorItem {
      inkTextRef.SetText(this.m_priceText, FloatToStringPrec(this.m_data.buyPrice, 0));
    } else {
      inkTextRef.SetText(this.m_priceText, FloatToStringPrec(this.m_data.price, 0));
    };
    inkWidgetRef.SetVisible(this.m_priceContainer, true);
  }
}

public class ProgramTooltipEffectController extends ItemTooltipModController {

  private func EntryWidgetToSpawn() -> CName {
    return n"programTooltipEffectEntry";
  }
}

public class ProgramTooltipStatController extends inkLogicController {

  private edit let m_arrow: inkImageRef;

  private edit let m_value: inkTextRef;

  private edit let m_diffValue: inkTextRef;

  public final func SetData(localizedKey: String, value: Float, diff: Float) -> Void {
    if AbsF(value) > 0.01 {
      this.GetRootWidget().SetState(n"Default");
      if value > 0.01 {
        inkTextRef.SetText(this.m_value, localizedKey + " " + FloatToStringPrec(value, 2) + " " + GetLocalizedText("UI-Quickhacks-Seconds"));
      } else {
        inkTextRef.SetText(this.m_value, localizedKey + " " + GetLocalizedText("UI-Quickhacks-Infinite"));
      };
    } else {
      this.GetRootWidget().SetState(n"Empty");
      inkTextRef.SetText(this.m_value, localizedKey + " " + GetLocalizedText("UI-Quickhacks-NotApplicable"));
    };
    this.UpdateComparedValue(diff);
  }

  private final func UpdateComparedValue(diffValue: Float) -> Void {
    let comaredStatText: String;
    let isVisible: Bool = diffValue != 0.00;
    let statToSet: CName = diffValue > 0.00 ? n"Better" : n"Worse";
    comaredStatText += diffValue > 0.00 ? "+" : "-";
    comaredStatText += FloatToStringPrec(AbsF(diffValue), 2);
    inkTextRef.SetText(this.m_diffValue, comaredStatText);
    inkWidgetRef.SetVisible(this.m_arrow, isVisible);
    inkWidgetRef.SetVisible(this.m_diffValue, isVisible);
    inkWidgetRef.SetState(this.m_arrow, statToSet);
    inkWidgetRef.SetState(this.m_diffValue, statToSet);
    inkImageRef.SetBrushMirrorType(this.m_arrow, diffValue > 0.00 ? inkBrushMirrorType.NoMirror : inkBrushMirrorType.Vertical);
  }
}
