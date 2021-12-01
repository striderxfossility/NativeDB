
public class DisassembleAction extends BaseItemAction {

  public func CompleteAction(gameInstance: GameInstance) -> Void {
    let actionEffects: array<wref<ObjectActionEffect_Record>>;
    let actionRecord: ref<ObjectAction_Record>;
    let disassembleRequest: ref<DisassembleItemRequest>;
    let i: Int32;
    let j: Int32;
    let rewards: array<wref<RewardBase_Record>>;
    if this.GetItemData().HasTag(n"UnequipBlocked") || this.GetItemData().HasTag(n"Quest") {
      return;
    };
    if EquipmentSystem.GetInstance(this.GetExecutor()).IsEquipped(this.GetExecutor(), this.GetItemData().GetID()) {
      return;
    };
    actionRecord = this.GetObjectActionRecord();
    if IsDefined(actionRecord) {
      actionRecord.Rewards(rewards);
    };
    i = 0;
    while i < ArraySize(rewards) {
      j = 0;
      while j < this.GetRequestQuantity() {
        RPGManager.GiveReward(gameInstance, rewards[i].GetID(), Cast(this.GetRequesterID()));
        j += 1;
      };
      i += 1;
    };
    if IsDefined(actionRecord) {
      actionRecord.CompletionEffects(actionEffects);
    };
    this.ProcessStatusEffects(actionEffects, gameInstance);
    this.ProcessEffectors(actionEffects, gameInstance);
    disassembleRequest = new DisassembleItemRequest();
    disassembleRequest.target = this.GetExecutor();
    disassembleRequest.itemID = this.GetItemData().GetID();
    disassembleRequest.amount = this.GetRequestQuantity();
    CraftingSystem.GetInstance(gameInstance).QueueRequest(disassembleRequest);
  }
}
