
public native class gamePuppetMountableComponent extends MountableComponent {

  protected cb func OnInteractionChoice(choiceEvent: ref<InteractionChoiceEvent>) -> Bool {
    let lowLevelMountingInfo: MountingInfo;
    let mountData: ref<MountEventData>;
    let slotId: MountingSlotId;
    let mountingEvent: ref<MountingRequest> = new MountingRequest();
    slotId.id = n"leftShoulder";
    if MountableComponent.IsInteractionAcceptable(choiceEvent) {
      lowLevelMountingInfo.childId = choiceEvent.hotspot.GetEntityID();
      lowLevelMountingInfo.parentId = choiceEvent.activator.GetEntityID();
      lowLevelMountingInfo.slotId = slotId;
      mountingEvent.lowLevelMountingInfo = lowLevelMountingInfo;
      mountingEvent.preservePositionAfterMounting = false;
      mountingEvent.mountData = mountData;
      GameInstance.GetMountingFacility(this.GetEntity() as GameObject.GetGame()).Mount(mountingEvent);
    };
  }
}
