
public static exec func SetBreathingLow(gameInstance: GameInstance) -> Void {
  let player: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
  GameInstance.GetStatusEffectSystem(gameInstance).ApplyStatusEffect(player.GetEntityID(), t"BaseStatusEffect.BreathingLow", player.GetRecordID(), player.GetEntityID());
}

public static exec func SetBreathingHeavy(gameInstance: GameInstance) -> Void {
  let player: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
  GameInstance.GetStatusEffectSystem(gameInstance).ApplyStatusEffect(player.GetEntityID(), t"BaseStatusEffect.BreathingHeavy", player.GetRecordID(), player.GetEntityID());
}

public static exec func SetBreathingSick(gameInstance: GameInstance) -> Void {
  let player: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
  GameInstance.GetStatusEffectSystem(gameInstance).ApplyStatusEffect(player.GetEntityID(), t"BaseStatusEffect.BreathingSick", player.GetRecordID(), player.GetEntityID());
}

public static exec func SetBreathingJohnny(gameInstance: GameInstance) -> Void {
  let player: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
  GameInstance.GetStatusEffectSystem(gameInstance).ApplyStatusEffect(player.GetEntityID(), t"BaseStatusEffect.BreathingJohnny", player.GetRecordID(), player.GetEntityID());
}

public static exec func SetBreathingAll(gameInstance: GameInstance) -> Void {
  let player: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
  GameInstance.GetStatusEffectSystem(gameInstance).ApplyStatusEffect(player.GetEntityID(), t"BaseStatusEffect.BreathingLow", player.GetRecordID(), player.GetEntityID());
  GameInstance.GetStatusEffectSystem(gameInstance).ApplyStatusEffect(player.GetEntityID(), t"BaseStatusEffect.BreathingHeavy", player.GetRecordID(), player.GetEntityID());
  GameInstance.GetStatusEffectSystem(gameInstance).ApplyStatusEffect(player.GetEntityID(), t"BaseStatusEffect.BreathingSick", player.GetRecordID(), player.GetEntityID());
  GameInstance.GetStatusEffectSystem(gameInstance).ApplyStatusEffect(player.GetEntityID(), t"BaseStatusEffect.BreathingJohnny", player.GetRecordID(), player.GetEntityID());
}

public static exec func SetBreathingOff(gameInstance: GameInstance) -> Void {
  let player: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
  GameInstance.GetStatusEffectSystem(gameInstance).RemoveStatusEffect(player.GetEntityID(), t"BaseStatusEffect.BreathingLow");
  GameInstance.GetStatusEffectSystem(gameInstance).RemoveStatusEffect(player.GetEntityID(), t"BaseStatusEffect.BreathingHeavy");
  GameInstance.GetStatusEffectSystem(gameInstance).RemoveStatusEffect(player.GetEntityID(), t"BaseStatusEffect.BreathingSick");
  GameInstance.GetStatusEffectSystem(gameInstance).RemoveStatusEffect(player.GetEntityID(), t"BaseStatusEffect.BreathingJohnny");
}
