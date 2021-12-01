
public native class PreventionSpawnSystem extends IPreventionSpawnSystem {

  public final native func RequestSpawn(recordID: TweakDBID, preventionLevel: Uint32, spawnTransform: WorldTransform) -> EntityID;

  public final native func RequestDespawn(entityID: EntityID) -> Void;

  public final native func RequestDespawnPreventionLevel(preventionLevel: Uint32) -> Void;

  public final native func GetNumberOfSpawnedPreventionUnits() -> Int32;

  protected final func SpawnCallback(spawnedObject: ref<GameObject>) -> Void {
    if spawnedObject.IsPuppet() {
      PreventionSystem.RegisterPoliceUnit(spawnedObject.GetGame(), spawnedObject as ScriptedPuppet);
    } else {
      if spawnedObject.IsVehicle() {
        PreventionSystem.RegisterPoliceVehicle(spawnedObject.GetGame(), spawnedObject as VehicleObject);
      };
    };
  }
}
