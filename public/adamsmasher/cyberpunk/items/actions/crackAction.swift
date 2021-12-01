
public class CrackAction extends BaseItemAction {

  public func CompleteAction(gameInstance: GameInstance) -> Void {
    let crackActionRecord: wref<CrackAction_Record> = TweakDBInterface.GetCrackActionRecord(this.GetObjectActionID());
    let effector: TweakDBID = crackActionRecord.Effector().GetID();
    GameInstance.GetEffectorSystem(gameInstance).ApplyEffector(this.GetExecutor().GetEntityID(), this.GetExecutor(), effector, ItemID.GetTDBID(this.GetItemData().GetID()));
  }
}
