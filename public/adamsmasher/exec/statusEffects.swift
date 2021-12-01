
public static exec func ApplyEffectOnPlayer(gi: GameInstance, effect: String) -> Void {
  let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(gi).GetLocalPlayerControlledGameObject() as PlayerPuppet;
  let seID: TweakDBID = TDBID.Create(effect);
  GameInstance.GetStatusEffectSystem(gi).ApplyStatusEffect(player.GetEntityID(), seID, player.GetRecordID(), player.GetEntityID());
}

public static exec func RemoveEffectPlayer(gi: GameInstance, effect: String) -> Void {
  let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(gi).GetLocalPlayerControlledGameObject() as PlayerPuppet;
  let seID: TweakDBID = TDBID.Create(effect);
  GameInstance.GetStatusEffectSystem(gi).RemoveStatusEffect(player.GetEntityID(), seID);
}

public static exec func PrintEffectsOnPlayer(gi: GameInstance) -> Void {
  let effectString: String;
  let effects: array<ref<StatusEffect>>;
  let i: Int32;
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  GameInstance.GetStatusEffectSystem(gi).GetAppliedEffects(player.GetEntityID(), effects);
  Log("Status effects currently on Player:");
  i = 0;
  while i < ArraySize(effects) {
    effectString = TDBID.ToStringDEBUG(effects[i].GetRecord().GetID());
    Log(effectString);
    i += 1;
  };
}

public static exec func PrintEffectsOnNPC(gi: GameInstance) -> Void {
  let effectString: String;
  let effects: array<ref<StatusEffect>>;
  let i: Int32;
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  GameInstance.GetStatusEffectSystem(gi).GetAppliedEffects(GameInstance.GetTargetingSystem(gi).GetLookAtObject(player).GetEntityID(), effects);
  Log("Status effects currently on an NPC:");
  i = 0;
  while i < ArraySize(effects) {
    effectString = TDBID.ToStringDEBUG(effects[i].GetRecord().GetID());
    Log(effectString);
    i += 1;
  };
}

public static exec func ApplyEffectOnNPC(gi: GameInstance, effect: String) -> Void {
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  let seID: TweakDBID = TDBID.Create(effect);
  GameInstance.GetStatusEffectSystem(gi).ApplyStatusEffect(GameInstance.GetTargetingSystem(gi).GetLookAtObject(player).GetEntityID(), seID, player.GetRecordID(), player.GetEntityID());
}

public static exec func RagdollNPC(gi: GameInstance, pushForce: String) -> Void {
  let distance: Float;
  let playerCamFwd: Vector4;
  let playerCamPos: Vector4;
  let pulseOrigin: Vector4;
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  let target: ref<NPCPuppet> = GameInstance.GetTargetingSystem(gi).GetLookAtObject(player) as NPCPuppet;
  if IsDefined(target) {
    target.QueueEvent(CreateForceRagdollEvent(n"Debug Command"));
    if NotEquals(pushForce, "") {
      distance = Vector4.Distance(target.GetWorldPosition(), player.GetWorldPosition());
      playerCamPos = Matrix.GetTranslation(player.GetFPPCameraComponent().GetLocalToWorld());
      playerCamFwd = Matrix.GetDirectionVector(player.GetFPPCameraComponent().GetLocalToWorld());
      pulseOrigin = playerCamPos + Vector4.Normalize(playerCamFwd) * distance * 0.85;
      GameInstance.GetDelaySystem(player.GetGame()).DelayEvent(target, CreateRagdollApplyImpulseEvent(pulseOrigin, Vector4.Normalize(playerCamFwd) * StringToFloat(pushForce), 5.00), 0.10, false);
      GameInstance.GetDebugVisualizerSystem(player.GetGame()).DrawWireSphere(pulseOrigin, 0.30, new Color(255u, 0u, 0u, 255u), 3.00);
      GameInstance.GetDebugVisualizerSystem(player.GetGame()).DrawLine3D(pulseOrigin, pulseOrigin + Vector4.Normalize(playerCamFwd) * StringToFloat(pushForce), new Color(0u, 0u, 255u, 255u), 3.00);
    };
  };
}
