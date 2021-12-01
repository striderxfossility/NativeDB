
public class ActivatedDeviceNPCController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class ActivatedDeviceNPCControllerPS extends ActivatedDeviceControllerPS {

  private persistent let m_activatedDeviceNPCSetup: ActivatedDeviceNPCSetup;

  public final func GetSpawnedNPC() -> ref<NPCPuppet> {
    return this.m_activatedDeviceNPCSetup.m_npcSpawned;
  }

  protected func GameAttached() -> Void {
    let globalNodeRef: GlobalNodeRef = ResolveNodeRefWithEntityID(this.m_activatedDeviceNPCSetup.npcSpawnerNodeRef, this.GetOwnerEntityWeak().GetEntityID());
    if GlobalNodeRef.IsDefined(globalNodeRef) {
      GameInstance.GetEntitySpawnerEventsBroadcaster(this.GetGameInstance()).RegisterSpawnerEventPSListener(Cast(globalNodeRef), n"", this.GetID(), this.GetClassName());
    };
    this.GameAttached();
  }

  public final func OnGameEntitySpawnerEvent(evt: ref<gameEntitySpawnerEvent>) -> EntityNotificationType {
    if Equals(evt.eventType, gameEntitySpawnerEventType.Spawn) {
      this.m_activatedDeviceNPCSetup.m_npcSpawned = GameInstance.FindEntityByID(this.GetGameInstance(), evt.spawnedEntityId) as NPCPuppet;
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }
}
