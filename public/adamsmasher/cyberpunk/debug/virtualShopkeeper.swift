
public class DEBUG_VirtualShopkeeper extends GameObject {

  @default(DEBUG_VirtualShopkeeper, Vendors.CCLVendor)
  protected let m_vendorID: String;

  protected cb func OnInteractionChoice(choiceEvent: ref<InteractionChoiceEvent>) -> Bool {
    let data: VendorData;
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_Vendor);
    data.vendorId = this.m_vendorID;
    data.entityID = this.GetEntityID();
    data.isActive = true;
    blackboard.SetVariant(GetAllBlackboardDefs().UI_Vendor.VendorData, ToVariant(data));
    blackboard.SignalVariant(GetAllBlackboardDefs().UI_Vendor.VendorData);
  }
}
