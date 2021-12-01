
public class CyberwareUtility extends IScriptable {

  public final static func GetMaxActiveTimeFromTweak(item: TweakDBID) -> Float {
    return TweakDBInterface.GetFloat(item + t".maxActiveTime", 6.00);
  }

  public final static func GetActiveCyberwareItem(player: ref<PlayerPuppet>) -> TweakDBID {
    let cs: ref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(player.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    let item: ItemID = cs.GetPlayerData(player).GetActiveItem(gamedataEquipmentArea.QuickSlot);
    return ItemID.GetTDBID(item);
  }

  public final static func StartGenericCwCooldown(player: ref<PlayerPuppet>) -> Void;

  public final static func IsCurrentCyberwareOnCooldown(player: ref<PlayerPuppet>) -> Bool {
    return false;
  }
}
