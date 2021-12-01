
public class ModifyAttackEffector extends Effector {

  protected final func GetHitEvent() -> ref<gameHitEvent> {
    let i: Int32;
    let multiPrereqState: ref<MultiPrereqState>;
    let hitPrereqState: ref<GenericHitPrereqState> = this.GetPrereqState() as GenericHitPrereqState;
    if IsDefined(hitPrereqState) {
      return hitPrereqState.GetHitEvent();
    };
    multiPrereqState = this.GetPrereqState() as MultiPrereqState;
    if IsDefined(multiPrereqState) {
      i = 0;
      while i < ArraySize(multiPrereqState.nestedStates) {
        hitPrereqState = multiPrereqState.nestedStates[i] as GenericHitPrereqState;
        if IsDefined(hitPrereqState) {
          return hitPrereqState.GetHitEvent();
        };
        i += 1;
      };
    };
    return null;
  }
}
