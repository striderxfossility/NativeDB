
public static exec func SpawnLoot(gameInstance: GameInstance, loot: String) -> Void {
  let player: ref<GameObject> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject();
  GameInstance.GetLootManager(gameInstance).SpawnItemDrop(player, ItemID.FromTDBID(TDBID.Create(loot)), player.GetWorldPosition() + new Vector4(1.00, 1.00, 1.00, 0.00));
}
