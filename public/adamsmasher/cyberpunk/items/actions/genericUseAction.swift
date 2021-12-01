
public class UseAction extends BaseItemAction {

  public func IsPossible(target: wref<GameObject>, opt actionRecord: wref<ObjectAction_Record>, opt objectActionsCallbackController: wref<gameObjectActionsCallbackController>) -> Bool {
    let targetPrereqs: array<wref<IPrereq_Record>>;
    if !IsDefined(actionRecord) {
      actionRecord = this.GetObjectActionRecord();
    };
    if IsDefined(objectActionsCallbackController) && objectActionsCallbackController.HasObjectAction(actionRecord) {
      return objectActionsCallbackController.IsObjectActionInstigatorPrereqFulfilled(actionRecord);
    };
    actionRecord.InstigatorPrereqs(targetPrereqs);
    return RPGManager.CheckPrereqs(targetPrereqs, target);
  }
}
