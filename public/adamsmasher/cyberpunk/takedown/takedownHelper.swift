
public class TakedownGameEffectHelper extends IScriptable {

  public final static func FillTakedownData(executionOwner: wref<GameObject>, activator: wref<GameObject>, target: wref<GameObject>, effectName: CName, effectTag: CName, opt statusEffect: String) -> Bool {
    let broadcaster: ref<StimBroadcasterComponent>;
    let targetPosition: Vector4;
    let gameEffect: ref<EffectInstance> = GameInstance.GetGameEffectSystem(activator.GetGame()).CreateEffectStatic(effectName, effectTag, activator);
    if !(IsDefined(gameEffect) || IsDefined(activator) || IsDefined(target)) {
      return false;
    };
    targetPosition = target.GetWorldPosition();
    EffectData.SetVector(gameEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, targetPosition);
    EffectData.SetEntity(gameEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.entity, target);
    if IsStringValid(statusEffect) {
      EffectData.SetString(gameEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.effectorRecordName, statusEffect);
    };
    gameEffect.Run();
    broadcaster = activator.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.AddActiveStimuli(executionOwner, gamedataStimType.IllegalInteraction, -1.00);
    };
    return true;
  }
}
