
public native class gamevehicleVehicleMountableComponent extends MountableComponent {

  protected cb func OnInteractionChoice(choiceEvent: ref<InteractionChoiceEvent>) -> Bool {
    let record: wref<InteractionMountBase_Record>;
    let slotName: CName;
    if MountableComponent.IsInteractionAcceptable(choiceEvent) {
      record = InteractionChoiceMetaData.GetTweakData(choiceEvent.choice.choiceMetaData) as InteractionMountBase_Record;
      slotName = record.VehicleMountSlot();
      this.MountEntityToSlot(choiceEvent.hotspot.GetEntityID(), choiceEvent.activator.GetEntityID(), slotName);
    };
  }

  protected cb func OnActionDemolition(evt: ref<ActionDemolition>) -> Bool {
    this.MountEntityToSlot(evt.GetRequesterID(), evt.GetExecutor().GetEntityID(), evt.prop.name);
  }

  protected cb func OnActionEngineering(evt: ref<ActionEngineering>) -> Bool {
    this.MountEntityToSlot(evt.GetRequesterID(), evt.GetExecutor().GetEntityID(), evt.prop.name);
  }

  protected final func MountEntityToSlot(parentID: EntityID, childId: EntityID, slot: CName) -> Void {
    let attitude: EAIAttitude;
    let i: Int32;
    let isNPCAlive: Bool;
    let isOccupiedByNeutral: Bool;
    let lowLevelMountingInfo: MountingInfo;
    let scriptedPuppet: wref<GameObject>;
    let vehObject: wref<VehicleObject>;
    let mountingRequest: ref<MountingRequest> = new MountingRequest();
    let mountData: ref<MountEventData> = new MountEventData();
    let mountOptions: ref<MountEventOptions> = new MountEventOptions();
    lowLevelMountingInfo.parentId = parentID;
    lowLevelMountingInfo.childId = childId;
    lowLevelMountingInfo.slotId.id = slot;
    let npcMountInfo: MountingInfo = GameInstance.GetMountingFacility(this.GetEntity() as GameObject.GetGame()).GetMountingInfoSingleWithIds(lowLevelMountingInfo.parentId, lowLevelMountingInfo.slotId);
    let npcMountInfos: array<MountingInfo> = GameInstance.GetMountingFacility(this.GetEntity() as GameObject.GetGame()).GetMountingInfoMultipleWithIds(lowLevelMountingInfo.parentId);
    if EntityID.IsDefined(npcMountInfo.childId) {
      scriptedPuppet = GameInstance.FindEntityByID(this.GetEntity() as GameObject.GetGame(), npcMountInfo.childId) as GameObject;
      isNPCAlive = ScriptedPuppet.IsActive(scriptedPuppet);
      vehObject = this.GetEntity() as VehicleObject;
      vehObject.PreHijackPrepareDriverSlot();
    };
    i = 0;
    while i < ArraySize(npcMountInfos) {
      if EntityID.IsDefined(npcMountInfos[i].childId) {
        VehicleComponent.GetAttitudeOfPassenger(this.GetEntity() as GameObject.GetGame(), npcMountInfos[i].parentId, npcMountInfos[i].slotId, attitude);
        if Equals(attitude, EAIAttitude.AIA_Neutral) {
          isOccupiedByNeutral = true;
        };
      };
      i += 1;
    };
    mountingRequest.lowLevelMountingInfo = lowLevelMountingInfo;
    mountingRequest.preservePositionAfterMounting = true;
    mountingRequest.mountData = mountData;
    mountOptions.entityID = npcMountInfo.childId;
    mountOptions.alive = isNPCAlive;
    mountOptions.occupiedByNeutral = isOccupiedByNeutral;
    mountingRequest.mountData.mountEventOptions = mountOptions;
    GameInstance.GetMountingFacility(this.GetEntity() as GameObject.GetGame()).Mount(mountingRequest);
  }
}
