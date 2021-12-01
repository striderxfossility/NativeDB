
public native class gameprojectileScriptCollisionEvaluator extends gameprojectileCollisionEvaluator {

  protected func EvaluateCollision(defaultOnCollisionAction: gameprojectileOnCollisionAction, params: ref<CollisionEvaluatorParams>) -> gameprojectileOnCollisionAction {
    return defaultOnCollisionAction;
  }
}
