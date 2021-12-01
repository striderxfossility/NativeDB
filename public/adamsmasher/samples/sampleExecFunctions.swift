
public static exec func LogPlayerPositionAndName(gameInstance: GameInstance) -> Void {
  let worldPosition: Vector4;
  let playerObject: ref<GameObject> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject();
  if IsDefined(playerObject) {
    worldPosition = playerObject.GetWorldPosition();
    Log("Player Position:: " + Vector4.ToString(worldPosition));
    Log("Player Name:: " + NameToString(playerObject.GetName()));
  };
}

public static exec func ParameterTest1(gameInstance: GameInstance, param1: String) -> Void {
  Log("param1:: " + param1);
}

public static exec func ParameterTest5(gameInstance: GameInstance, param1: String, param2: String, param3: String, param4: String, param5: String) -> Void {
  Log("param1:: " + param1);
  Log("param2:: " + param2);
  Log("param3:: " + param3);
  Log("param4:: " + param4);
  Log("param5:: " + param5);
}

public static exec func ToIntTest(gameInstance: GameInstance, toInt: String) -> Void {
  let fromString: Int32 = StringToInt(toInt);
  fromString += 100;
  Log(IntToString(fromString));
}
