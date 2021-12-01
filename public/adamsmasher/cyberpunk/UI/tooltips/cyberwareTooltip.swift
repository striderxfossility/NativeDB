
public class CyberwareTooltip extends AGenericTooltipController {

  private edit let m_slotList: inkCompoundRef;

  private edit let m_label: inkTextRef;

  private let m_data: ref<CyberwareTooltipData>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    inkCompoundRef.RemoveAllChildren(this.m_slotList);
  }

  public func SetData(tooltipData: ref<ATooltipData>) -> Void {
    this.SetData(tooltipData as CyberwareTooltipData);
  }

  public final func SetData(data: ref<CyberwareTooltipData>) -> Void {
    if IsDefined(data) {
      this.m_data = data;
      this.UpdateLayout();
    };
  }

  private final func UpdateLayout() -> Void {
    let i: Int32;
    let slot: wref<CyberwareTooltipSlotListItem>;
    inkTextRef.SetText(this.m_label, this.m_data.label);
    inkCompoundRef.RemoveAllChildren(this.m_slotList);
    i = 0;
    while i < ArraySize(this.m_data.slotData) {
      slot = this.SpawnFromLocal(inkWidgetRef.Get(this.m_slotList), n"cyberware_slot_list_item").GetController() as CyberwareTooltipSlotListItem;
      slot.SetupData(this.m_data.slotData[i]);
      i += 1;
    };
  }

  public final func OnOutro() -> Void {
    this.m_Root.SetVisible(false);
  }
}

public class CyberwareTooltipSlotListItem extends AGenericTooltipController {

  private edit let m_icon: inkImageRef;

  private edit let m_label: inkTextRef;

  private edit let m_desc: inkTextRef;

  private let m_data: ref<CyberwareSlotTooltipData>;

  protected cb func OnInitialize() -> Bool;

  public final func SetupData(data: ref<CyberwareSlotTooltipData>) -> Void {
    this.m_data = data;
    if this.m_data.Empty {
      inkWidgetRef.SetVisible(this.m_desc, false);
      inkImageRef.SetTexturePart(this.m_icon, StringToName(this.m_data.IconPath));
      inkTextRef.SetText(this.m_label, GetLocalizedText("UI-ScriptExports-EmptySlot0"));
    } else {
      inkWidgetRef.SetVisible(this.m_desc, true);
      inkImageRef.SetTexturePart(this.m_icon, StringToName(this.m_data.IconPath));
      inkTextRef.SetLetterCase(this.m_label, textLetterCase.UpperCase);
      inkTextRef.SetText(this.m_label, this.m_data.Name);
      inkTextRef.SetText(this.m_desc, this.m_data.Description);
    };
  }
}
