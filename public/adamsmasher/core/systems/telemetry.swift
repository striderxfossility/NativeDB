
public static func ToInventoryItemData(owner: wref<GameObject>, itemID: ItemID) -> InventoryItemData {
  let equipmentSystem: ref<EquipmentSystem>;
  let inventoryManager: wref<InventoryDataManagerV2>;
  let itemData: wref<gameItemData>;
  let playerPuppet: wref<GameObject>;
  let transactionSystem: wref<TransactionSystem>;
  if IsDefined(owner) {
    equipmentSystem = GameInstance.GetScriptableSystemsContainer(owner.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    transactionSystem = GameInstance.GetTransactionSystem(owner.GetGame());
    playerPuppet = GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject();
    if IsDefined(equipmentSystem) && IsDefined(transactionSystem) && IsDefined(playerPuppet) {
      inventoryManager = equipmentSystem.GetInventoryManager(playerPuppet);
      if IsDefined(inventoryManager) {
        itemData = transactionSystem.GetItemData(owner, itemID);
        if IsDefined(itemData) {
          return inventoryManager.GetInventoryItemData(itemData);
        };
      };
    };
  };
  return EmptyInventoryItemData();
}

public static func ToTelemetryInventoryItem(owner: wref<GameObject>, itemID: ItemID) -> TelemetryInventoryItem {
  return ToTelemetryInventoryItem(ToInventoryItemData(owner, itemID));
}

public static func EmptyInventoryItemData() -> InventoryItemData {
  let inventoryItemData: InventoryItemData;
  return inventoryItemData;
}

public static func ToTelemetryInventoryItem(inventoryItemData: InventoryItemData) -> TelemetryInventoryItem {
  let telemetryItem: TelemetryInventoryItem;
  telemetryItem.friendlyName = InventoryItemData.GetGameItemData(inventoryItemData).GetNameAsString();
  telemetryItem.localizedName = InventoryItemData.GetName(inventoryItemData);
  telemetryItem.itemID = InventoryItemData.GetID(inventoryItemData);
  telemetryItem.quality = EnumInt(InventoryItemData.GetComparedQuality(inventoryItemData));
  telemetryItem.itemType = InventoryItemData.GetItemType(inventoryItemData);
  telemetryItem.itemLevel = InventoryItemData.GetItemLevel(inventoryItemData);
  telemetryItem.iconic = InventoryItemData.GetGameItemData(inventoryItemData).GetStatValueByType(gamedataStatType.IsItemIconic) > 0.00;
  return telemetryItem;
}

public static func ToTelemetryEnemy(target: wref<GameObject>) -> TelemetryEnemy {
  let puppet: ref<NPCPuppet>;
  let telemtryNME: TelemetryEnemy;
  telemtryNME.enemy = target;
  if IsDefined(target) {
    telemtryNME.enemyEntityID = target.GetEntityID();
    telemtryNME.level = Cast(GameInstance.GetStatsSystem(target.GetGame()).GetStatValue(Cast(telemtryNME.enemyEntityID), gamedataStatType.PowerLevel));
  };
  telemtryNME.characterRecord = GameObject.GetTDBID(target);
  if target.IsPuppet() {
    puppet = target as NPCPuppet;
    telemtryNME.enemyAffiliation = puppet.IsCharacterCivilian() ? "civilian" : puppet.GetAffiliation();
    telemtryNME.archetype = TweakDBInterface.GetCharacterRecord(GameObject.GetTDBID(puppet)).ArchetypeData().Type().Type();
  } else {
    if target.IsTurret() {
      telemtryNME.enemyAffiliation = "Turret";
    } else {
      if target.IsSensor() {
        telemtryNME.enemyAffiliation = "Sensor";
      } else {
        if target.IsDevice() {
          telemtryNME.enemyAffiliation = "Device";
        } else {
          telemtryNME.enemyAffiliation = "Other";
        };
      };
    };
  };
  return telemtryNME;
}

public static func ToTelemetryDamage(evt: ref<gameTargetDamageEvent>) -> TelemetryDamage {
  let telemetryDamage: TelemetryDamage = ToTelemetryDamage(evt.attackData);
  telemetryDamage.damageAmount = evt.damage;
  return telemetryDamage;
}

public static func ToTelemetryDamage(evt: ref<gameDamageReceivedEvent>) -> TelemetryDamage {
  let telemetryDamage: TelemetryDamage = ToTelemetryDamage(evt.hitEvent.attackData);
  telemetryDamage.damageAmount = evt.totalDamageReceived;
  return telemetryDamage;
}

public static func ToTelemetryDamage(attackData: ref<AttackData>) -> TelemetryDamage {
  let statSystem: ref<StatsSystem>;
  let telemetryDamage: TelemetryDamage;
  let weaponEntityID: EntityID;
  let weaponRecord: wref<WeaponItem_Record>;
  telemetryDamage.attackType = attackData.GetAttackType();
  let weapon: wref<WeaponObject> = attackData.GetWeapon();
  let instigator: wref<GameObject> = attackData.GetInstigator();
  if IsDefined(weapon) && IsDefined(instigator) {
    telemetryDamage.weapon.friendlyName = weapon.GetItemData().GetNameAsString();
    telemetryDamage.weapon.itemID = weapon.GetItemID();
    statSystem = GameInstance.GetStatsSystem(weapon.GetGame());
    weaponEntityID = weapon.GetEntityID();
    telemetryDamage.weapon.quality = Cast(statSystem.GetStatValue(Cast(weaponEntityID), gamedataStatType.Quality));
    telemetryDamage.weapon.itemLevel = Cast(statSystem.GetStatValue(Cast(weaponEntityID), gamedataStatType.ItemLevel));
    telemetryDamage.weapon.iconic = statSystem.GetStatValue(Cast(weaponEntityID), gamedataStatType.IsItemIconic) > 0.00;
    weaponRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(telemetryDamage.weapon.itemID)) as WeaponItem_Record;
    if IsDefined(weaponRecord) {
      telemetryDamage.weapon.itemType = weaponRecord.ItemType().Type();
      telemetryDamage.weapon.localizedName = LocKeyToString(weaponRecord.DisplayName());
    };
    telemetryDamage.weapon.isSilenced = weapon.IsSilenced();
  };
  return telemetryDamage;
}

public static func ToTelemetryDamageDealt(evt: ref<gameTargetDamageEvent>, situation: gameTelemetryDamageSituation, distance: Float, time: Float) -> TelemetryDamageDealt {
  let telemetryDamageDealt: TelemetryDamageDealt;
  telemetryDamageDealt.situation = situation;
  telemetryDamageDealt.damage = ToTelemetryDamage(evt);
  telemetryDamageDealt.enemy = ToTelemetryEnemy(evt.target);
  telemetryDamageDealt.damage.distance = distance;
  telemetryDamageDealt.damage.time = time;
  return telemetryDamageDealt;
}

public static func ToTelemetryDamageDealt(evt: ref<gameDamageReceivedEvent>, situation: gameTelemetryDamageSituation, distance: Float, time: Float) -> TelemetryDamageDealt {
  let telemetryDamageDealt: TelemetryDamageDealt;
  telemetryDamageDealt.situation = situation;
  telemetryDamageDealt.damage = ToTelemetryDamage(evt);
  telemetryDamageDealt.enemy = ToTelemetryEnemy(evt.hitEvent.attackData.GetInstigator());
  telemetryDamageDealt.damage.distance = distance;
  telemetryDamageDealt.damage.time = time;
  return telemetryDamageDealt;
}
