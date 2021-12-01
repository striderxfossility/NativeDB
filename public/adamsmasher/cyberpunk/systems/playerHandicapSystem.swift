
public class PlayerHandicapSystem extends ScriptableSystem {

  @default(PlayerHandicapSystem, true)
  private let m_canDropHealingConsumable: Bool;

  @default(PlayerHandicapSystem, true)
  private let m_canDropAmmo: Bool;

  public final static func GetInstance(owner: wref<GameObject>) -> ref<PlayerHandicapSystem> {
    let PHS: ref<PlayerHandicapSystem> = GameInstance.GetScriptableSystemsContainer(owner.GetGame()).Get(n"PlayerHandicapSystem") as PlayerHandicapSystem;
    return PHS;
  }

  public final const func CanDropHealingConsumable() -> Bool {
    return this.m_canDropHealingConsumable;
  }

  private final func OnBlockHealingConsumableDrop(request: ref<BlockHealingConsumableDrop>) -> Void {
    let delay: Float;
    let newRequest: ref<UnblockHealingConsumableDrop>;
    if this.m_canDropHealingConsumable {
      newRequest = new UnblockHealingConsumableDrop();
      delay = TweakDBInterface.GetFloat(t"GlobalStats.DelayOnDroppingSupportiveConsumable.value", 30.00);
      GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"PlayerHandicapSystem", newRequest, delay, true);
    };
    this.m_canDropHealingConsumable = false;
  }

  private final func OnUnblockHealingConsumableDrop(request: ref<UnblockHealingConsumableDrop>) -> Void {
    this.m_canDropHealingConsumable = true;
  }

  public final const func CanDropAmmo() -> Bool {
    return this.m_canDropAmmo;
  }

  private final func OnBlockAmmoDrop(request: ref<BlockAmmoDrop>) -> Void {
    let delay: Float;
    let unblockRequest: ref<UnblockAmmoDrop>;
    if this.m_canDropAmmo {
      delay = TweakDBInterface.GetFloat(t"GlobalStats.DelayOnDroppingHandicapAmmo.value", 30.00);
      unblockRequest = new UnblockAmmoDrop();
      GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"PlayerHandicapSystem", unblockRequest, delay, true);
    };
    this.m_canDropAmmo = false;
  }

  private final func OnUnblockAmmoDrop(request: ref<UnblockAmmoDrop>) -> Void {
    this.m_canDropAmmo = true;
  }

  public final const func GetHandicapAmmo() -> array<TweakDBID> {
    let awardedAmmo: array<TweakDBID>;
    let i: Int32;
    let itemData: wref<gameItemData>;
    let statsSystem: ref<StatsSystem>;
    let transactionSystem: ref<TransactionSystem>;
    let player: wref<GameObject> = GetPlayer(this.GetGameInstance());
    let equippedWeapons: array<ItemID> = EquipmentSystem.GetItemsInArea(player, gamedataEquipmentArea.Weapon);
    if this.CanDropAmmo() {
      statsSystem = GameInstance.GetStatsSystem(this.GetGameInstance());
      transactionSystem = GameInstance.GetTransactionSystem(this.GetGameInstance());
      i = 0;
      while i < ArraySize(equippedWeapons) {
        if ItemID.IsValid(equippedWeapons[i]) {
          itemData = transactionSystem.GetItemData(player, equippedWeapons[i]);
          if RPGManager.GetAmmoCountValue(player, equippedWeapons[i]) <= Cast(statsSystem.GetStatValue(itemData.GetStatsObjectID(), gamedataStatType.MagazineCapacity)) && WeaponObject.IsRanged(equippedWeapons[i]) {
            ArrayPush(awardedAmmo, RPGManager.GetWeaponAmmoTDBID(equippedWeapons[i]));
          };
        };
        i += 1;
      };
    };
    return awardedAmmo;
  }
}
