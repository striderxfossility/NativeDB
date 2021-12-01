
public static exec func TeleportPlayerToPosition(gi: GameInstance, xStr: String, yStr: String, zStr: String) -> Void {
  let position: Vector4;
  let rotation: EulerAngles;
  let playerPuppet: ref<GameObject> = GameInstance.GetPlayerSystem(gi).GetLocalPlayerMainGameObject();
  position.X = StringToFloat(xStr);
  position.Y = StringToFloat(yStr);
  position.Z = StringToFloat(zStr);
  GameInstance.GetTeleportationFacility(gi).Teleport(playerPuppet, position, rotation);
}
