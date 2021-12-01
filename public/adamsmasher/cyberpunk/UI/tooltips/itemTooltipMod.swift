
public class ItemTooltipModController extends inkLogicController {

  protected edit let m_dotIndicator: inkWidgetRef;

  protected edit let m_modAbilitiesContainer: inkCompoundRef;

  protected let m_partIndicatorController: wref<InventoryItemPartDisplay>;

  protected func EntryWidgetToSpawn() -> CName {
    return n"itemTooltipModEntry";
  }

  public final func SetData(record: wref<GameplayLogicPackageUIData_Record>) -> Void {
    inkCompoundRef.RemoveAllChildren(this.m_modAbilitiesContainer);
    this.SpawnController().Setup(record);
  }

  public final func SetData(record: wref<GameplayLogicPackageUIData_Record>, itemData: wref<gameItemData>) -> Void {
    inkCompoundRef.RemoveAllChildren(this.m_modAbilitiesContainer);
    this.SpawnController().Setup(record, itemData);
  }

  public final func SetData(record: wref<GameplayLogicPackageUIData_Record>, innerItemData: InnerItemData) -> Void {
    inkCompoundRef.RemoveAllChildren(this.m_modAbilitiesContainer);
    this.SpawnController().Setup(record, innerItemData);
  }

  public final func SetData(ability: InventoryItemAbility) -> Void {
    inkCompoundRef.RemoveAllChildren(this.m_modAbilitiesContainer);
    this.SpawnController().Setup(ability);
  }

  public final func SetData(attachment: InventoryItemAttachments) -> Void {
    let abilitiesSize: Int32;
    let i: Int32;
    let quality: CName;
    let slotName: String;
    inkCompoundRef.RemoveAllChildren(this.m_modAbilitiesContainer);
    quality = InventoryItemData.GetQuality(attachment.ItemData);
    inkWidgetRef.SetVisible(this.m_dotIndicator, true);
    inkWidgetRef.SetState(this.m_dotIndicator, IsNameValid(quality) ? quality : n"Empty");
    if InventoryItemData.IsEmpty(attachment.ItemData) {
      slotName = GetLocalizedText(UIItemsHelper.GetEmptySlotName(attachment.SlotID));
      if !IsStringValid(slotName) {
        slotName = UIItemsHelper.GetEmptySlotName(attachment.SlotID);
      };
      this.SpawnController().Setup(slotName);
      return;
    };
    abilitiesSize = InventoryItemData.GetAbilitiesSize(attachment.ItemData);
    if abilitiesSize == 0 {
      this.SpawnController().Setup(InventoryItemData.GetName(attachment.ItemData));
      return;
    };
    i = 0;
    while i < abilitiesSize {
      this.SpawnController().Setup(InventoryItemData.GetAbility(attachment.ItemData, i));
      i += 1;
    };
  }

  public final func SetData(data: ref<MinimalItemTooltipModData>) -> Void {
    if IsDefined(data as MinimalItemTooltipModRecordData) {
      this.SetData(data as MinimalItemTooltipModRecordData);
    } else {
      this.SetData(data as MinimalItemTooltipModAttachmentData);
    };
  }

  public final func SetData(data: ref<MinimalItemTooltipModRecordData>) -> Void {
    inkCompoundRef.RemoveAllChildren(this.m_modAbilitiesContainer);
    this.SpawnController().Setup(data);
    this.HideDotIndicator();
  }

  public final func SetData(data: ref<MinimalItemTooltipModAttachmentData>) -> Void {
    let i: Int32;
    inkCompoundRef.RemoveAllChildren(this.m_modAbilitiesContainer);
    inkWidgetRef.SetVisible(this.m_dotIndicator, true);
    inkWidgetRef.SetState(this.m_dotIndicator, data.qualityName);
    if data.isEmpty || data.abilitiesSize == 0 {
      this.SpawnController().Setup(data.slotName);
    } else {
      i = 0;
      while i < data.abilitiesSize {
        this.SpawnController().Setup(data.abilities[i]);
        i += 1;
      };
    };
  }

  private final func SpawnController() -> wref<ItemTooltipModEntryController> {
    let widget: wref<inkWidget> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_modAbilitiesContainer), this.EntryWidgetToSpawn());
    widget.SetVAlign(inkEVerticalAlign.Top);
    widget.SetHAlign(inkEHorizontalAlign.Left);
    return widget.GetController() as ItemTooltipModEntryController;
  }

  public final func HideDotIndicator() -> Void {
    inkWidgetRef.SetVisible(this.m_dotIndicator, false);
  }
}

public class ItemTooltipModEntryController extends inkLogicController {

  protected edit let m_modName: inkTextRef;

  public final func Setup(text: String) -> Void {
    inkTextRef.SetText(this.m_modName, text);
  }

  public final func Setup(data: ref<MinimalItemTooltipModRecordData>) -> Void {
    inkTextRef.SetText(this.m_modName, data.description);
    inkWidgetRef.SetTintColor(this.m_modName, new Color(127u, 226u, 215u, 255u));
    if Cast(data.dataPackage.GetParamsCount()) {
      inkTextRef.SetTextParameters(this.m_modName, data.dataPackage.GetTextParams());
    };
  }

  public final func Setup(record: wref<GameplayLogicPackageUIData_Record>) -> Void {
    let dataPackage: ref<UILocalizationDataPackage>;
    inkTextRef.SetText(this.m_modName, record.LocalizedDescription());
    dataPackage = UILocalizationDataPackage.FromLogicUIDataPackage(record);
    if Cast(dataPackage.GetParamsCount()) {
      inkTextRef.SetTextParameters(this.m_modName, dataPackage.GetTextParams());
    };
  }

  public final func Setup(record: wref<GameplayLogicPackageUIData_Record>, itemData: wref<gameItemData>) -> Void {
    let dataPackage: ref<UILocalizationDataPackage>;
    inkTextRef.SetText(this.m_modName, record.LocalizedDescription());
    inkWidgetRef.SetTintColor(this.m_modName, new Color(127u, 226u, 215u, 255u));
    dataPackage = UILocalizationDataPackage.FromLogicUIDataPackage(record, itemData);
    if Cast(dataPackage.GetParamsCount()) {
      inkTextRef.SetTextParameters(this.m_modName, dataPackage.GetTextParams());
    };
  }

  public final func Setup(record: wref<GameplayLogicPackageUIData_Record>, partItemData: InnerItemData) -> Void {
    let dataPackage: ref<UILocalizationDataPackage>;
    inkTextRef.SetText(this.m_modName, record.LocalizedDescription());
    dataPackage = UILocalizationDataPackage.FromLogicUIDataPackage(record, partItemData);
    if Cast(dataPackage.GetParamsCount()) {
      inkTextRef.SetTextParameters(this.m_modName, dataPackage.GetTextParams());
    };
  }

  public final func Setup(ability: InventoryItemAbility) -> Void {
    if NotEquals(ability.Description, "") {
      inkTextRef.SetText(this.m_modName, ability.Description);
      if ability.LocalizationDataPackage.GetParamsCount() > 0 {
        inkTextRef.SetTextParameters(this.m_modName, ability.LocalizationDataPackage.GetTextParams());
      };
    } else {
      inkTextRef.SetText(this.m_modName, GetLocalizedText("UI-Labels-EmptySlot"));
    };
  }
}
