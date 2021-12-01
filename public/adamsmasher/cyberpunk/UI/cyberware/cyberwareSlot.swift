
public class CyberwareSlot extends BaseButtonView {

  private edit let m_IconImageRef: inkImageRef;

  private let m_SlotEquipArea: gamedataEquipmentArea;

  private let m_NumSlots: Int32;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
  }

  public final func Setup(equipArea: gamedataEquipmentArea, numSlots: Int32) -> Void {
    this.m_SlotEquipArea = equipArea;
    this.m_NumSlots = numSlots;
    switch equipArea {
      case gamedataEquipmentArea.SystemReplacementCW:
        inkImageRef.SetTexturePart(this.m_IconImageRef, n"slot_brain");
        break;
      case gamedataEquipmentArea.FrontalCortexCW:
        inkImageRef.SetTexturePart(this.m_IconImageRef, n"slot_brain");
        break;
      case gamedataEquipmentArea.EyesCW:
        inkImageRef.SetTexturePart(this.m_IconImageRef, n"slot_eyes");
        break;
      case gamedataEquipmentArea.HandsCW:
        inkImageRef.SetTexturePart(this.m_IconImageRef, n"slot_hands");
        break;
      case gamedataEquipmentArea.ArmsCW:
        inkImageRef.SetTexturePart(this.m_IconImageRef, n"slot_arms");
        break;
      case gamedataEquipmentArea.LegsCW:
        inkImageRef.SetTexturePart(this.m_IconImageRef, n"slot_legs");
        break;
      case gamedataEquipmentArea.MusculoskeletalSystemCW:
        inkImageRef.SetTexturePart(this.m_IconImageRef, n"slot_muscoskeletal");
        break;
      case gamedataEquipmentArea.NervousSystemCW:
        inkImageRef.SetTexturePart(this.m_IconImageRef, n"slot_nervous");
        break;
      case gamedataEquipmentArea.CardiovascularSystemCW:
        inkImageRef.SetTexturePart(this.m_IconImageRef, n"slot_cardiovascular");
        break;
      case gamedataEquipmentArea.ImmuneSystemCW:
        inkImageRef.SetTexturePart(this.m_IconImageRef, n"slot_immune");
        break;
      case gamedataEquipmentArea.IntegumentarySystemCW:
        inkImageRef.SetTexturePart(this.m_IconImageRef, n"slot_skin");
    };
  }

  public final func GetEquipmentArea() -> gamedataEquipmentArea {
    return this.m_SlotEquipArea;
  }

  public final func GetNumSlots() -> Int32 {
    return this.m_NumSlots;
  }
}
