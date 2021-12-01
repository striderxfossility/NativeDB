
public static exec func SetZoneType(gameInstance: GameInstance, zoneType: String) -> Void {
  let intValue: Int32 = StringToInt(zoneType);
  SetFactValue(gameInstance, n"CityAreaType", intValue);
}

public static exec func SetQuestWeaponState(gameInstance: GameInstance, weaponState: String) -> Void {
  SetFactValue(gameInstance, n"ForceSafeState", 0);
  SetFactValue(gameInstance, n"ForceEmptyHands", 0);
  switch StringToInt(weaponState) {
    case 1:
      SetFactValue(gameInstance, n"ForceSafeState", 1);
      break;
    case 2:
      SetFactValue(gameInstance, n"ForceEmptyHands", 1);
      break;
    default:
  };
}

public static exec func RequestItem(gameInstance: GameInstance, itemTDBID: TweakDBID, slotID: TweakDBID) -> Void {
  let param: ref<parameterRequestItem>;
  let psmEvent: ref<PSMPostponedParameterScriptable>;
  let request: RequestItemParam;
  let playerObject: ref<GameObject> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject();
  if IsDefined(playerObject) {
    request.itemIDToEquip = ItemID.CreateQuery(itemTDBID);
    request.slotID = slotID;
    request.forceFirstEquip = true;
    param = new parameterRequestItem();
    ArrayPush(param.requests, request);
    psmEvent = new PSMPostponedParameterScriptable();
    psmEvent.value = param;
    psmEvent.id = n"requestItem";
    playerObject.QueueEvent(psmEvent);
  };
}
