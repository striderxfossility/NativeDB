
public static func PlayFinisher(gameInstance: GameInstance) -> Void;

public static func PlayFinisherSingle(gameInstance: GameInstance) -> Void {
  let player: ref<PlayerPuppet> = GetPlayer(gameInstance);
  let gameEffectInstance: ref<EffectInstance> = GameInstance.GetGameEffectSystem(gameInstance).CreateEffectStatic(n"playFinisher", n"playFinisherSingle", player);
  EffectData.SetVector(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, player.GetWorldPosition() + new Vector4(0.00, 0.00, 1.00, 1.00));
  EffectData.SetVector(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, player.GetWorldForward());
  EffectData.SetFloat(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, 20.00);
  EffectData.SetFloat(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, 20.00);
  gameEffectInstance.Run();
}
