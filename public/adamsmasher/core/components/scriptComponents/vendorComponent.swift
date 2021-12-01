
public class VendorComponent extends ScriptableComponent {

  @attrib(customEditor, "TweakDBGroupInheritance;Vendors.VendingMachine")
  private edit let m_vendorTweakID: TweakDBID;

  private edit const let m_junkItemArray: array<JunkItemRecord>;

  @attrib(customEditor, "AudioEvent")
  @default(VendorComponent, dev_vending_machine_processing)
  private edit let m_brandProcessingSFX: CName;

  @attrib(customEditor, "AudioEvent")
  @default(VendorComponent, dev_vending_machine_can_falls)
  private edit let m_itemFallSFX: CName;

  public final const func GetVendorID() -> TweakDBID {
    return this.m_vendorTweakID;
  }

  public final const func GetJunkItemIDs() -> array<JunkItemRecord> {
    return this.m_junkItemArray;
  }

  public final const func GetJunkCount() -> Int32 {
    return ArraySize(this.m_junkItemArray);
  }

  public final const func GetProcessingSFX() -> CName {
    return this.m_brandProcessingSFX;
  }

  public final const func GetItemFallSFX() -> CName {
    return this.m_itemFallSFX;
  }
}
