
public class EncumbranceEvaluationEffector extends Effector {

  protected func RepeatedAction(owner: ref<GameObject>) -> Void {
    let evt: ref<EvaluateEncumbranceEvent> = new EvaluateEncumbranceEvent();
    owner.QueueEvent(evt);
  }
}
