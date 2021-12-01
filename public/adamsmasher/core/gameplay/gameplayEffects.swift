
public static exec func SpawnTestEffect(gameInstance: GameInstance) -> Void {
  let pos: Vector4;
  pos.X = 0.00;
  pos.Y = 0.00;
  pos.Z = 0.00;
  let effect: ref<EffectInstance> = GameInstance.GetGameEffectSystem(gameInstance).CreateEffectStatic(n"test_effect", n"explosion", GetPlayer(gameInstance));
  EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, pos);
  effect.Run();
}

public abstract class EffectDataHelper extends IScriptable {

  public final static func FillMeleeEffectData(effectData: EffectData, colliderBoxSize: Vector4, duration: Float, position: Vector4, rotation: Quaternion, direction: Vector4, range: Float) -> Void {
    EffectData.SetVector(effectData, GetAllBlackboardDefs().EffectSharedData.box, colliderBoxSize);
    EffectData.SetFloat(effectData, GetAllBlackboardDefs().EffectSharedData.duration, duration);
    EffectData.SetVector(effectData, GetAllBlackboardDefs().EffectSharedData.position, position);
    EffectData.SetQuat(effectData, GetAllBlackboardDefs().EffectSharedData.rotation, rotation);
    EffectData.SetVector(effectData, GetAllBlackboardDefs().EffectSharedData.forward, direction);
    EffectData.SetFloat(effectData, GetAllBlackboardDefs().EffectSharedData.range, range);
    EffectData.SetFloat(effectData, GetAllBlackboardDefs().EffectSharedData.radius, range);
  }
}
